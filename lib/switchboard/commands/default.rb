module Switchboard
  module Commands
    class Default < Switchboard::Command
      unregister!

      def self.options(opts)
        super(opts)

        opts.banner = "Usage: #{opts.program_name} [options] COMMAND [options] [args]"

        opts.on("-a", "--anonymous", "Connect anonymously.") { OPTIONS["anonymous"] = true }
        # opts.on("-d", "--daemon", "Make server run as a daemon.") { OPTIONS["detach"] = true }
        opts.on("-j", "--jid=jid", String, "Specifies the JID to use.") { |v| OPTIONS["jid"] = v }
        opts.on("-r", "--resource=resource", String, "Specifies the resource to use.") { |v| OPTIONS["resource"] = v }
        opts.on("-p", "--password=password", String, "Specifies the password to use.") { |v| OPTIONS["password"] = v }
        # opts.on("-p", "--pidfile=path", String,
        #         "Specifies a pidfile to use.") { |v| OPTIONS[:pidfile] = v }
        # opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| OPTIONS[:verbose] = v }

        opts.separator ""

        opts.on_tail("-h", "--help", "Show this help message.") { puts opts; exit }
        opts.on_tail("--version", "Show version.") { puts "switchboard version #{Switchboard::VERSION * "."}"; exit }
      end

      def self.run!
        puts self.options(OptionParser.new).help
        puts
        puts "Available commands:"
        Switchboard.commands.each do |name, command|
          puts "   #{command.to_command.ljust(15)}#{command.description}"
          command.options(OptionParser.new).summarize do |line|
            puts " " * 16 + line
          end
        end
        puts
        puts "See '#{@options.program_name} help COMMAND' for more information on a specific command."
      end
    end
  end
end
