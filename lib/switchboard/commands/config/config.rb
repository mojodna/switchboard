module Switchboard
  module Commands
    class Config < Switchboard::Command
      description "Get and set global options"

      def self.run!
        settings = Switchboard::Settings.new
        if ARGV.empty?
          super
        elsif ARGV.length == 1
          puts settings.get(ARGV.shift)
        elsif ARGV.length == 2
          settings.set!(ARGV.shift, ARGV.shift)
        else
          puts "error: More than one value for the key #{ARGV.shift}: #{ARGV * " "}"
        end
      end
    end
  end
end