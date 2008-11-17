module Switchboard
  module Commands
    class Register < Switchboard::Command
      description "Register a JID"

      class Registration < Switchboard::Core
        def initialize(settings = Switchboard::Settings.new, spin = false)
          super(settings, false)
        end

      protected

        def auth!
          unless settings["jid"] && settings["password"]
            puts "A JID and password are required to register a new account."
            shutdown(false)
            exit
          end

          # TODO consider using client.register_info.inspect
          begin
            puts "Registering #{settings["jid"]} with password '#{settings["password"]}'."
            iq = client.register(settings["password"])
          rescue Jabber::ServerError => e
            puts "Could not register: #{e}"
            shutdown(false)
            exit 1
          end

          # now log in
          super
        end
      end

      def self.run!
        Registration.new.run!
      end
    end
  end
end
