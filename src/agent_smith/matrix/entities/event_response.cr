require "json"

module AgentSmith
  module Matrix
    module Entities
      class EventResponse
        JSON.mapping(
          event_id: String
        )
      end
    end
  end
end
