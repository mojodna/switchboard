module Switchboard
  module Commands
    class Unregister < Switchboard::Command
      description "Unregister a JID"

      def self.run!
        switchboard = Switchboard::Core.new do
          begin
            client.remove_registration
          rescue Jabber::ServerError => e
            puts "Could not unregister #{settings["jid"]}: #{e}"
            shutdown(false)
            exit 1
          end
        end

        switchboard.run!
      end
    end
  end
end
