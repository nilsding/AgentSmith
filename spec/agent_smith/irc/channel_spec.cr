require "../../spec_helper"
require "../../../src/agent_smith/irc/channel"

private macro test_power_level_method(method_name, test_data)
  describe "#" + "{{ method_name }}" do
    user = AgentSmith::IRC::User.new("@nilsding:example.com")

    context "when no power level set for user" do
      channel = AgentSmith::IRC::Channel.new("!someroom:example.com")
      channel.members << user

      it "returns \"\"" do
        channel.{{ method_name }}(user).should eq ""
      end
    end

    {{ test_data }}.each do |level, expected|
      context "when power level for user is set to #{level}" do
        channel = AgentSmith::IRC::Channel.new("!someroom:example.com")
        channel.members << user
        channel.power_levels[user] = level

        it "returns #{expected.inspect}" do
          channel.{{ method_name }}(user).should eq expected
        end
      end
    end
  end
end

describe AgentSmith::IRC::Channel do
  test_power_level_method(power_level_mode, {
        -35 => "",
          0 => "",
          1 => "v",
         49 => "v",
         50 => "h",
         99 => "h",
        100 => "o",
    2345892 => "o",
  })

  test_power_level_method(power_level_mode_user_char, {
        -35 => "",
          0 => "",
          1 => "+",
         49 => "+",
         50 => "%",
         99 => "%",
        100 => "@",
    2345892 => "@",
  })
end
