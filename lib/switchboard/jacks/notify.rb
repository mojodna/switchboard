class NotifyJack
  def self.connect(switchboard)
    switchboard.on_roster_loaded do
      roster.items.each do |jid, item|
        presence(nil, jid)
      end
    end

    switchboard.on_shutdown do
      roster.items.each do |jid, item|
        presence(:unavailable, jid)
      end
    end
  end
end
