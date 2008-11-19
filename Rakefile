require 'switchboard'

task :gemspec do
  gemspec =<<-EOF
Gem::Specification.new do |s|
  s.name = "switchboard"
  s.version = "#{Switchboard::VERSION * "."}"
  s.summary = "XMPP toolkit."
  s.description = "A toolkit for assembling XMPP clients and interacting with XMPP servers."
  s.authors = ["Seth Fitzsimmons"]
  s.email = ["seth@mojodna.net"]

  s.files = #{Dir.glob("**/*").select { |f| File.file?(f) }.inspect}
  s.executables = ["switchboard"]
  s.require_paths = ["lib"]

  s.add_dependency("xmpp4r")
end
  EOF

  open("switchboard.gemspec", "w") do |f|
    f << gemspec
  end

  puts "gemspec successfully created."
end

task :default => :gemspec