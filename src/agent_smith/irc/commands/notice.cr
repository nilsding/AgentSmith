require "./base"

module AgentSmith
  module IRC
    module Commands
      # OwO
      class Notice < Base
        def call
          unless msg.params.size == 1
            send_need_more_params
            return
          end

          return if msg.trailing.strip.empty?

          target = msg.params.first

          # only forward notices to ourself
          # some IRC clients (e.g. KVIrc) use this as lagometer
          return unless target == client.nickname

          text = msg.trailing
          is_ctcp = text

          Message::ServerToClient.new(
            prefix: client.ident_s,
            command: "NOTICE",
            trailing: text
          ).send to: client
        end
      end
    end
  end
end
