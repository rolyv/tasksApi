provider "aws" {
  region   = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# DynamoDB Tasks table
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

# Attach managed policy LambdaBasicExecutionRole to all Lambda roles
resource "aws_iam_policy_attachment" "Lambda_ExecutionPolicy" {
  name       = "Lambda_ExecutionPolicy"
  roles      = [
    "${aws_iam_role.LambdaCreateTasksRole.name}",
    "${aws_iam_role.LambdaReadTasksRole.name}",
    "${aws_iam_role.LambdaEmailTasksRole.name}"
  ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
