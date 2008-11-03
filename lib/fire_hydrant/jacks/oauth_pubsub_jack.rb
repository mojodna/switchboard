class OAuthPubSubJack
  def self.connect(switchboard)
    switchboard.on_startup do
      @pubsub = Jabber::PubSub::OAuthServiceHelper.new(client, @config[:server])

      @oauth_consumer = OAuth::Consumer.new(@config[:oauth_consumer_key], @config[:oauth_consumer_secret])
      @oauth_token = OAuth::Token.new(@config[:oauth_token], @config[:oauth_token_secret])
      @general_token = OAuth::Token.new(@config[:general_token], @config[:general_token_secret])

      @pubsub.add_event_callback do |event|
        on(:pubsub_event, event)
      end
    end

    def switchboard.pubsub
      @pubsub
    end

    def switchboard.on_pubsub_event(&block)
      register_hook(:pubsub_event, &block)
    end
  end
end