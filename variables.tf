variable "delete_after" {
  type        = number
  description = "Specifies the number of days after creation that a recovery point is deleted."
  default     = 35
}

variable "schedule" {
  type        = string
  description = "Cron-style schedule for backup vault (default: once a day at 12pm)."
  default     = "0 12 * * ? *"
}

variable "src_kms_key_arn" {
  type        = string
  description = "ARN of the source KMS key. If not provided, a new KMS key will be created."
  default     = null
}

variable "dst_kms_key_arn" {
  type        = string
  description = "ARN of the destination KMS key. If not provided, a new KMS key will be created."
  default     = null
}