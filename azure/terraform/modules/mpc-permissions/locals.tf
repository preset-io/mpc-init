locals {
  # Azure built-in role definition IDs
  role_definition_ids = {
    Owner                      = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
    Contributor                = "b24988ac-6180-42a0-ab88-20f7382dd24c"
    Reader                     = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
    Monitoring_Reader          = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    User_Access_Administrator  = "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
  }
}
