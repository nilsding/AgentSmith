require "logger"
require "option_parser"
require "secrets"

require "./irc/server"
require "./matrix/client"

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

    def self.matrix_access_token
      ENV["MATRIX_ACCESS_TOKEN"]
    end

    def self.logger
      @@logger ||= Logger.new(
        STDOUT, level: Logger::Severity.parse(ENV.fetch("LOG_LEVEL", "DEBUG"))
      )
    end

    @homeserver = ""
    @port = 6667

    def initialize(@argv : Array(String)); end

    def run
      optparser = OptionParser.new do |parser|
        parser.banner = "Usage: AgentSmith [arguments]"

        parser.on("-v", "Increase verbosity level") { @@verbose += 1 }
        parser.on("-s HOMESERVER", "--homeserver HOMESERVER", "Use this matrix homeserver (e.g. https://matrix.org)") do |homeserver|
          @homeserver = homeserver
        end
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

      if @homeserver.empty?
        STDERR.puts "error: HOMESERVER was not set"
        STDERR.puts optparser
        exit 1
      end

      # TODO: store those things in a database, maybe?
      unless ENV.has_key?("MATRIX_ACCESS_TOKEN")
        puts "Performing first time login on #{@homeserver}"
        print "Username: "
        username = gets
        if username.nil?
          puts "Oopsie woopsie uwu"
          exit 1
        end
        username = username.not_nil!.strip
        password = Secrets.gets("Password: ")

        ok, response = Matrix::Client.new(@homeserver).login(username, password)

        unless ok
          puts "Oopsie woopsie uwu"
          exit 1
        end

        access_token = response.not_nil!.access_token

        puts
        puts "Your access token is: #{access_token}"
        puts
        puts "Please place it in your ENV like this:"
        puts "   setenv MATRIX_ACCESS_TOKEN #{access_token.inspect}"
        puts "                            ----- or -----"
        puts "   export MATRIX_ACCESS_TOKEN=#{access_token.inspect}"
        puts

        exit
      end

      IRC::Server.new(port: @port).run
    end
  end
end
