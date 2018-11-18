require "./base"

module AgentSmith
  module IRC
    module Commands
      class UnknownCommand < Base
        def call
          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::ERR_UNKNOWNCOMMAND.code_s,
            params: ["*", msg.command],
            trailing: "Unknown command."
          ).send to: client
        end
      end
    end
  end
end
