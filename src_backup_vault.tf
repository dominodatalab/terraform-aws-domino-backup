resource "aws_backup_vault" "aws_src_backup_vault" {
  name        = "aws_backup_vault"
  kms_key_arn = aws_kms_key.aws_src_backup_kms_key.arn
}

resource "aws_backup_vault_policy" "aws_dst_backup_vault_policy" {
  backup_vault_name = aws_backup_vault.aws_src_backup_vault.name
  policy            = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "Allow ${data.aws_caller_identity.dst_account.account_id} to copy into ${aws_backup_vault.aws_dst_backup_vault.name}",
      "Effect": "Allow",
      "Action": "backup:CopyIntoBackupVault",
      "Resource": "*",
      "Principal": {
        "AWS": "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.dst_account.account_id}:root"
      }
    }
  ]
}
POLICY
}

resource "aws_backup_plan" "aws_backup_plan" {
  name = "cross-account-backup"

  rule {
    rule_name = "cross-account-rule"

    schedule                 = "cron(${var.schedule})"
    start_window             = 60
    enable_continuous_backup = true

    copy_action {
      destination_vault_arn = aws_backup_vault.aws_dst_backup_vault.arn

      lifecycle {
        delete_after = var.delete_after
      }
    }

    lifecycle {
      delete_after = var.delete_after
    }

    target_vault_name = aws_backup_vault.aws_src_backup_vault.name
  }
}

resource "aws_iam_role" "aws_backup_role" {
  name = "aws_backup_role"
}

resource "aws_iam_role_policy_attachment" "aws_backup_role-default-policy-backup-attachement" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "aws_backup_role-default-policy-restore-attachement" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role_policy_attachment" "aws_backup_role-s3-policy-backup-attachement" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
}

resource "aws_iam_role_policy_attachment" "aws_backup_role-s3-policy-restore-attachement" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
}

resource "aws_backup_selection" "aws_backup_selection" {
  iam_role_arn = aws_iam_role.aws_backup_role.arn
  name         = "backup_selection"
  plan_id      = aws_backup_plan.aws_backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup_plan"
    value = "cross-account"
  }
}