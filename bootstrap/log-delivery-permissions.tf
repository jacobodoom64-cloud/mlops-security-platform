resource "aws_iam_role_policy" "codebuild_deploy_log_delivery" {
  name = "mlops-codebuild-deploy-log-delivery-policy"
  role = aws_iam_role.codebuild_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LogDeliveryManage"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_scan_log_delivery_read" {
  name = "mlops-codebuild-scan-log-delivery-read-policy"
  role = aws_iam_role.codebuild_scan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LogDeliveryRead"
        Effect = "Allow"
        Action = [
          "logs:GetLogDelivery",
          "logs:ListLogDeliveries",
          "logs:DescribeResourcePolicies"
        ]
        Resource = "*"
      }
    ]
  })
}
