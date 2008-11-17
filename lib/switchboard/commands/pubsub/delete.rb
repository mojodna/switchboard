module Switchboard
  module Commands
    class PubSub
      class Delete < Switchboard::Command
        description "Deletes a pubsub node"

        def self.run!
          switchboard = Switchboard::Core.new do
            defer :node_deleted do
              begin
                delete_node(OPTIONS["pubsub.node"])
              rescue Jabber::ServerError => e
                puts e
              end
            end

            def node_deleted(success)
              if success
                puts "Node '#{OPTIONS["pubsub.node"]}' was deleted."
              else
                puts "Node '#{OPTIONS["pubsub.node"]}' could not be deleted."
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