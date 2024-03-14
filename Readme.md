# Terraform module terratest action

This action allows you to run terratest against a Terraform module.


## Requirements

This action expects the Terraform module to use terratest and for the tests to be under the `test` directory in the root of the repository.


## Options
As defined in [action.yml](./action.yml).

|      Option       |                                            Description                                                                         | Required |
|-------------------|--------------------------------------------------------------------------------------------------------------------------------|----------|
| SSH_PRIV_KEY      | Private SSH key with access to private repos that tests will need access to                                                    | Yes      |
| terraform_version | If set, override any .terraform-version file in the repo and use this specific version. `latest` will use most-recent version. | No       |
| timeout           | Timeout before cancelling the tests. Defaults to 50m.                                                                          | No       |


This action typically creates and destroys actual infrastructure and should only be run against dedicated test / sandbox accounts.

```yaml
name: Automated Testing
on: [push]

jobs:
  test:
    name: checkout
    runs-on: ubuntu-latest
    steps:
      - name: checkout step
        uses: actions/checkout@v1
        with:
          fetch-depth: 1
      - name: test execution step
        uses: fac/terratest-github-action@master
        with:
          SSH_PRIV_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```
