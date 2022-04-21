# frozen_string_literal: true

require 'vcr'
require 'minispec-metadata'
require 'minitest-vcr'
require 'webmock/minitest'

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
  c.debug_logger = File.open('log/vcr.log', 'w')
end

MinitestVcr::Spec.configure!
