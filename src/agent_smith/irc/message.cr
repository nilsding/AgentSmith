require "./codes"
require "../errors"

module AgentSmith
  module IRC
    module Message
      abstract class Base
        property prefix : String,
          command : String,
          params : Array(String),
          trailing : String

        abstract def to_msg

        def initialize(@command : String, @prefix = "", @params = [] of String, @trailing = ""); end

        def initialize(command : IRC::Codes, @prefix = "", @params = [] of String, @trailing = "")
          initialize(command.code_s, prefix, params, trailing)
        end

        def send(to client)
          Application.logger.debug "#{client.remote_address} <- #{self.to_msg.inspect}"
          client << self.to_msg
          client << "\r\n"
        end
      end

      class ClientToServer < Base
        def to_msg
          [command, params.join(" ")].tap do |ary|
            ary << ":#{trailing}" unless trailing.empty?
          end.join(" ")
        end

        def self.parse(line) : ClientToServer?
          line = line.strip
          raise ParseError.new("can not parse empty line") if line.empty?

          # optional prefix
          prefix = ""
          if line[0] == ':'
            offset = line.index(' ')
            raise ParseError.new("just the prefix?  seriously?") unless offset
            prefix = line[1..offset]
            line = line[offset..-1]
          end

          # command
          command = line
          offset = line.index(' ')
          return new(prefix: prefix, command: command) unless offset
          command = line[0..offset].strip.upcase
          raise ParseError.new("invalid command: #{command.inspect}") unless command =~ /\A([a-z]+|\d{3})\z/i
          line = line[offset..-1]

          # params + trailing
          line = line[1..-1] if line[0] == ':'
          # some people use the : in their channel name for no apparent reason
          # which would fuck up everything.  therefore, check for " :" instead
          # of just ' '.
          offset = line.index(" :")
          trailing = ""
          if offset
            trailing = line[(offset + 2)..-1]
            line = line[0..offset]
          end
          params = line.split(' ', remove_empty: true)

          new(
            prefix: prefix,
            command: command,
            params: params,
            trailing: trailing
          )
        end
      end

      class ServerToClient < Base
        def to_msg
          [command, params.join(" ")].tap do |ary|
            ary.unshift(":#{prefix}") unless prefix.empty?
            ary << ":#{trailing}" unless trailing.empty?
          end.join(" ")
        end
      end
    end
  end
end
