resource "aws_backup_vault" "aws_dst_backup_vault" {
  name        = "aws_backup_vault"
  provider    = aws.dst
  kms_key_arn = aws_kms_key.aws_dst_backup_kms_key.arn
}