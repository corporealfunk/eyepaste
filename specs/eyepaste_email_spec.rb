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
        @email_multi_part = Eyepaste::Email.parse_raw_email(email_multipart_content)
      end

      it "sets the raw_header attribute" do
        @email.raw_headers.should_not be_nil
      end

      it "sets the decoded_body attribute" do
        @email.decoded_body.should_not be_nil
      end

      it "has no parts" do
        @email.parts.count.should == 0
      end

      context "plain email" do
        it "returns the email header to: field" do
          @email.to.to_s.should == "notarealaddress@gmail.com"
        end
      end

      context "multi part email" do
        it "returns the email header to: field" do
          @email_multi_part.to.to_s.should == "notarealaddress@gmail.com"
        end
      end
    end

    context "a multi part email" do
      let(:email_content) do
        File.open(EMAILS[:multi_part], 'rb') { |f| f.read }
      end

      before(:each) do
        @email = Eyepaste::Email.parse_raw_email(email_content)
      end

      it "has two parts" do
        @email.parts.count.should == 2
      end

      it "returns the plain text part of the body" do
        @email.plain_text.should_not be_nil
        @email.plain_text.should_not =~ /href=/
        @email.plain_text.should =~ /Top 10 destinations for 2012/
      end

      it "returns the html text part of the body" do
        @email.html.should_not be_nil
        @email.html.should =~ /href=/
      end

      it "can encode the attributes as json" do
        @email.attributes.to_json.should be_kind_of(String)
      end
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

    it "returns the parts correctly" do
      @email.attributes[:parts].should == @email.parts
    end

    it "returns the to correctly" do
      @email.attributes[:to].should == @email.to
    end
  end

  describe "#initialize" do
    context "attributes passed as symbols as keys" do
      it "sets attributes internally" do
        email = Eyepaste::Email.new(:raw_headers => 'headers',
                                    :decoded_body => 'body',
                                    :to => 'me@me.com',
                                    :parts => {
                                      :plain => 'plain',
                                      :html => 'html' }
                                   )
        email.raw_headers.should == 'headers'
        email.decoded_body.should == 'body'
        email.parts[:plain].should == 'plain'
        email.parts[:html].should == 'html'
        email.to.should == 'me@me.com'
      end
    end

    context "attributes passed as symbols as strings" do
      it "sets attributes internally" do
        email = Eyepaste::Email.new('raw_headers' => 'headers',
                                    'decoded_body' => 'body',
                                    'to' => 'me@me.com',
                                    'parts' => {
                                      'plain' => 'plain',
                                      'html' => 'html' }
                                   )
        email.raw_headers.should == 'headers'
        email.decoded_body.should == 'body'
        email.parts['plain'].should == 'plain'
        email.parts['html'].should == 'html'
        email.to.should == 'me@me.com'
      end
    end
  end
end
