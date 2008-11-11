#!/usr/bin/env ruby
require 'fire_hydrant'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml"))) do
  if roster.items.any?
    puts "#{@config[:jid]}'s roster:"
    puts roster.items.keys.map { |jid| jid.to_s } * "\n"
  else
    puts "#{@config[:jid]}'s roster is empty."
  end
end

hydrant.jack!(AutoAcceptJack)

hydrant.run!
