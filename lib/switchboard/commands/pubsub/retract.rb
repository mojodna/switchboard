module Switchboard
  module Commands
    class PubSub
      class Retract < Switchboard::Command
        description "Retracts an item from a pubsub node"

        def self.options(opts)
          super(opts)
          opts.on("--item-id=id", String, "Specifies the item id to retract.") { |v| OPTIONS["pubsub.retract.id"] = v }
        end

        def self.run!
          switchboard = Switchboard::Client.new do
            defer :item_retracted do
              delete_item_from(OPTIONS["pubsub.node"], OPTIONS["pubsub.retract.id"])
            end

            def item_retracted(success)
              # puts "Result: #{success.to_s}"
              if success
                puts "Item was retracted." # TODO with id?
              else
                puts "Item could not be retracted."
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