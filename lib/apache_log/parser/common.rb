module ApacheLog
  module Parser
    class Common
      def initialize(args)
        @ip_address     = args[:ip_address]
        @identity_check = args[:identity_check]
        @user           = args[:user]
        @datetime       = args[:datetime]
        @request        = args[:request]
        @status         = args[:status]
        @size           = args[:size]
      end

      attr_reader :ip_address, :identity_check, :user, :datetime, :request, :status, :size

      def self.parse(line)
        match = log_pattern.match(line)
        raise "parse error\n at line: <#{line}> \n" if match.nil?

        columns = match.to_a.values_at(1..7)
        self.new({
          :ip_address      => columns[0],
          :identity_check  => columns[1],
          :user            => columns[2],
          :datetime        => parse_datetime(columns[3]),
          :request         => parse_request(columns[4]),
          :status          => columns[5],
          :size            => columns[6],
        })
      end

      def self.log_pattern
        /^
          (\S+)                                      # ip_address
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
        $/x
      end

      def self.parse_datetime(str)
        DateTime.strptime( str, '%d/%b/%Y:%T %z')
      end

      def self.parse_request(str)
        method, path, protocol = str.split
        {
          :method   => method,
          :path     => path,
          :protocol => protocol
        }
      end

      private_class_method :log_pattern, :parse_datetime, :parse_request
    end

  end
end
