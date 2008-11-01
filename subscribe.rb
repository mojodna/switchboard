#!/usr/bin/env ruby

$: << File.join(File.dirname(__FILE__), "lib", "fire_hydrant")

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

settings = {
  "jid"      => "client@memberfresh-lm.local",
  "password" => "client",
  "server"   => "ubuntu.local"
}

@server = settings["server"]

trap(:INT) do
  if (items = @roster.find(@server)).any?
    item = items.values.first
    puts "Removing #{item.jid.to_s} from my roster..."
    item.remove
  end

  puts "Shutting down cleanly."
  @client.close
  exit
end


# Jabber.debug = true


# Connect
@client = Jabber::Client.new(settings["jid"])
@client.connect
@client.auth(settings["password"])

# register default callbacks
@client.on_exception do |e, stream, where|
  case where
  when :something
  else
    puts "Caught #{e.inspect} on #{stream} at #{where}.  You might want to consider handling this."
    raise e
  end
end

@client.add_presence_callback do |presence|
  # puts "<< #{presence.to_s}"
end

@client.add_message_callback do |message|
  puts "<< #{message.to_s}"
end

@client.add_iq_callback do |iq|
  puts "<< #{iq.to_s}"
end

# mark ourselves as online
presence = Jabber::Presence.new
puts ">> #{presence.to_s}"
@client.send(presence)

# who are my contacts?
@roster = Jabber::Roster::Helper.new(@client)

@roster.add_presence_callback do |item, old_presence, new_presence|
  # presence from someone on our roster
  puts "presence << #{item.inspect}: #{old_presence.to_s}, #{new_presence.to_s}"
end

@roster.add_query_callback do |query|
  # roster data; don't care
  # puts "query << #{query.to_s}"
end

@roster.add_subscription_callback do |item, presence|
  # confirmation that we were able to subscribe to someone else
  # puts "subscription << #{item.to_s}: #{presence.to_s}"
  unless presence.type == :subscribed
    puts "Our subscription request was rejected"
  end
end

@roster.add_subscription_request_callback do |item, presence|
  # someone wants to subscribe to me!
  # puts "subscription request << #{item.to_s}: #{presence.to_s}"
  puts "Accepting subscription from #{presence.from}"
  @roster.accept_subscription(presence.from)
end

@roster.add_update_callback do |old_item, new_item|
  # roster has been updated; don't care
  # puts "update: #{old_item.inspect}, #{new_item.inspect}"
end

# wait for the roster to load and add the server as a contact if it wasn't already added
@roster.wait_for_roster
if @roster.find(@server).empty?
  puts "Adding #{@server} to my roster..."
  @roster.add(@server, nil, true)
end

if @roster.items.any?
  puts "My roster contains: #{@roster.items.keys.map { |jid| jid.to_s } * ", "}"
end

@pubsub = Jabber::PubSub::OAuthServiceHelper.new(@client, @server)
@pubsub.add_event_callback do |message|
  puts "<< #{message.to_s}".yellow
end

oauth_consumer = OAuth::Consumer.new("lymcu2589svt", "zhlikcolltnb0od6vbp9pfa5l7xxt4yx")
oauth_token = OAuth::Token.new("aumptqi5nzs9", "265gsszu59j1qr7zpjzvi6v7nkb84rhr")

# send a subscription request
begin
  # TODO use a hash so that it's clearer what's what
  retval = @pubsub.subscribe_to("/api/0.1/user/aumptqi5nzs9", oauth_consumer, oauth_token)
  puts "Subscription returned: #{retval.inspect}"
rescue Jabber::ServerError => e
  puts "Error: #{e.inspect}"
end

# send an unsubscription request
begin
  retval = @pubsub.unsubscribe_from("/api/0.1/user/aumptqi5nzs9", oauth_consumer, oauth_token)
  puts "Unsubscribe returned: #{retval.inspect}"
rescue Jabber::ServerError => e
  puts "Error: #{e.inspect}"
end

while(true)
  sleep 5
end