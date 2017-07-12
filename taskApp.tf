provider "aws" {
  region   = "us-east-1"
  profile  = "terraform"
}

resource "aws_dynamodb_table" "tasks_dynamodb_table" {
  name            = "Tasks"
  read_capacity   = 5
  write_capacity  = 5
  hash_key        = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "LambdaDeleteTasksDB" {
    name               = "LambdaDeleteTasksDB"
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

resource "aws_iam_role" "LambdaEmailer" {
    name               = "LambdaEmailer"
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

resource "aws_iam_role" "LambdaReadTasksDB" {
    name               = "LambdaReadTasksDB"
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

resource "aws_iam_policy_attachment" "Lambda_ExecutionPolicy" {
  name       = "Lambda_ExecutionPolicy"
  roles      = ["${aws_iam_role.LambdaCreateTasksRole.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "CreateTasks" {
  filename      = "lambda_funcs.zip"
  function_name = "CreateTasks"
  description   = "Lambda function to handle http requests for creating new tasks"
  role          = "${aws_iam_role.LambdaCreateTasksRole.arn}"
  handler       = "create.handler"
  runtime       = "python3.6"
}
