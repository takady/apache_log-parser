require "apache_log/parser/version"

module ApacheLog
  module Parser

    def self.parse(line, format)

      common_fields = %w(remote_host identity_check user datetime request status size)
      combined_fields = common_fields + %w(referer user_agent)

      common_pattern   = '(\S+)\s+(\S+)\s+(\S+)\s+\[ (\d{2}\/.*?\d{4}:\d{2}:\d{2}:\d{2}\s.*?) \]\s+\" (.*?\s.*?\s.*?) \"\s+(\S+)\s+(\S+)'
      combined_pattern = common_pattern + '\s+\" (.*?) \"\s+\" (.*?) \"'

      case format
      when 'common'
        fields = common_fields
        pattern = /^#{common_pattern}$/x
      when 'combined'
        fields = combined_fields
        pattern = /^#{combined_pattern}$/x
      else
        raise "format error\n no such format: <#{format}> \n"
      end

      match = pattern.match(line)
      raise "parse error\n at line: <#{line}> \n" if match.nil?

      columns = match.to_a

      parsed_hash = {}
      fields.each.with_index do |val, idx|
        val = val.to_sym
        if val == :datetime
          parsed_hash[val] = to_datetime(columns[idx+1])
        elsif val == :request
          parsed_hash[val] = parse_request(columns[idx+1])
        else
          parsed_hash[val] = columns[idx+1]
        end
      end

      parsed_hash
    end

    private
      def self.to_datetime(str)
        DateTime.strptime( str, '%d/%b/%Y:%T %z')
      end

      def self.parse_request(str)
        method, path, protocol = str.split
        {
          method:   method,
          path:     path,
          protocol: protocol,
        }
      end

  end
end
