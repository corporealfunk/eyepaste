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

  # to test your own storage engine, change the each block below
  # to construct your own storage engine
  before(:each) do
    # clean the keys:
    redis.flushdb
    @storage = Eyepaste::Storage::Redis.new(redis)
  end

  describe "#append_email" do
    it "returns 1" do
      @storage.append_email('test@eyepaste.com', Eyepaste::Email.new).should == 1
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

    context "emails have not been added to the inbox" do
      it "returns empty array" do
        @storage.get_inbox('test@eyepaste.com').should == []
      end
    end
  end

  describe "#expire_emails_before" do
    it "deletes emails created before the given timestamp"
  end
end
