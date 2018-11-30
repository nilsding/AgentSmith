require "./base"

module AgentSmith
  module IRC
    module TextFormatters
      class None < Base
        def format
          @text.delete { |c| Format::All.includes?(c) }
        end
      end
    end
  end
end
