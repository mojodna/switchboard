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
        switchboard = Switchboard::Client.new do
          helper = Jabber::LastActivity::Helper.new(client)
          resp = helper.get_last_activity_from(jid = Jabber::JID.new(settings["last.target"]))

          status = " (#{resp.status})" if resp.status
          status ||= ""

          if jid.resource
            puts "#{jid} idle: #{resp.seconds} seconds" << status
          elsif jid.node
            puts "#{jid} last disconnected: " << (Time.new - resp.seconds).to_s << status
          else
            puts "#{jid} uptime: #{resp.seconds} seconds" << status
          end
        end

        switchboard.run!
      end
    end
  end
end
