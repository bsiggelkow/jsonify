require 'json'
require 'benchmark'
require 'bundler'
require 'bundler/setup'
require 'jsonify'
require 'jsonify/tilt'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
end
