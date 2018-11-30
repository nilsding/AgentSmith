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
        @bold = false
        @reverse = false
        @italic = false
        @underline = false
        @foreground_color = -1
        @background_color = -1

        def initialize(@text : String)
        end

        abstract def format : String
      end
    end
  end
end
