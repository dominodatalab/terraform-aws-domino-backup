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
