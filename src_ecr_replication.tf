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