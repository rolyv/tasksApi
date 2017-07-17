# ReadTasks Lambda function and accompanying roles/policies
resource "aws_iam_role" "LambdaReadTasksRole" {
    name               = "LambdaReadTasks"
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

resource "aws_iam_role_policy" "LambdaReadTasks_Policy-201707102006" {
    name   = "LambdaReadTasks_Policy-201707102006"
    role   = "LambdaReadTasks"
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
    }
  ]
}
POLICY
}

resource "aws_lambda_function" "ReadTasks" {
  filename      = "lambda_funcs.zip"
  function_name = "ReadTasks"
  description   = "Lambda function to handle http requests for reading tasks"
  role          = "${aws_iam_role.LambdaReadTasksRole.arn}"
  handler       = "read.handler"
  runtime       = "python3.6"
}
