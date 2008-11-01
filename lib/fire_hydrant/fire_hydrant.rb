require 'rubygems'
begin
  require 'oauth'
  require 'xmpp4r'
rescue LoadError => e
  gem = e.message.split("--").last.strip
  puts "The #{gem} gem is required."
end

require 'oauth/consumer'
require 'oauth/request_proxy/mock_request'
require 'xmpp4r/pubsub'
require 'xmpp4r/pubsub/helper/oauth_service_helper'
require 'xmpp4r/roster'

class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[1m\e[32m"); end
  def dark_green; colorize(self, "\e[32m"); end
  def yellow; colorize(self, "\e[1m\e[33m"); end
  def blue; colorize(self, "\e[1m\e[34m"); end
  def dark_blue; colorize(self, "\e[34m"); end
  def purple; colorize(self, "\e[1m\e[35m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end

class FireHydrant
  attr_reader :client, :roster

  def initialize(config)
    # register a handler for SIGINTs
    trap(:INT) do
      shutdown
      exit
    end

    @config = Hash[*config.collect { |k,v| [k.to_sym, v] }.flatten]

    @client = Jabber::Client.new(@config[:jid])
  end

  def run!
    startup

    sleep 5 while true
  end

  # startup hook
  def on_startup(&block)
    @startup_hooks ||= []

    if block_given?
      puts "Registering startup hook"
      @startup_hooks << block
    else
      @startup_hooks.each do |hook|
        # TODO figure out how to set context/binding appropriately
        hook.call
      end
    end
  end

  # shutdown hook
  def on_shutdown(&block)
    @shutdown_hooks ||= []

    if block_given?
      puts "Registering shutdown hook"
      @shutdown_hooks << block
    else
      @shutdown_hooks.each do |hook|
        hook.call
      end
    end
  end

protected

  def connect!
    client.connect
    client.auth(@config[:password])
    @roster = Jabber::Roster::Helper.new(client)
  end

  def presence(status = nil)
    presence = Jabber::Presence.new(status)
    puts ">> #{presence.to_s}"
    client.send(presence)
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
      # puts "<< #{presence.to_s}"
    end

    client.add_message_callback do |message|
      puts "<< #{message.to_s}"
    end

    client.add_iq_callback do |iq|
      puts "<< #{iq.to_s}"
    end
  end

  def register_roster_callbacks
    roster.add_presence_callback do |item, old_presence, new_presence|
      # presence from someone on our roster
      puts "presence << #{item.inspect}: #{old_presence.to_s}, #{new_presence.to_s}"
    end

    roster.add_query_callback do |query|
      # roster data; don't care
      # puts "query << #{query.to_s}"
    end

    roster.add_subscription_callback do |item, presence|
      # confirmation that we were able to subscribe to someone else
      # puts "subscription << #{item.to_s}: #{presence.to_s}"
      unless presence.type == :subscribed
        puts "My subscription request was rejected!"
      end
    end

    roster.add_subscription_request_callback do |item, presence|
      # someone wants to subscribe to me!
      # puts "subscription request << #{item.to_s}: #{presence.to_s}"
      puts "Accepting subscription from #{presence.from}"
      roster.accept_subscription(presence.from)
    end

    roster.add_update_callback do |old_item, new_item|
      # roster has been updated; don't care
      # puts "update: #{old_item.inspect}, #{new_item.inspect}"
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

    on_startup

    puts "Startup completed."
  end

  def shutdown
    on_shutdown

    puts "Shutting down..."
    client.close
  end
end
