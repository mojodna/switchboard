module Switchboard
  module Commands
    class Roster
      class Online < Switchboard::Command
        description "List online members of your roster"

        def self.run!
          switchboard = Switchboard::Client.new do
            puts "Collecting presences..."
            sleep 5
            roster.items.each do |jid, item|
              next unless item.online?
              puts "#{item.jid}:"
              item.each_presence do |presence|
                status = [presence.show, presence.status].compact * " - "
                status = "available" if status == ""
                puts "  /#{presence.from.resource} (#{status}) [#{presence.priority}]"
              end
            end
          end

          switchboard.plug!(AutoAcceptJack)
          switchboard.run!
        end
      end
    end
  end
end