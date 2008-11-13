Gem::Specification.new do |s|
  s.name = "switchboard"
  s.version = "0.0.2"
  s.summary = "XMPP toolkit"
  s.description = "A toolkit for assembling XMPP clients and interacting with XMPP servers."
  s.authors = ["Seth Fitzsimmons"]
  s.email = ["seth@mojodna.net"]

  s.files = ["bin", "bin/switchboard", "examples/election_results.rb", "github-test.rb", "lib", "lib/switchboard", "lib/switchboard/colors.rb", "lib/switchboard/commands", "lib/switchboard/commands/command.rb", "lib/switchboard/commands/config", "lib/switchboard/commands/config/config.rb", "lib/switchboard/commands/config.rb", "lib/switchboard/commands/default.rb", "lib/switchboard/commands/help", "lib/switchboard/commands/help/help.rb", "lib/switchboard/commands/help.rb", "lib/switchboard/commands/pubsub", "lib/switchboard/commands/pubsub/pubsub.rb", "lib/switchboard/commands/pubsub/subscribe.rb", "lib/switchboard/commands/pubsub/subscriptions.rb", "lib/switchboard/commands/pubsub/unsubscribe.rb", "lib/switchboard/commands/pubsub.rb", "lib/switchboard/commands/roster", "lib/switchboard/commands/roster/add.rb", "lib/switchboard/commands/roster/list.rb", "lib/switchboard/commands/roster/remove.rb", "lib/switchboard/commands/roster/roster.rb", "lib/switchboard/commands/roster.rb", "lib/switchboard/commands.rb", "lib/switchboard/core.rb", "lib/switchboard/instance_exec.rb", "lib/switchboard/jacks", "lib/switchboard/jacks/auto_accept.rb", "lib/switchboard/jacks/debug.rb", "lib/switchboard/jacks/notify.rb", "lib/switchboard/jacks/oauth_pubsub.rb", "lib/switchboard/jacks/pubsub.rb", "lib/switchboard/jacks/roster_debug.rb", "lib/switchboard/jacks.rb", "lib/switchboard/oauth", "lib/switchboard/oauth/request_proxy", "lib/switchboard/oauth/request_proxy/mock_request.rb", "lib/switchboard/settings.rb", "lib/switchboard/switchboard.rb", "lib/switchboard/version.rb", "lib/switchboard/xmpp4r", "lib/switchboard/xmpp4r/pubsub", "lib/switchboard/xmpp4r/pubsub/helper", "lib/switchboard/xmpp4r/pubsub/helper/oauth_service_helper.rb", "lib/switchboard.rb", "README.markdown", "switchboard-0.0.1.gem", "switchboard.gemspec"]
  s.executables = ["switchboard"]
  s.require_paths = ["lib"]

  s.add_dependency("xmpp4r")
end
