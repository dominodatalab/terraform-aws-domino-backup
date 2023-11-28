resource "aws_ecr_registry_policy" "ecr_registry_permission" {
  provider = aws.dst

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ReplicationAccessCrossAccount",
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        },

        Action = [
          "ecr:CreateRepository",
          "ecr:ReplicateImage"
        ],

        Resource = [
          "arn:${data.aws_partition.dst_current.partition}:ecr:${data.aws_region.dst_region.name}:${data.aws_caller_identity.dst_account.account_id}:repository/*"
        ]
      }
    ]
  })
}