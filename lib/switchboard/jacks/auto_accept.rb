class AutoAcceptJack
  def self.connect(switchboard, settings)
    # complain if subscription requests were denied
    switchboard.on_roster_subscription do |item, subscription|
      unless subscription.type == :subscribed
        puts "My subscription request was denied!"
      end
    end

    # auto-accept subscription requests
    switchboard.on_roster_subscription_request do |item, subscription|
      puts "Accepting subscription from #{subscription.from}"
      roster.accept_subscription(subscription.from)
    end
  end
end
