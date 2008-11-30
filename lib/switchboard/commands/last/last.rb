require 'xmpp4r/last'

module Switchboard
  module Commands
    class Last < Switchboard::Command
      description "Last Activity (XEP-0012)"

      def self.options(opts)
        super(opts)
        opts.on("--target=target", String, "Specifies the target to query.") { |v| OPTIONS["last.target"] = v }
      end

      def self.run!
        iq_id = Jabber::IdGenerator.generate_id

        switchboard = Switchboard::Client.new

        switchboard.on_startup do
          iq = Jabber::Iq.new(:get, settings["last.target"])
          iq.id = iq_id
          iq.add(Jabber::LastActivity::IqQueryLastActivity.new)
          client.send(iq)
        end

        switchboard.on_iq do |iq|
          # look for a response to the query we just made
          if iq.from == settings["last.target"] && iq.id == iq_id
            status = " (#{iq.query.status})" if iq.query.status
            status ||= ""
            if iq.from.resource
              puts "#{iq.from} idle: #{iq.query.seconds} seconds" << status
            elsif iq.from.node
              puts "#{iq.from} last disconnected: " << (Time.new - iq.query.seconds).to_s << status
            else
              puts "#{iq.from} uptime: #{iq.query.seconds} seconds" << status
            end

            shutdown!
          end
        end

        switchboard.run!
      end
    end
  end
end
