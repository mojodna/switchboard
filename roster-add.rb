#!/usr/bin/env ruby
require 'fire_hydrant'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml"))) do
  # add the server as a contact if it wasn't already added
  ARGV.each do |jid|
    if roster.find(jid).empty?
      puts "Adding #{jid} to my roster..."
      roster.add(jid, nil, true)
    end
  end
end

hydrant.jack!(AutoAcceptJack, DebugJack, RosterDebugJack)

hydrant.run!
