
variable "aws_account_id" {
  description = "aws_account_id aws account number"
  type        = string
}

variable "preset_devops_aws_account_id" {
  description = "preset_devops_aws_account_id aws account number"
  type        = string
}

variable "preset_target_env_account_id" {
  description = "preset_target_env_account_id aws account number"
  type        = string
}

variable "preset_sts_external_id" {
  description = "The external ID provided by preset for role assumption"
  type = string
}