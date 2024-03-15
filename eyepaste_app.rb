require 'sinatra'

require File.dirname(__FILE__) + '/config.rb'

set :haml, :format => :html5

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

    get %r{/inbox/(.*?)(\.rss|\.json)?} do
      _set_host_and_port
      storage = Eyepaste::Storage.factory
      @inbox = params[:captures].first

      sort_map = {
        "asc" => :asc,
        "desc" => :desc
      }

      sort = sort_map[params["sort"]]

      inbox_params = {
        sort: sort,
        limit: params["limit"] == nil ? nil : params["limit"].to_i,
        start: params["start"] == nil ? nil : params["start"].to_i
      }.compact

      @emails = storage.get_inbox(
        "#{params[:captures].first}",
        inbox_params
      )

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
