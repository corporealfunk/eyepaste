require File.dirname(__FILE__) + '/lib/eyepaste/storage'
require File.dirname(__FILE__) + '/lib/eyepaste/storage/redis'

# set the max life of emails in hours
EMAIL_MAX_LIFE_HOURS = 1

# what domains do we accept email for?
ACCEPTED_DOMAINS = %w[eyepaste.com]

# configure the storage engine:
Eyepaste::Storage.set_factory do
  redis = ::Redis.new(:url => ENV['REDIS_URL'])
  storage = Eyepaste::Storage::Redis.new(redis)
  storage.accepted_domains = ACCEPTED_DOMAINS
  storage
end

# configure the logger:
log_file = File.dirname(__FILE__) + '/log/eyepaste.log'
LOGGER = Logging.logger['eyepaste_log']
LOGGER.add_appenders(
  Logging.appenders.file(log_file)
)
LOGGER.level = :info

# touch log file and make it world writeable if it does not exist:
if !File.exist?(log_file)
  FileUtils.touch(log_file)

  # world writable:
  FileUtils.chmod(0666, log_file)
end
