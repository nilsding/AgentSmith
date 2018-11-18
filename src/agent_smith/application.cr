require "logger"
require "option_parser"

require "./irc/server"

module AgentSmith
  VERSION = "0.1.0"

  class Application
    def self.run(argv)
      new(argv.dup).run
    end

    @@verbose = 0

    def self.verbosity
      @@verbose
    end

    def self.logger
      @@logger ||= Logger.new(
        STDOUT, level: Logger::Severity.parse(ENV.fetch("LOG_LEVEL", "DEBUG"))
      )
    end

    @port = 6667

    def initialize(@argv : Array(String)); end

    def run
      optparser = OptionParser.new do |parser|
        parser.banner = "Usage: AgentSmith [arguments]"

        parser.on("-v", "Increase verbosity level") { @@verbose += 1 }
        parser.on("-p PORT", "--port PORT", "Listen on this port (default: #{@port})") do |port|
          @port = port.to_i
        end
        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit 0
        end

        parser.invalid_option do |flag|
          STDERR.puts "error: #{flag} is not a valid option."
          STDERR.puts parser
          exit 1
        end
      end

      optparser.parse(@argv)

      IRC::Server.new(port: @port).run
    end
  end
end
