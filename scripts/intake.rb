require 'rubygems'
require 'bundler/setup'

Bundler.require

require File.expand_path(File.dirname(__FILE__) + '/../config.rb')

# Pipe to stdin emails
email = ''
while data = $stdin.gets
  email << data
end

storage = Eyepaste::Storage.factory

email = Eyepaste::Email.parse_raw_email(email)

storage.append_email(email.to, email)