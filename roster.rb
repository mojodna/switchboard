#!/usr/bin/env ruby

$: << File.join(File.dirname(__FILE__), "lib", "fire_hydrant")

require 'fire_hydrant'

# TODO extract me into a YAML file
config = {
  "jid"      => "client@memberfresh-lm.local",
  "password" => "client",
}

hydrant = FireHydrant.new(config, false)

def hydrant.on_startup
  super

  if roster.items.any?
    puts "My roster contains: #{roster.items.keys.map { |jid| jid.to_s } * ", "}"
  end
end

hydrant.run!
