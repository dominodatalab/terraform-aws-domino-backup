resource "aws_backup_vault" "aws_src_backup_vault" {
  name        = "aws_backup_vault"
  kms_key_arn = aws_kms_key.aws_src_backup_kms_key.arn
}

resource "aws_backup_vault_policy" "aws_src_backup_vault_policy_allow_dst" {
  backup_vault_name = aws_backup_vault.aws_src_backup_vault.name
  policy            = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "Allow ${data.aws_caller_identity.dst_account.account_id} to copy into ${aws_backup_vault.aws_src_backup_vault.name}",
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
  name               = "aws_backup_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "backup.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_backup_role_default_policy_backup_attachement" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "aws_backup_role_default_policy_restore_attachement" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role_policy_attachment" "aws_backup_role_s3_policy_backup_attachement" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
}

resource "aws_iam_role_policy_attachment" "aws_backup_role_s3_policy_restore_attachement" {
  role       = aws_iam_role.aws_backup_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
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