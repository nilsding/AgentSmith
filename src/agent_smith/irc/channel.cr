require "./user"

module AgentSmith
  module IRC
    class Channel
      getter matrix_name : String
      property canonical_alias : String = "",
        topic : String?,
        members = Set(User).new,
        power_levels = {} of User => Int32

      def initialize(@matrix_name)
        @canonical_alias = @matrix_name.sub(/^!/, "#")
      end

      # returns the room name
      def room_name
        canonical_alias.empty? ? matrix_name : canonical_alias
      end

      POWER_LEVEL_MODE = {
        Int32::MIN...1  => "",
        1...50          => "v",
        50...100        => "h",
        100..Int32::MAX => "o",
      }

      MODE_USER_CHAR = {
        "v" => "+",
        "h" => "%",
        "o" => "@",
      }

      def power_level_mode(user : User) : String
        return "" unless power_levels.has_key?(user)
        power_level = power_levels[user]
        power_level_range_mode = POWER_LEVEL_MODE.find { |range, _| range.covers?(power_level) }
        return "" unless power_level_range_mode
        power_level_range_mode[1]
      end

      def power_level_mode_user_char(user : User) : String
        user_char = power_level_mode(user)
        MODE_USER_CHAR.fetch(user_char, "")
      end
    end
  end
end
