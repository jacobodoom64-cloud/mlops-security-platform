resource "aws_apigatewayv2_api" "inference" {
  name          = "mlops-inference-api"
  protocol_type = "HTTP"
  description   = "HTTP endpoint for the MLOps model inference Lambda"

  tags = {
    Project = "mlops-security-platform"
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.inference.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.inference.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "predict" {
  api_id    = aws_apigatewayv2_api.inference.id
  route_key = "POST /predict"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/apigateway/mlops-inference-api"
  retention_in_days = 14

  tags = {
    Project = "mlops-security-platform"
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.inference.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = {
    Project = "mlops-security-platform"
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.inference.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.inference.execution_arn}/*/*"
}

output "api_endpoint" {
  value = "${aws_apigatewayv2_stage.default.invoke_url}predict"
}
