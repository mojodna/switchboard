module Switchboard
  module Commands
    class PubSub
      class Config < Switchboard::Command
        description "Gets the configuration for a pubsub node"

        def self.run!
          switchboard = Switchboard::Core.new do
            defer :configuration_retrieved do
              begin
                get_config_from(OPTIONS["pubsub.node"])
              rescue Jabber::ServerError => e
                puts e
              end
            end

            def configuration_retrieved(config)
              if config
                puts "Configuration for node '#{config.node}':"
                config.options.each do |k,v|
                  puts "  " + [k, v] * ": "
                end
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