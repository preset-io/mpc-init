package main

import (
  "flag"
  "fmt"
  "github.com/preset-io/mpc-init/generator"
  "github.com/preset-io/mpc-init/generator/cloudformation"
  "github.com/preset-io/mpc-init/generator/terraform"
)

const policiesPath = "./generator/iam/policies"

func main() {
  var PolicyRoleMap = []*generator.PolicyRoleMapping{
    {
      ResourceName: "clientAccessPolicy",
      PolicyName:   "client-access-management",
      RoleRef:      "clientAccessRole",
    }, {
      ResourceName: "infraPolicy",
      PolicyName:   "infra",
      RoleRef:      "workspaceProvisionerRole",
    }, {
      ResourceName: "provisionerPolicy",
      PolicyName:   "preset-provision-workspaces",
      RoleRef:      "workspaceProvisionerRole",
    },
  }

  tf := flag.Bool("tf", false, "Generate Terraform")
  cfn := flag.Bool("cfn", false, "Generate CloudFormation")
  flag.Parse()

  if *tf {
    terraform.GenTf(PolicyRoleMap, policiesPath)
  } else if *cfn {
    cloudformation.GenCfn(PolicyRoleMap, policiesPath)
  } else {
    fmt.Println("Please specify either -tf or -cfn")
  }
}
