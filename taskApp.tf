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
    "${aws_iam_role.LambdaReadTasksRole.name}"
  ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#!> CreateTasks Lambda
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

#¡>

#!> ReadTasks Lambda
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

#¡>

# resource "aws_iam_role" "LambdaDeleteTasksDB" {
#     name               = "LambdaDeleteTasksDB"
#     path               = "/service-role/"
#     assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }
#
# resource "aws_iam_role" "LambdaEmailer" {
#     name               = "LambdaEmailer"
#     path               = "/service-role/"
#     assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

#!> API Gateway
resource "aws_api_gateway_rest_api" "TasksApi" {
  name        = "TasksApi"
  description = "Tasks API - create, list, update, delete Tasks"
}

# Root resource
resource "aws_api_gateway_resource" "TasksResource" {
  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  parent_id   = "${aws_api_gateway_rest_api.TasksApi.root_resource_id}"
  path_part   = "tasks"
}

# !> GET tasks
resource "aws_api_gateway_method" "GetTasks" {
  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  resource_id = "${aws_api_gateway_resource.TasksResource.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "GetTasksLambdaIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  resource_id = "${aws_api_gateway_resource.TasksResource.id}"
  http_method = "${aws_api_gateway_method.GetTasks.http_method}"
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.ReadTasks.arn}/invocations"
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  resource_id = "${aws_api_gateway_resource.TasksResource.id}"
  http_method = "${aws_api_gateway_method.GetTasks.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "GetTasksIntegrationResponse" {
  depends_on = ["aws_api_gateway_integration.GetTasksLambdaIntegration"]

  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  resource_id = "${aws_api_gateway_resource.TasksResource.id}"
  http_method = "${aws_api_gateway_method.GetTasks.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
}

resource "aws_lambda_permission" "ApiInvokeLambdaRead" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ReadTasks.arn}"
  principal = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.TasksApi.id}/*/${aws_api_gateway_method.GetTasks.http_method}/tasks"
}
# ¡> end GET tasks

# !> POST tasks
resource "aws_api_gateway_method" "PostTasks" {
  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  resource_id = "${aws_api_gateway_resource.TasksResource.id}"
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "PostTasksLambdaIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  resource_id = "${aws_api_gateway_resource.TasksResource.id}"
  http_method = "${aws_api_gateway_method.PostTasks.http_method}"
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.CreateTasks.arn}/invocations"
}

resource "aws_api_gateway_method_response" "201" {
  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  resource_id = "${aws_api_gateway_resource.TasksResource.id}"
  http_method = "${aws_api_gateway_method.PostTasks.http_method}"
  status_code = "201"
}

resource "aws_api_gateway_integration_response" "PostTasksIntegrationResponse" {
  depends_on = ["aws_api_gateway_integration.PostTasksLambdaIntegration"]

  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  resource_id = "${aws_api_gateway_resource.TasksResource.id}"
  http_method = "${aws_api_gateway_method.PostTasks.http_method}"
  status_code = "${aws_api_gateway_method_response.201.status_code}"
}

resource "aws_lambda_permission" "ApiInvokeLambdaCreate" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.CreateTasks.arn}"
  principal = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.TasksApi.id}/*/${aws_api_gateway_method.PostTasks.http_method}/tasks"
}
# ¡> end POST tasks

resource "aws_api_gateway_deployment" "testDeploy" {
  depends_on = [
    "aws_api_gateway_integration.GetTasksLambdaIntegration",
    "aws_api_gateway_integration.PostTasksLambdaIntegration"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.TasksApi.id}"
  stage_name = "test"
}

output "url" {
  value = "${aws_api_gateway_deployment.testDeploy.invoke_url}"
}
#¡> end API Gateway
