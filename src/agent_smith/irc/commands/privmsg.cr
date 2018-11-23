require "./base"

module AgentSmith
  module IRC
    module Commands
      class Privmsg < Base
        def call
          unless msg.params.size == 1
            send_need_more_params
            return
          end

          return if msg.trailing.strip.empty?

          target = msg.params.first

          if target.starts_with?("#")
            matrix_room_id = client.channel_map.key_for?(target)
            unless matrix_room_id
              Application.logger.warn "PRIVMSG: no matrix room id found for #{target.inspect}"
              return
            end

            ok, response = client.@matrix_client.room_send(
              ENV["MATRIX_ACCESS_TOKEN"],
              room_id: matrix_room_id,
              event_type: "m.room.message",
              content: {
                "msgtype" => "m.text",
                "body"    => msg.trailing,
              }
            )

            unless ok
              Application.logger.error "PRIVMSG: message sending failed, argh!"
              return
            end

            client.own_events << response.not_nil!.event_id
          end
        end
      end
    end
  end
end
