require "crest"
require "json"

require "./entities/*"

module AgentSmith
  module Matrix
    class Client
      def initialize(homeserver)
        @api = Crest::Resource.new(File.join(homeserver, "_matrix"))
      end

      def login(user, password)
        response = @api["client/r0/login"].post(
          headers: {"Content-Type" => "application/json"},
          form: {
            :type => "m.login.password",
            :user => user,
            :password => password
          }.to_json
        )

        {true, Entities::LoginResponse.from_json(response.body)}
      rescue
        {false, nil}
      end

      def sync(access_token, timeout = 0, timeline_limit: -1)
        params = { "timeout" => timeout.to_s }

        if timeline_limit > 0
          params["filter"] = {
            "room" => {
              "timeline" => {
                "limit" => timeline_limit
              }
            }
          }.to_json
        end

        response = @api["client/r0/sync"].get(
          params: params,
          access_token: access_token
        )

        {true, Entities::SyncResponse.from_json(response.body)}
      rescue
        {false, nil}
      end
    end
  end
end
