require 'xmpp4r/pubsub'
# TODO this is broken in XMPP4R 0.4.0
# require 'xmpp4r/pubsub/helper/nodebrowser'

module Switchboard
  module Helpers
    module PubSubHelper
      attr_reader :pubsub

      delegate :create_node, :create_collection_node, :delete_node,
        :get_config_from, :get_options_from, :get_items_from, :publish_item_to,
        :publish_item_with_id_to, :purge_items_from, :set_config_for,
        :subscribe_to, :unsubscribe_from, :to => :pubsub

      Switchboard::Core.hook(:pubsub_event)

      def subscriptions(node = nil)
        # NOTE: node-specific subscriptions do not appear to work in ejabberd 2.0.2
        if node
          pubsub.get_subscriptions_from(node)
        else
          pubsub.get_subscriptions_from_all_nodes
        end
      end
    end
  end
end
