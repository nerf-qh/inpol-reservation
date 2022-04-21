# frozen_string_literal: true

require 'pry'
require './inpol'

require 'minitest/autorun'
require 'mocha/minitest'

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |rb| require(rb) }
