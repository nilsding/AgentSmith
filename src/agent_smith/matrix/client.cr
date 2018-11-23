require "crest"
require "json"
require "uri"
require "uuid"

require "./entities/*"

module AgentSmith
  module Matrix
    class Client
      getter base_url

      def initialize(homeserver)
        @base_url = File.join(homeserver, "_matrix")
      end

      def login(user, password)
        response = api_client["client/r0/login"].post(
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
          "timeout" => timeout.to_s,
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

        response = api_client["client/r0/sync"].get(
          params: params,
          headers: {"Authorization" => "Bearer #{access_token}"}
        )

        {true, Entities::SyncResponse.from_json(response.body)}
      rescue
        {false, nil}
      end

      def room_send(access_token, room_id : String, event_type : String, content = {} of String => String)
        room_id = URI.escape(room_id)
        transaction_id = UUID.random

        response = api_client["client/r0/rooms/#{room_id}/send/#{event_type}/#{transaction_id}"].put(
          headers: {"Content-Type"  => "application/json",
                    "Authorization" => "Bearer #{access_token}"},
          form: content.to_json
        )

        {true, Entities::EventResponse.from_json(response.body)}
      rescue
        {false, nil}
      end

      private def api_client
        Crest::Resource.new(@base_url)
      end
    end
  end
end
