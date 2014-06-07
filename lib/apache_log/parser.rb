require "apache_log/parser/version"
require "apache_log/parser/common"
require "apache_log/parser/combined"

module ApacheLog
  module Parser
    def self.getParser(format)
      case format
      when 'common'
        ApacheLog::Parser::Common
      when 'combined'
        ApacheLog::Parser::Combined
      else
        raise "format error\n no such format: <#{format}> \n"
      end
    end
  end
end
