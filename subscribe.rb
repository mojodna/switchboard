#!/usr/bin/env ruby
require 'fire_hydrant'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")), false)
hydrant.jack!(OAuthPubSubJack)

hydrant.on_startup do
  defer :subscribed do
    begin
      pubsub.subscribe_to("/api/0.1/user/aumptqi5nzs9", @oauth_consumer, @oauth_token)
    rescue Jabber::ServerError => e
      puts e
    end
  end

  # define here or as hydrant.subscriptions_received
  def subscribed(subscription)
    if subscription.subscription == :subscribed
      puts "Subscribe successful."
    else
      puts "Subscribe failed!".red
    end
  end
end

hydrant.run!
