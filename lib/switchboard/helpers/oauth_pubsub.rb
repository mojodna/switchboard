begin
  require 'oauth'
rescue LoadError => e
  lib = e.message.split("--").last.strip
  puts "#{lib} is required."
  exit 1
end

require 'oauth/version'
if OAuth::VERSION < "0.3.1.4"
  puts "The OAuth library must be at least version 0.3.1.4."
  exit 1
end

require 'switchboard/helpers/pubsub'
require 'oauth/consumer'
require 'oauth/request_proxy/mock_request'
require 'xmpp4r/pubsub'
require 'xmpp4r/pubsub/helper/oauth_service_helper'

module Switchboard
  module Helpers
    module OAuthPubSubHelper
      include PubSubHelper

      attr_reader :oauth_consumer, :oauth_token

      delegate :create_node, :create_collection_node, :delete_node,
        :delete_item_from, :get_config_from, :get_options_from, :get_items_from,
        :publish_item_to, :publish_item_with_id_to, :purge_items_from,
        :set_config_for, :subscribe_to, :unsubscribe_from,
        :to   => :pubsub

      def subscriptions(node = nil)
        if node
          # TODO this needs to be implemented in OAuthServiceHelper
          pubsub.get_subscriptions_from(node)
        else
          pubsub.get_subscriptions_from_all_nodes
        end
      end
    end
  end
end
