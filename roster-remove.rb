#!/usr/bin/env ruby
require 'fire_hydrant'

# TODO extract me into a YAML file
config = {
  "jid"      => "client@memberfresh-lm.local",
  "password" => "client",
  "server"   => "ubuntu.local"
}

hydrant = FireHydrant.new(config, false)

hydrant.on_startup do
  if (items = roster.find(@config[:server])).any?
    item = items.values.first
    puts "Removing #{item.jid.to_s} from my roster..."
    item.remove
  end
end

hydrant.run!
