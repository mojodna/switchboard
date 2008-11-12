#!/usr/bin/env ruby
require 'fire_hydrant'
require 'fireeagle'
require 'yaml'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")), true)
hydrant.plug!(AutoAcceptJack, NotifyJack, OAuthPubSubJack)

hydrant.on_pubsub_event do |event|
  event.payload.each do |payload|
    puts "Node: #{payload.node}"
    payload.elements.each do |item|
      rsp = item.first_element("rsp")
      response = FireEagle::Response.new(rsp.to_s)
      user = response.users[0]
      # # for some reason the Fire Eagle gem doesn't let me do this
      name = user.locations[0].instance_eval { @doc.at("//name").innerText }
      puts "#{user.token} has moved to #{name}."
    end
  end
end

hydrant.run!
