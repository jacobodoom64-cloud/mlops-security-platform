resource "aws_codebuild_project" "mlops_security_scan" {
  name          = "mlops-security-scan"
  service_role  = "arn:aws:iam::616150220421:role/mlops-codebuild_role"
  build_timeout = 60

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    image                       = "aws/codebuild/standard:7.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = {}
}
