require "json"

module AgentSmith
  module Matrix
    module Entities
      class SyncResponse
        JSON.mapping(
          rooms: SyncResponse::Rooms
        )

        class Rooms
          JSON.mapping(
            join: Hash(String, Room)
          )
        end

        class Room
          JSON.mapping(
            timeline: Timeline,
            unread_notifications: UnreadNotifications,
          )

          class Timeline
            JSON.mapping(
              events: Array(Event)
            )
          end

          class Event
            JSON.mapping(
              content: EventContent,
              origin_server_ts: Int64,
              sender: String,
              type: String
            )
          end

          class EventContent
            JSON.mapping(
              body: { type: String, nilable: true },
              msgtype: { type: String, nilable: true }
            )
          end

          class UnreadNotifications
            JSON.mapping(
              highlight_count: { type: Int32, nilable: true },
              unread_count: { type: Int32, nilable: true }
            )
          end
        end
      end
    end
  end
end
