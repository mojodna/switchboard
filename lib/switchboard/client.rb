module Switchboard
  class Client < Core
    attr_reader :client, :roster

    def initialize(settings = Switchboard::Settings.new, spin = true)
      super(settings, spin)

      # TODO jid may already have a resource, so account for that
      @client = Jabber::Client.new([settings["jid"], settings["resource"]] * "/")

      on_stream_connected do
        register_roster_callbacks

        # tell others that we're online
        presence

        defer :roster_loaded do
          # wait for the roster to load
          roster.wait_for_roster

          # roster has now been loaded
          on(:roster_loaded)
        end
      end
    end

    def on_roster_presence(&block)
      register_hook(:roster_presence, &block)
    end

    def on_roster_query(&block)
      register_hook(:roster_query, &block)
    end

    def on_roster_subscription(&block)
      register_hook(:roster_subscription, &block)
    end

    def on_roster_subscription_request(&block)
      register_hook(:roster_subscription_request, &block)
    end

    def on_roster_loaded(&block)
      register_hook(:roster_loaded, &block)
    end

    def on_roster_update(&block)
      register_hook(:roster_update, &block)
    end

  protected

    def auth!
      client.auth(settings["password"])
      @roster = Jabber::Roster::Helper.new(client)
    rescue Jabber::ClientAuthenticationFailure => e
      puts "Could not authenticate as #{settings["jid"]}"
      shutdown(false)
      exit 1
    end

    def connect!
      client.connect
      auth!
    end

    def disconnect!
      presence(:unavailable)
      client.close
    end

    def presence(status = nil, to = nil)
      presence = Jabber::Presence.new(nil, status)
      presence.to = to
      client.send(presence)
    end

    def register_roster_callbacks
      # presence from someone on my roster
      roster.add_presence_callback do |item, old_presence, new_presence|
        on(:roster_presence, item, old_presence, new_presence)
      end

      # roster query completed (rarely used)
      roster.add_query_callback do |query|
        on(:roster_query, query)
      end

      # roster subscription
      roster.add_subscription_callback do |item, presence|
        # confirmation that we were able to subscribe to someone else
        on(:roster_subscription, item, presence)
      end

      roster.add_subscription_request_callback do |item, presence|
        # someone wants to subscribe to me!
        on(:roster_subscription_request, item, presence)
      end

      # roster was updated (rarely used)
      roster.add_update_callback do |old_item, new_item|
        # roster has been updated; don't care
        # puts "update: #{old_item.inspect}, #{new_item.inspect}"
        on(:roster_update, old_item, new_item)
      end
    end

    def stream
      client
    end
  end
end