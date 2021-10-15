[![Workato SDK](https://github.com/Definence/WORKATO_SDK/actions/workflows/ruby.yml/badge.svg?branch=master)](https://github.com/Definence/WORKATO_SDK/actions/workflows/ruby.yml)

### Based on [SDK](https://github.com/workato/workato-connector-sdk)
### ENV variables [here](https://docs.google.com/document/d/190QP8DSwGMhJ11xSEKEw1fc4h_EWMcxWtl0Bbstx7vA/edit)

### Edit settings credentials
```shell
EDITOR=nano workato edit settings.yaml.enc
```

### Run specs
```shell
rspec spec
```

### Jira

##### #test_connection
```shell
workato exec test --connector="jira.rb" --connection=jira --verbose
```

##### #get_issue
```shell
workato exec actions.get_issue.execute --connector="jira.rb" --connection=jira --verbose --input="fixtures/actions/jira/get_issue_input.json" --output="fixtures/actions/jira/get_issue_output.json"
```

### Spotify

##### #test_connection
```shell
workato exec test --connector="spotify.rb" --connection=spotify --verbose
```

##### #search_artists
```shell
workato exec actions.search_artists.execute --connector="spotify.rb" --connection=spotify --verbose --input="fixtures/actions/spotify/search_artists_input.json" --output="fixtures/actions/spotify/search_artists_output.json"
```
