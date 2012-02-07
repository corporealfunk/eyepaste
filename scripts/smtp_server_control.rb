# this script daemonizes and "controls" the smtp_server.rb script
# (using the Deamons gem which tracks pidfiles, stderr/out logging, etc)
# this script should be called to start and stop the smtp_server like so:
#
# ruby smtp_server_control.rb (start|stop|restart|status)

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
