#!/usr/bin/env ruby
require 'fire_hydrant'

# TODO extract me into a YAML file
config = {
  "jid"      => "client@memberfresh-lm.local",
  "password" => "client"
}

hydrant = FireHydrant.new(config, false)

hydrant.on_startup do
  if roster.items.any?
    puts "#{@config[:jid]}'s roster contains: #{roster.items.keys.map { |jid| jid.to_s } * ", "}"
  else
    puts "#{@config[:jid]}'s roster is empty."
  end
end

hydrant.run!
