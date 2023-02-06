package generator

type ManagedPolicies struct {
  policies []*PolicyRoleMapping
}

type PolicyRoleMapping struct {
  ResourceName string
  PolicyName   string
  RoleRef      string
}
