module Switchboard
  module Commands
    class PubSub
      class Unsubscribe < Switchboard::Command
        description "Unsubscribe from a pubsub node"

        def self.run!
          switchboard = Switchboard::Core.new do
            # this executes in the main loop, so it doesn't really matter that this runs in a different thread
            defer :unsubscribed do
              begin
                unsubscribe_from(settings["pubsub.node"])
              rescue Jabber::ServerError => e
                puts e
              end
            end

            # define here or as hydrant.subscriptions_received
            def unsubscribed(successful)
              puts "Unsubscribe was successful." if successful
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