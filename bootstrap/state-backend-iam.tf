resource "aws_iam_role_policy" "codebuild_scan_state" {
  name = "mlops-codebuild-scan-state-policy"
  role = aws_iam_role.codebuild_scan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "StateBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::mlops-security-platform-tfstate-616150220421/project1/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_deploy_state" {
  name = "mlops-codebuild-deploy-state-policy"
  role = aws_iam_role.codebuild_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "StateBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::mlops-security-platform-tfstate-616150220421/project1/*"
      }
    ]
  })
}
