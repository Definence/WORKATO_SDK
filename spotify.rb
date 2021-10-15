# frozen_string_literal: true

require 'byebug'

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

      input_fields: lambda do
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

  triggers: {
  },

  methods: {
  },

  pick_lists: {
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
}
