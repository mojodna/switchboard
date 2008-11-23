module Switchboard
  module Commands
    class PubSub
      class Options < Switchboard::Command
        description "Gets subscription options for a pubsub node"

        def self.options(opts)
          super(opts)
          opts.on("--subscriber=jid", String, "Specifies the subscriber to retrieve options for.") { |v| OPTIONS["pubsub.subscriber"] = v }
        end

        def self.run!
          switchboard = Switchboard::Client.new do
            defer :options_retrieved do
              get_options_from(OPTIONS["pubsub.node"], OPTIONS["pubsub.subscriber"] || OPTIONS["jid"])
            end

            def options_retrieved(options)
              if options
                puts "Options for subscription by '#{OPTIONS["pubsub.subscriber"] || OPTIONS["jid"]}' to node '#{options.node}':"
                options.options.each do |k,v|
                  puts "  " + [k, v] * ": "
                end
              else
                puts "Could not load options for subscription by '#{OPTIONS["pubsub.subscriber"] || OPTIONS["jid"]}' to node '#{OPTIONS["pubsub.node"]}'."
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