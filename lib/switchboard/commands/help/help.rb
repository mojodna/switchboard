module Switchboard
  module Commands
    class Help < Switchboard::Command
      hide!

      def self.run!
        if ARGV.any?
          puts Switchboard::COMMANDS[ARGV * "_"].help
        else
          Switchboard::Commands::Default.run!
        end
      end
    end
  end
end