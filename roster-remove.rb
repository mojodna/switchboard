#!/usr/bin/env ruby
require 'fire_hydrant'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")), false)

hydrant.on_startup do
  if (items = roster.find(@config[:server])).any?
    item = items.values.first
    puts "Removing #{item.jid.to_s} from my roster..."
    item.remove
  end
end

hydrant.run!
