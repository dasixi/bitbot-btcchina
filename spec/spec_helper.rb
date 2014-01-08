require 'rubygems'
require 'bundler/setup'
require 'vcr'

require 'bitbot'
require_relative '../lib/bitbot-btcchina'

class Settings
  class << self
    def rate; 6.06 end
  end
end

module VCRMatcher
  def body_matcher
    lambda do |req1, req2|
      body1 = JSON.parse(req1.body)
      body2 = JSON.parse(req2.body)
      body1['method'] == body2['method'] && body1['params'] == body2['params']
    end
  end
end

RSpec.configure do |c|
  c.include VCRMatcher
end


VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  #c.debug_logger = STDOUT

  c.filter_sensitive_data('KEY') do |interaction|
    unless interaction.request.body.empty?
      body = JSON.parse(interaction.request.body)
      body['accesskey']
    end
  end
end
