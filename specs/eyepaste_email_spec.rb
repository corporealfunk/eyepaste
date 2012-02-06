require 'json'

require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/email_helper'

describe Eyepaste::Email do
  describe "#parse_raw_email" do
    it "returns Eyepaste::Email object" do
      Eyepaste::Email.parse_raw_email('email content').should be_a(Eyepaste::Email)
    end

    context "a plain text email" do
      let(:email_plain_content) do
        File.open(EMAILS[:plain_text], 'r+b') { |f| f.read }
      end

      let(:email_multipart_content) do
        File.open(EMAILS[:multi_part], 'r+b') { |f| f.read }
      end

      before(:each) do
        @email = Eyepaste::Email.parse_raw_email(email_plain_content)
      end

      it "sets the raw_header attribute" do
        @email.raw_headers.should_not be_nil
      end

      it "sets the decoded_body attribute" do
        @email.decoded_body.should_not be_nil
      end

      it "returns the email header to: field" do
        @email.to.to_s.should == "notarealaddress@gmail.com"
      end

      it "returns the email header from: field" do
        @email.from.to_s.should == 'Linode Alerts <noreply@linode.com>'
      end

      it "sets the date attribute" do
        @email.date.should == 'Tue, 31 Jan 2012 08:22:43 -0500'
      end

      it "sets the subject attribute" do
        @email.subject.should == 'Linode Alert - CPU Usage - ubuntu (linode411)'
      end
    end

    context "a multi part email" do
      let(:email_content) do
        File.open(EMAILS[:multi_part], 'rb') { |f| f.read }
      end

      before(:each) do
        @email = Eyepaste::Email.parse_raw_email(email_content)
      end

      it "returns the email header to: field" do
        @email.to.to_s.should == "notarealaddress@gmail.com"
      end

      it "can encode the attributes as json" do
        @email.attributes.to_json.should be_kind_of(String)
      end

      it "sets the date attribute" do
        @email.date.should == 'Wed, 01 Feb 2012 05:33:49 +1100'
      end

      it "returns the email header from: field" do
        @email.from.to_s.should == 'Airbnb <automated@airbnb.com>'
      end

    end
  end

  context "an encoding problematic email when multipart" do
    let(:email_content) do
      File.open(EMAILS[:encoding_problem], 'rb') { |f| f.read }
    end

    it "can encode the attributes as json" do
      @email = Eyepaste::Email.parse_raw_email(email_content)
      @email.attributes.to_json.should be_kind_of(String)
    end
  end

  context "an encoding problematic email when single part" do
    let(:email_content) do
      File.open(EMAILS[:xd3_conversion], 'rb') { |f| f.read }
    end

    it "can encode the attributes as json" do
      @email = Eyepaste::Email.parse_raw_email(email_content)
      @email.attributes.to_json.should be_kind_of(String)
    end
  end

  describe "#attributes" do
    let(:email_content) do
      File.open(EMAILS[:plain_text], 'rb') { |f| f.read }
    end

    before(:each) do
      @email = Eyepaste::Email.parse_raw_email(email_content)
    end

    it "returns all the attributes in a hash" do
      @email.attributes.should be_kind_of(Hash)
    end

    it "returns the raw_headers correctly" do
      @email.attributes[:raw_headers].should == @email.raw_headers
    end

    it "returns the decoded_body correctly" do
      @email.attributes[:decoded_body].should == @email.decoded_body
    end

    it "returns the to correctly" do
      @email.attributes[:to].should == @email.to
    end

    it "returns the date correctly" do
      @email.attributes[:date].should == @email.date
    end

    it "returns the subject correctly" do
      @email.attributes[:subject].should == @email.subject
    end

    it "returns the from correctly" do
      @email.attributes[:from].should == @email.from
    end
  end

  describe "#initialize" do
    context "attributes passed as symbols as keys" do
      it "sets attributes internally" do
        email = Eyepaste::Email.new(:raw_headers => 'headers',
                                    :decoded_body => 'body',
                                    :to => 'me@me.com',
                                    :from => 'you@you.com',
                                    :date => 'Wed, 01 Feb 2012 05:33:49 +1100',
                                    :subject => 'my subject'
                                   )
        email.raw_headers.should == 'headers'
        email.decoded_body.should == 'body'
        email.to.should == 'me@me.com'
        email.from.should == 'you@you.com'
        email.date.should == 'Wed, 01 Feb 2012 05:33:49 +1100'
        email.subject.should == 'my subject'
      end
    end

    context "attributes passed as symbols as strings" do
      it "sets attributes internally" do
        email = Eyepaste::Email.new('raw_headers' => 'headers',
                                    'decoded_body' => 'body',
                                    'to' => 'me@me.com',
                                    'from' => 'you@you.com',
                                    'date' => 'Wed, 01 Feb 2012 05:33:49 +1100',
                                    'subject' => 'my subject'
                                   )
        email.raw_headers.should == 'headers'
        email.decoded_body.should == 'body'
        email.to.should == 'me@me.com'
        email.from.should == 'you@you.com'
        email.date.should == 'Wed, 01 Feb 2012 05:33:49 +1100'
        email.subject.should == 'my subject'
      end
    end
  end
end
