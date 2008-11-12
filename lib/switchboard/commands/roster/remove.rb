module Switchboard
  module Commands
    class Roster
      class Remove < Switchboard::Command
        description "Remove a JID from your roster"

        def self.options(opts)
          super(opts)
          opts.on("-l", "--log=path", String, "Specifies a path to log script output.") { |v| OPTIONS[:log] = v }
        end

        def self.run!
          # TODO get settings from elsewhere
          switchboard = Switchboard::Core.new(YAML.load(File.read("fire_hydrant.yml"))) do
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