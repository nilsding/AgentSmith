require "system"

require "./base"

module AgentSmith
  module IRC
    module Commands
      class Mode < Base
        def call
          unless msg.params.size == 1
            send_need_more_params
            return
          end

          if msg.params.first.starts_with?("#")
            Message::ServerToClient.new(
              prefix: System.hostname,
              command: Codes::RPL_CHANNELMODEIS,
              params: [client.nickname, msg.params.first, "+nt"]
            ).send to: client
          end
        end
      end
    end
  end
end
