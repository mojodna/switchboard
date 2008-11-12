require 'rubygems'
begin
  require 'switchboard'
rescue LoadError => e
  gem = e.message.split("--").last.strip
  puts "The #{gem} gem is required."
end

class FireHydrant < Switchboard::Core
  # TODO enhance with a default set of jacks
end
