module Switchboard
  COMMANDS = {}

  def self.commands(command = nil)
    if command
      COMMANDS.select { |k,v| k =~ /^#{command.to_command_name("_")}_/ }
    else
      COMMANDS.reject { |k,v| k =~ /_/ }
    end
  end

  def self.hide_command(command)
    COMMANDS["_#{command.to_command_name("_")}"] = unregister_command(command)
  end

  def self.register_command(command)
    COMMANDS[command.to_command_name("_")] = command
  end

  def self.unregister_command(command)
    COMMANDS.delete(command.to_command_name("_"))
  end


  module Commands
  end

  class Command
    def self.description(description = nil)
      @description = description if description
      @description
    end

    def self.help
      "No help is available for this command (#{self.to_command_name})."
    end

    # TODO consider accepting a block in subclasses
    def self.options(opts)
      @options = opts
      @options.banner = "Usage: #{opts.program_name} [options] #{self.to_command_name} [options] [args]"
      @options
    end

    def self.run!
      puts self.options(OptionParser.new).help
      puts
      puts "Available commands:"
      Switchboard.commands(self).each do |name, command|
        puts "   #{command.to_command.ljust(15)}#{command.description}"
        command.options(OptionParser.new).summarize do |line|
          puts " " * 16 + line
        end
      end
      puts
      puts "See '#{@options.program_name} help COMMAND' for more information on a specific command."
    end

    def self.to_command
      self.name.gsub("Switchboard::Commands::", "").split("::").last.downcase
    end

    def self.to_command_name(delimiter = " ")
      self.name.gsub("Switchboard::Commands::", "").split("::").map { |c| c.downcase } * delimiter
    end

  private

    def self.hide!
      Switchboard.hide_command(self)
    end

    def self.inherited(klass)
      Switchboard.register_command(klass) if klass.name =~ /^Switchboard::Commands/
    end

    def self.unregister!
      Switchboard.unregister_command(self)
    end
  end
end
