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

/* commenting out
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      },
      {
          "Effect": "Allow",
          "Action": "logs:CreateLogGroup",
          "Resource": "arn:aws:logs:us-east-1:790579188910:*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": [
              "arn:aws:logs:us-east-1:790579188910:log-group:/aws/lambda/ListTasks:*"
          ]
      },
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
              "arn:aws:dynamodb:us-east-1:790579188910:table/Tasks"
          ]
      }
  ]
}
EOF
}
*/
