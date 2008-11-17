module Switchboard
  module Commands
    class PubSub
      class Create < Switchboard::Command
        description "Creates a pubsub node"

        def self.run!
          switchboard = Switchboard::Core.new do
            defer :node_created do
              begin
                create_node(OPTIONS["pubsub.node"])
              rescue Jabber::ServerError => e
                puts e
              end
            end

            def node_created(name)
              if name
                puts "Node '#{name}' was created."
              else
                puts "An auto-named node was created."
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