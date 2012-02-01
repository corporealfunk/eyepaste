require 'rubygems'
require 'bundler'

Bundler.require

RSpec.configure do |conf|
  conf.mock_with :rspec
  conf.color_enabled = true
end

