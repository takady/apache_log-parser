require 'apache_log/parser/version'
require 'date'

module ApacheLog
  class Parser
    COMMON_FIELDS = %w(remote_host identity_check user datetime request status size)
    COMBINED_FIELDS = COMMON_FIELDS + %w(referer user_agent)

    COMMON_PATTERN = '(?:^|\s)((?:\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})|(?:[\w:]+?))\s+(\S+)\s+(\S+)\s+\[(\d{2}\/.*\d{4}:\d{2}:\d{2}:\d{2}\s.*)\]\s+"(.*?)"\s+(\S+)\s+(\S+)'
    COMBINED_PATTERN = COMMON_PATTERN + '\s+"(.*?[^\\\\])"\s+"(.*?[^\\\\])"'
    ADDITIONAL_PATTERN = '\s+"?([^"]*)"?'

    def initialize(format, additional_fields=[])
      additional_pattern = ''
      additional_pattern << ADDITIONAL_PATTERN * additional_fields.size

      case format
      when 'common'
        @fields = COMMON_FIELDS + additional_fields
        @pattern = /#{COMMON_PATTERN}#{additional_pattern}/
      when 'combined'
        @fields = COMBINED_FIELDS + additional_fields
        @pattern = /#{COMBINED_PATTERN}#{additional_pattern}/
      else
        raise "format error\n no such format: <#{format}> \n"
      end
    end

    def parse(line)
      matched = @pattern.match(line)

      raise "parse error\n at line: <#{line}> \n" if matched.nil?

      generate_hash(@fields, matched.to_a)
    end

    private

    def generate_hash(keys, values)
      keys.each.with_index(1).each_with_object({}) do |(key, i), hash|
        key = key.to_sym

        case key
        when :datetime
          hash[key] = to_datetime(values[i])
        when :request
          hash[key] = parse_request(values[i])
        else
          hash[key] = values[i]
        end
      end
    end

    def to_datetime(str)
      DateTime.strptime(str, '%d/%b/%Y:%T %z')
    end

    def parse_request(str)
      method, path, protocol = str.split

      { method: method, path: path, protocol: protocol }
    end
  end
end
