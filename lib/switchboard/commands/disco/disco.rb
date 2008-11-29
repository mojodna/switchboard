module Switchboard
  module Commands
    class Disco < Switchboard::Command
      description "Service discovery"

      def self.options(opts)
        super(opts)
        opts.on("--node=node", String, "Specifies the node to query.") { |v| OPTIONS["disco.node"] = v }
        opts.on("--target=target", String, "Specifies the target to query.") { |v| OPTIONS["disco.target"] = v }
      end
    end
  end
end
