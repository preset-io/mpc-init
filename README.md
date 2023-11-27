# Preset MPC Bootstrap Scripts

This repository contains a collection of bootstrap scripts for Preset Managed Private Clouds (MPCs).
We currently support Cloudformation as the primary bootstrap method, with Terraform support currently in beta.

## Prerequisites

1. An AWS account with sufficient permissions to create IAM roles and policies, and to create and manage Cloudformation stacks.
2. An external ID for the Preset MPC you wish to bootstrap. This can be obtained from the Preset team.

## Cloudformation

The Cloudformation bootstrap script is located in the `cloudformation` directory. 

### Usage

1. Simply apply the [preset-mpc-iam.yaml](cloudformation%2Fpreset-mpc-iam.yaml) Cloudformation template to your AWS account.
2. When prompted, enter the external ID for your Preset MPC provided by the Preset team.
3. Choose `production` when prompted for the environment. (The staging environment is used for internal testing only.)

### Outputs

* A set of IAM roles and policies for the Preset MPC that will allow the Preset team to provision your cluster.

## Terraform

Coming soon.
