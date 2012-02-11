# eyepaste

## Description

eyepaste is a disposable email system that does not require account creation before mail can be received. For any domain that the system is currently accepting mail for, all email is accepted without question, stored, and accessible on the web as HTML or RSS.

There are two components to eyepaste:

* A web application which is responsible for responding to HTTP requests to display received emails for a given eyepaste inbox
* An intake process that receives emails as they arrive and stores them for later retrieval by the web application

Currently, there are two supported email intake methods:

* Pipe raw emails to `scripts/intake.rb` stdin
* Run the Eyepaste::SmtpServer daemon process to receive emails directly using the SMTP protocol (control script at `scripts/smtp_server_control.rb`)

It is not recommended that the Eyepaste::SmtpServer process be bound to your public IP address on port 25 to function as your frontline SMTP server. It is not a full-fledged SMTP protocol implementation. It is better to run a tested, secure SMTP server publicly (Postfix, Exim, etc.), then configure that server process to forward email to the Eyepaste::SmtpServer which can be bound to a port on the loopback address.

Currently, the only backend storage system that is supported is Redis. However, writing new Eyepaste::Storage::* classes to connect to a different backend should be fairly straightforward.

## Requirements

## Linux

eyepaste has only been fully deployed and tested on Debian Squeeze.

### Ruby

eyepaste has been tested against ruby-1.9.2-p290.

### RubyGems

eyepaste uses the `bundler` gem to manage gem dependencies.

### Redis

Currently Redis is the only supported storage system.

eyepaste has been tested against redis-2.4.2.

### Rack Compatible Web Server

eyepaste's web application is developed in sinatra, which requires it be served by a rack compatible server.

For testing and tinkering, you can use the `rackup` command, but for production you'll need a better deployment strategy.

eyepaste.com uses Phusion Passenger under Apache.

### Fully Implemented SMTP Server

Whether or not the eypaste installation uses the 'intake script' or the Eyepaste::SmtpServer email intake method, you need to be able to run and configure your own full-fledged 'frontline' SMTP server that is configured to accept email for any domain that eyepaste is receiving and storing email for.

### DNS MX records

For any domain that eyepaste will be receiving email for, you will need to point that domain's DNS MX record to the server where the frontline SMTP server is running.

### Monit

Though not truely a requirement, the nature of Redis is that it will consume all the system's RAM, then the swap space until it can no longer allocate memory, and then it crashes. Redis can be configured with a memory limit, but may behave erratically when it reaches the limit. Monit allows you set memory limits on a process, then take action if the treshold is met. For eyepaste, maybe this means flushing the email keys, etc.

Monit is also a very easy way to start the Eyepaste::SmtpServer and monitor that it has not crashed, restarting the server process if it is unresponsive.

## Known Problems

* eyepaste relies on the Mail gem which at times has difficulty with string encoding. eyepaste logs all encoding errors and saves the corresponding email. Anecdotally, most emails with encoding problems are spam and probably not of interest to an end user.  I suspect the encoding problems are because a raw email states it's charset incorrectly in the MIME parts and/or headers.

## Numbers

The installation of eyepaste at eyepaste.com currently receives over 150,000 emails (mostly spam) per day using the Eyepaste::SmtpServer intake method which runs behind Postfix. Because of this volume of email, emails are only kept for 1 hour before being flushed from Redis.

## Configuration

### The Web Application

In the application root there is a `config.rb` file. It contains some constants of interest as well as configuration of the storage engine.

```ruby
# this determines how long emails will be kept in storage after being created
EMAIL_MAX_LIFE_HOURS = 1

# an array of domains to accept email for. Any email that is not "@" a domain in this
# array will not be stored
ACCEPTED_DOMAINS = %w[yourdomain.com]

# Setup your storage engine, here Redis is being used, you can configure
# the Redis gem as necessary, then pass it to the Eyepaste::Storage::Redis
# initializer. This block is run every time a storage engine object is
# requested from Eyepaste::Storage.factory()
Eyepaste::Storage.set_factory do
  redis = ::Redis.new(:host => "127.0.0.1", :port => 6379)
  storage = Eyepaste::Storage::Redis.new(redis)
  storage.accepted_domains = ACCEPTED_DOMAINS
  storage
end
```

You must also run `bundle install` in the root of the app to install all necessary gems.

run `rackup` to ensure that you are able to start the application and visit it via http.

### Cron

In order to delete emails that should no longer be stored because they have reached their maximum age `scripts/gc.rb` must be run periodically.

An example cron line:

```bash
# run once an hour on the hour
0 * * * * /path/to/eyepaste/scripts/cd.sh /usr/bin/ruby scripts/gc.rb
```

