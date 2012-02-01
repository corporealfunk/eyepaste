require File.dirname(__FILE__) + '/spec_helper'

require File.dirname(__FILE__) + '/../lib/eyepaste/email.rb'

path_to_emails = File.dirname(__FILE__) + '/emails'
emails = {
  :plain_text => "#{path_to_emails}/plain_text.eml",
  :multi_part => "#{path_to_emails}/multi_part.eml"
}


describe Eyepaste::Email do
  describe "#parse_raw_email" do
    it "returns Eyepaste::Email object" do
      Eyepaste::Email.parse_raw_email('email content').should be_a(Eyepaste::Email)
    end

    context "a plain text email" do
      let(:email_content) do
        File.open(emails[:plain_text], 'rb') { |f| f.read }
      end

      before(:each) do
        @email = Eyepaste::Email.parse_raw_email(email_content)
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
    end

    context "a multi part email" do
      let(:email_content) do
        File.open(emails[:multi_part], 'rb') { |f| f.read }
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
    end
  end
end
