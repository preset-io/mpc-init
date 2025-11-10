# MPC Setup for GCP

This repository provides tools to set up MPC (Managed Private Cloud) permissions in your GCP project.

## Setup Options

Choose the method that best fits your workflow:

### Option 1: Terraform Module (Recommended)

For organizations using Terraform for infrastructure management.

**See the complete documentation:** [gcp/terraform/modules/mpc-permissions/README.md](gcp/terraform/modules/mpc-permissions/README.md)

The Terraform module provides:
- Infrastructure as code with version control
- Drift detection and management
- CI/CD integration
- Declarative configuration

### Option 2: Shell Script

For quick one-time setup or organizations not using Terraform.

**Script location:** [gcp/shell/setup-mpc-permissions.sh](gcp/shell/setup-mpc-permissions.sh)

**Quick start:**
```bash
export PROJECT_ID="your-project-id"
export PRESET_SERVICE_ACCOUNT="Service account email provided by Preset"
./gcp/shell/setup-mpc-permissions.sh
```

The shell script is:
- Idempotent (safe to run multiple times)
- Self-contained
- Easy to audit

## What Gets Created

Both methods create the following resources in your GCP project:

1. **Custom IAM Role** (`PresetMPCAdminV2`) - Contains all necessary permissions for Preset to manage MPC infrastructure
2. **MPC Service Account** (`preset-mpc-sa`) - Used by Preset to manage your resources
3. **IAM Bindings** - Grants appropriate permissions to Preset's service account

## Support

If you encounter issues or need assistance:

1. Review the detailed documentation for your chosen method (links above)
2. Check the GCP Cloud Console for error messages
3. Contact your Preset support representative with:
   - Your project ID
   - Error messages or logs
   - Which setup method you're using

## Additional Resources

- [GCP IAM Custom Roles Documentation](https://cloud.google.com/iam/docs/creating-custom-roles)
- [GCP Service Accounts Documentation](https://cloud.google.com/iam/docs/service-accounts)
- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)