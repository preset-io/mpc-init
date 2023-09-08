{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "route53",
      "Effect": "Allow",
      "Action": [
        "route53:Get*",
        "route53:List*",
        "route53:CreateHostedZone",
        "route53:Change*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "route53Delete",
      "Effect": "Allow",
      "Action": [
        "route53:DeleteHostedZone"
      ],
      "Resource": "*"
    },
    {
      "Sid": "acm",
      "Effect": "Allow",
      "Action": [
        "acm:RequestCertificate",
        "acm:AddTagsToCertificate",
        "acm:DescribeCertificate",
        "acm:ListTagsForCertificate"
      ],
      "Resource": "*"
    },
    {
      "Sid": "acmDelete",
      "Effect": "Allow",
      "Action": [
        "acm:DeleteCertificate"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Owner": "Preset-io"
        }
      }
    },
    {
      "Sid": "logs",
      "Effect": "Allow",
      "Action": [
        "logs:Untag*",
        "logs:Tag*",
        "logs:Create*",
        "logs:Put*",
        "logs:Describe*",
        "logs:List*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "logsDelete",
      "Effect": "Allow",
      "Action": [
        "logs:DeleteLogGroup",
        "logs:DeleteSubscriptionFilter"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Owner": "Preset-io"
        }
      }
    },
    {
      "Sid": "rds",
      "Effect": "Allow",
      "Action": [
        "rds:RemoveTagsFromResource",
        "rds:AddTagsToResource",
        "rds:Create*",
        "rds:Describe*",
        "rds:Modify*",
        "rds:ListTagsForResource"
      ],
      "Resource": "*"
    },
    {
      "Sid": "rdsDelete",
      "Effect": "Allow",
      "Action": [
        "rds:Delete*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Owner": "Preset-io"
        }
      }
    },
    {
      "Sid": "Elasticache",
      "Effect": "Allow",
      "Action": [
        "elasticache:Describe*",
        "elasticache:Create*",
        "elasticache:AddTagsToResource",
        "elasticache:RemoveTagsFromResource",
        "elasticache:ModifyCacheParameterGroup",
        "elasticache:ModifyReplicationGroup",
        "elasticache:ListTagsForResource"
      ],
      "Resource": "*"
    },
    {
      "Sid": "elasticacheDelete",
      "Effect": "Allow",
      "Action": [
        "elasticache:Delete*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Owner": "Preset-io"
        }
      }
    },
    {
      "Sid": "ec2",
      "Effect": "Allow",
      "Action": [
        "ec2:AllocateAddress",
        "ec2:AssignPrivateIpAddresses",
        "ec2:Associate*",
        "ec2:AttachNetworkInterface",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Create*",
        "ec2:Describe*",
        "ec2:Detach*",
        "ec2:Disassociate*",
        "ec2:ReleaseAddress",
        "ec2:Revoke*",
        "ec2:Update*",
        "ec2:GetLaunchTemplateData",
        "ec2:ModifyLaunchTemplate",
        "ec2:RunInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    },
    {
      "Sid": "elb",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ec2Delete",
      "Effect": "Allow",
      "Action": [
        "ec2:Delete*",
        "ec2:TerminateInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Owner": "Preset-io"
        }
      }
    },
    {
      "Sid": "ec2DeleteTags",
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags"
      ],
      "Resource": "*"
    },
    {
      "Sid": "eks",
      "Effect": "Allow",
      "Action": [
        "eks:Associate*",
        "eks:Create*",
        "eks:Describe*",
        "eks:List*",
        "eks:Update*",
        "eks:TagResource",
        "eks:UntagResource",
        "eks:DeleteAddon"
      ],
      "Resource": "*"
    },
    {
      "Sid": "eksDelete",
      "Effect": "Allow",
      "Action": [
        "eks:Delete*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Owner": "Preset-io"
        }
      }
    },
    {
      "Sid": "Autoscalng",
      "Effect": "Allow",
      "Action": [
        "autoscaling:EnableMetricsCollection",
        "autoscaling:AttachInstances",
        "autoscaling:Create*",
        "autoscaling:Delete*",
        "autoscaling:Describe*",
        "autoscaling:DetachInstances",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:SetInstanceProtection",
        "autoscaling:SuspendProcesses"
      ],
      "Resource": "*"
    },
    {
      "Sid": "iam",
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:AttachRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:CreateOpenIDConnectProvider",
        "iam:CreatePolicy",
        "iam:CreatePolicyVersion",
        "iam:CreateRole",
        "iam:CreateServiceLinkedRole",
        "iam:DeletePolicyVersion",
        "iam:Get*",
        "iam:List*",
        "iam:PutRolePolicy",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:TagOpenIDConnectProvider",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:TagPolicy",
        "iam:TagInstanceProfile",
        "iam:UpdateAssumeRolePolicy",
        "iam:DetachRolePolicy",
        "iam:DeletePolicy",
        "iam:UpdateRoleDescription"
      ],
      "Resource": "*"
    },
    {
      "Sid": "iamPassRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "lambda.amazonaws.com",
            "vpc-flow-logs.amazonaws.com",
            "eks.amazonaws.com",
            "rds.amazonaws.com",
            "mq.amazonaws.com",
            "s3.amazonaws.com"
          ]
        }
      }
    },
    {
      "Sid": "iamDelete",
      "Effect": "Allow",
      "Action": [
        "iam:Delete*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Owner": "Preset-io"
        }
      }
    },
    {
      "Sid": "kms",
      "Effect": "Allow",
      "Action": [
        "kms:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "kmsDelete",
      "Effect": "Allow",
      "Action": [
        "kms:ScheduleKeyDeletion",
        "kms:DeleteAlias"
      ],
      "Resource": "arn:aws:kms:*:${aws_account_id}:alias/velero-backups-*"
    },
    {
      "Sid": "s3",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucketVersions",
        "s3:CreateBucket",
        "s3:Get*",
        "s3:Put*",
        "s3:List*",
        "s3:Replicate*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "states",
      "Effect": "Allow",
      "Action": [
        "states:ListStateMachines"
      ],
      "Resource": "*"
    },
    {
      "Sid": "s3Delete",
      "Effect": "Allow",
      "Action": [
        "s3:Delete*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "wafv2",
      "Effect": "Allow",
      "Action": [
        "wafv2:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "firehose",
      "Effect": "Allow",
      "Action": [
        "firehose:*"
      ],
      "Resource": "*"
    }
  ]
}
