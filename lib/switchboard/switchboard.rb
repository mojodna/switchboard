require 'rubygems'
begin
  require 'oauth'
rescue LoadError => e
end

require 'switchboard/core'
require 'switchboard/client'
require 'switchboard/component'
require 'switchboard/jacks'
require 'switchboard/settings'
require 'switchboard/version'
