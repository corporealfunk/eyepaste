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
    @storage = Eyepaste::Storage::Redis.new(redis)
    @storage.delete_all
  end

  describe "#delete_all" do
    it "removes all emails from storage" do
      @storage.append_email('test@eyepaste.com', Eyepaste::Email.new)
      @storage.count_emails.should == 1
      @storage.delete_all
      @storage.count_emails.should == 0
    end
  end

  describe "#append_email" do
    it "returns true" do
      @storage.append_email('test@eyepaste.com', Eyepaste::Email.new).should == true
    end

    context "strange utf8 characters being stored" do
      it "returns true" do
        @storage.append_email('test@eyepaste.com', emails[:multi_part]).should == true
      end
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

  describe "#count_emails" do
    context "no emails have been stored" do
      it "returns 0 emails have been stored" do
        @storage.count_emails.should == 0
      end
    end

    context "emails have been stored" do
      it "returns that 1 email has been stored" do
        @storage.append_email('test@eyepaste.com', emails[:plain_text])
        @storage.count_emails.should == 1
      end
    end
  end

  describe "#expire_emails_before" do
    it "deletes emails created before the given timestamp" do
      Timecop.freeze(Time.now.utc - 600) do
        @storage.append_email('test@eyepaste.com', emails[:plain_text])
      end
      Timecop.freeze(Time.now.utc - 300) do
        @storage.append_email('bob@eyepaste.com', emails[:plain_text])
      end
      @storage.expire_emails_before(Time.now.utc - 300)
      @storage.count_emails.should == 1
    end
  end
end
