{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Action" : [
        "eks:AccessKubernetesApi",
        "eks:Describe*",
        "eks:List*",
        "ec2:*",
        "ssm:*"
      ],
      "Effect" : "Allow",
      "Resource" : "*"
      }, {
      "Effect" : "Deny",
      "Action" : "ssm:*",
      "Resource" : "*",
      "Condition" : {
        "NotIpAddress" : {
          "aws:SourceIp" : [
            "35.161.45.11/32",
            "52.32.136.34/32",
            "54.244.23.85/32",
            "52.88.46.148/32",
            "35.161.104.245/32",
            "52.88.129.18/32"
          ]
        }
      }
    }
  ]
}
