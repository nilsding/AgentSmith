require "./base"

module AgentSmith
  module IRC
    module TextFormatters
      class None < Base
        protected def begin_format(format_char : Char, index)
        end

        protected def end_format(format_char : Char, index)
        end

        protected def reset_format
        end
      end
    end
  end
end
