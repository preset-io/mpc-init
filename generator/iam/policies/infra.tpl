{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VPC",
      "Effect": "Allow",
      "Action": [
        "ec2:ModifyVpc*",
        "ec2:Attach*",
        "ec2:Detach*"
      ],
      "Resource": "*"
    },{
      "Sid": "cfn",
      "Effect": "Allow",
      "Action": [
        "cloudformation:Get*",
        "cloudformation:List*",
        "cloudformation:Describe*",
        "cloudformation:ValidateTemplate",
        "cloudformation:Create*",
        "cloudformation:Update*",
        "cloudformation:Tag*",
        "cloudformation:Untag*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "cfnDelete",
      "Effect": "Allow",
      "Action": [
        "cloudformation:Delete*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "lambda",
      "Effect": "Allow",
      "Action": [
        "lambda:Add*",
        "lambda:Remove*",
        "lambda:List*",
        "lambda:Get*",
        "lambda:Create*",
        "lambda:Update*",
        "lambda:Put*",
        "lambda:Tag*",
        "lambda:Untag*",
        "lambda:Publish*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "LambdaDelete",
      "Effect": "Allow",
      "Action": [
        "lambda:DeleteFunction"
      ],
      "Resource": "<infra_replacement>"
    },{
      "Sid": "secretsManager",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:List*",
        "secretsmanager:Describe*",
        "secretsmanager:Get*",
        "secretsmanager:Tag*",
        "secretsmanager:Untag*",
        "secretsmanager:Create*",
        "secretsmanager:Update*",
        "secretsmanager:Put*"
      ],
      "Resource": "*"
    },{
      "Sid": "SecretManagerDelete",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:Delete*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Owner": "Preset-io"
        }
      }
    }
  ]
}
