resource "aws_kms_key" "aws_dst_backup_kms_key" {
  description         = "KMS Key for Destination Backup"
  enable_key_rotation = true
  provider            = aws.dst
  policy              = <<POLICY
{
    "Id": "aws-dst-backup-kms-key",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.dst_account.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.dst_account.account_id}:root"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.dst_account.account_id}:root",
                    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.dst_account.account_id}:root",
                    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_kms_alias" "aws_dst_kms_alias" {
  name          = "alias/aws-backup-kms"
  provider      = aws.dst
  target_key_id = aws_kms_key.aws_dst_backup_kms_key.key_id
}