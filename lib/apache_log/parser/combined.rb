require "apache_log/parser/format"

module ApacheLog
  module Parser
    class Combined < Format
      def initialize
      end

      def self.parse(line)
        match = log_pattern.match(line)
        raise "parse error\n at line: <#{line}> \n" if match.nil?

        columns = match.to_a.values_at(1..9)
        {
          remote_host:    columns[0],
          identity_check: columns[1],
          user:           columns[2],
          datetime:       to_datetime(columns[3]),
          request:        parse_request(columns[4]),
          status:         columns[5],
          size:           columns[6],
          referer:        columns[7],
          user_agent:     columns[8],
        }
      end

      def self.log_pattern
        /^
          (\S+)                                     # remote_host
          \s+
          (\S+)                                  # identity_check
          \s+
          (\S+)                                            # user
          \s+
          \[ (\d{2}\/.*?\d{4}:\d{2}:\d{2}:\d{2}\s.*?) \]   # date
          \s+
          " (.*?\s.*?\s.*?) "                           # request
          \s+
          (\S+)                                          # status
          \s+
          (\S+)                                            # size
          \s+
          " (.*?) "                                     # referer
          \s+
          " (.*?) "                                  # user_agent
        $/x
      end

      private_class_method :log_pattern
    end

  end
end
