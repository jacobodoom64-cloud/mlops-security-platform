resource "aws_iam_role" "lambda_exec" {
  name = "mlops-lambda-inference-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = "mlops-security-platform"
  }
}

resource "aws_iam_role_policy" "lambda_logs" {
  name = "mlops-lambda-logs-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "CloudWatchLogs"
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:eu-north-1:616150220421:log-group:/aws/lambda/mlops-*"
    }]
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/mlops-model-inference"
  retention_in_days = 14

  tags = {
    Project = "mlops-security-platform"
  }
}

resource "aws_lambda_function" "inference" {
  function_name = "mlops-model-inference"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.model.repository_url}:${var.image_tag}"

  memory_size = 3008
  timeout     = 120

  tags = {
    Project = "mlops-security-platform"
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

output "lambda_function_name" {
  value = aws_lambda_function.inference.function_name
}
