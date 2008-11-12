module Switchboard
  module Commands
    class Roster
      class List < Switchboard::Command
        description "List all roster items"

        def self.run!
          # TODO get settings from elsewhere
          switchboard = Switchboard::Core.new(YAML.load(File.read("fire_hydrant.yml"))) do
            if roster.items.any?
              puts "#{config[:jid]}'s roster:"
              puts roster.items.keys.map { |jid| jid.to_s } * "\n"
            else
              puts "#{config[:jid]}'s roster is empty."
            end
          end

          switchboard.plug!(AutoAcceptJack)
          switchboard.run!
        end
      end
    end
  end
end