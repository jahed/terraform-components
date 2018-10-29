data "aws_iam_policy_document" "allow_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "apigateway.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "allow_logs" {
  statement {
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${aws_lambda_function.handler.function_name}:*",
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "slack_event_subscription_${var.app_name}"
  assume_role_policy = "${data.aws_iam_policy_document.allow_assume_role.json}"
}

resource "aws_iam_policy" "allow_logs" {
  name   = "slack_event_subscription_allow_logs_${var.app_name}"
  policy = "${data.aws_iam_policy_document.allow_logs.json}"
}

resource "aws_iam_role_policy_attachment" "allow_logs" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.allow_logs.arn}"
}

resource "aws_lambda_function" "handler" {
  function_name = "slack_event_subscription_${var.app_name}"
  description   = "Handler for '${var.app_name}' Slack App's Event Subscription"
  role          = "${aws_iam_role.lambda.arn}"
  tags          = "${var.tags}"

  filename         = "${var.filename}"
  source_code_hash = "${var.source_code_hash}"
  runtime          = "${var.runtime}"
  handler          = "${var.handler}"
  timeout          = "${var.timeout}"

  environment {
    variables = "${merge(map("terraformed", true), var.environment_variables)}"
  }
}

resource "aws_api_gateway_resource" "event" {
  rest_api_id = "${var.api_id}"
  parent_id   = "${var.root_resource_id}"
  path_part   = "${var.app_name}"
}

resource "aws_api_gateway_method" "event" {
  rest_api_id   = "${var.api_id}"
  resource_id   = "${aws_api_gateway_resource.event.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "event" {
  rest_api_id             = "${var.api_id}"
  resource_id             = "${aws_api_gateway_resource.event.id}"
  http_method             = "${aws_api_gateway_method.event.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.handler.function_name}/invocations"
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "allow_invoke" {
  statement_id  = "SlackEventSubscriptionAllowInvoke_${var.app_name}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.handler.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${var.api_id}/*/${aws_api_gateway_method.event.http_method}${aws_api_gateway_resource.event.path}"
}

resource "aws_api_gateway_deployment" "slack_event_subscription" {
  depends_on = [
    "aws_api_gateway_method.event",
    "aws_api_gateway_integration.event",
  ]

  rest_api_id = "${var.api_id}"
  stage_name  = "slack_event_subscription"
}
