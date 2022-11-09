# this script daemonizes and "controls" the smtp_server.rb script
# (using the Deamons gem which tracks pidfiles, stderr/out logging, etc)
# this script should be called to start and stop the smtp_server like so:
#
# ruby smtp_server_control.rb (start|stop|restart|status)

require 'rubygems'
require 'bundler/setup'

Bundler.require

full_path = File.expand_path(File.dirname(__FILE__))

Daemons.run(File.join(full_path, 'smtp_server.rb'), {
  :app_name => 'eyepaste_smtp',
  :dir_mode => :normal,
  :dir => full_path + '/../tmp/pids',
  :log_dir => full_path + '/../log',
  :log_output => true
})
