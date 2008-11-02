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
  # General Purpose access tokens
  "oauth_token"           => "wwukmsi3shhu",
  "oauth_token_secret"    => "utdt1o9zbjhvubjlo75a1zpg97zdzo08"
}

hydrant = FireHydrant.new(config, false)

hydrant.on_startup do
  @pubsub = Jabber::PubSub::OAuthServiceHelper.new(client, @config[:server])

  @oauth_consumer = OAuth::Consumer.new(@config[:oauth_consumer_key], @config[:oauth_consumer_secret])
  @oauth_token = OAuth::Token.new(@config[:oauth_token], @config[:oauth_token_secret])

  # TODO this is a synchronous call, so we might want to wrap it (and other pubsub calls) in a thread w/ callbacks
  # defer :subscriptions_received do
  #   ...
  # end
  subscriptions = @pubsub.get_subscriptions_from_all_nodes(@oauth_consumer, @oauth_token)
  puts "Subscriptions:"
  puts subscriptions.collect { |subscription| "#{subscription.jid} => #{subscription.node}" } * "\n"
end

hydrant.run!
