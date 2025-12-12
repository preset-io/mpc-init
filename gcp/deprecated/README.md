# MPC Cloud init for GCP

This is a deployment manager template for deploying all the necessary permission for MPC on GCP.

## Prerequisites

- Project needs to enable:
  - Identity and Access Management (IAM) API
  - Cloud Resource Manager API
  - Deployment Manager API
  - Service Usage API

```bash
PROJECT_ID=<PROJECT_ID>
gcloud services enable iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  deploymentmanager.googleapis.com \
  serviceusage.googleapis.com \
  --project="$PROJECT_ID"
```

Add the following organizations to your project Organization Policy:
constraint ID: iam.allowedPolicyMemberDomains
C0147pk0i # Datadog https://docs.datadoghq.com/integrations/google_cloud_platform/?tab=dataflowmethodrecommended
C01i2thyr # Preset.io

Use the following command to set the organization policy:
# Note you will need to use an account with Org admin access

```bash
PROJECT_ID=<PROJECT_ID>
gcloud resource-manager org-policies set-policy --project $PROJECT_ID project-org-policy.yaml
```

Required permissions to allow google's deployment manager service to create a custom Role.
```bash
PROJECT_ID=<PROJECT_ID>
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)") && \
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:${PROJECT_NUMBER}@cloudservices.gserviceaccount.com" --role="roles/iam.roleAdmin" && \
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:${PROJECT_NUMBER}@cloudservices.gserviceaccount.com" --role="roles/resourcemanager.projectIamAdmin" && \
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:${PROJECT_NUMBER}@cloudservices.gserviceaccount.com" --role="roles/iam.serviceAccountAdmin"
```

Create the deployment manager template (assuming PROJECT_ID env var is already set):
```bash
gcloud deployment-manager deployments create preset-mpc-org --config deployment.yaml --automatic-rollback-on-error --project $PROJECT_ID
```
