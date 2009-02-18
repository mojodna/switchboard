class EchoJack
  def self.connect(switchboard, settings)
    switchboard.on_message do |message|
      stream.send(message.answer)
    end
  end
end
