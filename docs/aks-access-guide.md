# AKS Cluster Access via Lighthouse

## Overview

Preset engineers can access customer AKS clusters through Azure Lighthouse delegation. Access is controlled by membership in the **INFRA-NON-PROD** group in the Preset MPC Entra ID tenant.

## Prerequisites

- Azure CLI installed (`az` command)
- `kubectl` installed
- Your account must be a member of the **INFRA-NON-PROD** group in Entra ID
  - To request access, contact your team lead to be added to the group in the Azure portal (Entra ID → Groups → INFRA-NON-PROD)

## Steps

### 1. Login to the Preset MPC tenant

```bash
az login --tenant c8309e53-d775-46bd-947f-7fe0d1fb7b7a
```

This opens a browser for authentication. Sign in with your `@presetmpc.onmicrosoft.com` account.

### 2. List available customer subscriptions

```bash
az account list --output table
```

You should see the customer subscriptions delegated via Lighthouse.

### 3. Select the customer subscription

```bash
az account set --subscription <customer-subscription-id>
```

### 4. Find the AKS cluster

```bash
az aks list --output table
```

This shows all AKS clusters in the subscription with their names, resource groups, and locations.

### 5. Get AKS credentials

```bash
az aks get-credentials \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --admin

kubectl config set-cluster <cluster-name> --proxy-url=http://squid.devops.preset.zone:1080
```

The `--admin` flag is required. Don't forget to add the proxy

### 6. Use kubectl

```bash
KUBECONFIG=~/.kube/config-<customer-name> kubectl get nodes
```

Or export it for the session:

```bash
export KUBECONFIG=~/.kube/config-<customer-name>
kubectl get nodes
kubectl get pods -A
```

## Example (Non-Prod)

```bash
az login --tenant c8309e53-d775-46bd-947f-7fe0d1fb7b7a
az account set --subscription d83f91f8-4292-4810-8f92-f678a9d53ec2
az aks get-credentials --resource-group preset-azure-mpc --name preset-azure-mpc --admin --file ~/.kube/config-nonprod
KUBECONFIG=~/.kube/config-nonprod kubectl get nodes
```

## Troubleshooting

### "AuthorizationFailed" on `az aks get-credentials`

- Make sure you're using the `--admin` flag
- Verify you're a member of the INFRA-NON-PROD group in Entra ID
- If you were recently added to the group, wait up to 30 minutes for Lighthouse to propagate

### Customer subscription not visible in `az account list`

- Confirm you logged into the correct tenant (`c8309e53-d775-46bd-947f-7fe0d1fb7b7a`)
- The Lighthouse delegation may not be deployed on that customer subscription yet

### `kubectl` commands fail after getting credentials

- Verify the kubeconfig file exists: `ls -la ~/.kube/config-<customer-name>`
- Make sure `KUBECONFIG` points to the right file
- Try refreshing credentials: re-run `az aks get-credentials` with the same flags
