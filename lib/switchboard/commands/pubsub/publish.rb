module Switchboard
  module Commands
    class PubSub
      class Publish < Switchboard::Command
        description "Publish to a pubsub node"

        def self.options(opts)
          super(opts)
          opts.on("--item-id=id", String, "Specifies the item id to use.") { |v| OPTIONS["pubsub.publish.id"] = v }
          opts.on("--xml", "Specifies whether to parse input as raw xml.") { |v| OPTIONS["pubsub.publish.xml"] = v }
        end

        def self.run!
          switchboard = Switchboard::Client.new do
            defer :item_published do
              item = Jabber::PubSub::Item.new
              content = STDIN.read

              if OPTIONS["pubsub.publish.xml"]
                doc = REXML::Document.new(content)
                item << doc.root
              else
                item.text = content
              end

              if OPTIONS["pubsub.publish.id"]
                publish_item_with_id_to(OPTIONS["pubsub.node"], item, OPTIONS["pubsub.publish.id"])
              else
                publish_item_to(OPTIONS["pubsub.node"], item)
              end
            end

            def item_published(success)
              # puts "Result: #{success.to_s}"
              if success
                puts "Item was published." # TODO include id
              else
                puts "Item could not be published."
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
