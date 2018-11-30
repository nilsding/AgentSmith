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

        # http://www.mirc.com/colors.html
        COLORS = {
           0 => "#ffffff", # white
           1 => "#000000", # black
           2 => "#00007f", # blue
           3 => "#009300", # green
           4 => "#ff0000", # light red
           5 => "#7f0000", # Brown/dark red
           6 => "#9c009c", # purple
           7 => "#fc7f00", # orange
           8 => "#ffff00", # yellow
           9 => "#00fc00", # light green
          10 => "#009393", # cyan
          11 => "#00ffff", # light cyan
          12 => "#0000fc", # blue
          13 => "#ff00ff", # pink
          14 => "#7f7f7f", # grey
          15 => "#d2d2d2", # light grey
        }

        def format
          @text = @text.gsub("&", "&amp;")
          @text = @text.gsub("<", "&lt;")
          super
        end

        protected def begin_format(format_char : Char, index : Int32)
          format_stack.push format_char
          return begin_color(index) if format_char == Format::Color
          new_text << "<#{TAG_MAP[format_char]}>"
        end

        protected def end_format(format_char : Char, index : Int32)
          popped = [] of Char

          while char = format_stack.pop?
            break if char == format_char
            new_text << "</#{TAG_MAP[char]}>"
            popped.push char
          end

          new_text << "</#{TAG_MAP[format_char]}>"
          if format_char == Format::Color
            # maybe just a colour switch -- in this case call begin_color again
            char = '\u0000'
            if index + 1 < @text.size &&
               (char = @text[index + 1]) && valid_color_param?(char)
              format_stack.push format_char
              begin_color(index)
            end
          end

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

        private def begin_color(index)
          @readahead = 1
          raw_color_params = ""
          has_bg_color = false
          char = '\u0000'
          while index + @readahead < @text.size &&
                (char = @text[index + @readahead]) && valid_color_param?(char)
            break if char == ',' && has_bg_color
            has_bg_color = true if char == ','
            raw_color_params += char
            @readahead += 1
          end
          @readahead -= 1

          if raw_color_params.empty?
            new_text << "<font>"
            return
          end

          color_params = begin
            raw_color_params.split(",", 2).map(&.to_i)
          rescue
            [] of Int32
          end
          @active_color = case color_params.size
                          when 1
                            {color_params[0], -1}
                          when 2
                            {color_params[0], color_params[1]}
                          else
                            {-1, -1}
                          end

          attribs = color_to_attribs
          new_text << if attribs.empty?
            "<font>"
          else
            "<font #{attribs}>"
          end
        end

        private def color_to_attribs
          params = {} of String => String

          foreground, background = @active_color
          if COLORS.has_key?(foreground)
            params["color"] = COLORS[foreground]
            params["data-mx-color"] = COLORS[foreground]

            if COLORS.has_key?(background)
              params["data-mx-bg-color"] = COLORS[background]
            end
          end

          params.map { |key, val| "#{key}=#{val.inspect}" }.join(" ")
        end
      end
    end
  end
end
