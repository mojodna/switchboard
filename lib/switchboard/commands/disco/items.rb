require 'xmpp4r/discovery'

module Switchboard
  module Commands
    class Disco
      class Items < Switchboard::Command
        description "Item discovery"

        def self.run!
          iq_id = Jabber::IdGenerator.generate_id

          switchboard = Switchboard::Client.new

          switchboard.on_startup do
            iq = Jabber::Iq.new(:get, settings["disco.target"])
            iq.id = iq_id
            disco = Jabber::Discovery::IqQueryDiscoItems.new
            disco.node = settings["disco.node"]
            iq.add(disco)
            client.send(iq)
          end

          switchboard.on_iq do |iq|
            # look for a response to the query we just made
            if iq.from == settings["disco.target"] && iq.id == iq_id
              items = Jabber::Discovery::IqQueryDiscoItems.import(iq.query)

              if items.items.any?
                puts "Item Discovery for #{settings["disco.target"]}#{settings["disco.node"] ? " (#{settings["disco.node"]})" : ""}"
                items.items.each do |item|
                  name = "#{item.iname}#{item.node ? " (#{item.node})" : ""}"
                  puts "  " + [item.jid, name].reject { |x| x == "" } * ": "
                end
              else
                puts "No items were discoverable for #{settings["disco.target"]}."
              end

              shutdown!
            end
          end

          switchboard.run!
        end
      end
    end
  end
end
