output "lighthouse_definition_id" {
  description = "The ID of the Lighthouse definition"
  value       = azurerm_lighthouse_definition.this.id
}

output "lighthouse_assignment_id" {
  description = "The ID of the Lighthouse assignment"
  value       = azurerm_lighthouse_assignment.this.id
}

output "subscription_id" {
  description = "The subscription ID where Lighthouse is configured"
  value       = data.azurerm_subscription.current.subscription_id
}

output "managing_tenant_id" {
  description = "The tenant ID that now has access"
  value       = var.managing_tenant_id
}

output "custom_role_id" {
  description = "The ID of the custom MPC admin role"
  value       = azurerm_role_definition.mpc_role.role_definition_id
}

output "custom_role_name" {
  description = "The name of the custom MPC admin role"
  value       = azurerm_role_definition.mpc_role.name
}
