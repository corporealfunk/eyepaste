require File.dirname(__FILE__) + '/spec_helper'

require File.dirname(__FILE__) + '/../lib/eyepaste/storage.rb'

describe Eyepaste::Storage do
  # this isn't great because these
  # tests depend on order, the "it returns nil"
  # test will only pass if no other storage factory
  # has been set yet. Not sure how to get around that
  context "a factory has not been set" do
    it "returns nil" do
      Eyepaste::Storage.factory.should be_nil
    end
  end

  context "a factory has been set" do
    before(:each) {
      Eyepaste::Storage.set_factory { 'i am a useless factory' }
    }

    it "returns what the factory block sets up" do
      Eyepaste::Storage.factory.should == 'i am a useless factory'
    end
  end
end
