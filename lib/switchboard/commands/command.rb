module Switchboard
  COMMANDS = {}

  def self.register_command(cmd)
    COMMANDS[cmd.command_hierarchy * "_"] = cmd
  end

  class Command
    def self.command(*args)
      @@commands ||= {}

      if args.any?
        @@commands[self.to_s] = args.shift
        register(self)
      end

      @@commands[self.to_s]
    end

    def self.command_hierarchy
      [self < Switchboard::Command ? superclass.command_hierarchy : nil, command].flatten.compact
    end

    # TODO consider accepting a block
    def self.options(opts)
    end

  private

    def self.register(klass)
      Switchboard.register_command(klass)
    end
  end
end