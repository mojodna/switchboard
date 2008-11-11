#!/usr/bin/env ruby
require 'fire_hydrant'
require 'switchboard'

require 'optparse'

OPTIONS = {
  :detach  => false,
  :verbose => false
}

puts Switchboard::COMMANDS.inspect

ARGV.clone.options do |opts|
  # opts.banner = "Usage: example.rb [options]"

  opts.on("-d", "--daemon", "Make server run as a daemon.") { OPTIONS[:detach] = true }
  # opts.on("-l", "--log=path", String, "Specifies a path to log script output.") { |v| OPTIONS[:log] = v }
  # opts.on("-p", "--pidfile=path", String,
  #         "Specifies a pidfile to use.") { |v| OPTIONS[:pidfile] = v }
  opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| OPTIONS[:verbose] = v }

  opts.separator ""

  opts.on_tail("-h", "--help", "Show this help message.") { puts opts; exit }
  opts.on_tail("--version", "Show version") { puts VERSION; exit }

  cmd = []
  argv = []

  # force optparse into being a command parser
  opts.order! do |arg|
    cmd << arg

    if Switchboard::COMMANDS.keys.include?(cmd * "_")
      # run through command-specific options
      Switchboard::COMMANDS[cmd * "_"].options(opts)
    else
      # unrecognized, unclaimed argument; keep as ARGV
      argv << arg
    end
  end

  # correct ARGV to match unrecognized, unclaimed arguments
  ARGV.reject! { |v| !argv.include?(v) }
end
