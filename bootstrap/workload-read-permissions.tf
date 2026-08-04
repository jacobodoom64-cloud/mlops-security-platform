resource "aws_iam_role_policy" "codebuild_scan_vpc_read" {
  name = "mlops-codebuild-scan-vpc-read-policy"
  role = aws_iam_role.codebuild_scan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VPCReadForWorkloadPlan"
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeSubnets",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeRouteTables",
          "ec2:DescribeTags",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      }
    ]
  })
}
