module Switchboard
  module Commands
    class PubSub
      class Subscribe < Switchboard::Command
        description "Subscribe to a pubsub node"

        def self.run!
          # TODO override settings with values from the command line
          switchboard = Switchboard::Core.new do
            # this executes in the main loop, so it doesn't really matter that this runs in a different thread
            defer :subscribed do
              begin
                pubsub.subscribe_to("/api/0.1/user/#{settings["oauth.token"]}", oauth_consumer, oauth_token)
              rescue Jabber::ServerError => e
                puts e
              end
            end

            # define here or as hydrant.subscriptions_received
            def subscribed(subscription)
              if subscription.subscription == :subscribed
                puts "Subscribe successful."
              else
                puts "Subscribe failed!".red
              end
            end
          end

          switchboard.plug!(OAuthPubSubJack)
          switchboard.run!
        end
      end
    end
  end
end