require "json"

module AgentSmith
  module Matrix
    module Entities
      class LoginResponse
        JSON.mapping(
          access_token: String,
          home_server: String,
          user_id: String
        )
      end
    end
  end
end
