# ApacheLog::Parser
[![Build Status](https://travis-ci.org/takady/apache_log-parser.svg?branch=master)](https://travis-ci.org/takady/apache_log-parser)[![Code Climate](https://codeclimate.com/github/takady/apache_log-parser/badges/gpa.svg)](https://codeclimate.com/github/takady/apache_log-parser)
Gem to parse apache log including common, combined and customized format.

## Installation

Add this line to your application's Gemfile:

    gem 'apache_log-parser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apache_log-parser

## Usage

```ruby
require 'apache_log/parser'

# common format
common_log = ApacheLog::Parser.parse(log_line, 'common')
common_log[:remote_host]    #=> remote host
common_log[:datetime]       #=> datetime
common_log[:request]        #=> request

# combined format
combined_log = ApacheLog::Parser.parse(log_line, 'combined')
combined_log[:referer]        #=> referer
combined_log[:user_agent]     #=> user_agent

# custom format(additional fields after 'combined')
# custom format: LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%v\" \"%{cookie}n\" %D"
custom_log = ApacheLog::Parser.parse(log_line, 'combined', %w(vhost usertrack request_duration))
custom_log[:user_agent]        #=> user_agent
custom_log[:vhost]             #=> vhost
custom_log[:usertrack]         #=> usertrack
custom_log[:request_duration]  #=> request_duration
```

The format parameter must be 'common' or 'combined'.

## Contributing

1. Fork it ( https://github.com/takady/apache_log-parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
