require 'spec_helper'
require 'date'

describe ApacheLog::Parser do
  it 'has a version number' do
    expect(ApacheLog::Parser::VERSION).not_to be nil
  end

  it 'can parse common format log' do
    parser = ApacheLog::Parser.getParser('common')
    line = '127.0.0.1 - - [20/May/2014:20:04:04 +0900] "GET /test/indx.html HTTP/1.1" 200 4576'
    entity = parser.parse(line.chomp)

    expect = {
      remote_host:    '127.0.0.1',
      identity_check: '-',
      user:           '-',
      datetime:       DateTime.new(2014, 5, 20, 20, 04, 04, 0.375),
      request:        {
                        method:   'GET',
                        path:     '/test/indx.html',
                        protocol: 'HTTP/1.1',
                      },
      status:         '200',
      size:           '4576',
    }

    expect(entity).to eq(expect)
  end

  it 'can parse combined format log' do
    parser = ApacheLog::Parser.getParser('combined')
    line = '104.24.160.39 - - [07/Jun/2014:14:58:55 +0900] "GET /category/electronics HTTP/1.1" 200 128 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"'
    entity = parser.parse(line.chomp)

    expect = {
      remote_host:    '104.24.160.39',
      identity_check: '-',
      user:           '-',
      datetime:       DateTime.new(2014, 6, 7, 14, 58, 55, 0.375),
      request:        {
                        method:   'GET',
                        path:     '/category/electronics',
                        protocol: 'HTTP/1.1',
                      },
      status:         '200',
      size:           '128',
      referer:        '-',
      user_agent:     'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1',
    }

    expect(entity).to eq(expect)
  end
end
