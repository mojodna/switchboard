module Switchboard
  module Commands
    class PubSub
      class Items < Switchboard::Command
        description "Get items from a pubsub node"

        def self.options(opts)
          opts.on("--item-count=count", Integer, "Specifies the number of items to retrieve.") { |v| OPTIONS["pubsub.items.count"] = v }
        end

        def self.run!
          switchboard = Switchboard::Core.new do
            defer :items_retrieved do
              begin
                get_items_from(OPTIONS["pubsub.node"], OPTIONS["pubsub.items.count"])
              rescue Jabber::ServerError => e
                puts e
              end
            end

            def items_retrieved(items)
              if items && items.any?
                puts "Items:"
                items.each do |id, item|
                  puts [id, item] * ": "
                end
              else
                puts "No items available for node '#{OPTIONS["pubsub.node"]}'."
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