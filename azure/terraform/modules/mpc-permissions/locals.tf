locals {
  # Azure built-in role definition IDs
  role_definition_ids = {
    Owner                     = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
    Contributor               = "b24988ac-6180-42a0-ab88-20f7382dd24c"
    Reader                    = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
    Monitoring_Reader         = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    User_Access_Administrator = "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
    AKS_Cluster_Admin         = "0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8"
    AKS_RBAC_Cluster_Admin    = "b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b"
    DNS_Zone_Contributor      = "befefa01-2a29-4197-83a8-272ff33ce314"
  }
}
