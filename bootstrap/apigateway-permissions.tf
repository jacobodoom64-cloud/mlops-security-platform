resource "aws_iam_role_policy" "codebuild_scan_apigw_read" {
  name = "mlops-codebuild-scan-apigw-read-policy"
  role = aws_iam_role.codebuild_scan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "APIGatewayReadForPlan"
        Effect   = "Allow"
        Action   = "apigateway:GET"
        Resource = "arn:aws:apigateway:eu-north-1::/apis*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_deploy_apigw" {
  name = "mlops-codebuild-deploy-apigw-policy"
  role = aws_iam_role.codebuild_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "APIGatewayManage"
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:PATCH",
          "apigateway:PUT",
          "apigateway:DELETE",
          "apigateway:TagResource",
          "apigateway:UntagResource"
        ]
        Resource = "arn:aws:apigateway:eu-north-1::/apis*"
      },
      {
        Sid    = "APIGatewayTags"
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:DELETE"
        ]
        Resource = "arn:aws:apigateway:eu-north-1::/tags*"
      }
    ]
  })
}
