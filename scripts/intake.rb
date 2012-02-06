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

begin
  email = Eyepaste::Email.parse_raw_email(content)
rescue ArgumentError => e
  LOGGER.warn "#{e.class}: #{e.message}:\n#{content}"

  # exit gracefully
  exit 0
end

begin
  storage.append_email(email.to, email)
rescue NoMethodError, Encoding::UndefinedConversionError => e
  LOGGER.warn "#{e.class}: #{e.message}:\n#{content}"

  # exit gracefully
  exit 0
end
