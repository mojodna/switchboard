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

class OAuthPubSubJack
  def self.connect(switchboard)
    switchboard.on_startup do
      @pubsub = Jabber::PubSub::OAuthServiceHelper.new(client, settings["pubsub.server"])

      @oauth_consumer = OAuth::Consumer.new(settings["oauth.consumer_key"], settings["oauth.consumer_secret"])
      @oauth_token = OAuth::Token.new(settings["oauth.token"], settings["oauth.token_secret"])
      # this is Fire Eagle-specific
      @general_token = OAuth::Token.new(settings["oauth.general_token"], settings["oauth.general_token_secret"])

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
