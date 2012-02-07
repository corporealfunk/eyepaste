#!/bin/bash
### BEGIN INIT INFO
# Provides:          eyepaste
# Required-Start:    $remote_fs $syslog postfix redis-server
# Required-Stop:     $remote_fs $syslog postfix redis-server
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: eyepaste smpt server
# Description:       eyepaste smpt server
### END INIT INFO

# Author: Jon Moniaci <jonmoniaci [at] gmail.com>

# change APP_ROOT and RUBY to match your eyepaste and ruby installation
APP_ROOT="/Users/jonathan/eyepaste"
RUBY="/Users/jonathan/.rvm/wrappers/ruby-1.9.2-p290/ruby"
USER=jonathan

DESC="Eyepaste SMTP server"
NAME=eyepaste_smtp
SCRIPT="$APP_ROOT/scripts/smtp_server_control.rb"

cd "$APP_ROOT"

run_cmd() {
  su $USER -c "$1"
}

case $1 in
  start)
    run_cmd "$RUBY $SCRIPT start"
  ;;
  stop)
    run_cmd "$RUBY $SCRIPT stop"
  ;;
  restart)
    run_cmd "$RUBY $SCRIPT restart"
  ;;
  reload)
    run_cmd "$RUBY $SCRIPT reload"
  ;;
  status)
    run_cmd "$RUBY $SCRIPT status"
  ;;
  *)
    echo "usage: $0 (start|stop|restart|reload|status)"
  ;;
esac
