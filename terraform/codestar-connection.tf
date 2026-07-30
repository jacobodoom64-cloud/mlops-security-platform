resource "aws_codestarconnections_connection" "github" {
  name          = "mlops-security-platform-github"
  provider_type = "GitHub"

  tags = {
    Project = "mlops-security-platform"
  }
}

output "codestar_connection_arn" {
  value = aws_codestarconnections_connection.github.arn
}


