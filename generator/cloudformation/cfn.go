package cloudformation

import (
  "fmt"
  "github.com/awslabs/goformation/v7/cloudformation"
  "github.com/awslabs/goformation/v7/cloudformation/iam"
  "github.com/preset-io/mpc-init/generator"
  "io/ioutil"
  "log"
  "os"
  "path/filepath"
  "strings"
)

var roles = []map[string]*iam.Role{
  {
    "clientAccessRole": {
      RoleName:    cloudformation.String("mpc-account-mgmt"),
      Description: cloudformation.String("Preset Cluster Provisioner Role"),
      AssumeRolePolicyDocument: map[string]interface{}{
        "Version": "2012-10-17",
        "Statement": []map[string]interface{}{
          {
            "Sid":    "",
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": map[string]interface{}{
              "AWS": []string{
                cloudformation.Join("", []string{
                  "arn:aws:iam::",
                  cloudformation.Ref("AWS::AccountId"),
                  ":root",
                }),
              },
            },
          },
        },
      },
    },
  }, {
    "workspaceProvisionerRole": {
      RoleName:    cloudformation.String("preset-admin"),
      Description: cloudformation.String("Preset Cluster Provisioner Role"),
      AssumeRolePolicyDocument: map[string]interface{}{
        "Version": "2012-10-17",
        "Statement": []map[string]interface{}{
          {
            "Sid":    "",
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": map[string]interface{}{
              "AWS": []string{
                cloudformation.Join("", []string{
                  "arn:aws:iam::",
                  cloudformation.Ref("PresetEnvAccountId"),
                  ":root",
                }),
                cloudformation.Join("", []string{
                  "arn:aws:iam::",
                  cloudformation.Ref("PresetDevOpsAccountId"),
                  ":root",
                }),
              },
            },
          },
        },
      },
    },
  },
}

func GenCfn(PolicyRoleMap []*generator.PolicyRoleMapping, policiesPath string) {
  // Create a new CloudFormation template
  template := NewTemplate()

  // Roles
  templateRoles(template)

  // Resources
  templateResources(template, PolicyRoleMap, policiesPath)

  // Generate a YAML AWS CloudFormation template
  yamlTemplate, err := GenerateYaml(template)
  if err != nil {
    log.Fatalf("error creating yaml: %v", err)
  }

  writeFile(yamlTemplate, "cloudformation/preset-mpc-iam.yaml")
}

func writeFile(content, path string) {
  file, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
  if err != nil {
    fmt.Println(err)
    return
  }
  defer file.Close()

  _, err = file.Write([]byte(content))
  if err != nil {
    fmt.Println(err)
    return
  }
}

func NewTemplate() *cloudformation.Template {
  template := cloudformation.NewTemplate()
  template.Description = "This template creates resources for a Preset Superset workspace in your AWS account."
  template.Parameters = map[string]cloudformation.Parameter{
    "AccountId": {
      Description: "MPC account id",
      Type:        "String",
    },
    "PresetEnvAccountId": {
      Description: "Preset environment account id",
      Type:        "String",
    },
    "PresetDevOpsAccountId": {
      Description: "Preset devops environment account id",
      Type:        "String",
    },
  }
  return template
}

func GenerateYaml(template *cloudformation.Template) (string, error) {
  y, err := template.YAML()
  if err != nil {
    return "", fmt.Errorf("Failed to generate YAML: %s\n", err)
  } else {
    return fmt.Sprintf("%s\n", string(y)), nil
  }
}

func templateRoles(template *cloudformation.Template) {
  for _, r := range roles {
    for name, role := range r {
      template.Resources[name] = role
    }
  }
}

func templateResources(template *cloudformation.Template, policyRoleMappings []*generator.PolicyRoleMapping, policiesPath string) {
  cwd, err := os.Getwd()
  if err != nil {
    log.Fatalf("Failed to get current working directory: %v", err)
  }

  for _, policy := range policyRoleMappings {
    // read policy document from file
    fileName := filepath.Join(cwd, fmt.Sprintf("%s/%s.tpl", policiesPath, policy.PolicyName))
    J, err := ioutil.ReadFile(fileName)
    if err != nil {
      log.Fatalf("error reading policy document from file %s: %v", fileName, err)
      return
    }

    var doc []string
    doc = append(doc, strings.Replace(string(J), `"<infra_replacement>"`, `!Sub "arn:aws:lambda:*:${AWS::AccountId}:function:datadog_log_monitoring"`, 1))
    doc = append(doc, strings.Replace(string(J), `"<kms_velero_replacement>"`, `!Join [ "", ["arn:aws:kms:*:", !Ref "AWS::AccountId", ":alias/velero-backups-*"] ]`, 1))

    template.Resources[policy.ResourceName] = &iam.ManagedPolicy{
      ManagedPolicyName: &policy.PolicyName,
      PolicyDocument:    strings.Join(doc, "\n"),
      Roles:             []string{cloudformation.Ref(cloudformation.StringValue(&policy.RoleRef))},
    }
  }
}
