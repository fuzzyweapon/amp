module AresMUSH
  module Api
    class ApiResponse
      attr_accessor :command_name, :status, :args_str
    
      def initialize(command_name, status, args_str = "")
        @command_name = command_name
        @status = status
        @args_str = args_str
      end
    
      def to_s
        "#{command_name} #{status} #{args_str}" 
      end
    
      def is_success?
        @status == self.ok_status
      end
    
      def self.error_status
        "ERR"
      end
    
      def self.ok_status
        "OK"
      end
    
      def self.create_from(response_str)
        cracked = /(?<command>\S+) (?<status>\S+)\s?(?<args>.*)/.match(response_str)
        raise "Invalid response format: #{response_str}." if cracked.nil?
      
        self.new(cracked[:command], cracked[:status], cracked[:args])
      end
    end
  end
end