module Switchboard
  module Commands
    class Roster
      class Remove < Switchboard::Command
        description "Remove a JID from your roster"

        def self.run!
          switchboard = Switchboard::Client.new(Switchboard::Settings.new, false)

          switchboard.on_roster_loaded do
            ARGV.each do |jid|
              if (items = roster.find(jid)).any?
                item = items.values.first
                puts "Removing #{item.jid.to_s} from my roster..."
                item.remove
              end
            end
          end

          switchboard.run!
        end
      end
    end
  end
end