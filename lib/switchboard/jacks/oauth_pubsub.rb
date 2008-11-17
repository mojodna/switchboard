require 'rubygems'
begin
  require 'oauth'
rescue LoadError => e
  gem = e.message.split("--").last.strip
  puts "The #{gem} gem is required."
end

require 'oauth/consumer'
require 'oauth/request_proxy/mock_request'
require 'xmpp4r/pubsub'
require 'xmpp4r/pubsub/helper/oauth_service_helper'

# TODO subclass PubSubJack
class OAuthPubSubJack
  def self.connect(switchboard, settings)
    # TODO generalize this pattern for required settings
    unless settings["pubsub.server"]
      puts "A pubsub server must be specified."
      return false
    end

    switchboard.on_startup do
      @pubsub = Jabber::PubSub::OAuthServiceHelper.new(client, settings["pubsub.server"])

      @oauth_consumer = OAuth::Consumer.new(settings["oauth.consumer_key"], settings["oauth.consumer_secret"])
      @oauth_token = OAuth::Token.new(settings["oauth.token"], settings["oauth.token_secret"])

      @pubsub.add_event_callback do |event|
        on(:pubsub_event, event)
      end
    end

    def switchboard.create_node(node)
      # TODO this needs to be implemented in OAuthServiceHelper
      pubsub.create_node(node, oauth_consumer, oauth_token)
    end

    def switchboard.subscribe_to(node)
      pubsub.subscribe_to(node, oauth_consumer, oauth_token)
    end

    def switchboard.subscriptions(node = nil)
      if node
        # TODO this needs to be implemented in OAuthServiceHelper
        pubsub.get_subscriptions_from(node, oauth_consumer, oauth_token)
      else
        pubsub.get_subscriptions_from_all_nodes(oauth_consumer, oauth_token)
      end
    end

    def switchboard.unsubscribe_from(node)
      pubsub.unsubscribe_from(node, oauth_consumer, oauth_token)
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
