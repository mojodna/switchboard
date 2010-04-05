module Switchboard
  module Helpers
    module MUCHelper
      attr_reader :muc

      Switchboard::Core.hook(:muc_join, :muc_leave, :muc_message, :muc_private_message, :muc_room_message, :muc_self_leave, :muc_subject_change)
    end
  end
end

