require "../client"
require "../codes"
require "../message"

module AgentSmith
  module IRC
    module Commands
      abstract class Base
        def self.call(msg, client)
          new(msg, client).call
        end

        getter msg, client

        def initialize(@msg : Message::ClientToServer, @client : Client); end

        abstract def call

        private def send_need_more_params
          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::ERR_NEEDMOREPARAMS,
            params: [client.nickname.empty? ? "*" : client.nickname, msg.command],
            trailing: "Not enough parameters"
          ).send to: client
        end
      end
    end
  end
end
