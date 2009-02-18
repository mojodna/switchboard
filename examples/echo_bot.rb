#!/usr/bin/env ruby -rubygems

require 'switchboard'

switchboard = Switchboard::Client.new
switchboard.plug!(AutoAcceptJack, EchoJack, NotifyJack)
switchboard.run!
