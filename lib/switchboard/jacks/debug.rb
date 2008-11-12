require 'switchboard/colors'

class DebugJack
  def self.connect(switchboard)
    switchboard.on_presence do |presence|
      puts "<< #{presence.to_s}".green
    end

    switchboard.on_message do |message|
      puts "<< #{message.to_s}".blue
    end

    switchboard.on_iq do |iq|
      puts "<< #{iq.to_s}".yellow
    end
  end
end
