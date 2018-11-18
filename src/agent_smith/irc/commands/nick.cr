require "./base"

module AgentSmith
  module IRC
    module Commands
      class Nick < Base
        def call
          unless msg.params.size == 1
            send_need_more_params
            return
          end

          if client.authenticated?
            Message::ServerToClient.new(
              prefix: client.ident_s,
              command: "NICK",
              params: [msg.params[0]]
            ).send to: client
          end

          client.nickname = msg.params[0]
        end
      end
    end
  end
end
