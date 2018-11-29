require "system"

require "./base"

module AgentSmith
  module IRC
    module Commands
      class Ping < Base
        def call
          unless (1..2).covers? msg.params.size
            send_need_more_params
            return
          end

          Message::ServerToClient.new(
            prefix: System.hostname,
            command: "PONG",
            params: [System.hostname],
            trailing: msg.params.first
          ).send to: client
        end
      end
    end
  end
end
