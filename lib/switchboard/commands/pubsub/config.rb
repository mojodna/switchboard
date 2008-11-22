module Switchboard
  module Commands
    class PubSub
      class Config < Switchboard::Command
        description "Gets the configuration for a pubsub node"

        def self.run!
          switchboard = Switchboard::Client.new do
            defer :configuration_retrieved do
              if ARGV.length == 2
                key, value = ARGV
                puts "Setting '#{key}' to '#{value}'"
                config = Jabber::PubSub::NodeConfig.new(OPTIONS["pubsub.node"], key => value)
                set_config_for(OPTIONS["pubsub.node"], config)
              end

              get_config_from(OPTIONS["pubsub.node"])
            end

            def configuration_retrieved(config)
              if config
                puts "Configuration for node '#{config.node}':"
                config.options.each do |k,v|
                  puts "  " + [k, v] * ": "
                end
              else
                puts "Could not load configuration for node '#{OPTIONS["pubsub.node"]}'."
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