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

      abstract class Base
        getter new_text = [] of String | Char,
          format_stack = [] of Char

        @foreground_color = -1
        @background_color = -1

        def initialize(@text : String)
        end

        def format
          @text += Format::Reset

          @text.each_char do |char|
            case char
            when Format::Bold, Format::Italic, Format::Underline, Format::Color
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

        def handle_format(format_char : Char)
          return end_format(format_char) if format_stack.includes?(format_char)
          begin_format(format_char)
        end

        protected abstract def begin_format(format_char : Char)
        protected abstract def end_format(format_char : Char)
        protected abstract def reset_format
      end
    end
  end
end
