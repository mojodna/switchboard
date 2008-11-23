require 'rubygems'
require 'xmpp4r/tune'

module Switchboard
  module Commands
    class PEP
      class Tune < Switchboard::Command
        description "Broadcasting UserTune (XEP-0118)"

        def self.run!
          begin
            require 'appscript'
          rescue LoadError => e
            gem = e.message.split("--").last.strip
            puts "The #{gem} gem is required for this command to work."
            exit 1
          end

          switchboard = Switchboard::Client.new do
            @tune_helper = Jabber::UserTune::Helper.new(client, nil)

            itunes = Appscript.app('iTunes')
            old_track_info = nil
            last_state = :paused

            while !shutdown?
              track = itunes.current_track.get
              state = itunes.player_state.get

              if track && state == :playing

                artist = track.artist.get
                name = track.name.get
                source = track.album.get
                track_info = [artist, name, source]

                if track_info != old_track_info
                  duration = track.duration.get.to_i
                  track = track.track_number.get.to_s

                  puts "Now playing: #{name} by #{artist}"
                  tune = Jabber::UserTune::Tune.new \
                    artist,
                    name,
                    duration,
                    track,
                    source

                  begin
                    @tune_helper.now_playing(tune)
                  rescue Jabber::ServerError => e
                    puts e
                  end
                end

              elsif state != last_state
                track_info = nil
                begin
                  @tune_helper.stop_playing
                rescue Jabber::ServerError => e
                  puts e
                end
              end

              old_track_info = track_info
              last_state = state
              sleep 1
            end
          end

          switchboard.on_shutdown do
            begin
              @tune_helper.stop_playing
            rescue Jabber::ServerError => e
              puts e
            end
          end

          switchboard.plug!(AutoAcceptJack)

          switchboard.run!
        end
      end
    end
  end
end
