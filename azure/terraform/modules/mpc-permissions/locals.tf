locals {
  # Role description
  mpc_role_description = "Custom role for Preset MPC administration with specific permissions for infrastructure management"

  # MPC custom role permissions (actions)
  mpc_permissions = [
    # Azure SQL Database
    "Microsoft.Sql/servers/*",
    "Microsoft.Sql/servers/databases/*",
    "Microsoft.Sql/servers/firewallRules/*",
    "Microsoft.Sql/servers/virtualNetworkRules/*",

    # Azure Cache for Redis
    "Microsoft.Cache/redis/*",
    "Microsoft.Cache/redisEnterprise/*",

    # Storage Accounts (Buckets)
    "Microsoft.Storage/storageAccounts/*",
    "Microsoft.Storage/storageAccounts/blobServices/*",
    "Microsoft.Storage/storageAccounts/fileServices/*",

    # DNS Zones and Records
    "Microsoft.Network/dnsZones/*",
    "Microsoft.Network/privateDnsZones/*",
    "Microsoft.Network/privateDnsZones/virtualNetworkLinks/*",

    # AKS - Azure Kubernetes Service
    "Microsoft.ContainerService/managedClusters/*",
    "Microsoft.ContainerService/containerServices/*",

    # Key Vault (Certificates Manager)
    "Microsoft.KeyVault/vaults/*",
    "Microsoft.KeyVault/locations/*",
    "Microsoft.KeyVault/operations/read",

    # Virtual Networks and Subnets
    "Microsoft.Network/virtualNetworks/*",
    "Microsoft.Network/virtualNetworks/subnets/*",
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/*",

    # VPN Gateway
    "Microsoft.Network/virtualNetworkGateways/*",
    "Microsoft.Network/localNetworkGateways/*",
    "Microsoft.Network/connections/*",
    "Microsoft.Network/vpnGateways/*",
    "Microsoft.Network/vpnSites/*",

    # NAT Gateway
    "Microsoft.Network/natGateways/*",

    # Public IP Addresses (for NAT, VPN, etc.)
    "Microsoft.Network/publicIPAddresses/*",
    "Microsoft.Network/publicIPPrefixes/*",

    # Network Security Groups
    "Microsoft.Network/networkSecurityGroups/*",
    "Microsoft.Network/applicationSecurityGroups/*",

    # Route Tables
    "Microsoft.Network/routeTables/*",

    # Network Interfaces (for VMs/AKS)
    "Microsoft.Network/networkInterfaces/*",

    # Load Balancers
    "Microsoft.Network/loadBalancers/*",

    # Application Gateway
    "Microsoft.Network/applicationGateways/*",

    # Virtual Machines (for AKS node pools)
    "Microsoft.Compute/virtualMachines/*",
    "Microsoft.Compute/virtualMachineScaleSets/*",
    "Microsoft.Compute/disks/*",
    "Microsoft.Compute/availabilitySets/*",

    # Resource Groups (for organizing resources)
    "Microsoft.Resources/subscriptions/resourceGroups/*",

    # Managed Identities (for AKS, VMs)
    "Microsoft.ManagedIdentity/userAssignedIdentities/*",

    # Monitor and Diagnostics
    "Microsoft.Insights/diagnosticSettings/*",
    "Microsoft.Insights/metrics/read",
    "Microsoft.Insights/logs/read",

    # Container Registry (for AKS)
    "Microsoft.ContainerRegistry/registries/*",

    # Private Endpoints
    "Microsoft.Network/privateEndpoints/*",
    "Microsoft.Network/privateLinkServices/*",

    # Read permissions for subscription
    "Microsoft.Resources/subscriptions/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
  ]

  # Not allowed actions (safety restrictions)
  mpc_not_actions = [
    # Prevent role assignment changes
    "Microsoft.Authorization/*/Delete",
    "Microsoft.Authorization/*/Write",
    "Microsoft.Authorization/elevateAccess/Action",
  ]
}
