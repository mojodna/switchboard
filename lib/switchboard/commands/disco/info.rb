require 'xmpp4r/discovery'

module Switchboard
  module Commands
    class Disco
      class Info < Switchboard::Command
        description "Basic service discovery"

        def self.run!
          iq_id = Jabber::IdGenerator.generate_id

          switchboard = Switchboard::Client.new

          switchboard.on_startup do
            iq = Jabber::Iq.new(:get, settings["disco.target"])
            iq.id = iq_id
            disco = Jabber::Discovery::IqQueryDiscoInfo.new
            disco.node = settings["disco.node"]
            iq.add(disco)
            client.send(iq)
          end

          switchboard.on_iq do |iq|
            # look for a response to the query we just made
            if iq.from == settings["disco.target"] && iq.id == iq_id
              if iq.query.identities.any? || iq.query.features.any?
                puts "Discovery Info for #{settings["disco.target"]}#{settings["disco.node"] ? " (#{settings["disco.node"]})" : ""}"

                if iq.query.identities.any?
                  puts "Identities:"
                  iq.query.identities.each do |identity|
                    puts "  #{identity.category}/#{identity.type}: #{identity.iname ? identity.iname : "n/a"}"
                  end
                  puts
                end

                puts "Features:" if iq.query.features.any?
                iq.query.features.each do |feature|
                  puts "  #{feature}"
                end
              else
                puts "No information was discoverable for #{settings["disco.target"]}"
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
