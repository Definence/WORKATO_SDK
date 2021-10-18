# frozen_string_literal: true

{
  title: 'Spotify SDK',

  connection: {
    fields: [
      { name: 'client_id', optional: false },
      { name: 'client_secret', control_type: 'password', optional: false }
    ],

    authorization: {
      type: 'oauth2',

      # where we will redirect the user via a browser popup to provide authorization
      authorization_url: lambda do |connection|
        scopes = 'user-read-private user-read-email user-library-read user-read-recently-played'
        query = {
          response_type: 'code',
          client_id: connection['client_id'],
          redirect_uri: 'https://www.workato.com/oauth/callback',
          scopes: scopes
        }.to_param

        "https://accounts.spotify.com/authorize?#{query}"
      end,

      # pull the access_token and refresh_token from the response
      acquire: lambda do |connection, auth_code|
        post('https://accounts.spotify.com/api/token')
          .payload(
            grant_type: 'authorization_code',
            code: auth_code,
            redirect_uri: 'https://www.workato.com/oauth/callback'
          )
          .user(connection['client_id'])
          .password(connection['client_secret'])
          .request_format_www_form_urlencoded
      end,

      refresh: lambda do |connection, refresh_token|
        post('https://accounts.spotify.com/api/token')
          .payload(
            grant_type: 'refresh_token',
            refresh_token: refresh_token
          )
          .user(connection['client_id'])
          .password(connection['client_secret'])
          .request_format_www_form_urlencoded
      end,

      apply: lambda do |_connection, access_token|
        headers("Authorization": "Bearer #{access_token}")
      end,

      refresh_on: 401
    },

    base_uri: lambda do |_connection|
      'https://api.spotify.com'
    end
  },

  test: lambda do |_connection|
    get('/v1/me')
      .after_error_response(401) do |_code, body, _header, message|
        error("#{message}: #{body}")
      end
  end,

  actions: {
    search_artists: {
      title: 'Search for Artist in Spotify',
      hint: 'Returns a list of artists matching the search criteria.',
      description: 'Search <span class="provider">Artists</span> in '\
      '<span class="provider">Spotify</span>',

      input_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          {
            name: 'q',
            label: 'Artist',
            type: 'string',
            optional: false
          }
        ]
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'items',
            type: 'array',
            of: 'object',
            properties: object_definitions['artist']
          }
        ]
      end,

      # sample_output: lambda do |_connection, _input|
      # end,

      execute: lambda do |_connection, input, _input_schema, _output_schema|
        res = get('https://api.spotify.com/v1/search', input)
              .params(type: 'artist')
              .after_error_response([404]) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end

        res['artists']
      end
    }
  },

  object_definitions: {
    artist: {
      fields: lambda do
        [
          { name: 'id' },
          { name: 'name' },
          { name: 'uri', label: 'Spotify URI' },
          { name: 'external_urls' },
          { name: 'href', type: 'string', control_type: 'url' }
        ]
      end
    }
  }

  # triggers: {
  #   # Dynamic webhook example. Subscribes and unsubscribes webhooks programatically
  #   # see more at https://docs.workato.com/developing-connectors/sdk/guides/building-triggers/dynamic-webhook.html
  #   new_event: {
  #     description: "New <span class='provider'>event</span> " \
  #       "in <span class='provider'>Calendly</span>",
  #     input_fields: lambda do |_object_definitions|
  #       {
  #         name: "event",
  #         control_type: "select",
  #         pick_list: "event_type",
  #         optional: false
  #       }
  #     end,

  #     webhook_subscribe: lambda do |webhook_url, _connection, input|
  #       event_type = case input["event_type"]
  #                    when "invitee.created"
  #                      ["invitee.created"]
  #                    when "invitee.canceled"
  #                      ["invitee.canceled"]
  #                    else
  #                      ["invitee.created", "invitee.canceled"]
  #                    end

  #       post("/api/v1/hooks")
  #         .payload(url: webhook_url, events: event_type)
  #     end,

  #     webhook_notification: lambda do |_input, payload|
  #       payload
  #     end,

  #     webhook_unsubscribe: lambda do |webhook|
  #       delete("/api/v1/hooks/#{webhook['id']}")
  #     end,

  #     dedup: lambda do |event|
  #       event["event"] + "@" + event["payload"]["event"]["uuid"]
  #     end,

  #     output_fields: lambda do |object_definitions|
  #       object_definitions["event"]
  #     end,

  #     sample_output: lambda do |_connection, _input|
  #       {
  #         "event": "invitee.created",
  #         "time": "2018-03-14T19:16:01Z",
  #         "payload": {
  #           "event_type": {
  #             "uuid": "CCCCCCCCCCCCCCCC",
  #             "kind": "One-on-One",
  #             "slug": "event_type_name",
  #             "name": "Event Type Name",
  #             "duration": 15,
  #             "owner": {
  #               "type": "users",
  #               "uuid": "DDDDDDDDDDDDDDDD"
  #             }
  #           },
  #           "event": {
  #             "uuid": "BBBBBBBBBBBBBBBB",
  #             "assigned_to": [
  #               "Jane Sample Data"
  #             ],
  #             "extended_assigned_to": [
  #               {
  #                 "name": "Jane Sample Data",
  #                 "email": "user@example.com",
  #                 "primary": false
  #               }
  #             ],
  #             "start_time": "2018-03-14T12:00:00Z",
  #             "start_time_pretty": "12:00pm - Wednesday, March 14, 2018",
  #             "invitee_start_time": "2018-03-14T12:00:00Z",
  #             "invitee_start_time_pretty": "12:00pm - Wednesday, " \
  #             "March 14, 2018",
  #             "end_time": "2018-03-14T12:15:00Z",
  #             "end_time_pretty": "12:15pm - Wednesday, March 14, 2018",
  #             "invitee_end_time": "2018-03-14T12:15:00Z",
  #             "invitee_end_time_pretty": "12:15pm - Wednesday, March 14, 2018",
  #             "created_at": "2018-03-14T00:00:00Z",
  #             "location": "The Coffee Shop",
  #             "canceled": false,
  #             "canceler_name": "",
  #             "cancel_reason": "",
  #             "canceled_at": ""
  #           },
  #           "invitee": {
  #             "uuid": "AAAAAAAAAAAAAAAA",
  #             "first_name": "Joe",
  #             "last_name": "Sample Data",
  #             "name": "Joe Sample Data",
  #             "email": "not.a.real.email@example.com",
  #             "timezone": "UTC",
  #             "created_at": "2018-03-14T00:00:00Z",
  #             "is_reschedule": false,
  #             "payments": [
  #               {
  #                 "id": "ch_AAAAAAAAAAAAAAAAAAAAAAAA",
  #                 "provider": "stripe",
  #                 "amount": 1234.56,
  #                 "currency": "USD",
  #                 "terms": "sample terms of payment (up to 1,024 characters)",
  #                 "successful": true
  #               }
  #             ],
  #             "canceled": false,
  #             "canceler_name": "",
  #             "cancel_reason": "",
  #             "canceled_at": ""
  #           },
  #           "questions_and_answers": [
  #             {
  #               "question": "Skype ID",
  #               "answer": "fake_skype_id"
  #             },
  #             {
  #               "question": "Facebook ID",
  #               "answer": "fake_facebook_id"
  #             },
  #             {
  #               "question": "Twitter ID",
  #               "answer": "fake_twitter_id"
  #             },
  #             {
  #               "question": "Google ID",
  #               "answer": "fake_google_id"
  #             }
  #           ],
  #           "questions_and_responses": {
  #             "1_question": "Skype ID",
  #             "1_response": "fake_skype_id",
  #             "2_question": "Facebook ID",
  #             "2_response": "fake_facebook_id",
  #             "3_question": "Twitter ID",
  #             "3_response": "fake_twitter_id",
  #             "4_question": "Google ID",
  #             "4_response": "fake_google_id"
  #           },
  #           "tracking": {
  #             "utm_campaign": "",
  #             "utm_source": "",
  #             "utm_medium": "",
  #             "utm_content": "",
  #             "utm_term": "",
  #             "salesforce_uuid": ""
  #           },
  #           "old_event": "",
  #           "old_invitee": "",
  #           "new_event": "",
  #           "new_invitee": ""
  #         }
  #       }
  #     end
  #   }

  # Reusable methods can be called from object_definitions, picklists or actions
  # See more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/methods.html
  # methods: {
  # },

  # pick_lists: {
  #   # Picklists can be referenced by inputs fields or object_definitions
  #   # possible arguements - connection
  #   # see more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/picklists.html
  #   event_type: lambda do
  #     [
  #       # Display name, value
  #       %W[Event\ Created invitee.created],
  #       %W[Event\ Canceled invitee.canceled],
  #       %W[All\ Events all]
  #     ]
  #   end

  #   # folder: lambda do |connection|
  #   #   get("https://www.wrike.com/api/v3/folders")["data"].
  #   #     map { |folder| [folder["title"], folder["id"]] }
  #   # end
  # },
}
