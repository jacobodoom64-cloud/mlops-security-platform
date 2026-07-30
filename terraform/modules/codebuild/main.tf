resource "aws_codebuild_project" "security_scan" {
    name = "mlops-security-scan"
    service_role = "arn:aws:iam::616150220421:role/mlops-codebuild_role"

    source {
        type = "GITHUB"
        location = "https://github.com/jacobodoom64-cloud/mlops-security-platform.git"    
    }

    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:7.0"
        type = "LINUX_CONTAINER"
    }

    artifacts {
        type = "NO_ARTIFACTS"
    }
}