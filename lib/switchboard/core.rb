require 'rubygems'
begin
  require 'xmpp4r'
rescue LoadError => e
  gem = e.message.split("--").last.strip
  puts "The #{gem} gem is required."
  exit 1
end

# allow local library modifications/additions to be loaded
$: << File.join(File.dirname(__FILE__))

require 'switchboard/ext/delegate'
require 'switchboard/ext/instance_exec'
require 'xmpp4r/roster'

module Switchboard
  class Core
    include Timeout

    attr_reader :jacks, :settings

    # Register a hook
    def self.hook(*events)
      events.each do |event|
        module_eval(<<-EOS, __FILE__, __LINE__)
          def on_#{event}(method = nil, &block)
            if block_given?
              register_hook(:#{event}, &block)
            elsif method
              register_hook(:#{event}, method)
            end
          end
        EOS
      end
    end

    def initialize(settings = Switchboard::Settings.new, spin = true, &block)
      # register a handler for SIGINTs
      trap(:INT) do
        # exit on a second ^C
        trap(:INT) do
          exit
        end

        @deferreds.each do |name, deferred|
          puts "Killing #{name}" if debug?
          deferred.kill
        end

        shutdown!

        sleep 0.1 until shutdown_complete?
      end

      at_exit do
        @deferreds.each do |name, deferred|
          puts "Killing #{name}" if debug?
          deferred.kill
        end

        shutdown!

        sleep 0.1 until shutdown_complete?
      end

      @settings = settings
      @loop = spin
      @shutdown = false
      @deferreds = {}
      @main = block if block_given?
    end

    # Start running.
    def run!
      startup

      @ready = true

      if @main
        instance_eval(&@main)
      elsif loop?
        sleep 1 while !shutdown?
      end

      shutdown
    end

    # TODO don't start threads yet; wait until all startup hooks have been run
    def defer(callback_name, timeout = 30, &block)
      puts "Deferring to #{callback_name}..." if debug?
      @deferreds[callback_name.to_sym] = Thread.new(callback_name.to_sym) do |callback|

        begin

          timeout(timeout) do
            begin
              results = instance_eval(&block)
              send(callback, results) if respond_to?(callback)
            rescue Jabber::ServerError => e
              puts "Server error: #{e}"
            end
          end

          puts "Done with #{callback}." if debug?
          # TODO make this thread-safe
          @deferreds.delete(callback)

        rescue Timeout::Error
          puts "Deferred method timed out."
        rescue
          puts "An error occurred while running a deferred: #{$!}"
          puts $!.backtrace * "\n"
          shutdown!
        end
      end
    end

    def hook(*events)
      self.class.hook(*events)
    end

    # Connect a jack to the switchboard
    def plug!(*jacks)
      @jacks ||= []
      jacks.each do |jack|
        puts "Connecting jack: #{jack}" if debug?
        @jacks << jack
        if jack.connect(self, settings) == false
          puts "A jack was unable to connect. Shutting down..."
          shutdown(false)
          exit 1
        end
      end
    end

    def ready?
      @ready
    end

    hook(:exception, :iq, :message, :presence, :startup, :stream_connected, :shutdown)

  protected

    def connect!
      raise NotImplementedError, "subclasses of Switchboard::Core must implement connect!"
    end

    def connected?
      @connected
    end

    def debug?
      settings["debug"]
    end

    def disconnect!
      stream.close
    end

    def register_hook(name, method = nil, &block)
      @hooks ||= {}
      name = name.to_sym
      @hooks[name] ||= []

      puts "Registering #{name} hook" if debug?
      if block_given?
        @hooks[name] << block
      else
        @hooks[name] << lambda do |*args|
          send(method.to_sym, *args)
        end
      end
    end

    def on(name, *args)
      @hooks ||= {}
      @hooks[name.to_sym] ||= []
      @hooks[name.to_sym].each do |hook|
        puts "Executing hook '#{name}'" if debug?
        execute_hook(hook, *args)
      end
    end

    def execute_hook(hook, *args)
      timeout(1) do
        instance_exec(*args, &hook)
      end
    rescue Timeout::Error
      puts "Hook timed out, consider deferring it."
    rescue
      puts "An error occurred while running the hook; shutting down..."
      puts $!
      puts $!.backtrace * "\n"
      shutdown!
      raise
    end

    def loop?
      @loop
    end

    def register_default_callbacks
      stream.on_exception do |e, stream, where|
        on(:exception, e, stream, where)

        case where
        when :disconnected
          puts "Jabber service disconnected.  Shutting down."
          exit 1
        when :exit
          puts "Shutting down."
        else
          puts "Caught #{e.inspect} on #{stream} at #{where}.  You might want to consider handling this."
          raise e
        end
      end

      stream.add_presence_callback do |presence|
        on(:presence, presence)
      end

      stream.add_message_callback do |message|
        on(:message, message)
      end

      stream.add_iq_callback do |iq|
        on(:iq, iq)
      end
    end

    def startup
      begin
        timeout(30) do
          register_default_callbacks

          connect!
          @connected = true

          on(:stream_connected)
        end
      rescue Timeout::Error
        puts "Startup took too long.  Shutting down."
        shutdown(false)
        exit 1
      end

      puts "Core startup completed." if debug?

      # run startup hooks
      on(:startup)

      puts "=> Switchboard started."
    end

    def stream
      raise NotImplementedError, "subclasses of Switchboard::Core must implement stream"
    end

    def shutdown!
      puts "Shutdown initiated."
      @shutdown = true
    end

    def shutdown(run_hooks = true)
      if Thread.current != Thread.main
        $stderr.puts "Wrong thread! You should be using #shutdown! instead."
        shutdown!
        return
      end

      while (pending = @deferreds.select { |k,d| d.alive? }.length) > 0
        puts "Waiting for #{pending} thread(s) to finish" if debug?
        sleep 1
      end

      # run shutdown hooks
      on(:shutdown) if run_hooks

      puts "Shutting down..." if debug?
      disconnect! if connected?

      @shutdown_complete = true
    end

    def shutdown?
      @shutdown
    end

    def shutdown_complete?
      @shutdown_complete
    end
  end
end
