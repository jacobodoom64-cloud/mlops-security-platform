resource "aws_codepipeline" "mlops_pipeline" {
  name     = "mlops-security-platform-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "jacobodoom64-cloud/mlops-security-platform"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Scan"

    action {
      name             = "PlanAndScan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["scan_output"]

      configuration = {
        ProjectName = aws_codebuild_project.mlops_security_scan.name
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = "Review the Terraform plan and tfsec/checkov scan results before approving deployment."
      }
    }
  }

  stage {
    name = "Deploy"

   action {
      name            = "ApplyAndSign"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output", "scan_output"]

      configuration = {
        ProjectName   = aws_codebuild_project.mlops_deploy.name
        PrimarySource = "source_output"
      }
    }
 }

  tags = {
    Project = "mlops-security-platform"
  }
}
