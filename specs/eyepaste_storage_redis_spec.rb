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
    @storage = Eyepaste::Storage::Redis.new(redis)
    #set up which domains to store email for
    @storage.accepted_domains = %w[eyepaste.com gmail.com]

    # clean the keys:
    @storage.delete_all
  end

  describe "#accepted_domains=" do
    it "sets an acceptable domain as a string, stores as array" do
      @storage.accepted_domains = 'whatme.com'
      @storage.accepted_domains.should be_an(Array)
      @storage.accepted_domains.length.should == 1
    end

    it "sets an acceptable domain as a array, stores as array" do
      @storage.accepted_domains = %w[whatme.com whoyou.com]
      @storage.accepted_domains.should be_an(Array)
      @storage.accepted_domains.length.should == 2
    end
  end

  describe "#delete_all" do
    it "removes all emails from storage" do
      @storage.append_email('test@eyepaste.com', Eyepaste::Email.new)
      expect {
        @storage.delete_all
      }.to change{ @storage.count_emails }.from(1).to(0)
    end
  end

  describe "#append_email" do
    let(:inbox) { 'test@eyepaste.com' }

    it "appends the email" do
      expect {
        @storage.append_email(inbox, Eyepaste::Email.new)
      }.to change{ @storage.count_emails }.by 1
    end

    context "array passed as inbox" do
      let(:inbox) { %w[test@eyepaste.com yoyo@eyepaste.com] }

      it "appends the emails" do
        expect {
          @storage.append_email(inbox, Eyepaste::Email.new)
        }.to change{ @storage.count_emails }.by 2
      end
    end

    context "nil passed as inbox" do
      let(:inbox) { nil }

      it "does not append the email" do
        expect {
          @storage.append_email(inbox, Eyepaste::Email.new)
        }.to_not change{ @storage.count_emails }
      end
    end

    context "empty string passed as inbox" do
      let(:inbox) { '' }

      it "does not append the email" do
        expect {
          @storage.append_email(inbox, Eyepaste::Email.new)
        }.to_not change{ @storage.count_emails }
      end
    end

    context "unacceptable domain in inbox" do
      let(:inbox) { 'wah@example.com' }

      before(:each) do
        @storage.accepted_domains = 'eyepaste.com'
      end

      it "does not append the email" do
        expect {
          @storage.append_email(inbox, Eyepaste::Email.new)
        }.to_not change{ @storage.count_emails }
      end

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
