class RosterDebugJack
  def self.connect(switchboard)
    switchboard.on_roster_presence do |item, old_presence, new_presence|
      puts "[presence] << #{item.inspect}: #{old_presence.to_s}, #{new_presence.to_s}"
    end

    switchboard.on_roster_query do |query|
      puts "[roster query] << #{query.to_s}"
    end

    switchboard.on_roster_subscription do |item, subscription|
      puts "[subscription] << #{item.inspect}: #{subscription.to_s}"
    end

    switchboard.on_roster_subscription_request do |item, subscription|
      puts "[subscription request] << #{item.inspect}: #{subscription.to_s}"
    end

    switchboard.on_roster_update do |old_item, new_item|
      puts "[update] #{old_item.inspect}, #{new_item.inspect}"
    end
  end
end
