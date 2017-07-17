# 
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
