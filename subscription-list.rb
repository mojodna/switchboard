#!/usr/bin/env ruby
require 'fire_hydrant'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")), false)

hydrant.on_startup do
  @pubsub = Jabber::PubSub::OAuthServiceHelper.new(client, @config[:server])

  @oauth_consumer = OAuth::Consumer.new(@config[:oauth_consumer_key], @config[:oauth_consumer_secret])
  @oauth_token = OAuth::Token.new(@config[:general_token], @config[:general_token_secret])

  # TODO this is a synchronous call, so we might want to wrap it (and other pubsub calls) in a thread w/ callbacks
  # defer :subscriptions_received do
  #   ...
  # end
  subscriptions = @pubsub.get_subscriptions_from_all_nodes(@oauth_consumer, @oauth_token)
  puts "Subscriptions:"
  puts subscriptions.collect { |subscription| "#{subscription.jid} => #{subscription.node}" } * "\n"
end

hydrant.run!
