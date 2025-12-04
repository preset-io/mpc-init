# MPC Cloud init for AWS

This is a cloudformation template for deploying all the necessary permissions for MPC on AWS.

# Instructions for customers

To get started with integrating your AWS account, 
please follow the bootstrap process outlined below. 
This will provision the necessary IAM role and permissions required for our platform to
securely access your environment and provision all the necessary resources.

Instructions:
- Access the CloudFormation Console
    - Log in to your AWS Management Console.
    - Navigate to the **CloudFormation** service.
    - Choose the appropriate AWS region where your MPC is located (us-east-1)
- Select the "Create Stack" -> with new resources
- On "Prerequisite – Prepare template"
    - Select "Choose an existing template"
- On "Specify template"
    - Select "Upload a template file"
- Upload the attached file "preset-iam.yaml"
- Click "Next"
- Stack parameters:
    - Stack name, you can choose any name you policy dictates
    - PresetEnv: production
    - StsExternalId: Use the shared External_id
- **Configure Stack options**
    - Keep all existing options
    - Check `I acknowledge that AWS CloudFormation might create IAM resources with customised names.`
    - Click `Next`
- Review
    - Review changes and click `Submit`.

