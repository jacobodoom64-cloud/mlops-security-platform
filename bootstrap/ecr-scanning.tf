resource "aws_ecr_registry_scanning_configuration" "basic" {
  scan_type = "BASIC"

  rule {
    scan_frequency = "SCAN_ON_PUSH"

    repository_filter {
      filter      = "mlops-*"
      filter_type = "WILDCARD"
    }
  }
}
