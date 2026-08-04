resource "aws_codebuild_project" "mlops_deploy" {
  name          = "mlops-deploy"
  service_role  = aws_iam_role.codebuild_deploy.arn
  build_timeout = 60

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-deploy.yml"
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

  tags = {
    Project = "mlops-security-platform"
    Stage   = "deploy"
  }
}
