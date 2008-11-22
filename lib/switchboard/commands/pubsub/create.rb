module Switchboard
  module Commands
    class PubSub
      class Create < Switchboard::Command
        description "Creates a pubsub node"

        def self.options(opts)
          super(opts)
          opts.on("--collection", "Specifies that a 'collection' node should be created.") { |v| OPTIONS["pubsub.create.node_type"] = "collection" }
        end

        def self.run!
          switchboard = Switchboard::Core.new do
            defer :node_created do
              if OPTIONS["pubsub.create.node_type"] == "collection"
                create_collection_node(OPTIONS["pubsub.node"], nil)
              else
                create_node(OPTIONS["pubsub.node"], nil)
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