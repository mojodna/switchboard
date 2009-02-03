require 'yaml'

module Switchboard
  class Settings
    DEFAULT_PATH = File.join(ENV["HOME"], ".switchboardrc")

    def initialize(path = DEFAULT_PATH)
      @path = path

      if File.exists?(path)
        set_perms
        @config = YAML.load(File.read(path))
      end

      @config ||= {}
    end

    def get(key)
      Switchboard::Command::OPTIONS[key] || @config[key] || Switchboard::Command::DEFAULT_OPTIONS[key]
    end

    alias_method :[], :get

    def set!(key, value)
      set(key, value)
      write
      set_perms
    end

    def set(key, value)
      @config[key] = value
    end

    def []=(key, value)
      set(key, value)
    end

    def write
      open(@path, "w") do |f|
        f << @config.to_yaml
      end
    end

    def set_perms
      File.chmod 0600, @path
    end

  end
end