variable "lambda_name" {
  description = "Lambda name"
  type        = string
  default     = "ec2-saver"
}

variable "lambda_iam_role_name" {
  description = "Lambda IAM role name"
  type        = string
  default     = "ec2-saver"
}

variable "time_zone" {
  type    = string
  default = "UTC"
}
