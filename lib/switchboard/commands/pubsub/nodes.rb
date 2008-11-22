module Switchboard
  module Commands
    class PubSub
      class Nodes < Switchboard::Command
        hide! # Jabber::PubSub::NodeBrowser is broken in xmpp4r-0.4.0
        description "Lists available pubsub nodes (maybe use pubsub.<server>)"

        def self.run!
          switchboard = Switchboard::Client.new do
            defer :nodes_retrieved do
              browser = Jabber::PubSub::NodeBrowser.new(client)
              browser.nodes(OPTIONS["pubsub.server"])
            end

            def nodes_retrieved(nodes)
              if nodes && nodes.compact! && nodes.any?
                puts "Nodes available on '#{OPTIONS["pubsub.server"]}':"
                nodes.each do |node|
                  puts "  #{node.to_s}"
                end
              else
                puts "No nodes are available on '#{OPTIONS["pubsub.server"]}'."
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
