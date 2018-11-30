module AgentSmith
  module IRC
    class TextFormatter
      private module Format
        Bold      = '\u0002'
        Color     = '\u0003'
        Reset     = '\u000f'
        Reverse   = '\u0016'
        Italic    = '\u001d'
        Underline = '\u001f'
      end

      def self.format(text : String)
        new(text.dup).format
      end

      @bold = false
      @reverse = false
      @italic = false
      @underline = false
      @foreground_color = -1
      @background_color = -1

      def initialize(@text : String)
      end

      def format
        @text = @text.gsub("<", "&lt;")
        @text += Format::Reset
        new_text = [] of String | Char

        @text.each_char do |char|
          case char
          when Format::Bold
            @bold = !@bold
            new_text << (@bold ? "<strong>" : "</strong>")
          when Format::Italic
            @italic = !@italic
            new_text << (@italic ? "<em>" : "</em>")
          when Format::Underline
            @underline = !@underline
            new_text << (@underline ? "<u>" : "</u>")
          when Format::Reset
            new_text << "</strong>" if @bold
            @bold = false
            new_text << "</em>" if @italic
            @italic = false
            new_text << "</u>" if @underline
            @underline = false
            @foreground_color = -1
            @background_color = -1
          else
            new_text << char
          end
        end

        new_text.join("")
      end
    end
  end
end
