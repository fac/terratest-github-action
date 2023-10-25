config {
  # Currently superlinter is unable to download private repos as dependencies
  # meaning we have to disable module inspection.
  # https://github.com/github/super-linter/blob/01d3218744765b55c3b5ffbb27e50961e50c33c5/README.md?plain=1#L582
  module = false
}

plugin "aws" {
  enabled = true
  source = "github.com/terraform-linters/tflint-ruleset-aws"
  version = "0.22.1"
}

rule "terraform_required_providers" {
  enabled = false
}
