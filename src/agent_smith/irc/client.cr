require "system"

require "./codes"
require "../matrix/client"

module AgentSmith
  module IRC
    class Client
      getter client : TCPSocket

      property nickname : String = "",
        username : String = "",
        realname : String = "",
        hostname : String = "",
        # XXX: those should be probably in an own class.  just a POC for now
        joined_channels = [] of String,
        channel_topics = {} of String => String?,
        channel_map = {} of String => String,
        next_batch = ""

      def initialize(@client)
        @hostname = @client.remote_address.address
        @matrix_client = Matrix::Client.new(Application.homeserver)
      end

      def ident_s
        "#{nickname}!#{username}@#{hostname}"
      end

      def authenticated?
        !(username.empty? && realname.empty?)
      end

      def matrix_sync
        ok, response = @matrix_client.sync(ENV["MATRIX_ACCESS_TOKEN"], timeout: 30000, timeline_limit: 20, since: next_batch)
        unless ok
          Application.logger.error "failed to sync matrix for some reason. waiting 3 seconds until next retry"
          sleep 3
          return
        end

        response = response.not_nil!
        response.rooms.join.each do |matrix_room_name, room|
          room_name_event = room.state.find_event("m.room.canonical_alias")
          room_name = ""

          if room_name_event
            room_name = room_name_event.content.alias.not_nil!
            channel_map[matrix_room_name] = room_name

            unless joined_channels.includes?(room_name)
              Message::ServerToClient.new(
                prefix: ident_s,
                command: "JOIN",
                params: [room_name]
              ).send to: client
              joined_channels << room_name
            end

            send_channel_topic(room, room_name)
          end

          next unless channel_map.has_key?(matrix_room_name)
          room_name = channel_map[matrix_room_name]

          send_channel_history(room, room_name)
        end

        @next_batch = response.next_batch
      end

      private def send_channel_topic(room, room_name)
        channel_topic_event = room.state.find_event("m.room.topic")

        unless channel_topic_event
          unless channel_topics.fetch(room_name, "") == nil
            Message::ServerToClient.new(
              prefix: System.hostname,
              command: Codes::RPL_NOTOPIC,
              params: [nickname, room_name],
              trailing: "No topic is set"
            ).send to: client
          end
          channel_topics[room_name] = nil
          return
        end

        channel_topic = channel_topic_event.content.topic.not_nil!
        unless channel_topics.fetch(room_name, nil) == channel_topic
          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::RPL_TOPIC,
            params: [nickname, room_name],
            trailing: channel_topic
          ).send to: client
        end
        channel_topics[room_name] = channel_topic
      end

      private def send_channel_history(room, room_name)
        Message::ServerToClient.new(
          prefix: "*AgentSmith!AgentSmith@#{System.hostname}",
          command: "PRIVMSG",
          params: [room_name],
          trailing: "*** Playing back messages..."
        ).send to: client if next_batch.empty?

        room.timeline.events.each do |event|
          case event.type
          when "m.room.message"
            # file attachments
            if event.content.url
              download_url = File.join(
                @matrix_client.base_url,
                "media/v1/download",
                event.content.url.not_nil!.sub(%r{\Amxc://}, "")
              )

              [
                "[\x16File\x16] #{event.content.body}",
                "       \x02Download:\x02 #{download_url}",
              ].each do |line|
                Message::ServerToClient.new(
                  prefix: matrix2ident(event.sender),
                  command: "PRIVMSG",
                  params: [room_name],
                  trailing: line
                ).send to: client
              end

              next
            end

            # normal urls
            event.content.body.not_nil!.each_line(chomp: false) do |line|
              Message::ServerToClient.new(
                prefix: matrix2ident(event.sender),
                command: "PRIVMSG",
                params: [room_name],
                trailing: line
              ).send to: client
            end
          when "m.room.member"
            case event.membership
            when "join"
              Message::ServerToClient.new(
                prefix: matrix2ident(event.sender),
                command: "JOIN",
                trailing: room_name
              )
            else
              Application.logger.warn "unhandled m.room.member membership type #{event.membership.inspect}"
            end
          else
            Application.logger.warn "unhandled timeline event type #{event.type.inspect}"
          end
        end

        Message::ServerToClient.new(
          prefix: "*AgentSmith!AgentSmith@#{System.hostname}",
          command: "PRIVMSG",
          params: [room_name],
          trailing: "*** Playback done."
        ).send to: client if next_batch.empty?
      end

      # @nilsding:rrerr.net => nilsding!nilsding@rrerr.net
      private def matrix2ident(matrix_id)
        matrix_id.sub(/@([^:]+):(.+)/, "\\1!\\1@\\2", backreferences: true)
      end

      forward_missing_to @client
    end
  end
end
