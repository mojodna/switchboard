require 'xmpp4r/discovery'

module Switchboard
  module Commands
    class Disco
      class Items < Switchboard::Command
        description "Item discovery"

        def self.run!
          switchboard = Switchboard::Client.new do
            helper = Jabber::Discovery::Helper.new(client)
            resp = helper.get_items_for(settings["disco.target"], settings["disco.node"])

            if resp.items.any?
              puts "Item Discovery for #{settings["disco.target"]}#{settings["disco.node"] ? " (#{settings["disco.node"]})" : ""}"
              resp.items.each do |item|
                name = "#{item.iname}#{item.node ? " (#{item.node})" : ""}"
                puts "  " + [item.jid, name].reject { |x| x == "" } * ": "
              end
            else
              puts "No items were discoverable for #{settings["disco.target"]}."
            end
          end

          switchboard.run!
        end
      end
    end
  end
end
