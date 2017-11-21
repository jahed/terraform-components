# tf_aws_slack_slash_command

Creates an AWS API Gateway Resource hooked up to an AWS Lambda to handle Slack Slash Commands.

## Usage

See `variables.tf` and `outputs.tf` for descriptions of each field.

### Example

This example adds a `/gaming` endpoint to a given AWS API Gateway Resource.

```terraform
variable "region" {
  default = "your aws region"
}

variable "account_id" {
  default = "your account id"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_api_gateway_rest_api" "slack_slash_commands" {
  name = "slack_slash_commands"
  description = "Slack Slash Commands Endpoint"
}

data "archive_file" "gaming_slack_slash_command_build" {
  type = "zip"
  source_dir = "${path.module}/package"
  output_path = "${path.module}/archives/lambda.zip"
}

module "gaming_slack_slash_command" {
  source     = "../slack_slash_command"
  region     = "${var.region}"
  account_id = "${var.account_id}"

  command          = "gaming"
  filename         = "${data.archive_file.gaming_slack_slash_command_build.output_path}"
  source_code_hash = "${data.archive_file.gaming_slack_slash_command_build.output_base64sha256}"

  runtime = "nodejs6.10"
  handler = "index.handler"
  timeout = 60

  api_id               = "${aws_api_gateway_rest_api.slack_slash_commands.id}"
  root_resource_id     = "${aws_api_gateway_rest_api.slack_slash_commands.root_resource_id}"
}
```