module Switchboard
  class Component < Core
    attr_reader :component

    def initialize(settings = Switchboard::Settings.new, spin = true)
      super(settings, spin)

      @component = Jabber::Component.new(settings["component.domain"])
    end

  protected

    def auth!
      component.auth(settings["component.secret"])
    rescue Jabber::AuthenticationFailure
      puts "Component authentication failed. Check your secret."
      shutdown(false)
      exit 1
    end

    def connect!
      component.connect(settings["component.host"], settings["component.port"])
      auth!
      puts "Component connected." if debug?
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
      puts "Couldn't connect to Jabber server at #{settings["component.host"]}:#{settings["component.host"]}.
            That may mean the Jabber server isn't running or listening on that port,
            or there might be firewall issues. Exiting."
      exit 1
    end

    def stream
      component
    end
  end
end