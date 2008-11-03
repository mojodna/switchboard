#!/usr/bin/env ruby
require 'fire_hydrant'
require 'fire_hydrant/oauth_pubsub_jack'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")), false)
hydrant.jack!(OAuthPubSubJack)

hydrant.on_startup do
  # send an unsubscription request
  begin
    puts "Unsubscribe was successful." if pubsub.unsubscribe_from("/api/0.1/user/aumptqi5nzs9", @oauth_consumer, @oauth_token)
  rescue Jabber::ServerError => e
    puts "Error: #{e.inspect}"
  end
end

hydrant.run!
