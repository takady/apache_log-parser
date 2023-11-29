# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apache_log/parser/version'

Gem::Specification.new do |spec|
  spec.name          = "apache_log-parser"
  spec.version       = ApacheLog::Parser::VERSION
  spec.authors       = ["Yuichi Takada"]
  spec.email         = ["takadyuichi@gmail.com"]
  spec.summary       = "Parse apache log including common, combined and customized format"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/takady/apache_log-parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
end
