require 'rubygems'
require 'bundler/setup'

Bundler.require

Daemons.run(File.join(File.dirname(__FILE__), 'smtp_server.rb'), {
  :app_name => 'eyepaste_smtp',
  :dir_mode => :normal,
  :dir => File.dirname(__FILE__) + '/../tmp',
  :log_dir => File.dirname(__FILE__) + '/../logs',
  :log_output => true
})
