# This script cleans up emails that are older than
# the specified time limit in the config.rb
# It should be run periodically with cron

require 'rubygems'
require 'bundler/setup'

Bundler.require

require File.expand_path(File.dirname(__FILE__) + '/../config.rb')

storage = Eyepaste::Storage.factory

storage.expire_emails_before(Time.now.to_i - (EMAIL_MAX_LIFE_HOURS * 60 * 60))
