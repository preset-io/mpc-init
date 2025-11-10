locals {
  mpc_permissions = [
    # Permissions for CloudSQL
    "cloudsql.databases.create",
    "cloudsql.databases.delete",
    "cloudsql.databases.get",
    "cloudsql.instances.create",
    "cloudsql.instances.delete",
    "cloudsql.instances.list",
    "cloudsql.instances.get",
    "cloudsql.instances.update",
    "cloudsql.users.list",
    "cloudsql.users.get",

    # Permissions for Compute Engine
    "compute.addresses.create",
    "compute.addresses.delete",
    "compute.addresses.get",
    "compute.addresses.setLabels",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.setMetadata",
    "compute.instances.setTags",
    "compute.instances.update",
    "compute.disks.create",
    "compute.disks.delete",
    "compute.disks.update",

    # Permissions for Storage
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.objects.create",
    "storage.objects.delete",

    # VPC Network Permissions
    "compute.networks.create",
    "compute.networks.delete",
    "compute.networks.get",
    "compute.networks.list",
    "compute.networks.updatePolicy",
    "compute.networks.update",
    "compute.networks.use",

    # Subnet Permissions
    "compute.subnetworks.create",
    "compute.subnetworks.delete",
    "compute.subnetworks.expandIpCidrRange",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.subnetworks.update",

    # Firewall Rules Permissions
    "compute.firewalls.create",
    "compute.firewalls.delete",
    "compute.firewalls.get",
    "compute.firewalls.list",
    "compute.firewalls.update",
    "compute.globalOperations.get",
    "compute.globalOperations.list",
    "compute.globalAddresses.createInternal",
    "compute.globalAddresses.deleteInternal",
    "compute.globalAddresses.get",
    "compute.globalAddresses.create",
    "compute.globalAddresses.setLabels",

    # Routes Permissions
    "compute.routes.create",
    "compute.routes.delete",
    "compute.routes.get",
    "compute.routes.list",

    # NAT Gateway Permissions
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.list",
    "compute.routers.update",
    "compute.routers.use",

    # Additional compute permissions
    "compute.regionOperations.get",
    "compute.regionOperations.list",
    "compute.zoneOperations.get",
    "compute.zoneOperations.list",
    "compute.zones.list",
    "compute.securityPolicies.create",
    "compute.securityPolicies.delete",
    "compute.securityPolicies.get",
    "compute.securityPolicies.getIamPolicy",
    "compute.securityPolicies.list",
    "compute.securityPolicies.setIamPolicy",
    "compute.securityPolicies.update",
    "compute.securityPolicies.use",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.list",

    # Permissions for Kubernetes Engine
    "container.clusters.create",
    "container.clusters.delete",
    "container.clusters.get",
    "container.clusters.list",
    "container.clusters.update",
    "container.namespaces.create",
    "container.namespaces.delete",
    "container.namespaces.get",
    "container.operations.get",
    "container.operations.list",
    "container.secrets.create",
    "container.secrets.delete",
    "container.secrets.get",
    "container.secrets.update",

    # Permissions for DNS
    "dns.managedZones.get",
    "dns.managedZones.list",
    "dns.managedZones.create",
    "dns.managedZones.delete",
    "dns.managedZones.update",
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.update",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",

    # VPC peering to service networking
    "servicenetworking.services.addPeering",

    # IAM Permissions
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.disable",
    "iam.serviceAccounts.enable",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.setIamPolicy",
    "iam.serviceAccounts.update",
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.delete",
    "iam.serviceAccountKeys.list",
    "iam.serviceAccountKeys.get",

    # Project IAM Admin permissions
    "iam.policybindings.get",
    "iam.policybindings.list",

    # For Workload Identity Pools
    "iam.workloadIdentityPools.create",
    "iam.workloadIdentityPools.delete",
    "iam.workloadIdentityPools.get",
    "iam.workloadIdentityPools.list",
    "iam.workloadIdentityPools.update",
    "iam.workloadIdentityPoolProviders.create",
    "iam.workloadIdentityPoolProviders.delete",
    "iam.workloadIdentityPoolProviders.get",
    "iam.workloadIdentityPoolProviders.list",
    "iam.workloadIdentityPoolProviders.update",

    # Redis permissions
    "redis.instances.get",
    "redis.instances.list",
    "redis.instances.create",
    "redis.instances.update",
    "redis.instances.delete",
    "redis.operations.get",
    "redis.operations.list",

    # Resource Manager permissions
    "resourcemanager.projects.createPolicyBinding",
    "resourcemanager.projects.deletePolicyBinding",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.searchPolicyBindings",
    "resourcemanager.projects.setIamPolicy",
    "resourcemanager.projects.updatePolicyBinding",

    # Service Usage permissions
    "serviceusage.services.enable",
    "serviceusage.services.get",
    "serviceusage.services.list",

    # Service Networking permissions
    "servicenetworking.services.get",
    "servicenetworking.services.deleteConnection",
  ]
}