require "../../spec_helper"
require "../../../src/agent_smith/irc/text_formatter"

describe AgentSmith::IRC::TextFormatter do
  describe ".format_html" do
    texts = {
      "\u0002bold lol\u0002 not more bold \u001Funderline \u0002underline bold" => "<strong>bold lol</strong> not more bold <u>underline <strong>underline bold</strong></u>",
      "hahaha <script>&quot;geh&auml;ckt&quot;</script>"                        => "hahaha &lt;script>&amp;quot;geh&amp;auml;ckt&amp;quot;&lt;/script>",
    }

    texts.each do |irc_format, html_format|
      it "formats message #{irc_format.inspect} correctly" do
        AgentSmith::IRC::TextFormatter.format_html(irc_format).should eq html_format
      end
    end
  end

  describe ".format_none" do
    texts = {
      "\u0002bold lol\u0002 not more bold \u001Funderline \u0002underline bold" => "bold lol not more bold underline underline bold",
    }

    texts.each do |irc_format, none_format|
      it "formats message #{irc_format.inspect} correctly" do
        AgentSmith::IRC::TextFormatter.format_none(irc_format).should eq none_format
      end
    end
  end
end
