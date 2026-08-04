resource "aws_iam_role" "codebuild_deploy" {
  name = "mlops-codebuild-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = "mlops-security-platform"
    Role    = "deploy-write-access"
  }
}

resource "aws_iam_role_policy" "codebuild_deploy_logs" {
  name = "mlops-codebuild-deploy-logs-policy"
  role = aws_iam_role.codebuild_deploy.id

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
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_deploy_artifacts" {
  name = "mlops-codebuild-deploy-artifacts-policy"
  role = aws_iam_role.codebuild_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "ArtifactBucketAccess"
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject"
      ]
      Resource = [
        aws_s3_bucket.pipeline_artifacts.arn,
        "${aws_s3_bucket.pipeline_artifacts.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_deploy_infra" {
  name = "mlops-codebuild-deploy-infra-policy"
  role = aws_iam_role.codebuild_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VPCNetworking"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:Describe*",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3BucketManagement"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketVersioning",
          "s3:PutEncryptionConfiguration",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucket*",
          "s3:PutBucketTagging"
        ]
        Resource = "arn:aws:s3:::mlops-security-platform-*"
      },
      {
        Sid    = "IAMRoleManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:TagRole",
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::*:role/mlops-*"
      },
      {
        Sid    = "CodeBuildProjectManagement"
        Effect = "Allow"
        Action = [
          "codebuild:CreateProject",
          "codebuild:UpdateProject",
          "codebuild:BatchGetProjects"
        ]
        Resource = "arn:aws:codebuild:*:*:project/mlops-*"
      },
      {
        Sid    = "CodePipelineManagement"
        Effect = "Allow"
        Action = [
          "codepipeline:CreatePipeline",
          "codepipeline:UpdatePipeline",
          "codepipeline:GetPipeline"
        ]
        Resource = "*"
      }
    ]
  })
}
