module Switchboard
  module Commands
    class PubSub < Switchboard::Command
      description "Pubsub node manipulation"

      def self.help
        "These are the more extensive instructions for using the pubsub command."
      end

      def self.options(opts)
        super(opts)
        opts.on("--node=node", String, "Specifies the PubSub node to use.") { |v| OPTIONS["pubsub.node"] = v }
        opts.on("--oauth", "Sign requests using OAuth.") { OPTIONS["oauth"] = true }
        opts.on("--oauth-consumer-key=consumer-key", String, "Specifies the OAuth consumer key to use.") { |v| OPTIONS["oauth.consumer_key"] = v }
        opts.on("--oauth-consumer-secret=consumer-secret", String, "Specifies the OAuth consumer secret to use.") { |v| OPTIONS["oauth.consumer_secret"] = v }
        opts.on("--oauth-token=token", String, "Specifies the OAuth token to use.") { |v| OPTIONS["oauth.token"] = v }
        opts.on("--oauth-token-secret=token-secret", String, "Specifies the OAuth token secret to use.") { |v| OPTIONS["oauth.token_secret"] = v }
        opts.on("--node=node", String, "Specifies the PubSub node to use.") { |v| OPTIONS["pubsub.node"] = v }
        opts.on("--server=server", String, "Specifies the PubSub server to use.") { |v| OPTIONS["pubsub.server"] = v }
      end
    end
  end
end