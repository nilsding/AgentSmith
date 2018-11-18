require "system"

require "./base"

module AgentSmith
  module IRC
    module Commands
      class Motd < Base
        MOTD = <<-EOMOTD
   ___                __
  / _ |___ ____ ___  / /_
 / __ / _ `/ -_) _ \\/ __/
/_/ |_\\_, /\\__/_//_/\\__/
     /___/____      _ __  __ TM
         / __/_ _  (_) /_/ /
        _\\ \\/  ' \\/ / __/ _ \\
       /___/_/_/_/_/\\__/_//_/

yeaaah... hyper hyper
EOMOTD

        # msg is ignored here
        def call
          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::RPL_MOTDSTART,
            params: [client.nickname],
            trailing: "#{System.hostname} message of the day"
          ).send to: client

          MOTD.each_line do |line|
            Message::ServerToClient.new(
              prefix: System.hostname,
              command: Codes::RPL_MOTD,
              params: [client.nickname],
              trailing: "-#{line}"
            ).send to: client
          end

          Message::ServerToClient.new(
            prefix: System.hostname,
            command: Codes::RPL_ENDOFMOTD,
            params: [client.nickname],
            trailing: "End of message of the day"
          ).send to: client
        end
      end
    end
  end
end
