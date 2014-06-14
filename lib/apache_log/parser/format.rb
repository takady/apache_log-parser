module ApacheLog
  module Parser
    class Format
      def initialize
      end

      def self.parse(line)
      end

      def self.log_pattern
      end

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

      private_class_method :to_datetime, :parse_request
    end

  end
end
