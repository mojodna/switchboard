#!/usr/bin/env ruby

require 'yaml'
require 'rubygems'
# work-around for a bug in oauth 0.2.4
require 'oauth/helper'
require 'fireeagle'

# read the configuration
config = YAML.load(open("fire_hydrant.yml").read)

if config.has_key?("oauth_token") && config.has_key?("oauth_token_secret")
  puts "Application has already been authorized."
  exit
end

# initialize a Fire Eagle client
client = FireEagle::Client.new \
  :consumer_key => config["oauth_consumer_key"],
  :consumer_secret => config["oauth_consumer_secret"]

## Step 1 - Get a request token

client.get_request_token

## Step 2 - Ask the user to authorize the application, using that request token

puts "Please authorize this application:"
puts " #{client.authorization_url}"
print "<waiting>"
gets

## Step 3 - Convert the request token into an access token

client.convert_to_access_token

puts "Your OAuth token is: #{client.access_token.token}"
puts "Your OAuth token secret is: #{client.access_token.secret}"
