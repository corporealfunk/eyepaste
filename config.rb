require File.dirname(__FILE__) + '/lib/eyepaste/storage'
require File.dirname(__FILE__) + '/lib/eyepaste/storage/redis'

# configure the storage engine:
Eyepaste::Storage.set_factory do
  redis = ::Redis.new(:host => "127.0.0.1", :port => 6379)
  Eyepaste::Storage::Redis.new(redis)
end

# configure the logger:
LOGGER = Logging.logger['eyepaste_log']
LOGGER.add_appenders(
  Logging.appenders.file(File.dirname(__FILE__) + '/logs/eyepaste.log')
)
LOGGER.level = :info
