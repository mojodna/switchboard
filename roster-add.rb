#!/usr/bin/env ruby
require 'fire_hydrant'
require 'fire_hydrant/jacks/auto_accept_jack'
require 'fire_hydrant/jacks/debug_jack'
require 'fire_hydrant/jacks/roster_debug_jack'

# TODO extract me into a YAML file
config = {
  "jid"      => "client@memberfresh-lm.local",
  "password" => "client",
  "server"   => "ubuntu.local"
}

hydrant = FireHydrant.new(config, false)

hydrant.on_startup do
  # add the server as a contact if it wasn't already added
  if roster.find(@config[:server]).empty?
    puts "Adding #{@config[:server]} to my roster..."
    roster.add(@config[:server], nil, true)
  end
end

hydrant.jack(AutoAcceptJack, DebugJack, RosterDebugJack)

hydrant.run!
