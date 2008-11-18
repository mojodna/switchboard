require 'switchboard/helpers/pubsub'

class PubSubJack
  def self.connect(switchboard, settings)
    # TODO generalize this pattern for required settings
    unless settings["pubsub.server"]
      puts "A pubsub server must be specified."
      return false
    end

    switchboard.extend(Switchboard::Helpers::PubSubHelper)

    switchboard.on_startup do
      @pubsub = Jabber::PubSub::ServiceHelper.new(client, settings["pubsub.server"])

      @pubsub.add_event_callback do |event|
        on(:pubsub_event, event)
      end
    end
  end
end
