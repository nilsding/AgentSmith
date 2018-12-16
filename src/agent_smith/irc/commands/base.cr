require "../client"
require "../codes"
require "../message"

module AgentSmith
  module IRC
    module Commands
      abstract class Base
        def self.call(msg, client)
          new(msg, client).call
        end

        getter msg, client

        def initialize(@msg : Message::ClientToServer, @client : Client); end

        abstract def call

        private def send_need_more_params
          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::ERR_NEEDMOREPARAMS,
            params: [client.nickname.empty? ? "*" : client.nickname, msg.command],
            trailing: "Not enough parameters"
          ).send to: client
        end

        private def is_channel?(target)
          target.starts_with?("#") || target.starts_with?("!")
        end

        private def find_channel(irc_name) : Channel?
          channel_tuple = client.joined_channels.find { |mid, ch| ch.room_name == irc_name }

          unless channel_tuple
            Application.logger.warn "#{self.class.name.split("::").last.upcase}: no channel object found for #{irc_name.inspect}"
            return
          end

          _matrix_room_id, channel = channel_tuple

          channel
        end
      end
    end
  end
end
