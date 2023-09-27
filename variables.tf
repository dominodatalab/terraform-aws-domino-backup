variable "delete_after" {
  type        = number
  description = "Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than cold_storage_after."
  default     = 125
}

variable "schedule" {
  type        = string
  description = "Cron-style schedule for backup vault (default: once a day at 12pm)."
  default     = "0 12 * * ? *"
}