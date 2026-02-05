# Azure Lighthouse Terraform Module
# Run this in the tenant that OWNS the subscription (the one granting access)

# Get current subscription
data "azurerm_subscription" "current" {}

# Lighthouse Definition
resource "azurerm_lighthouse_definition" "this" {
  name               = var.offer_name
  description        = var.offer_description
  managing_tenant_id = var.managing_tenant_id
  scope              = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"

  authorization {
    principal_id           = var.principal_id
    role_definition_id     = local.role_definition_ids[var.role]
    principal_display_name = var.principal_name
  }

  authorization {
    principal_id                  = var.principal_id
    role_definition_id            = local.role_definition_ids["User_Access_Administrator"]
    principal_display_name        = var.principal_name
    delegated_role_definition_ids = [
      local.role_definition_ids["Contributor"],
      local.role_definition_ids["Reader"],
      local.role_definition_ids["Monitoring_Reader"],
    ]
  }
}

# Lighthouse Assignment
resource "azurerm_lighthouse_assignment" "this" {
  scope                    = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  lighthouse_definition_id = azurerm_lighthouse_definition.this.id
}
