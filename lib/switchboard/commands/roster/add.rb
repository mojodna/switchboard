module Switchboard
  module Commands
    class Roster
      class Add < Switchboard::Command
        description "Add a JID to your roster"

        def self.run!
          # TODO get settings from elsewhere
          switchboard = Switchboard::Core.new(YAML.load(File.read("fire_hydrant.yml"))) do
            # add the server as a contact if it wasn't already added
            ARGV.each do |jid|
              if roster.find(jid).empty?
                puts "Adding #{jid} to my roster..."
                roster.add(jid, nil, true)
              end
            end
          end

          switchboard.plug!(AutoAcceptJack, DebugJack, RosterDebugJack)

          switchboard.run!
        end
      end
    end
  end
end