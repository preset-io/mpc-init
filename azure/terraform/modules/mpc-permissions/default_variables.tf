variable "principal_name" {
  description = "Display name for the principal"
  type        = string
  default     = "Preset MPC Admin"
}

variable "offer_name" {
  description = "Name of the Lighthouse offer"
  type        = string
  default     = "Preset MPC Management Access"
}

variable "offer_description" {
  description = "Description of the Lighthouse offer"
  type        = string
  default     = "Grants custom MPC admin access to Preset tenant"
}

variable "custom_role_name" {
  description = "Name for the custom MPC admin role"
  type        = string
  default     = "Preset MPC Admin"
}
