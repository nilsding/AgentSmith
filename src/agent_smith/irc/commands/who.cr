require "system"

require "./base"

module AgentSmith
  module IRC
    module Commands
      class Who < Base
        def call
          unless msg.params.size == 1
            send_need_more_params
            return
          end

          target = msg.params.first

          if is_channel?(target)
            channel = find_channel(target)
            return unless channel

            channel.members.each do |user|
              # 352    RPL_WHOREPLY
              #        "<channel> <user> <host> <server> <nick>
              #        ( "H" / "G" > ["*"] [ ( "@" / "+" ) ]
              #        :<hopcount> <real name>"
              username = is_self?(user) ? client.username : user.nickname
              hostname = is_self?(user) ? client.hostname : user.hostname
              server = is_self?(user) ? System.hostname : user.hostname
              hopcount = is_self?(user) ? 0 : 1
              realname = is_self?(user) ? client.realname : user.nickname
              Message::ServerToClient.new(
                prefix: System.hostname,
                command: Codes::RPL_WHOREPLY,
                params: [client.nickname, target, username, hostname, server, user.nickname, "H"],
                trailing: "#{hopcount} #{realname}"
              ).send to: client
            end
          end

          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::RPL_ENDOFWHO,
            params: [client.nickname, target],
            trailing: "End of /WHO list."
          ).send to: client
        end

        private macro is_self?(user)
          user.nickname == client.nickname
        end
      end
    end
  end
end
