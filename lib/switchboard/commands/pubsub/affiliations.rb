module Switchboard
  module Commands
    class PubSub
      class Affiliations < Switchboard::Command
        description "Lists pubsub affiliations"

        def self.run!
          switchboard = Switchboard::Core.new do
            defer :affiliations_received do
              pubsub.get_affiliations(OPTIONS["pubsub.node"])
            end

            def affiliations_received(affiliations)
              if affiliations
                affiliations.each do |node, affiliation|
                  puts [node, affiliation] * " => "
                end
              else
                puts "No affiliations."
              end
            end
          end

          if OPTIONS["oauth"]
            switchboard.plug!(OAuthPubSubJack)
          else
            switchboard.plug!(PubSubJack)
          end
          switchboard.run!
        end
      end
    end
  end
end