resource "aws_ecr_registry_policy" "ecr_registry_permission" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ReplicationAccessCrossAccount",
        Effect = "Allow",
        Resource = [
          "arn:${data.aws_partition.current.partition}:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
        ],

        Action = [
          "ecr:CreateRepository",
          "ecr:ReplicateImage"
        ],
        
        Principal = {
          "AWS" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.dst_account.account_id}:root"
        }
      }
    ]
  })
}

resource "aws_ecr_replication_configuration" "ecr_replication" {
  replication_configuration {
    rule {
      destination {
        region      = data.aws_region.dst_region.name
        registry_id = data.aws_caller_identity.dst_account.account_id
      }
    }
  }
}