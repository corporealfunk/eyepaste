# this is the actual main loop for the eyepaste SMTP
# server, run via EventMachine

require 'rubygems'
require 'bundler/setup'

Bundler.require

require File.expand_path(File.dirname(__FILE__) + '/../config.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/eyepaste/smtp_server.rb')

bind_addr = ENV['SMTP_ADDRESS'] || "127.0.0.1"
bind_port = ENV['SMTP_PORT'] || "2525"

EM.run {
  EM.start_server bind_addr, bind_port, Eyepaste::SmtpServer
}
