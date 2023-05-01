#!/bin/bash

set -eo pipefail

GODIR=/go/src/github.com/fac

# Setup SSH KEY for private repo access
echo "Setting up SSH key"
mkdir -p /root/.ssh && chmod 700 /root/.ssh
echo "${INPUT_SSH_PRIV_KEY}" > /root/.ssh/id_rsa
unset INPUT_SSH_PRIV_KEY

chmod 600 /root/.ssh/id_rsa
eval $(ssh-agent -s)
ssh-add

# Pre-seed host keys for github.com
ssh-keyscan github.com >> /root/.ssh/known_hosts

# Allow terraform version override
if [[ ! -z "$INPUT_TERRAFORM_VERSION" ]]; then
  echo "terraform_version override set to $INPUT_TERRAFORM_VERSION"
  echo "$INPUT_TERRAFORM_VERSION" > .terraform-version
  tfenv install "$INPUT_TERRAFORM_VERSION"
else
  # Make sure we have the correct terraform version, if we have a .terraform-version file
  tfenv install || true
fi

if [ "$INPUT_ONLY_TEST_MODIFIED" == "true" ]; then
  if [ -z "$INPUT_TARGET_BRANCH" ]; then
    INPUT_TARGET_BRANCH="master"
  fi
  git_diff="$(git diff --name-only "origin/$INPUT_TARGET_BRANCH...")"
  tests_to_run=$(python3 -c '
import sys, re; from pathlib import Path
for input_line in sys.stdin:
  filename = input_line.rstrip()
  if filename.endswith(".tf"):
    module_name = Path(filename).parent.name
    test_name = module_name.title().replace("-", "")
    print(f"-run Test{test_name}")
  elif filename.endswith("_test.go"):
    with open(filename, "r") as file:
      for line in file:
        if re.search(r"func Test[A-Z]", line):
          print(f"-run {line.split()[1]}")
' <<< "$git_diff" | sort -u)
  if [ -z "$tests_to_run" ]; then
    echo "No tests to run"
    exit 0
  fi
fi

if [ -f "$PWD/test/go.mod" ]; then
    echo "Detected go.mod in test directory. Using that for dependencies."
    cd "$PWD/test"
else
    # Setup under GOPATH so dep etc works
    echo "Setting up GOPATH to include $PWD"
    CHECKOUT=$(basename "$PWD")
    mkdir -p $GODIR
    ln -s "$(pwd)" "${GODIR}/${CHECKOUT}"

    cd "${GODIR}/${CHECKOUT}/test"
    echo "Running go dep"
    dep ensure
fi

echo "Starting tests"
# shellcheck disable=SC2086
gotestsum --format standard-verbose -- -v -timeout 50m -parallel 128 $tests_to_run
