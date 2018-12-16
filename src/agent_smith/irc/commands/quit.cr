require "./base"
require "../text_formatter"

module AgentSmith
  module IRC
    module Commands
      class Quit < Base
        def call
          quit_message = msg.trailing.empty? ? "Client exited" : "Quit: #{msg.trailing}"
          Message::ServerToClient.new(
            command: "ERROR",
            trailing: "Closing link: (#{client.username}@#{client.hostname}) [#{quit_message}]"
          ).send to: client

          client.should_close = true
        end
      end
    end
  end
end
