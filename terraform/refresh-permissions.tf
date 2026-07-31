resource "aws_iam_role_policy" "codebuild_scan_refresh" {
  name = "mlops-codebuild-scan-refresh-policy"
  role = aws_iam_role.codebuild_scan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IAMRoleReadForRefresh"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "arn:aws:iam::616150220421:role/mlops-*"
      },
      {
        Sid    = "CodeBuildReadForRefresh"
        Effect = "Allow"
        Action = ["codebuild:BatchGetProjects"]
        Resource = [
          aws_codebuild_project.mlops_security_scan.arn,
          aws_codebuild_project.mlops_deploy.arn
        ]
      },
      {
        Sid    = "CodeStarConnectionReadForRefresh"
        Effect = "Allow"
        Action = [
          "codestar-connections:GetConnection",
          "codestar-connections:ListTagsForResource"
        ]
        Resource = aws_codestarconnections_connection.github.arn
      },
      {
        Sid    = "S3BucketConfigReadForRefresh"
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketPublicAccessBlock"
        ]
        Resource = aws_s3_bucket.pipeline_artifacts.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_deploy_refresh" {
  name = "mlops-codebuild-deploy-refresh-policy"
  role = aws_iam_role.codebuild_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IAMRoleReadForRefresh"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "arn:aws:iam::616150220421:role/mlops-*"
      },
      {
        Sid    = "CodeStarConnectionReadForRefresh"
        Effect = "Allow"
        Action = [
          "codestar-connections:GetConnection",
          "codestar-connections:ListTagsForResource"
        ]
        Resource = aws_codestarconnections_connection.github.arn
      },
      {
        Sid    = "S3BucketConfigReadForRefresh"
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketPublicAccessBlock"
        ]
        Resource = aws_s3_bucket.pipeline_artifacts.arn
      }
    ]
  })
}
