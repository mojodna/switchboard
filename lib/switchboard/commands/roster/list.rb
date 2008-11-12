module Switchboard
  module Commands
    class Roster
      class List < Switchboard::Command
        description "List all roster items"

        def self.run!
          # TODO override settings with values from the command line
          switchboard = Switchboard::Core.new do
            if roster.items.any?
              puts "#{settings["jid"]}'s roster:"
              puts roster.items.keys.map { |jid| jid.to_s } * "\n"
            else
              puts "#{settings["jid"]}'s roster is empty."
            end
          end

          switchboard.plug!(AutoAcceptJack)
          switchboard.run!
        end
      end
    end
  end
end