#!/usr/bin/env ruby
require 'fire_hydrant'
require 'fireeagle'
require 'appscript'

earth = Appscript.app("Google Earth")

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml")).merge("jid" => "fire_hydrant@jabber.org/visualizer"), true)
hydrant.jack!(AutoAcceptJack, NotifyJack, OAuthPubSubJack)

hydrant.on_pubsub_event do |event|
  event.payload.each do |payload|
    puts "Node: #{payload.node}"
    payload.elements.each do |item|
      rsp = item.first_element("rsp")
      response = FireEagle::Response.new(rsp.to_s)
      user = response.users[0]
      # for some reason the Fire Eagle gem doesn't let me do this
      begin
        name = user.locations[0].instance_eval { @doc.at("//name").innerText }
        geom = user.locations[0].geom
        puts "#{user.token} has moved to #{name}."
        pt = geom.is_a?(GeoRuby::SimpleFeatures::Envelope) ? geom.center : geom
        earth.SetViewInfo({:latitude => pt.y, :longitude => pt.x, :distance => (rand * 25000) + 5000, :azimuth => rand * 360, :tilt => (rand * 75)}, {:speed => 1})
      rescue
      end
    end
  end
end

hydrant.run!
