# require 'byebug'

{
  title: "Jira SDK Lab",

  connection: {
    fields: [
      {
        name: 'subdomain',
        control_type: 'subdomain',
        url: '.atlassian.net',
        hint: 'Your Atlassian URL for your Jira Cloud instance.'
      }, {
        name: 'username',
        optional: false,
        hint: 'Your email.'
      }, {
        name: 'api_token',
        control_type: 'password',
        label: 'API token'
      },
    ],

    authorization: {
      type: "basic_auth",
      apply: lambda do |connection|
        user(connection['username'])
        password(connection['api_token'])
      end
    },

    base_uri: lambda do |connection|
      "https://#{connection['subdomain']}.atlassian.net"
    end
  },

  test: lambda do |_connection|
    get("/rest/api/3/myself").
      after_error_response(401) do |code, body, header, message|
        error("#{message}: #{body}")
      end
  end,

  # https://docs.workato.com/developing-connectors/sdk/sdk-reference/actions.html#structure
  actions: {
    get_issue: {
      title: 'Get issue from Jira',
      subtitle: 'Get issue details from Jira Cloud',
      description: "Get <span class='provider'>issue ID and issue summary</span> " \
                   "from <span class='provider'>Jira Cloud</span>",
      help: "This action retriieves your issue ID and issue summary from Jira Cloud. Use thus acttion" \
            " to search for issues from your Jira Cloud instance",


      input_fields: lambda do |object_definitions, connection, config_fields|
        [
          {
            name: 'issue_id',
            label: 'Issue ID',
            optional: false,
          },
        ]
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: 'key', label: 'Issue key' },
          { name: 'id', label: 'Issue ID' },
          { name: 'fields', label: 'Issue fields', type: 'object', properties: [
            { name: 'summary', label: 'Summary' },
          ] },
        ]
      end,

      execute: lambda do |_connection, input, _input_schema, _output_schema|
        url = "/rest/api/3/issue/#{input['issue_id']}"
        get(url).
          after_error_response([404]) do |code, body, header, message|
            error("#{message}: #{body}")
          end
      end,
    },
  },

  triggers: {

  },

  methods: {

  },

  object_definitions: {

  },

  pick_lists: {

  }
}
