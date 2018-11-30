require "../../spec_helper"
require "../../../src/agent_smith/irc/text_formatter"

describe AgentSmith::IRC::TextFormatter do
  describe ".format" do
    texts = {
      "\u0002bold lol\u0002 not more bold \u001Funderline \u0002underline bold" => "<strong>bold lol</strong> not more bold <u>underline <strong>underline bold</strong></u>",
    }

    texts.each do |irc_format, html_format|
      it "formats message #{irc_format.inspect} correctly" do
        AgentSmith::IRC::TextFormatter.format(irc_format).should eq html_format
      end
    end
  end
end
