module AgentSmith
  module IRC
    class Client
      getter client : TCPSocket

      property nickname : String = "",
               username : String = "",
               realname : String = "",
               hostname : String = ""

      def initialize(@client)
        @hostname = @client.remote_address.address
      end

      def ident_s
        "#{nickname}!#{username}@#{hostname}"
      end

      def authenticated?
        !(username.empty? && realname.empty?)
      end

      forward_missing_to @client
    end
  end
end
