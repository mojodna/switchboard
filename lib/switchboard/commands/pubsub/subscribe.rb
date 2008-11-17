module Switchboard
  module Commands
    class PubSub
      class Subscribe < Switchboard::Command
        description "Subscribe to a pubsub node"

        def self.run!
          switchboard = Switchboard::Core.new do
            # this executes in the main loop, so it doesn't really matter that this runs in a different thread
            defer :subscribed do
              begin
                subscribe_to(settings["pubsub.node"])
              rescue Jabber::ServerError => e
                puts e
              end
            end

            # define here or as hydrant.subscriptions_received
            def subscribed(subscription)
              if subscription && subscription.subscription == :subscribed
                puts "Subscribe successful."
              else
                puts "Subscribe failed!"
              end
            end
          end

          if OPTIONS["oauth"]
            switchboard.plug!(OAuthPubSubJack)
          else
            switchboard.plug!(PubSubJack)
          end
          switchboard.run!
        end
      end
    end
  end
end