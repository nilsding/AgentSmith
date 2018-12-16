require "system"

require "./base"

module AgentSmith
  module IRC
    module Commands
      class Names < Base
        def call
          unless msg.params.size == 1
            send_need_more_params
            return
          end

          target = msg.params.first
          channel = find_channel(target) if is_channel?(target)

          unless channel
            Message::ServerToClient.new(
              prefix: System.hostname,
              command: Codes::ERR_NOSUCHNICK,
              params: [client.nickname, target],
              trailing: "No such nick/channel"
            ).send to: client
            return
          end

          self.class.send_names(client, channel)
        end

        def self.send_names(client, channel)
          channel.members.each_slice(8) do |users|
            Message::ServerToClient.new(
              prefix: System.hostname,
              command: Codes::RPL_NAMREPLY,
              params: [client.nickname, "=", channel.room_name],
              trailing: users.map do |user|
                [channel.power_level_mode_user_char(user), user.nickname].join("")
              end.join(" ")
            ).send to: client
          end

          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::RPL_ENDOFNAMES,
            params: [client.nickname, channel.room_name],
            trailing: "End of /NAMES list."
          ).send to: client
        end
      end
    end
  end
end
