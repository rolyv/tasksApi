# CreateTasks Lambda function and accompanying roles/policies
resource "aws_iam_role" "LambdaCreateTasksRole" {
    name               = "LambdaCreateTasks"
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

resource "aws_iam_role_policy" "LambdaCreateTasks_Policy-201707102006" {
    name   = "LambdaCreateTasks_Policy-201707102006"
    role   = "LambdaCreateTasks"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.tasks_dynamodb_table.arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_lambda_function" "CreateTasks" {
  filename      = "lambda_funcs.zip"
  function_name = "CreateTasks"
  description   = "Lambda function to handle http requests for creating new tasks"
  role          = "${aws_iam_role.LambdaCreateTasksRole.arn}"
  handler       = "create.handler"
  runtime       = "python3.6"
}
