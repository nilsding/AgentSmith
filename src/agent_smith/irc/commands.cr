require "./codes"
require "./message"
require "./commands/*"

module AgentSmith
  module IRC
    module Commands
      COMMANDS = {{AgentSmith::IRC::Commands::Base.subclasses}}.map do |subclass|
        {subclass.name.split("::").last.upcase, subclass}
      end.to_h

      def self.[](command)
        COMMANDS.fetch(command.upcase, UnknownCommand)
      end
    end
  end
end
