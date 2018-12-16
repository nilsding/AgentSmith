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

          if target.starts_with?("#") || target.starts_with?("!")
            channel_tuple = client.joined_channels.find { |mid, ch| ch.room_name == target }
            unless channel_tuple
              Application.logger.warn "PRIVMSG: no channel object found for #{target.inspect}"
              return
            end

            matrix_room_id, channel = channel_tuple

            ok, response = client.@matrix_client.room_send(
              ENV["MATRIX_ACCESS_TOKEN"],
              room_id: matrix_room_id,
              event_type: "m.room.message",
              content: {
                "msgtype"        => is_ctcp && ctcp_type == "ACTION" ? "m.emote" : "m.text",
                "body"           => TextFormatter.format_none(text),
                "format"         => "org.matrix.custom.html",
                "formatted_body" => TextFormatter.format_html(text),
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
