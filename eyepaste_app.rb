module Eyepaste
  class App < Sinatra::Base
    get "/" do
      haml :index
    end

    get "/about.html" do
      haml :about
    end

    get "/inbox/:email_box@eyepaste\.com.?:format" do
      # TODO: write the email storage/retrieval stuff
      # we need to:
      # 1. pull emails for the inbox from storage
      # 2. if html, template that
      # 3. if rss, template that
      # 4. if json, cat them, md5 hash them spit out json with the hash result
      # if not found in storage send to 404
    end
  end
end
