variable "project_id" {
  description = "The GCP project ID where MPC resources will be managed"
  type        = string
}

variable "preset_service_account" {
  description = "The Preset service account email that will manage MPC resources"
  type        = string
}