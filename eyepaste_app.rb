module Eyepaste
  class App < Sinatra::Base
    get "/" do
      haml :index
    end

    get "/about" do
    end

    get "/inbox/:email.?:format" do

    end
  end
end
