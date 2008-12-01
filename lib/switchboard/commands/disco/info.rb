require 'xmpp4r/discovery'

module Switchboard
  module Commands
    class Disco
      class Info < Switchboard::Command
        description "Basic service discovery"

        def self.run!
          switchboard = Switchboard::Client.new do
            helper = Jabber::Discovery::Helper.new(client)
            resp = helper.get_info_for(settings["disco.target"], settings["disco.node"])

            if resp.identities.any? || resp.features.any?
              puts "Discovery Info for #{settings["disco.target"]}#{settings["disco.node"] ? " (#{settings["disco.node"]})" : ""}"

              if resp.identities.any?
                puts "Identities:"
                resp.identities.each do |identity|
                  puts "  #{identity.category}/#{identity.type}: #{identity.iname ? identity.iname : "n/a"}"
                end
                puts
              end

              puts "Features:" if resp.features.any?
              resp.features.each do |feature|
                puts "  #{feature}"
              end
            else
              puts "No information was discoverable for #{settings["disco.target"]}"
            end
          end

          switchboard.run!
        end
      end
    end
  end
end
