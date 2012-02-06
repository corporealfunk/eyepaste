require 'rubygems'
require 'bundler/setup'

Bundler.require

require File.expand_path(File.dirname(__FILE__) + '/../config.rb')

# Pipe to stdin emails
content = ''
while data = $stdin.gets
  content << data
end

storage = Eyepaste::Storage.factory

email = Eyepaste::Email.parse_raw_email(content)

begin
  storage.append_email(email.to, email)
rescue Encoding::UndefinedConversionError => e
  LOGGER.warn "#{e.class}: #{content}"
end
