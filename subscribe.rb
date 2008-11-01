#!/usr/bin/env ruby

require 'rubygems'
begin
  require 'oauth'
  require 'xmpp4r'
  require 'xmpp4r/pubsub'
  require 'xmpp4r/roster'
rescue LoadError => e
  gem = e.message.split("--").last.strip
  puts "The #{gem} gem is required."
end

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

require 'oauth/request_proxy/base'
require 'oauth/signature/hmac/sha1'
require 'cgi'

module OAuth
  module RequestProxy
    class MockRequest < OAuth::RequestProxy::Base
      proxies Hash

      def parameters
        @request["parameters"]
      end

      def method
        @request["method"]
      end

      def uri
        @request["uri"]
      end
    end
  end
end

module Jabber
  module PubSub
    class OAuthServiceHelper < ServiceHelper
      def initialize(stream, pubsubjid)
        super(stream, pubsubjid)
      end

      def subscribe_to(node, oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret)
        iq = basic_pubsub_query(:set)
        sub = REXML::Element.new('subscribe')
        sub.attributes['node'] = node
        sub.attributes['jid'] = @stream.jid.strip.to_s

        # add the OAuth sauce (XEP-235)
        sub.add(create_oauth_node(oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret))

        iq.pubsub.add(sub)
        res = nil
        @stream.send_with_id(iq) do |reply|
          pubsubanswer = reply.pubsub
          if pubsubanswer.first_element('subscription')
            res = PubSub::Subscription.import(pubsubanswer.first_element('subscription'))
          end
        end # @stream.send_with_id(iq)
        res
      end

      def unsubscribe_from(node, oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret, subid=nil)
        iq = basic_pubsub_query(:set)
        unsub = PubSub::Unsubscribe.new
        unsub.node = node
        unsub.jid = @stream.jid.strip

        # add the OAuth sauce (XEP-235)
        unsub.add(create_oauth_node(oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret))

        iq.pubsub.add(unsub)
        ret = false
        @stream.send_with_id(iq) { |reply| 
          ret = reply.kind_of?(Jabber::Iq) and reply.type == :result
        } # @stream.send_with_id(iq)
        ret
      end

    protected

      def create_oauth_node(oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret)
        request = OAuth::RequestProxy.proxy \
          "method" => "iq",
          "uri"    => [@stream.jid.strip.to_s, @pubsubjid.strip.to_s] * "&",
          "parameters" => {
            "oauth_consumer_key"     => oauth_consumer_key,
            "oauth_token"            => oauth_token,
            "oauth_signature_method" => "HMAC-SHA1"
          }

        puts "Request: #{request.inspect}"
        signature = OAuth::Signature.sign(request) do |token|
          [oauth_token_secret, oauth_consumer_secret]
        end

        puts "Signature: #{signature}"

        oauth = REXML::Element.new("oauth")
        oauth.attributes['xmlns'] = 'urn:xmpp:oauth'

        oauth_consumer_key_node = REXML::Element.new("oauth_consumer_key")
        oauth_consumer_key_node.text = oauth_consumer_key
        oauth.add(oauth_consumer_key_node)

        oauth_token_node = REXML::Element.new("oauth_token")
        oauth_token_node.text = oauth_token
        oauth.add(oauth_token_node)

        oauth_signature_method = REXML::Element.new("oauth_signature_method")
        oauth_signature_method.text = "HMAC-SHA1"
        oauth.add(oauth_signature_method)

        oauth_signature = REXML::Element.new("oauth_signature")
        oauth_signature.text = signature
        oauth.add(oauth_signature)

        oauth
      end
    end
  end
end
@pubsub = Jabber::PubSub::OAuthServiceHelper.new(@client, @server)
@pubsub.add_event_callback do |message|
  puts "<< #{message.to_s}".yellow
end

# send a subscription request
begin
  # TODO use a hash so that it's clearer what's what
  retval = @pubsub.subscribe_to("/api/0.1/user/aumptqi5nzs9", "lymcu2589svt", "zhlikcolltnb0od6vbp9pfa5l7xxt4yx", "aumptqi5nzs9", "265gsszu59j1qr7zpjzvi6v7nkb84rhr")
  puts "Subscription returned: #{retval.inspect}"
rescue Jabber::ServerError => e
  puts "Error: #{e.inspect}"
end

# send an unsubscription request
begin
  retval = @pubsub.unsubscribe_from("/api/0.1/user/aumptqi5nzs9", "lymcu2589svt", "zhlikcolltnb0od6vbp9pfa5l7xxt4yx", "aumptqi5nzs9", "265gsszu59j1qr7zpjzvi6v7nkb84rhr")
  puts "Unsubscribe returned: #{retval.inspect}"
rescue Jabber::ServerError => e
  puts "Error: #{e.inspect}"
end

while(true)
  sleep 5
end