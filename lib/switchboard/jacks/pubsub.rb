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

    def switchboard.subscribe_to(node)
      pubsub.subscribe_to(node)
    end

    # NOTE: node-specific subscriptions do not appear to work in ejabberd 2.0.2
    def switchboard.subscriptions(node = nil)
      if node
        pubsub.get_subscriptions_from(node)
      else
        pubsub.get_subscriptions_from_all_nodes
      end
    end

    def switchboard.unsubscribe_from(node)
      pubsub.unsubscribe_from(node)
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
