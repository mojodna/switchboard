module Switchboard
  module Commands
    class Config < Switchboard::Command
      description "Get and set global options"

      def self.run!
        puts "Setting #{ARGV.shift} to #{ARGV.shift}"
        # $HOME/.switchboardrc
      end
    end
  end
end