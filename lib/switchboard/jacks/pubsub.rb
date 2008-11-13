require 'xmpp4r/pubsub'

class PubSubJack
  def self.connect(switchboard, settings)
    # TODO generalize this pattern for required settings
    unless settings["pubsub.server"]
      puts "A pubsub server must be specified."
      return false
    end

    switchboard.on_startup do
      @pubsub = Jabber::PubSub::ServiceHelper.new(client, settings["pubsub.server"])

      @pubsub.add_event_callback do |event|
        on(:pubsub_event, event)
      end
    end

    # TODO add the ability to define accessors
    def switchboard.general_token
      @general_token
    end

    def switchboard.oauth_consumer
      @oauth_consumer
    end

    def switchboard.oauth_token
      @oauth_token
    end

    def switchboard.pubsub
      @pubsub
    end

    def switchboard.on_pubsub_event(&block)
      register_hook(:pubsub_event, &block)
    end
  end
end
