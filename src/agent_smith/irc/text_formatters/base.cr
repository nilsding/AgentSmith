module AgentSmith
  module IRC
    module TextFormatters
      module Format
        Bold      = '\u0002'
        Color     = '\u0003'
        Reset     = '\u000f'
        Reverse   = '\u0016'
        Italic    = '\u001d'
        Underline = '\u001f'

        All = [
          Bold, Color, Reset, Reverse, Italic, Underline,
        ]
      end

      # {foreground, background}
      # values from -1 to 15
      # -1 => unset
      alias Color = {Int32, Int32}

      abstract class Base
        getter new_text = [] of String | Char,
          format_stack = [] of Char,
          active_color : Color = {-1, -1}

        @readahead = 0

        def initialize(@text : String)
        end

        def format
          @text += Format::Reset

          @text.each_char_with_index do |char, i|
            next @readahead -= 1 if @readahead > 0

            case char
            when Format::Bold, Format::Italic, Format::Underline, Format::Color
              handle_format(char, i)
            when Format::Reset
              reset_format
            else
              new_text << char
            end
          end

          new_text.join("")
        end

        def handle_format(format_char : Char, index : Int32)
          return end_format(format_char, index) if format_stack.includes?(format_char)
          begin_format(format_char, index)
        end

        def valid_color_param?(char : Char)
          char.in_set?("0-9") || char == ','
        end

        protected abstract def begin_format(format_char : Char, index : Int32)
        protected abstract def end_format(format_char : Char, index : Int32)
        protected abstract def reset_format
      end
    end
  end
end
