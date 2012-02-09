# eyepaste

## Description

eyepaste is a disposable email system that does not require account creation before mail can be received. For any domain that the system is currently accepts mail for, all email is accepted without question, stored, and accessible on the web as html or rss.

There are two components to eyepaste:

* A web application which is responsible for responding to HTTP requests to display received emails for a given eyepaste mail address
* An intake process that must receive emails as they arrive and store them

Currently, there are two supported email intake methods:

* Pipe raw emails to `scripts/intake.rb` stdin
* Run the Eyepaste::SmtpServer daemon process to receive emails directly using the SMTP protocol, control script at `scripts/smtp_server_control.rb`

It is not recommended that the Eyepaste::SmtpServer process be bound to your public IP address on port 25 to function as your front-line SMTP server. It is not a full-fledged SMTP server implementation. It is better to run a tested, secure SMTP server publicly (Postfix, Exim, etc.), and then configure that server process to forward email to the Eyepaste::SmtpServer which can be bound to a port on the loopback address.

Currently, the only backend storage system that is supported is Redis. However, writing new Eyepaste::Storage::<Class> to connect to a different backend should be fairly straight forward.

## Requirements

## Linux

eyepaste has only been tested on Debian Squeeze.

The test suite passes on Apple OS 10.6, however the daemon init scripts are targeted for Debian Squeeze.

### Ruby

eyepaste has only been tested against ruby-1.9.2-p290.

### RubyGems

eyepaste has been tested against rubygems-1.8.15.

eyepatse uses the `bundler` gem to manage gem dependencies and this gem must be accessible before installing eyepaste.

### Redis

Currently Redis is the only supported storage system.

eyepaste has only been tested against redis-2.4.2.

### Rack Compatible Web Server

eyepaste's web application is developed in sinatra, which requires it be served by a rack compatible server.

for testing and tinkering, you can use the `rackup` command, but for production you'll need a better deployment strategy.

eyepaste.com uses Phusion Passenger under Apache.

### Fully Implemented SMTP Server

Whether or not the eypaste installation uses the 'intake script' or the Eyepast::SmtpServer email intake method, you need to be able to run and configure your own full-fledge 'frontline' SMTP server that is configured to accept email for any domain that eyepaste is receiving and storing email for.

### DNS MX records

For any domain that eyepaste will receiving email for, you will need to point your DNS MX record for that domain to the server where the frontline SMTP server is running.

### Monit

Though not truely a requirement, the nature of Redis is that it will consume all the system's RAM, then the swap space until it can no longer allocate memory, and then it crashes. Redis can be configured with a memory limit, but may behave erratically when reaches the limit. Monit allows you set memory limits on a process, then take action if it the treshold is met. For eyepaste, maybe this means flushing the email keys, etc.

Monit is also a very easy way to start the Eyepaste::SmtpServer and monitor that it has not crashed, restarting the server process if it is unresponsive.

## Known Problems

* eyepaste relies on the Mail gem which at times has difficulty with string encoding. eyepaste logs all encoding errors and saves the corresponding email. Anecdotally, most emails with encoding problems are spam and probably not of interest to an end user.  I suspect the encoding problems are because a raw email states it's charset incorrectly in the MIME parts and/or headers.

## Numbers

The installation of eyepaste at eyepaste.com currently receives over 150,000 emails (mostly spam) per day using the installation described below. Because of this volume of email, emails are only kept for 1 hour before being flushed from Redis.

## Installation
