require File.dirname(__FILE__) + '/email.rb'
# the storage factory allows you to write any storage
# backend you like, as long as it adheres to the storage
# interface. Once you have a a storage engine/class written,
# you can always get it out of the storage factory by first
# setting a storage factory that is just a block of code that
# sets up your storage engine and returns a new instance, 
# for example:
#
# Eyepaste::Storage.set_factory do
#   MyCustomKyotoCabinetStorageEngine.new(
#     :server => 'localhost',
#     :port => '9099'
#   )
# end
#
# any time you need that storage engine:
#
# storage = Eyepaste::Storage.factory
#
module Eyepaste
  module Storage
    @factory_block = Proc.new { nil }

    def self.set_factory(&block)
      @factory_block = block
    end

    def self.factory
      @factory_block.call
    end
  end
end
