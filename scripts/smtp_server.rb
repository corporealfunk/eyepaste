require 'rubygems'
require 'bundler/setup'

Bundler.require

require File.expand_path(File.dirname(__FILE__) + '/../config.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/eyepaste/smtp_server.rb')

EM.run {
  EM.start_server "127.0.0.1", 2525, Eyepaste::SmtpServer
}
