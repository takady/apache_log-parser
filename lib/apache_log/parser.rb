require 'apache_log/parser/version'
require 'date'

module ApacheLog
  class Parser
    COMMON_FIELDS = %i[remote_host identity_check user datetime request status size]
    COMBINED_FIELDS = COMMON_FIELDS + %i[referer user_agent]

    BAREWORD = '(\S+)'
    QUOTED = '"(.*?[^\\\\]|)"'

    PATTERNS = {
      remote_host: '((?:\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})|(?:[\w:]+?))',
      identity_check: BAREWORD,
      user: BAREWORD,
      datetime: '\[(\d{2}\/.*\d{4}:\d{2}:\d{2}:\d{2}\s.*)\]',
      request: QUOTED,
      status: BAREWORD,
      size: BAREWORD,
      referer: QUOTED,
      user_agent: QUOTED
    }

    ADDITIONAL_PATTERN = '\s+"?([^"]*)"?'

    def initialize(format, additional_fields = [])
      additional_pattern = ADDITIONAL_PATTERN * additional_fields.size

      base_fields = case format.to_s
                    when 'common' then COMMON_FIELDS
                    when 'combined' then COMBINED_FIELDS
                    else raise "format error\n no such format: <#{format}> \n"
                    end

      base_pattern = '(?:^|\s)' + base_fields.map { |f| PATTERNS[f] }.join('\s+')

      @fields = base_fields + additional_fields.map(&:to_sym)
      @pattern = /#{base_pattern}#{additional_pattern}/
    end

    def parse(line)
      matched = @pattern.match(line)

      raise "parse error\n at line: <#{line}> \n" if matched.nil?

      generate_hash(@fields, matched.to_a)
    end

    private

    def generate_hash(keys, values)
      keys.each.with_index(1).each_with_object({}) do |(key, i), hash|
        hash[key] = case key
                    when :datetime then to_datetime(values[i])
                    when :request then parse_request(values[i])
                    else values[i]
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
