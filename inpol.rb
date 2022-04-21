# frozen_string_literal: true

# require 'bundler/inline'
# require 'json'
# require 'time'

require 'bundler/setup'
Bundler.require

Dotenv.load

puts "USERNAME: #{ENV['USERNAME'].green}"
puts "START_DATE: #{ENV['START_DATE'].green}"

module Inpol; end

require './lib/inpol/api'
require './lib/inpol/checker'
