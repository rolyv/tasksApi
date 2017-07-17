# Emailer Lambda function that will email users daily with
# all incomplete Tasks. Includes CloudWatch scheduled event rule
# and necessary roles/permissions
resource "aws_iam_role" "LambdaEmailTasksRole" {
    name               = "LambdaEmailTasks"
    path               = "/service-role/"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "LambdaEmailTasks_Policy-201707102006" {
    name   = "LambdaEmailTasks_Policy-201707102006"
    role   = "LambdaEmailTasks"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": [
        "${aws_dynamodb_table.tasks_dynamodb_table.arn}"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_lambda_function" "EmailTasks" {
  filename      = "lambda_funcs.zip"
  function_name = "EmailTasks"
  description   = "Lambda function to email users daily with incomplete tasks"
  role          = "${aws_iam_role.LambdaEmailTasksRole.arn}"
  handler       = "emailer.handler"
  runtime       = "python3.6"
}

resource "aws_cloudwatch_event_rule" "daily" {
  name = "daily"
  description = "Scheduled event rule for once a day"
  schedule_expression = "rate(1 day)"
  is_enabled = false
}

resource "aws_cloudwatch_event_target" "emailerTarget" {
  rule = "${aws_cloudwatch_event_rule.daily.name}"
  arn = "${aws_lambda_function.EmailTasks.arn}"
}

resource "aws_lambda_permission" "CloudWatchInvokeLambdaEmailer" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.EmailTasks.arn}"
  principal = "events.amazonaws.com"

  source_arn = "arn:aws:events:${var.region}:${var.account_id}:rule/${aws_cloudwatch_event_rule.daily.name}"
}
