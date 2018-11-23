require "crest"
require "json"

require "./entities/*"

module AgentSmith
  module Matrix
    class Client
      getter base_url

      def initialize(homeserver)
        @base_url = File.join(homeserver, "_matrix")
        @api = Crest::Resource.new(@base_url)
      end

      def login(user, password)
        response = @api["client/r0/login"].post(
          headers: {"Content-Type" => "application/json"},
          form: {
            :type     => "m.login.password",
            :user     => user,
            :password => password,
          }.to_json
        )

        {true, Entities::LoginResponse.from_json(response.body)}
      rescue
        {false, nil}
      end

      def sync(access_token, timeout = 0, timeline_limit = -1, since = "")
        params = {
          "access_token" => access_token,
          "timeout"      => timeout.to_s,
        }

        if timeline_limit > 0
          params["filter"] = {
            "room" => {
              "timeline" => {
                "limit" => timeline_limit,
              },
            },
          }.to_json
        end

        params["since"] = since unless since.empty?

        response = @api["client/r0/sync"].get(
          params: params
        )

        {true, Entities::SyncResponse.from_json(response.body)}
      rescue
        {false, nil}
      end
    end
  end
end
