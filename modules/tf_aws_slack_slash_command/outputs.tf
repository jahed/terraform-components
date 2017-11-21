output "command_url" {
  value = "https://${aws_api_gateway_deployment.slack_slash_commands.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.slack_slash_commands.stage_name}${aws_api_gateway_resource.command.path}"
}

output "lambda_role_name" {
  description = "The IAM Role Name assigned to the Lambda. Use this for attaching more IAM Policies to the Lambda."
  value = "${aws_iam_role.lambda.name}"
}
