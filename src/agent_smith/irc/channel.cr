require "./user"

module AgentSmith
  module IRC
    class Channel
      getter matrix_name : String
      property canonical_alias : String = "",
        topic : String?,
        members = Set(User).new

      def initialize(@matrix_name)
        @canonical_alias = @matrix_name.sub(/^!/, "#")
      end

      # returns the room name
      def room_name
        canonical_alias.empty? ? matrix_name : canonical_alias
      end
    end
  end
end
