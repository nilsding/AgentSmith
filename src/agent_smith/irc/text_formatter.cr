require "./text_formatters/*"

module AgentSmith
  module IRC
    module TextFormatter
      def self.format(text : String, formatter : AgentSmith::IRC::TextFormatters::Base.class)
        formatter.new(text.dup).format
      end

      {% for formatter in AgentSmith::IRC::TextFormatters::Base.subclasses %}
        def self.format_{{formatter.name.split("::").last.downcase.id}}(text : String)
          format(text, formatter = {{ formatter }})
        end
      {% end %}
    end
  end
end
