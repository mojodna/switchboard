#!/usr/bin/env ruby
require 'fire_hydrant'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml"))) do
  # this executes in the main loop, so it doesn't really matter that this runs in a different thread
  defer :unsubscribed do
    begin
      pubsub.unsubscribe_from("/api/0.1/user/#{@oauth_token.token}", @oauth_consumer, @oauth_token)
    rescue Jabber::ServerError => e
      puts e
    end
  end

  # define here or as hydrant.subscriptions_received
  def unsubscribed(successful)
    puts "Unsubscribe was successful." if successful
  end
end

hydrant.jack!(OAuthPubSubJack)

hydrant.run!
