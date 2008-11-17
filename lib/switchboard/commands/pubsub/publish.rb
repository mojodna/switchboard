module Switchboard
  module Commands
    class PubSub
      class Publish < Switchboard::Command
        description "Publish to a pubsub node"

        def self.run!
          switchboard = Switchboard::Core.new do
            defer :item_published do
              begin
                item = Jabber::PubSub::Item.new
                item.text = STDIN.read
                publish_item_to(OPTIONS["pubsub.node"], item)
              rescue Jabber::ServerError => e
                puts e
              end
            end

            def item_published(success)
              if success
                puts "Item was published."
              else
                puts "Item could not be published."
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