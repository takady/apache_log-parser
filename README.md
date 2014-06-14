# ApacheLog::Parser

Gem to parse popular format apache log files.

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

parser = ApacheLog::Parser.getParser(format)
entity = []

File.foreach(logfile) do |line|
  entity << parser.parse(line.chomp)
end
```

The format parameter must be 'common' or 'combined'.

## Contributing

1. Fork it ( https://github.com/takady/apache_log-parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
