resource "aws_backup_vault" "aws_dst_backup_vault" {
  name        = "aws_backup_vault"
  provider    = aws.dst
  kms_key_arn = aws_kms_key.aws_dst_backup_kms_key.arn

  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id != data.aws_caller_identity.dst_account.account_id
      error_message = "Destination account ID (${data.aws_caller_identity.dst_account.account_id}) must not match source account ID (${data.aws_caller_identity.current.account_id})"
    }
  }
}

resource "aws_backup_vault_policy" "aws_dst_backup_vault_policy" {
  backup_vault_name = aws_backup_vault.aws_dst_backup_vault.name
  provider          = aws.dst
  policy            = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "Allow ${data.aws_caller_identity.current.account_id} to copy into ${aws_backup_vault.aws_dst_backup_vault.name}",
      "Effect": "Allow",
      "Action": "backup:CopyIntoBackupVault",
      "Resource": "*",
      "Principal": {
        "AWS": "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      }
    }
  ]
}
POLICY
}
