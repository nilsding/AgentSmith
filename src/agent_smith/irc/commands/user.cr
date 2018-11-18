require "system"

require "./base"
require "./motd"
require "../../application"

module AgentSmith
  module IRC
    module Commands
      class User < Base
        def call
          if msg.params.size < 3
            send_need_more_params
            return
          end

          client.username = msg.params[0]
          client.realname = msg.trailing

          send_welcome to: client
          Motd.call(msg, client)
        end

        private def send_welcome(to client)
          welcome_msgs = [
            { Codes::RPL_WELCOME,  "Hello from Agent Smith #{AgentSmith::VERSION}." },
            { Codes::RPL_YOURHOST, "Running on host #{System.hostname}." }
          ].map do |code, str|
            Message::ServerToClient.new(
              prefix: System.hostname,
              command: code,
              params: [client.nickname],
              trailing: str
            )
          end.each(&.send to: client)

          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::RPL_MYINFO,
            params: [client.nickname, System.hostname, "AgentSmith-#{AgentSmith::VERSION}", "iw", "nt"]
          ).send to: client

          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::RPL_BOUNCE,
            params: [client.nickname, "NETWORK=AgentSmith"],
            trailing: "are supported by this server"
          ).send to: client
        end
      end
    end
  end
end
