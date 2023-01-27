resource "aws_iam_role" "lambda" {
  name               = var.lambda_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json

  inline_policy {
    name   = "AllowEC2Access"
    policy = data.aws_iam_policy_document.ec2.json
  }
  inline_policy {
    name   = "AllowCloudWatchLogsAccess"
    policy = data.aws_iam_policy_document.logs.json
  }
}

data "aws_iam_policy_document" "ec2" {
  statement {
    resources = ["*"]
    actions = [
      "ec2:DescribeInstances",
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]
  }
}

data "aws_iam_policy_document" "logs" {
  statement {
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:*"
    ]
    actions = [
      "logs:CreateLogGroup"
    ]
  }
  statement {
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:log-group:/aws/lambda/${var.lambda_name}:*"
    ]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}