You'll notice here that we are first calling `scripts/cd.sh`, then passing the ruby binary and then the script to execute with ruby. `scripts/cd.sh` makes sure that the given ruby binary is operating in the correct working directory in order for Bundler to find the correct Gemfile and require the correct versions of gems.

`scripts/cd.sh` also makes it easy to use RVM and swap out your ruby binary being used, by simply passing in the path to the ruby binary or RVM ruby wrapper as the first argument to the script.

### Postfix

A full discussion of Postfix configuration is outside the scope of this document. Your Postfix configuration must be able to:

* Accept emails for the domains listed in your `config.rb` script's `ACCEPTED_DOMAINS` array
* Be able to accept email for any inbox for that domain (wildcard)

There are two methods for accepting and storing email:

#### Intake Script

This method is the easiest to configure, but does tend to be slow and consume more server resources, since the ruby interpreter is fired up and must initialize Bundler and the Eyepaste library on each email received. 

First, configure Postfix to accept all email for emails in your `ACCEPTED_DOMAINS` array via a virtual transport map:

as root:

```bash
adduser eyepaste
cd /etc/postfix
cat "@yourdomain.com eyepaste@localhost" > virtual
postmap virtual
cat "virtual_alias_maps = hash:/etc/postfix/virtual" >> main.cf
postfix reload
```

This instructs Postfix to forward any email for *@yourdomain.com to the eyepaste system user.

However, you now need to tell Postfix that all email for the eyepaste system user should be piped to the intake script:

as root:

```bash
cd /etc
cat 'eyepaste "|/path/to/eyepaste/scripts/cd_stdin.sh /usr/bin/ruby scripts/intake.rb"' >> aliases
newaliases
postfix reload
```

Note that it is important to use `scripts/cd_stdin.sh` vs the `scripts/cd.sh` that was used in the crontab. `scripts/cd_stdin.sh` changes the working directory before running ruby, but also passes all STDIN input through to ruby.

In reality, you probably want this alias at the top of your aliases file instead of at the bottom as appending would do above.

#### Eyepaste::SmtpServer Process

This setup requires more moving parts but is far more efficient, it relies on the EventMachine gem's EM::Protocols::SmtpServer implementation.

By default the server will bind to 127.0.0.1:2525

First, you need to start the eyepaste_smtp server process. The daemon control script is located at `scripts/smtp_server_control.rb` and uses the Daemons gem to manage the server process. There is also a sysvinit script located at `scripts/sysvinit/eyepaste_smtp`

If you use the sysvinit script, you will need to edit it to match your environment, specifically the bash variables:

```bash
APP_ROOT="/path/to/eyepaste"
RUBY="/path/to/ruby/binary"
USER="system_user_to_run_server_as"
```

If you choose to use monit to start, stop and monitor the eyepaste_smtp process, see the monit example in `monit/eyepaste_smtp`. You will need to edit the paths there as well.

I do not recommend you run the process as root. Calling the sysvinit script will run the process as the user specified in the script, like so:

`/path/to/eyepaste/scripts/sysvinit/eyepaste_smtp start`

Verify the process is running and bound:

`netstat -tap | grep 2525`

Next, configure Postfix to accept all email for emails in your `ACCEPTED_DOMAINS` array via a virtual transport map:

as root:

```bash
adduser eyepaste
cd /etc/postfix
cat "@yourdomain.com eyepaste@localhost" > virtual
postmap virtual
cat "virtual_alias_maps = hash:/etc/postfix/virtual" >> main.cf
postfix reload
```

Next, you need to tell Postfix to forward all email to this port:

as root:

```bash
cd /etc/postfix
cat "localhost smtp:[127.0.0.1]:2525" > transport
postmap transport
cat "transport_maps = hash:/etc/postfix/transport" >> main.cf
postfix reload
```

When you view your `/var/log/mail.log` you should see lines like:

```
Feb 11 06:22:19 hostname postfix/smtp[28869]: C34DFAAF7B: to=<eyepaste@localhost>, orig_to=<i5qmn@yourdomain.com>, relay=127.0.0.1[127.0.0.1]:2525, delay=2.3, delays=2.2/0/0/0.09, dsn=2.0.0, status=sent (250 Message accepted)
```

On the command line, you should be able to query Redis to see the keys of the stored emails:

```bash
redis-cli keys "*"
```

And on the web you should be able to visit `http://yourdomain.com/inbox/i5qmn@yourdomain.com`

## Tests

RSpec tests cover the Eyepaste library as well as integration testing of the sinatra application. Redis must be running to test the storage engine and run the integration tests.
The Eyepaste::SmtpServer is not currently covered by tests.

To run the test suite, with Redis running:

```bash
cd /path/to/eyepaste
rspec specs/*_spec.rb
```

Please note that the suite flushes the Redis store before each test involving storage.

## License

eyepaste is licensed under the MIT license:

Copyright (c) 2012. Jon Moniaci.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

