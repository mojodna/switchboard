module Switchboard
  module Commands
    class PubSub
      class Delete < Switchboard::Command
        description "Deletes a pubsub node"

        def self.run!
          switchboard = Switchboard::Client.new do
            defer :node_deleted do
              delete_node(OPTIONS["pubsub.node"])
            end

            def node_deleted(success)
              if success
                puts "Node '#{OPTIONS["pubsub.node"]}' was deleted."
              else
                puts "Node '#{OPTIONS["pubsub.node"]}' could not be deleted."
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