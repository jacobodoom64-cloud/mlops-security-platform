resource "aws_s3_bucket" "pipeline_artifacts" {
    bucket = "mlops-pipeline-artifacts-jake-2026"

    tags = {
        Name = "mlops-pipeline-artifacts"
    }
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts_versioning" {
    bucket = aws_s3_bucket.pipeline_artifacts.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts_encryption" {
    bucket = aws_s3_bucket.pipeline_artifacts.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}