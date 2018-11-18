require "socket"
require "system"

require "../application"
require "../errors"
require "./client"
require "./commands"
require "./message"

module AgentSmith
  module IRC
    class Server
      @hostname = System.hostname

      def initialize(@port : Int32); end

      def run
        server = TCPServer.new("0.0.0.0", @port)
        Application.logger.info("Listening on #{server.local_address}")

        while client = server.accept?
          spawn handle_client(Client.new client)
        end
      end

      def handle_client(client)
        Application.logger.info("Accepted connection from #{client.remote_address}")

        send_welcome_string to: client

        while line = client.gets
          Application.logger.debug("#{client.remote_address} -> #{line.inspect}")
          handle line, from: client
        end

        client.close
        Application.logger.info("Client #{client.ident_s} closed connection")
      end

      private def send_welcome_string(to client)
        Message::ServerToClient.new(
          command: "NOTICE",
          params: %w[Auth],
          trailing: "*** *notices your connection* OwO what's this?"
        ).send to: client
      end

      private def handle(line : String, from client)
        msg = Message::ClientToServer.parse(line)
        handle msg, from: client
      rescue e : ParseError
        Application.logger.warn("got #{e.inspect} from #{client.remote_address} for #{line.inspect}, ignoring")
      end

      private def handle(msg : Message::ClientToServer, from client)
        Commands[msg.command].call(msg, client)
      end
    end
  end
end
