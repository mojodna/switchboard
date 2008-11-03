#!/usr/bin/env ruby
require 'fire_hydrant'
require 'fire_hydrant/jacks/oauth_pubsub_jack'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")), false)
hydrant.jack!(OAuthPubSubJack)

hydrant.on_startup do
  # send a subscription request
  begin
    subscription = pubsub.subscribe_to("/api/0.1/user/aumptqi5nzs9", @oauth_consumer, @oauth_token)
    if subscription.subscription == :subscribed
      puts "Subscribe successful."
    else
      puts "Subscribe failed!".red
    end
  rescue Jabber::ServerError => e
    puts "Error: #{e.inspect}"
  end
end

hydrant.run!
