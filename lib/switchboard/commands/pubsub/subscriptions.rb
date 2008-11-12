module Switchboard
  module Commands
    class PubSub
      class Subscriptions < Switchboard::Command
        description "List pubsub subscriptions"

        def self.run!
          # TODO override settings with values from the command line
          switchboard = Switchboard::Core.new do
            # this executes in the main loop, so it doesn't really matter that this runs in a different thread
            defer :subscriptions_received do
              begin
                pubsub.get_subscriptions_from_all_nodes(oauth_consumer, general_token)
              rescue Jabber::ServerError => e
                puts e
              end
            end

            # define here or as hydrant.subscriptions_received
            def subscriptions_received(subscriptions)
              puts "Subscriptions:"
              puts subscriptions.collect { |subscription| "#{subscription.jid} => #{subscription.node}" } * "\n"
            end
          end

          switchboard.plug!(OAuthPubSubJack)
          switchboard.run!
        end
      end
    end
  end
end