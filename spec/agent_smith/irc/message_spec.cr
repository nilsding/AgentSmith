require "../../spec_helper"
require "../../../src/agent_smith/irc/message"

describe AgentSmith::IRC::Message::ClientToServer do
  describe ".parse" do
    messages = {
      "NICK nilsding\n" => {
        prefix: "", command: "NICK", params: %w[nilsding], trailing: "" },
      "USER nilsding \"nilsding.org\" \"192.168.0.3\" :Jyrki\n" => {
        prefix: "", command: "USER", params: %w[nilsding "nilsding.org" "192.168.0.3"], trailing: "Jyrki" },
      "QUIT :\n" => {
        prefix: "", command: "QUIT", params: %w[], trailing: "" },
    }

    messages.each_with_index do |(line, expected_args), i|
      it "parses message #{line.strip} correctly" do
        msg = AgentSmith::IRC::Message::ClientToServer.parse(line)

        msg.prefix.should eq expected_args[:prefix]
        msg.command.should eq expected_args[:command]
        msg.params.should eq expected_args[:params]
        msg.trailing.should eq expected_args[:trailing]
      end
    end
  end
end
