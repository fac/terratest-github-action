# Terraform module terratest action

This action allows you to run terratest against a terraform module.


## Requirements

This action expects the terraform module to use terratest and for the tests to be under the test directory in the root of the repository.


## Usage

The common workflow is running terratest to test terraform against AWS. The action accepts input paramters:

  * **SSH_PRIV_KEY** - SSH private key with clone access to any further private repositories that may be needed

For authentication with AWS you can set the environment variables:

  * **AWS_ACCESS_KEY_ID**
  * **AWS_SECRET_ACCESS_KEY**

You can pass in a list of modified modules from the source to only run those tests.
```yaml
name: Terratest
on: [push]

jobs:
  test:
    name: Checkout
    runs-on: ubuntu-latest
    steps:
      - name: checkout step
        uses: actions/checkout@v1
        with:
          fetch-depth: 0

      - name: Grab list of modified modules dynamically using diff against master
        run: echo "modified_modules=$(git diff origin/master... --name-only examples/ modules/ | awk -F'/' '{print $(NF-1)}'| sort -u | tr '\n' ' ')" >> "$GITHUB_ENV"

      - name: Terratest
        uses: fac/terratest-github-action@2.x-rc
        with:
          SSH_PRIV_KEY: ${{ secrets.TF_MODULES_SSH_KEY }}
          modified_modules: ${{ env.modified_modules }}
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

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
