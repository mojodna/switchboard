#!/usr/bin/env ruby
require 'fire_hydrant'
require 'fire_hydrant/jacks/oauth_pubsub_jack'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")), false)
hydrant.jack!(OAuthPubSubJack)

hydrant.on_startup do
  # TODO this is a synchronous call, so we might want to wrap it (and other pubsub calls) in a thread w/ callbacks
  # defer :subscriptions_received do
  #   ...
  # end
  subscriptions = pubsub.get_subscriptions_from_all_nodes(@oauth_consumer, @general_token)
  puts "Subscriptions:"
  puts subscriptions.collect { |subscription| "#{subscription.jid} => #{subscription.node}" } * "\n"
end

hydrant.run!
