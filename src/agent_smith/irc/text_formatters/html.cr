require "./base"

module AgentSmith
  module IRC
    module TextFormatters
      class Html < Base
        getter new_text = [] of String | Char,
          format_stack = [] of Char

        TAG_MAP = {
          Format::Bold      => "strong",
          Format::Italic    => "em",
          Format::Underline => "u",
        }

        def format
          @text = @text.gsub("&", "&amp;")
          @text = @text.gsub("<", "&lt;")
          @text += Format::Reset

          @text.each_char do |char|
            case char
            when Format::Bold, Format::Italic, Format::Underline
              handle_format(char)
            when Format::Reset
              reset_format
              @foreground_color = -1
              @background_color = -1
            else
              new_text << char
            end
          end

          new_text.join("")
        end

        private def handle_format(format_char : Char)
          raise ArgumentError.new("unknown format char: #{format_char.inspect}") unless TAG_MAP.has_key?(format_char)

          return end_format(format_char) if format_stack.includes?(format_char)
          begin_format(format_char)
        end

        private def end_format(format_char : Char)
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

        private def begin_format(format_char : Char)
          format_stack.push format_char
          new_text << "<#{TAG_MAP[format_char]}>"
        end

        private def reset_format
          while char = format_stack.pop?
            new_text << "</#{TAG_MAP[char]}>"
          end
        end
      end
    end
  end
end
