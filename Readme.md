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


## Usage

This action typically creates and destroys actual infrastructure and should only be run against dedicated test / sandbox AWS accounts. Create a role in the account with permissions to manage the resources defined in your module (or use a shared CI role).

We provide [a reuseable workflow that runs this action](./.github/workflows/terratest.yml), after checking out the calling repo and assuming the passed AWS role. Here's an example of calling it:

```yaml
name: Automated Testing
on: [push]

jobs:
  test-infra:
    uses: fac/terratest-github-action/.github/workflows/terratest.yml@1.x-stable
    permissions:
      id-token: write
      contents: read
    secrets:
      SSH_PRIV_KEY: ${{ secrets.SSH_PRIV_KEY }}
    with:
      role-to-assume: ${{ inputs.role-to-assume }}
```
