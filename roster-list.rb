#!/usr/bin/env ruby
require 'fire_hydrant'
require 'fire_hydrant/jacks/auto_accept_jack'
require 'fire_hydrant/jacks/debug_jack'
require 'fire_hydrant/jacks/roster_debug_jack'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")), false)

hydrant.on_startup do
  if roster.items.any?
    puts "#{@config[:jid]}'s roster:"
    puts roster.items.keys.map { |jid| jid.to_s } * "\n"
  else
    puts "#{@config[:jid]}'s roster is empty."
  end
end

hydrant.jack(AutoAcceptJack, DebugJack, RosterDebugJack)

hydrant.run!
