module Switchboard
  module Commands
    class PubSub
      class Listen < Switchboard::Command
        description "Listens for pubsub events"

        def self.run!
          switchboard = Switchboard::Core.new
          switchboard.plug!(PubSubJack)

          switchboard.on_pubsub_event do |event|
            puts event.to_s
          end

          switchboard.run!
        end
      end
    end
  end
end
