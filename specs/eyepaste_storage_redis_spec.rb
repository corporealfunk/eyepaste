require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/email_helper'

require File.dirname(__FILE__) + '/../lib/eyepaste/storage/redis.rb'

describe Eyepaste::Storage::Redis do
  let(:redis) do
    Redis.new(:host => 'localhost',
              :port => 6379
             )
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
    # clean the keys:
    redis.flushdb
    @storage = Eyepaste::Storage::Redis.new(redis)
  end

  describe "#append_email" do
    it "returns true" do
      @storage.append_email('test@eyepaste.com', 'dumb value').should == true
    end
  end

  describe "#get_inbox" do
    context "emails have been added to the inbox" do
      before(:each) do
        @storage.append_email('test@eyepaste.com', emails[:plain_text])
      end

      it "returns a non-empty array of Eyepaste::Email objects" do
        @storage.get_inbox('test@eyepaste.com').should be_kind_of(Array)
        @storage.get_inbox('test@eyepaste.com').count.should > 0
        @storage.get_inbox('test@eyepaste.com')[0].should be_kind_of(Eyepaste::Email)
      end

      it "should contain the email that was appended" do
        @storage.get_inbox('test@eyepaste.com')[0].attributes.should == emails[:plain_text].attributes
      end

    end
  end
end
