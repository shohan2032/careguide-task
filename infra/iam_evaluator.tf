data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_user" "evaluator" {
  count = var.create_evaluator_user ? 1 : 0

  name          = "${var.project}-evaluator"
  force_destroy = true

  tags = {
    Name = "${var.project}-evaluator"
  }
}

resource "aws_iam_user_login_profile" "evaluator" {
  count = var.create_evaluator_user ? 1 : 0

  user                    = aws_iam_user.evaluator[0].name
  password_length         = 24
  password_reset_required = true
}

resource "aws_iam_access_key" "evaluator" {
  count = var.create_evaluator_user ? 1 : 0

  user = aws_iam_user.evaluator[0].name
}

data "aws_iam_policy_document" "evaluator" {
  statement {
    sid = "SelfServicePassword"
    actions = [
      "iam:ChangePassword",
      "iam:GetUser",
    ]
    resources = ["arn:aws:iam::${local.account_id}:user/${var.project}-evaluator"]
  }

  statement {
    sid       = "PasswordPolicy"
    actions   = ["iam:GetAccountPasswordPolicy"]
    resources = ["*"]
  }

  statement {
    sid = "ReadOnlyInRegion"
    actions = [
      "ec2:Describe*",
      "ecr:DescribeRegistry",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ssm:DescribeInstanceInformation",
      "ssm:DescribeParameters",
      "ssm:ListCommands",
      "ssm:ListCommandInvocations",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  statement {
    sid = "EcrReadAndPull"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:ListTagsForResource",
    ]
    resources = [aws_ecr_repository.app.arn]
  }

  statement {
    sid = "IamList"
    actions = [
      "iam:ListInstanceProfiles",
      "iam:ListOpenIDConnectProviders",
      "iam:ListRoles",
    ]
    resources = ["*"]
  }

  statement {
    sid = "IamReadProjectResources"
    actions = [
      "iam:GetInstanceProfile",
      "iam:GetOpenIDConnectProvider",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/${var.project}-*",
      "arn:aws:iam::${local.account_id}:instance-profile/${var.project}-*",
      local.github_oidc_provider_arn,
    ]
  }
}

resource "aws_iam_user_policy" "evaluator" {
  count = var.create_evaluator_user ? 1 : 0

  name   = "${var.project}-evaluator-readonly"
  user   = aws_iam_user.evaluator[0].name
  policy = data.aws_iam_policy_document.evaluator.json
}
