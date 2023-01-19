#!/bin/bash

set -eo pipefail

# Setup SSH KEY for private repo access
echo "Setting up SSH key"
mkdir -p /root/.ssh && chmod 700 /root/.ssh
echo "${INPUT_SSH_PRIV_KEY}" >/root/.ssh/id_rsa
unset INPUT_SSH_PRIV_KEY
chmod 600 /root/.ssh/id_rsa
eval $(ssh-agent -s)
ssh-add

# Pre-seed host keys for github.com
ssh-keyscan github.com >>/root/.ssh/known_hosts

# Allow terraform version override
if [[ ! -z "$INPUT_TERRAFORM_VERSION" ]]; then
  echo "terraform_version override set to $INPUT_TERRAFORM_VERSION"
  echo "$INPUT_TERRAFORM_VERSION" >.terraform-version
  tfenv install "$INPUT_TERRAFORM_VERSION"
else
  # Make sure we have the correct terraform version, if we have a .terraform-version file
  tfenv install || true
fi

# Install Go Dependicies
cd "$PWD/test"
go install

# If we pass in a list of modified modules then only run those tests 
# otherwise run all tests.
if [[ ! -z "$modified_modules" ]]; then
  package_name=`cat go.mod | grep module | awk '{print $2}'`
  for i in $modified_modules; do
    TESTS+=$(echo "$package_name/$i ")
  done
  echo "Running tests: $TESTS"
  gotestsum --format standard-verbose -- -v -timeout 50m -parallel 128 $TESTS
else
  echo "Running all tests"
  gotestsum --format standard-verbose -- -v -timeout 50m -parallel 128
fi
