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
workato exec test --connection=jira --verbose
```

##### #get_issue
```shell
workato exec actions.get_issue.execute --connection=jira --verbose --input="fixtures/actions/get_issue/input.json" --output="fixtures/actions/get_issue/output.json"
```
