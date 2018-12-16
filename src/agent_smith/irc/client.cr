require "system"

require "./channel"
require "./codes"
require "./user"
require "../matrix/client"

module AgentSmith
  module IRC
    class Client
      getter client : TCPSocket

      property nickname : String = "",
        username : String = "",
        realname : String = "",
        hostname : String = "",
        joined_channels = {} of String => IRC::Channel,
        next_batch = "",
        own_events = [] of String

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

      def spawn_matrix_sync
        raise ArgumentError.new("matrix sync should only be spawned with an active socket") if @client.closed?

        spawn do
          until @client.closed?
            begin
              matrix_sync
            rescue e
              Application.logger.warn "error in matrix sync loop: #{e.inspect}"
              Application.logger.warn "restarting in 3 seconds"
              sleep 3
            end
          end
        end
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
          room_events = room.state.events + room.timeline.events

          channel = channel_for(matrix_room_name, room_events)

          send_channel_history(channel, room_events)
          send_names(channel) if next_batch.empty?
        end

        @next_batch = response.next_batch
      end

      private def channel_for(matrix_room_name : String, room_events) : IRC::Channel
        return joined_channels[matrix_room_name] if joined_channels.has_key?(matrix_room_name)

        joined_channels[matrix_room_name] = IRC::Channel.new(matrix_room_name).tap do |ch|
          room_name_event = find_event(room_events, "m.room.canonical_alias")
          ch.canonical_alias = room_name_event.content.alias.not_nil! if room_name_event

          Message::ServerToClient.new(
            prefix: ident_s,
            command: "JOIN",
            params: [ch.room_name]
          ).send to: client

          send_channel_topic(ch, room_events)
        end
      end

      private def find_event(events : Array(Matrix::Entities::SyncResponse::Room::Event), event_type)
        events.find { |event| event.type == event_type }
      end

      private def send_channel_topic(channel, room_events)
        channel_topic_event = find_event(room_events, "m.room.topic")

        unless channel_topic_event
          if channel.topic != nil
            Message::ServerToClient.new(
              prefix: System.hostname,
              command: Codes::RPL_NOTOPIC,
              params: [nickname, channel.room_name],
              trailing: "No topic is set"
            ).send to: client
          end

          channel.topic = nil
          return
        end

        channel_topic = channel_topic_event.content.topic.not_nil!
        unless channel.topic == channel_topic
          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::RPL_TOPIC,
            params: [nickname, channel.room_name],
            trailing: channel_topic
          ).send to: client

          channel.topic = channel_topic
        end
      end

      private def send_channel_history(channel, room_events)
        Message::ServerToClient.new(
          prefix: "*AgentSmith!AgentSmith@#{System.hostname}",
          command: "PRIVMSG",
          params: [channel.room_name],
          trailing: "*** Playing back messages..."
        ).send to: client if next_batch.empty?

        room_events.each do |event|
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
                  prefix: User.matrix_id_to_ident(event.sender),
                  command: "PRIVMSG",
                  params: [channel.room_name],
                  trailing: line
                ).send to: client
              end

              next
            end

            # do not resend own messages to the channel
            next if own_events.delete(event.event_id)

            # redacted messages do not have a body
            next unless event.content.body && event.content.msgtype

            # normal messages
            is_action = event.content.msgtype == "m.emote"
            event.content.body.not_nil!.each_line(chomp: true) do |line|
              line = " " if line.empty?
              line = "\x01ACTION #{line}\x01" if is_action
              Message::ServerToClient.new(
                prefix: User.matrix_id_to_ident(event.sender),
                command: "PRIVMSG",
                params: [channel.room_name],
                trailing: line
              ).send to: client
            end
          when "m.room.member"
            u = User.new(event.sender)
            case event.membership
            when "join"
              channel.members << u unless channel.members.includes?(u)
              Message::ServerToClient.new(
                prefix: User.matrix_id_to_ident(event.sender),
                command: "JOIN",
                trailing: channel.room_name
              ).send to: client
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
          params: [channel.room_name],
          trailing: "*** Playback done."
        ).send to: client if next_batch.empty?
      end

      private def send_names(channel)
        channel.members.each_slice(8) do |users|
          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::RPL_NAMREPLY,
            params: [nickname, "=", channel.room_name],
            trailing: users.map(&.nickname).join(" ")
          ).send to: client
        end

        Message::ServerToClient.new(
          prefix: System.hostname,
          command: Codes::RPL_ENDOFNAMES,
          params: [nickname, channel.room_name],
          trailing: "End of /NAMES list."
        ).send to: client
      end

      forward_missing_to @client
    end
  end
end
