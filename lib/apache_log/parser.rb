require 'apache_log/parser/version'
require 'date'

module ApacheLog
  class Parser
    def initialize(format, additional_fields=[])
      common_fields   = %w(remote_host identity_check user datetime request status size)
      combined_fields = common_fields + %w(referer user_agent)

      common_pattern     = '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\S+)\s+(\S+)\s+\[(\d{2}\/.*\d{4}:\d{2}:\d{2}:\d{2}\s.*)\]\s+"(\S+\s\S+\s\S+)"\s+(\S+)\s+(\S+)'
      combined_pattern   = common_pattern + '\s+"([^"]*)"\s+"([^"]*)"'
      additional_pattern = ''

      additional_fields.each do
        additional_pattern += '\s+"?([^"]*)"?'
      end

      case format
      when 'common'
        @fields = common_fields + additional_fields
        @pattern = /#{common_pattern}#{additional_pattern}/
      when 'combined'
        @fields = combined_fields + additional_fields
        @pattern = /#{combined_pattern}#{additional_pattern}/
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
      hash = {}

      keys.each.with_index(1) do |key, idx|
        key = key.to_sym
        case key
        when :datetime
          hash[key] = to_datetime(values[idx])
        when :request
          hash[key] = parse_request(values[idx])
        else
          hash[key] = values[idx]
        end
      end

      hash
    end

    def to_datetime(str)
      DateTime.strptime(str, '%d/%b/%Y:%T %z')
    end

    def parse_request(str)
      method, path, protocol = str.split
      {
        method:   method,
        path:     path,
        protocol: protocol,
      }
    end
  end
end
