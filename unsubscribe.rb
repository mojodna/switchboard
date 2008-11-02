#!/usr/bin/env ruby
require 'fire_hydrant'

# TODO extract me into a YAML file
config = {
  "jid"                   => "client@memberfresh-lm.local",
  "password"              => "client",
  "server"                => "ubuntu.local",
  "oauth_consumer_key"    => "lymcu2589svt",
  "oauth_consumer_secret" => "zhlikcolltnb0od6vbp9pfa5l7xxt4yx",
  # OAuth access tokens
  "oauth_token"           => "aumptqi5nzs9",
  "oauth_token_secret"    => "265gsszu59j1qr7zpjzvi6v7nkb84rhr",
}

hydrant = FireHydrant.new(config, false)

hydrant.on_startup do
  @pubsub = Jabber::PubSub::OAuthServiceHelper.new(client, @config[:server])

  # TODO extract these out
  @oauth_consumer = OAuth::Consumer.new(@config[:oauth_consumer_key], @config[:oauth_consumer_secret])
  @oauth_token = OAuth::Token.new(@config[:oauth_token], @config[:oauth_token_secret])

  # send an unsubscription request
  begin
    puts "Unsubscribe was successful." if @pubsub.unsubscribe_from("/api/0.1/user/aumptqi5nzs9", @oauth_consumer, @oauth_token)
  rescue Jabber::ServerError => e
    puts "Error: #{e.inspect}"
  end
end

hydrant.run!
