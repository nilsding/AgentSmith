require "json"

module AgentSmith
  module Matrix
    module Entities
      class SyncResponse
        JSON.mapping(
          next_batch: String,
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
            state: State,
          )

          class State
            JSON.mapping(
              events: Array(Event)
            )
          end

          class Timeline
            JSON.mapping(
              events: Array(Event)
            )
          end

          class Event
            JSON.mapping(
              content: EventContent,
              event_id: String,
              origin_server_ts: Int64,
              sender: String,
              type: String,
              membership: {type: String, nilable: true},
            )
          end

          class EventContent
            JSON.mapping(
              alias: {type: String, nilable: true},
              topic: {type: String, nilable: true},
              name: {type: String, nilable: true},
              body: {type: String, nilable: true},
              format: {type: String, nilable: true},
              formatted_body: {type: String, nilable: true},
              msgtype: {type: String, nilable: true},
              url: {type: String, nilable: true},
              membership: {type: String, nilable: true}
            )
          end

          class UnreadNotifications
            JSON.mapping(
              highlight_count: {type: Int32, nilable: true},
              unread_count: {type: Int32, nilable: true}
            )
          end
        end
      end
    end
  end
end
