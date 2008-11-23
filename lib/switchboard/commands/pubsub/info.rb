module Switchboard
  module Commands
    class PubSub
      class Info < Switchboard::Command
        hide! # Jabber::PubSub::NodeBrowser is broken in xmpp4r-0.4.0
        description "Gets information about a pubsub resource"

        def self.run!
          switchboard = Switchboard::Client.new do
            defer :info_retrieved do
              browser = Jabber::PubSub::NodeBrowser.new(client)
              browser.get_info(OPTIONS["pubsub.server"], OPTIONS["pubsub.node"])
            end

            def info_retrieved(info)
              if info
                if OPTIONS["pubsub.node"]
                  puts "Info for '#{OPTIONS["pubsub.node"]}' on '#{OPTIONS["pubsub.server"]}'"
                else
                  puts "Info for '#{OPTIONS["pubsub.server"]}'"
                end
                info.each do |k,v|
                  if v.is_a?(Array)
                    puts "  #{k}:"
                    v.each do |v2|
                      puts "    #{v2}"
                    end
                  else
                    puts "  #{k}: #{v}"
                  end
                end
              else
                puts "Info could not be loaded for '#{OPTIONS["pubsub.server"]}'"
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
