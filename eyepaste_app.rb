require 'sinatra'

require File.dirname(__FILE__) + '/config.rb'

module Eyepaste
  class App < ::Sinatra::Base
    get "/" do
      _set_host_and_port
      @email_domain = ACCEPTED_DOMAINS.first
      haml :index
    end

    get "/about.html" do
      _set_host_and_port
      haml :about
    end

    get %r{^/inbox/(.*?)(\.rss|\.json)?$} do
      _set_host_and_port
      storage = Eyepaste::Storage.factory
      @inbox = params[:captures].first
      @emails = storage.get_inbox("#{params[:captures].first}")

      case params[:captures][1]
      when nil
        haml :inbox
      when ".rss"
        haml :inbox_rss, :layout => false, :content_type => 'application/rss+xml'
      when ".json"
        content_type 'application/json', :charset => 'utf-8'
        {:count => @emails.length}.to_json
      end
    end

    not_found do
      haml :error_404, :layout => false
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    def _set_host_and_port
      @host = request.host
      @port = request.port
      port_with_colon = (@port.to_s == '80' || @port.to_s == '443') ? '' : ":#{@port}"
      @host_with_port = "#{@host}#{port_with_colon}"
    end
  end
end
