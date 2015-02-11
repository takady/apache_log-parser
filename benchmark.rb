$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'apache_log/parser'
require 'benchmark'

common_line = '127.0.0.1 - - [20/May/2014:20:04:04 +0900] "GET /test/indx.html HTTP/1.1" 200 4576'
combined_line = '104.24.160.39 - - [07/Jun/2014:14:58:55 +0900] "GET /category/electronics HTTP/1.1" 200 128 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"'
customized_line = '192.168.0.1 - - [07/Feb/2011:10:59:59 +0900] "GET /x/i.cgi/net/0000/ HTTP/1.1" 200 9891 "-" "DoCoMo/2.0 P03B(c500;TB;W24H16)" virtualhost.example.jp "192.0.2.16794832933550" "09011112222333_xx.ezweb.ne.jp" 533593'
 
common_parser = ApacheLog::Parser.new('common')
combined_parser = ApacheLog::Parser.new('combined')
customized_parser = ApacheLog::Parser.new('combined', %w(vhost usertrack mobileid request_duration))

n = 1_000_000
Benchmark.bm(12) do |x|
  x.report('common:')     { (1..n).each{common_parser.parse(common_line)} }
  x.report('combined:')   { (1..n).each{combined_parser.parse(combined_line)} }
  x.report('customized:') { (1..n).each{customized_parser.parse(customized_line)} }
end
