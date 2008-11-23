begin
  require 'fire_hydrant'
rescue LoadError => e
  gem = e.message.split("--").last.strip
  puts "The #{gem} gem is required."
  exit 1
end

require 'xmpp4r/location'

module Switchboard
  module Commands
    class PEP
      class Location < Switchboard::Command
        description "Broadcasting UserLocation (XEP-0080)"

        def self.run!
          switchboard = Switchboard::Client.new
          switchboard.plug!(AutoAcceptJack, FireEagleJack)

          switchboard.on_startup do
            @location_helper = Jabber::UserLocation::Helper.new(client, nil)
          end

          switchboard.on_location_update do |user|
            # for some reason the Fire Eagle gem doesn't work when I access #name directly
            name = user.locations[0].instance_eval { @doc.at("//name").innerText }
            timestamp = Time.parse(user.locations[0].instance_eval { @doc.at("//located-at").innerText })

            area, postalcode, locality, region, country = nil

            user.locations.each do |loc|
              level = loc.instance_eval { @doc.at("//level-name").innerText }
              normal_name = loc.instance_eval { @doc.at("//normal-name").innerText }
              case level
              when "exact"
                street = normal_name
              when "postal"
                postalcode = normal_name
              when "neighborhood"
                area = normal_name
              when "city"
                locality = normal_name
              when "state"
                region = normal_name
              when "country"
                country = normal_name
              end
              puts "level: #{level}"
            end

            puts "Current location: #{name}."

            geom = user.locations[0].geom
            if geom.is_a?(GeoRuby::SimpleFeatures::Envelope)
              pt = geom.center
              accuracy = geom.upper_corner.spherical_distance(geom.lower_corner) / 2
            else
              pt = geom
              accuracy = 0
            end

            location = Jabber::UserLocation::Location.new \
              "accuracy"    => accuracy,
              "area"        => area,
              "country"     => country,
              "description" => name,
              "lat"         => pt.lat,
              "locality"    => locality,
              "lon"         => pt.lon,
              "postalcode"  => postalcode,
              "region"      => region,
              "street"      => street,
              "timestamp"   => timestamp

            # parsing thread is still running, so the send needs to be deferred
            defer :location_sent do
              @location_helper.current_location(location)
            end
          end

          switchboard.on_shutdown do
            begin
              @location_helper.stop_publishing
            rescue Jabber::ServerError => e
              puts e
            end
          end

          switchboard.run!
        end
      end
    end
  end
end
