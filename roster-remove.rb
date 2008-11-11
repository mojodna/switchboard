#!/usr/bin/env ruby
require 'fire_hydrant'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml"))) do
  ARGV.each do |jid|
    if (items = roster.find(jid)).any?
      item = items.values.first
      puts "Removing #{item.jid.to_s} from my roster..."
      item.remove
    end
  end
end

hydrant.run!
