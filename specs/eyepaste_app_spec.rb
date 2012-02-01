require File.dirname(__FILE__) + '/spec_helper'
require 'rack/test'

require File.dirname(__FILE__) + '/../eyepaste_app.rb'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

set :environment, :test

def app
  Eyepaste::App
end

describe 'Eyepaste Site' do
  it 'loads the homepage' do
    get '/'
    last_response.should be_ok
  end

  it 'loads the about page' do
    get '/about.html'
    last_response.should be_ok
  end
end
