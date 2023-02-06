module "mpc_iam_init"  {
  source = "../modules/mpc_iam_init"

  aws_account_id = "12345678910"
  preset_devops_aws_account_id = "111111111111"
  preset_target_env_account_id = "999999999999"
}

provider "aws" {
  region = "us-west-2"
  allowed_account_ids = ["12345678910"]

    assume_role {
      role_arn = "arn:aws:iam::12345678910:role/some-role"
    }
}
