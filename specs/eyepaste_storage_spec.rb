require File.dirname(__FILE__) + '/spec_helper'

require File.dirname(__FILE__) + '/../lib/eyepaste/storage.rb'

describe Eyepaste::Storage do
  context "a factory has been set" do
    before(:each) {
      Eyepaste::Storage.set_factory { 'i am a useless factory' }
    }

    it "returns what the factory block sets up" do
      Eyepaste::Storage.factory.should == 'i am a useless factory'
    end
  end
end
