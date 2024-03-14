# Terraform module terratest action

This action allows you to run terratest against a terraform module.


## Requirements

This action expects the terraform module to use terratest and for the tests to be under the test directory in the root of the repository.


## Usage

The common workflow is running terratest to test terraform against AWS. The action accepts input paramters:

  * **SSH_PRIV_KEY** - SSH private key with clone access to any further private repositories that may be needed

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
