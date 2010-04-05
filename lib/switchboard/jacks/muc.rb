require 'xmpp4r/muc/helper/simplemucclient'
require 'switchboard/helpers/muc'

class MUCJack
  def self.connect(switchboard, settings)
    unless settings["muc.jid"]
      puts "A MUC must be specified."
      return false
    end

    switchboard.extend(Switchboard::Helpers::MUCHelper)

    def switchboard.muc_say(message)
      @muc.say(message)
    end

    switchboard.on_startup do
      @muc = Jabber::MUC::SimpleMUCClient.new(client)

      @muc.on_join do |time, nickname|
        on(:muc_join, time, nickname)
      end

      @muc.on_leave do |time, nickname|
        on(:muc_leave, time, nickname)
      end

      @muc.on_message do |time, sender, text|
        on(:muc_message, time, sender, text)
      end

      @muc.on_private_message do |time, sender, text|
        on(:muc_private_message, time, sender, text)
      end

      @muc.on_room_message do |time, text|
        on(:muc_room_message, time, text)
      end

      @muc.on_self_leave do |time|
        on(:muc_self_leave, time)
      end

      @muc.on_subject do |time, nickname, subject|
        on(:muc_subject_change, time, nickname, subject)
      end

      @muc.join(settings["muc.jid"])
    end
  end
end
