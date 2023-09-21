resource "aws_backup_vault" "aws_src_backup_vault" {
  name        = "aws_backup_vault"
  kms_key_arn = aws_kms_key.aws_src_backup_kms_key.arn
}

resource "aws_backup_plan" "aws_backup_plan" {
  name = "cross-account-backup"

  rule {
    rule_name = "cross-account-rule"

    schedule     = var.schedule
    start_window = 60

    copy_action {
      destination_vault_arn = aws_backup_vault.aws_dst_backup_vault.arn
    }

    lifecycle {
      cold_storage_after = var.cold_storage_after
      delete_after       = var.delete_after
    }

    target_vault_name = aws_backup_vault.aws_src_backup_vault.name
  }
}

resource "aws_backup_selection" "aws_backup_selection" {
  iam_role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/service-role/AWSBackupDefaultServiceRole"
  name         = "backup_selection"
  plan_id      = aws_backup_plan.aws_backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup-plan"
    value = "remote"
  }
}