class OAuthPubSubJack
  def self.connect(switchboard, settings)
    require 'switchboard/helpers/oauth_pubsub'

    # TODO generalize this pattern for required settings
    unless settings["pubsub.server"]
      puts "A pubsub server must be specified."
      return false
    end

    switchboard.extend(Switchboard::Helpers::OAuthPubSubHelper)

    switchboard.on_startup do
      @pubsub = Jabber::PubSub::OAuthServiceHelper.new(client, settings["pubsub.server"])

      @oauth_consumer = OAuth::Consumer.new(settings["oauth.consumer_key"], settings["oauth.consumer_secret"])
      @oauth_token = OAuth::Token.new(settings["oauth.token"], settings["oauth.token_secret"])

      @pubsub.add_event_callback do |event|
        on(:pubsub_event, event)
      end
    end
  end
end
