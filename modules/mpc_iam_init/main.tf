# The content of this file is autogenerated by the generator.

resource "aws_iam_role" "preset_admin" {
  name = "preset-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::${var.preset_target_env_account_id}:root", "arn:aws:iam::${var.preset_devops_aws_account_id}:root"
          ]
        }
      }
    ]
  })
}


resource "aws_iam_role" "mpc_account_mgmt" {
  name = "mpc-account-mgmt"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::${var.aws_account_id}:root"
          ]
        }
      }
    ]
  })
}



resource "aws_iam_policy" "client_access_management" {
  name = "client_access_management"
  path = "/"

  policy = templatefile("${path.module}/iam_policies/client-access-management.json.tpl", { aws_account_id = var.aws_account_id })
}

resource "aws_iam_role_policy_attachment" "attach_client_access_management" {
  role       = aws_iam_role.mpc_account_mgmt.name
  policy_arn = aws_iam_policy.client_access_management.arn
}


resource "aws_iam_policy" "infra" {
  name = "infra"
  path = "/"

  policy = templatefile("${path.module}/iam_policies/infra.json.tpl", { aws_account_id = var.aws_account_id })
}

resource "aws_iam_role_policy_attachment" "attach_infra" {
  role       = aws_iam_role.preset_admin.name
  policy_arn = aws_iam_policy.infra.arn
}


resource "aws_iam_policy" "preset_provision_workspaces" {
  name = "preset_provision_workspaces"
  path = "/"

  policy = templatefile("${path.module}/iam_policies/preset-provision-workspaces.json.tpl", { aws_account_id = var.aws_account_id })
}

resource "aws_iam_role_policy_attachment" "attach_preset_provision_workspaces" {
  role       = aws_iam_role.preset_admin.name
  policy_arn = aws_iam_policy.preset_provision_workspaces.arn
}