#!/usr/bin/env ruby
require 'fire_hydrant'

# Jabber.debug = true

# TODO extract me into a YAML file
config = {
  "jid"      => "client@memberfresh-lm.local",
  "password" => "client",
  # TODO better name - target? recipient? node?
  "server"   => "ubuntu.local"
}

hydrant = FireHydrant.new(config, false)

hydrant.on_startup do
  # add the server as a contact if it wasn't already added
  if roster.find(@config[:server]).empty?
    puts "Adding #{@config[:server]} to my roster..."
    roster.add(@config[:server], nil, true)
  end

  if roster.items.any?
    puts "My roster contains: #{roster.items.keys.map { |jid| jid.to_s } * ", "}"
  end

  @pubsub = Jabber::PubSub::OAuthServiceHelper.new(client, @config[:server])

  # TODO extract these out
  @oauth_consumer = OAuth::Consumer.new("lymcu2589svt", "zhlikcolltnb0od6vbp9pfa5l7xxt4yx")
  @oauth_token = OAuth::Token.new("aumptqi5nzs9", "265gsszu59j1qr7zpjzvi6v7nkb84rhr")

  register_pubsub_callbacks

  # send a subscription request
  begin
    subscription = @pubsub.subscribe_to("/api/0.1/user/aumptqi5nzs9", @oauth_consumer, @oauth_token)
    if subscription.subscription == :subscribed
      puts "Subscribe successful."
    else
      puts "Subscribe failed!".red
    end
  rescue Jabber::ServerError => e
    puts "Error: #{e.inspect}"
  end
end

def hydrant.register_pubsub_callbacks
  @pubsub.add_event_callback do |message|
    puts "<< #{message.to_s}".yellow
  end
end

hydrant.on_shutdown do
  # send an unsubscription request
  begin
    puts "Unsubscribe was successful." if @pubsub.unsubscribe_from("/api/0.1/user/aumptqi5nzs9", @oauth_consumer, @oauth_token)
  rescue Jabber::ServerError => e
    puts "Error: #{e.inspect}"
  end

  if (items = roster.find(@config[:server])).any?
    item = items.values.first
    puts "Removing #{item.jid.to_s} from my roster..."
    item.remove
  end
end

hydrant.run!
