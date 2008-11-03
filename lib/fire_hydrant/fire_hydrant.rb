require 'rubygems'
begin
  require 'oauth'
  require 'xmpp4r'
rescue LoadError => e
  gem = e.message.split("--").last.strip
  puts "The #{gem} gem is required."
end

# allow local library modifications/additions to be loaded
$: << File.join(File.dirname(__FILE__))

require 'fire_hydrant/instance_exec'
require 'oauth/consumer'
require 'oauth/request_proxy/mock_request'
require 'xmpp4r/pubsub'
require 'xmpp4r/pubsub/helper/oauth_service_helper'
require 'xmpp4r/roster'

class FireHydrant
  include Timeout
  DEFAULTS = {
    :resource => "fire_hydrant"
  }

  attr_reader :client, :jacks, :roster

  def initialize(config, spin = true)
    # register a handler for SIGINTs
    trap(:INT) do
      shutdown
      exit
    end

    config = DEFAULTS.merge(config)

    @config = Hash[*config.collect { |k,v| [k.to_sym, v] }.flatten]
    @loop = spin

    # TODO jid may already have a resource, so account for that
    @client = Jabber::Client.new([@config[:jid], @config[:resource]] * "/")
  end

  # Turn the hydrant on.
  def run!
    startup

    if loop?
      sleep 5 while true
    end

    shutdown
  end

  # Connect a jack to the switchboard
  def jack(*jacks)
    @jacks ||= []
    jacks.each do |jack|
      puts "Connecting jack: #{jack}"
      @jacks << jack
      jack.connect(self)
    end
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

  def disconnect
    client.close
  end

  def register_hook(name, &block)
    @hooks ||= {}
    @hooks[name.to_sym] ||= []

    puts "Registering #{name} hook"
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
    timeout(15) do
      instance_exec(*args, &hook)
    end
  rescue Timeout::Error
    puts "Hook timed out"
  rescue
    puts "An error occurred while running the hook; shutting down..."
    shutdown
    raise
  end

  def loop?
    @loop
  end

  def presence(status = nil)
    client.send(Jabber::Presence.new(status))
  end

  def register_default_callbacks
    # register default callbacks
    client.on_exception do |e, stream, where|
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

    puts "Core startup completed."

    # run startup hooks
    on(:startup)
  end

  def shutdown
    # run shutdown hooks
    on(:shutdown)

    puts "Shutting down..."
    disconnect
  end
end
