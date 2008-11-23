module Switchboard
  module Commands
    class PubSub
      class Purge < Switchboard::Command
        description "Purges a pubsub node"

        def self.run!
          switchboard = Switchboard::Client.new do
            defer :node_purged do
              purge_items_from(OPTIONS["pubsub.node"])
            end

            def node_purged(success)
              if success
                puts "Node '#{OPTIONS["pubsub.node"]}' was successfully purged."
              else
                puts "Could not purge node '#{OPTIONS["pubsub.node"]}'."
              end
            end
          end

          if defined?(OAuth) && OPTIONS["oauth"]
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