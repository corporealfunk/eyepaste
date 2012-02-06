require 'sinatra'

require File.dirname(__FILE__) + '/config.rb'

module Eyepaste
  class App < ::Sinatra::Base
    get "/" do
      @host = request.host
      @port = request.port
      haml :index
    end

    get "/about.html" do
      haml :about
    end

    get %r{/inbox/(.+)(\.rss)?} do
      storage = Eyepaste::Storage.factory
      @inbox = params[:captures].first
      @emails = storage.get_inbox("#{params[:captures].first}")

      haml :inbox
    end

    not_found do
      haml :error_404, :layout => false
    end
  end
end
