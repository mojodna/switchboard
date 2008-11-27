require 'rubygems'
begin
  require 'oauth'
rescue LoadError => e
  gem = e.message.split("--").last.strip
  puts "The #{gem} gem is required."
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

      # TODO most/all of these need to be implemented in OAuthServiceHelper
      delegate :create_node, :create_collection_node, :delete_node,
        :delete_item_from, :get_config_from, :get_options_from, :get_items_from,
        :publish_item_to, :publish_item_with_id_to, :purge_items_from,
        :set_config_for, :subscribe_to, :unsubscribe_from,
        :to   => :pubsub,
        :with => [:oauth_consumer, :oauth_token]

      def subscriptions(node = nil)
        if node
          # TODO this needs to be implemented in OAuthServiceHelper
          pubsub.get_subscriptions_from(node, oauth_consumer, oauth_token)
        else
          pubsub.get_subscriptions_from_all_nodes(oauth_consumer, oauth_token)
        end
      end
    end
  end
end
