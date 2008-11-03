require 'rubygems'
begin
  require 'xmpp4r'
rescue LoadError => e
  gem = e.message.split("--").last.strip
  puts "The #{gem} gem is required."
end

# allow local library modifications/additions to be loaded
$: << File.join(File.dirname(__FILE__))

require 'fire_hydrant/instance_exec'
require 'xmpp4r/roster'

class FireHydrant
  include Timeout
  DEFAULTS = {
    :debug    => false,
    :resource => "fire_hydrant"
  }

  attr_reader :client, :jacks, :roster

  def initialize(config, spin = true)
    # register a handler for SIGINTs
    trap(:INT) do
      @deferreds.each do |name, deferred|
        puts "Killing #{name}" if debug?
        deferred.kill
      end

      shutdown
      exit
    end

    config = DEFAULTS.merge(config)

    @config = Hash[*config.collect { |k,v| [k.to_sym, v] }.flatten]
    @loop = spin
    @shutdown = false
    @deferreds = {}

    # TODO jid may already have a resource, so account for that
    @client = Jabber::Client.new([@config[:jid], @config[:resource]] * "/")
  end

  # Turn the hydrant on.
  def run!
    startup

    if loop?
      sleep 5 while !@shutdown
    end

    shutdown
  end

  def defer(callback_name, &block)
    puts "Deferring to #{callback_name}..." if debug?
    @deferreds[callback_name.to_sym] = Thread.new do

      begin

        timeout(30) do
          results = instance_eval(&block)
          send(callback_name.to_sym, results)
        end

        puts "Done with #{callback_name}." if debug?
        # TODO make this thread-safe
        @deferreds.delete(callback_name.to_sym)

      rescue Timeout::Error
        puts "Deferred method timed out."
      rescue
        puts "An error occurred while running a deferred: #{$!}"
        puts $!.backtrace * "\n"
        puts "Initiating shutdown..."
        @shutdown = true
      end
    end
  end

  # Connect a jack to the switchboard
  def jack!(*jacks)
    @jacks ||= []
    jacks.each do |jack|
      puts "Connecting jack: #{jack}" if debug?
      @jacks << jack
      jack.connect(self)
    end
  end

  # Register a hook to run when the Jabber::Client encounters an exception.
  def on_exception(&block)
    register_hook(:exception, &block)
  end

  # Register a hook to run when iq stanzas are received.
  def on_iq(&block)
    register_hook(:iq, &block)
  end

  # Register a hook to run when message stanzas are received.
  def on_message(&block)
    register_hook(:message, &block)
  end

  # Register a hook to run when presence stanzas are received.
  def on_presence(&block)
    register_hook(:presence, &block)
  end

  def on_roster_presence(&block)
    register_hook(:roster_presence, &block)
  end

  def on_roster_query(&block)
    register_hook(:roster_query, &block)
  end

  def on_roster_subscription(&block)
    register_hook(:roster_subscription, &block)
  end

  def on_roster_subscription_request(&block)
    register_hook(:roster_subscription_request, &block)
  end

  def on_roster_loaded(&block)
    register_hook(:roster_loaded, &block)
  end

  def on_roster_update(&block)
    register_hook(:roster_update, &block)
  end

  # Register a startup hook.
  # Hooks will be given 5 seconds to complete before moving on.
  def on_startup(&block)
    register_hook(:startup, &block)
  end

  # Register a shutdown hook.
  # Hooks will be given 5 seconds to complete before moving on.
  def on_shutdown(&block)
    register_hook(:shutdown, &block)
  end

protected

  def connect!
    client.connect
    client.auth(@config[:password])
    @roster = Jabber::Roster::Helper.new(client)
  end

  def debug?
    @config[:debug]
  end

  def disconnect
    presence(:unavailable)
    client.close
  end

  def register_hook(name, &block)
    @hooks ||= {}
    @hooks[name.to_sym] ||= []

    puts "Registering #{name} hook" if debug?
    @hooks[name.to_sym] << block
  end

  def on(name, *args)
    @hooks ||= {}
    @hooks[name.to_sym] ||= []
    @hooks[name.to_sym].each do |hook|
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
    shutdown
    raise
  end

  def loop?
    @loop
  end

  def presence(status = nil, to = nil)
    presence = Jabber::Presence.new(nil, status)
    presence.to = to
    client.send(presence)
  end

  def register_default_callbacks
    client.on_exception do |e, stream, where|
      on(:exception, e, stream, where)

      case where
      when :something
      else
        puts "Caught #{e.inspect} on #{stream} at #{where}.  You might want to consider handling this."
        raise e
      end
    end

    client.add_presence_callback do |presence|
      on(:presence, presence)
    end

    client.add_message_callback do |message|
      on(:message, message)
    end

    client.add_iq_callback do |iq|
      on(:iq, iq)
    end
  end

  def register_roster_callbacks
    # presence from someone on my roster
    roster.add_presence_callback do |item, old_presence, new_presence|
      on(:roster_presence, item, old_presence, new_presence)
    end

    # roster query completed (rarely used)
    roster.add_query_callback do |query|
      on(:roster_query, query)
    end

    # roster subscription
    roster.add_subscription_callback do |item, presence|
      # confirmation that we were able to subscribe to someone else
      on(:roster_subscription, item, presence)
    end

    roster.add_subscription_request_callback do |item, presence|
      # someone wants to subscribe to me!
      on(:roster_subscription_request, item, presence)
    end

    # roster was updated (rarely used)
    roster.add_update_callback do |old_item, new_item|
      # roster has been updated; don't care
      # puts "update: #{old_item.inspect}, #{new_item.inspect}"
      on(:roster_update, old_item, new_item)
    end
  end

  def startup
    connect!
    register_default_callbacks
    register_roster_callbacks

    # tell others that we're online
    presence

    # wait for the roster to load
    roster.wait_for_roster
    on(:roster_loaded)

    puts "Core startup completed." if debug?

    # run startup hooks
    on(:startup)

    puts "=> Switchboard started."
  end

  def shutdown
    while (pending = @deferreds.select { |k,d| d.alive? }.length) > 0
      puts "Waiting for #{pending} thread(s) to finish" if debug?
      sleep 1
    end

    # run shutdown hooks
    on(:shutdown)

    puts "Shutting down..." if debug?
    disconnect
  end
end
