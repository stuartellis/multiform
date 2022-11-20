## Terraform Backend 0.4.0

- The builder reads the settings for the backend from a JSON file. Each environment has a *backend.json* file in the relevant subdirectory in *environments/* subdirectory.
- A *backend.json* file has an entry for the cloud provider.
- The entry for the cloud provider should contain the required items. For AWS, these items are *bucket*, *region* and *dynamodb_table*.
- The *key* should use the format */stacks/<environment_name>/<stack_name>*
