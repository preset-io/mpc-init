variable "principal_name" {
  description = "Display name for the service principal"
  type        = string
  default     = "Preset MPC Service Principal"
}

variable "offer_name" {
  description = "Name of the Lighthouse offer"
  type        = string
  default     = "Preset MPC Management Access"
}

variable "offer_description" {
  description = "Description of the Lighthouse offer"
  type        = string
  default     = "Grants Contributor access to Preset MPC tenant"
}

variable "role" {
  description = "Built-in role to assign: Owner, Contributor, or Reader"
  type        = string
  default     = "Contributor"

  validation {
    condition     = contains(["Owner", "Contributor", "Reader"], var.role)
    error_message = "Role must be Owner, Contributor, or Reader."
  }
}
