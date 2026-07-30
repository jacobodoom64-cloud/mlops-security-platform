resource "aws_iam_role" "codebuild_scan" {
  name = "mlops-codebuild_role"

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
}

resource "aws_iam_role_policy" "codebuild_scan_logs" {
  name = "mlops-codebuild-policy"
  role = aws_iam_role.codebuild_scan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
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
resource "aws_iam_role_policy" "codebuild_scan_artifacts" {
  name = "mlops-codebuild-scan-artifacts-policy"
  role = aws_iam_role.codebuild_scan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "ArtifactBucketReadAccess"
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ]
      Resource = "${aws_s3_bucket.pipeline_artifacts.arn}/*"
    }]
  })
}
