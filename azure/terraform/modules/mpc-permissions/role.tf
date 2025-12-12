# Custom Role Definition for MPC Admin
resource "azurerm_role_definition" "mpc_role" {
  name        = var.custom_role_name
  scope       = data.azurerm_subscription.current.id
  description = local.mpc_role_description

  permissions {
    actions     = local.mpc_permissions
    not_actions = local.mpc_not_actions
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}
