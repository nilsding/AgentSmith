require "./base"

module AgentSmith
  module IRC
    module TextFormatters
      class Html < Base
        def format
          @text = @text.gsub("&", "&amp;")
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
end
