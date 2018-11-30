require "./base"
require "../text_formatter"

module AgentSmith
  module IRC
    module Commands
      class Privmsg < Base
        KNOWN_CTCP_TYPES = %w[ACTION]

        def call
          unless msg.params.size == 1
            send_need_more_params
            return
          end

          return if msg.trailing.strip.empty?

          target = msg.params.first

          text = msg.trailing
          is_ctcp = text.starts_with?("\x01") && text.ends_with?("\x01")
          ctcp_type = ""

          if is_ctcp
            text = text.strip("\x01")
            ctcp_type, text = if text.includes?(" ")
                                text.split(" ", 2)
                              else
                                [text, ""]
                              end
            ctcp_type = ctcp_type.upcase

            unless KNOWN_CTCP_TYPES.includes?(ctcp_type)
              Application.logger.warn "PRIVMSG: unknown ctcp type #{ctcp_type.inspect} for message #{msg.trailing.inspect}"
              return
            end
          end

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
                "msgtype"        => is_ctcp && ctcp_type == "ACTION" ? "m.emote" : "m.text",
                "body"           => text,
                "format"         => "org.matrix.custom.html",
                "formatted_body" => TextFormatter.format(text),
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
