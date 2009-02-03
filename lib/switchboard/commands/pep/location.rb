require 'xmpp4r/location'

module Switchboard
  module Commands
    class PEP
      class Location < Switchboard::Command
        description "Broadcasting UserLocation (XEP-0080)"

        def self.run!
          begin
            require 'fire_hydrant'
          rescue LoadError => e
            lib = e.message.split("--").last.strip
            puts "#{lib} is required for this command to work."
            exit 1
          end

          # TODO check for at least one Fire Eagle subscription, otherwise this
          # will never broadcast anything.

          switchboard = Switchboard::Client.new
          switchboard.plug!(AutoAcceptJack, FireEagleJack)

          switchboard.on_startup do
            @location_helper = Jabber::UserLocation::Helper.new(client, nil)
          end

          switchboard.on_location_update do |user|
            name = user.locations.first
            timestamp = user.locations.first.located_at

            area, postalcode, locality, region, country = nil

            user.locations.each do |loc|
              level = loc.level_name
              normal_name = loc.normal_name
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
