resource "aws_iam_role" "codebuild_role" {
    name = "mlops-codebuild_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "codebuild.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy" "codebuild_policy" {
    name = "mlops-codebuild-policy"
    role = aws_iam_role.codebuild_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role" "codepipeline_role" {
    name = "mlops-codepipeline-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal ={
                    Service = "codepipeline.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
    name = "mlops-codepipeline-policy"
    role = aws_iam_role.codepipeline_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:GetObjectVersion",
                    "s3:PutObject"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "codebuild:StartBuild",
                    "codebuild:BatchGetBuilds"
                ]
                Resource = "*"
            }
        ]
    })
}