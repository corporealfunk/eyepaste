require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/email_helper'
require 'rack/test'

require File.dirname(__FILE__) + '/../eyepaste_app.rb'
require File.dirname(__FILE__) + '/../config.rb'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

set :environment, :test

def app
  Eyepaste::App
end

describe 'Eyepaste Site' do
  let(:storage) do
    Eyepaste::Storage.factory
  end

  let(:emails) do
    emails = {} 
    EMAILS.each do |key, path|
      content = File.open(path, 'rb') { |f| f.read }
      emails[key] = Eyepaste::Email.parse_raw_email(content)
    end

    emails
  end

  before(:each) do
    storage.delete_all
  end

  describe '/' do
    let(:original_domains) { ACCEPTED_DOMAINS }

    # this is a little hacky, but rack-test does
    # not allow you to assign variables in the app
    before(:each) do
      # trigger memoize:
      ACCEPTED_DOMAINS = original_domains

      # reset
      ACCEPTED_DOMAINS = %w[whatme.com]
      get '/'
    end

    after(:each) do
      ACCEPTED_DOMAINS = original_domains
    end

    it 'loads the homepage' do
      last_response.should be_ok
    end

    it 'contains the email domain' do
      last_response.body.should =~ /whatme.com/
    end
  end

  describe '/about.html' do
    it 'loads the about page' do
      get '/about.html'
      last_response.should be_ok
    end
  end

  describe '/inbox/jjm@eyepaste.com' do
    context 'no emails in the box' do
      before(:each) do
        get '/inbox/jjm@eyepaste.com'
      end

      it "displays the inbox email address" do
        last_response.body.should =~ /jjm@eyepaste.com/
      end

      it "displays a message that are no emails" do
        last_response.body.should =~ /no emails found/
      end
    end

    context "emails in the box" do
      context "one address in the to field" do
        before(:each) do
          storage.append_email('jjm@eyepaste.com', emails[:multi_part])
          get '/inbox/jjm@eyepaste.com'
        end

        it "displays the headers" do
          last_response.body.should =~ /notarealaddress/
        end

        describe "the to field" do
          it "displays the address" do
            last_response.body.should =~ /<td>Jon &lt;notarealaddress@gmail.com&gt;<\/td>/
          end
        end
      end

      context "more than one address in the to field" do
        before(:each) do
          storage.append_email('jjm@eyepaste.com', emails[:multiple_tos])
          get '/inbox/jjm@eyepaste.com'
        end

        it "displays the addresses" do
          last_response.body.should =~ /<td>&\#x27;Fake Man&\#x27; &lt;notarealaddress@gmail.com&gt;, &\#x27;Bobby Jones&\#x27; &lt;bobby@eyepaste.com&gt;, inurmailz@eyepaste.com<\/td>/
        end
      end
    end
  end

  describe '/inbox/jjm@eyepaste.com.rss' do
    it "returns a content type for RSS" do
      get '/inbox/jjm@eyepaste.com.rss'
      last_response.content_type.should =~ /application\/rss\+xml/
    end

    context "emails present in the inbox" do
      it "contains an item" do
        storage.append_email('jjm@eyepaste.com', emails[:multi_part])
        storage.append_email('jjm@eyepaste.com', emails[:plain_text])

        get '/inbox/jjm@eyepaste.com.rss'
        last_response.should =~ /item/
        last_response.should =~ /Airbnb/
      end
    end

    context "no emails present in the inbox" do
      it "does not contain an item" do
        get '/inbox/jjm@eyepaste.com.rss'
        last_response.should_not =~ /item/
      end
    end

  end

  describe '/inbox/jjm@eyepaste.com.json' do
    it "returns a content type for JSON" do
      get '/inbox/jjm@eyepaste.com.json'
      last_response.content_type.should =~ /application\/json/
    end

    it "contains the count of emails" do
      storage.append_email('jjm@eyepaste.com', emails[:multi_part])
      storage.append_email('jjm@eyepaste.com', emails[:plain_text])

      get '/inbox/jjm@eyepaste.com.json'
      last_response.should =~ /"count":2/
    end

  end

  describe '404 not found' do
    it "display our custom 404 page" do
      get '/fakepagenotreal'
      last_response.body.should =~ /Page Not Found :\(/
    end
  end
end
