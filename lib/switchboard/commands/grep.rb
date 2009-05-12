module Switchboard
  module Commands
    class Grep < Switchboard::Command
      description "Search for an XPath expression"

      def self.run!
        expr = ARGV.pop

        switchboard = Switchboard::Client.new
        switchboard.plug!(AutoAcceptJack, NotifyJack)

        switchboard.on_stanza do |stanza|
          # TODO doesn't handle default namespaces properly
          REXML::XPath.each(stanza, expr) do |el|
            puts el.to_s
          end
        end

        switchboard.run!
      end
    end
  end
end
