#!/usr/bin/env ruby
require 'fire_hydrant'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")), false)
hydrant.jack!(OAuthPubSubJack)

hydrant.on_startup do
  defer :subscriptions_received do
    begin
      pubsub.get_subscriptions_from_all_nodes(@oauth_consumer, @general_token)
    rescue Jabber::ServerError => e
      puts e
    end
  end

  # define here or as hydrant.subscriptions_received
  def subscriptions_received(subscriptions)
    puts "Subscriptions:"
    puts subscriptions.collect { |subscription| "#{subscription.jid} => #{subscription.node}" } * "\n"
  end
end

hydrant.run!
