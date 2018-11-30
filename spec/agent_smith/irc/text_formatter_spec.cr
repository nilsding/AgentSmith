require "../../spec_helper"
require "../../../src/agent_smith/irc/text_formatter"

describe AgentSmith::IRC::TextFormatter do
  describe ".format_html" do
    texts = {
      "\u0002bold lol\u0002 not more bold \u001Funderline \u0002underline bold"                => "<strong>bold lol</strong> not more bold <u>underline <strong>underline bold</strong></u>",
      "hahaha <script>&quot;geh&auml;ckt&quot;</script>"                                       => "hahaha &lt;script>&amp;quot;geh&amp;auml;ckt&amp;quot;&lt;/script>",
      "\u0002bold \u001Funderline bold\u0002 only underline"                                   => "<strong>bold <u>underline bold</u></strong><u> only underline</u>",
      "\u{0003}9yay colours"                                                                   => "<font color=\"#00fc00\" data-mx-color=\"#00fc00\">yay colours</font>",
      "\u{0003}13more colours!\u0003 and now none!"                                            => "<font color=\"#ff00ff\" data-mx-color=\"#ff00ff\">more colours!</font> and now none!",
      "\u{0003}9,13super nice \u0002colours with background and bold"                          => "<font color=\"#00fc00\" data-mx-color=\"#00fc00\" data-mx-bg-color=\"#ff00ff\">super nice <strong>colours with background and bold</strong></font>",
      "\u{0003}9for my next trick\u{0003}7 i'll switch colours"                                => "<font color=\"#00fc00\" data-mx-color=\"#00fc00\">for my next trick</font><font color=\"#fc7f00\" data-mx-color=\"#fc7f00\"> i'll switch colours</font>",
      "\u{0003}invalid colours should not break"                                               => "<font>invalid colours should not break</font>",
      "\u{0003}9color enabled \u0002bold enabled \0003color disabled but bold is still active" => "<font color=\"#00fc00\" data-mx-color=\"#00fc00\">color enabled <strong>bold enabled </strong></font><strong>color disabled but bold is still active</strong>",
      "\u{0003}"                                                                               => "<font></font>",
      "\u{0003}\u{0003}"                                                                       => "<font></font>",
      "\u{0003},"                                                                              => "<font></font>",
      "\u{0003},2lol"                                                                          => "<font>lol</font>",
      "\u{0003}9,13,5lol"                                                                      => "<font color=\"#00fc00\" data-mx-color=\"#00fc00\" data-mx-bg-color=\"#ff00ff\">,5lol</font>",
      "\u{0003}2"                                                                              => "<font color=\"#00007f\" data-mx-color=\"#00007f\"></font>",
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
