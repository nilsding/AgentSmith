require "./base"

module AgentSmith
  module IRC
    module TextFormatters
      class Html < Base
        TAG_MAP = {
          Format::Bold      => "strong",
          Format::Italic    => "em",
          Format::Underline => "u",
          Format::Color     => "font",
        }

        def format
          @text = @text.gsub("&", "&amp;")
          @text = @text.gsub("<", "&lt;")
          super
        end

        protected def begin_format(format_char : Char)
          format_stack.push format_char
          new_text << "<#{TAG_MAP[format_char]}>"
        end

        protected def end_format(format_char : Char)
          popped = [] of Char
          while char = format_stack.pop?
            break if char == format_char
            new_text << "</#{TAG_MAP[char]}>"
            popped.push char
          end

          new_text << "</#{TAG_MAP[format_char]}>"

          while char = popped.shift?
            new_text << "<#{TAG_MAP[char]}>"
            format_stack.push char
          end
        end

        protected def reset_format
          while char = format_stack.pop?
            new_text << "</#{TAG_MAP[char]}>"
          end
        end
      end
    end
  end
end
