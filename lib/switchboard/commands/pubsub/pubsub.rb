module Switchboard
  module Commands
    class PubSub < Switchboard::Command
      description "Pubsub node manipulation"

      def self.help
        "These are the more extensive instructions for using the pubsub command."
      end

      def self.options(opts)
        super(opts)
        opts.on("--oauth", "Sign requests using OAuth.") { OPTIONS[:oauth] = true }
      end
    end
  end
end