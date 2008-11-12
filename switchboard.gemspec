Gem::Specification.new do |s|
  s.name = "switchboard"
  s.version = "0.0.1"
  s.summary = "XMPP toolkit"
  s.description = "A toolkit for assembling XMPP clients and interacting with XMPP servers."
  s.authors = ["Seth Fitzsimmons"]
  s.email = ["seth@mojodna.net"]

  s.files = Dir.glob(File.join("**", "*"))
  s.executables = ["switchboard"]
  s.require_paths = ["lib"]

  s.add_dependency("xmpp4r")
end