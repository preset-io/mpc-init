variable "managing_tenant_id" {
  description = "Tenant ID of the managing tenant (the one receiving access)"
  type        = string
}

variable "principal_id" {
  description = "Object ID of the user/group to grant access"
  type        = string
}
