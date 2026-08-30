#
# GitHub Actions OIDC Provider
#

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-github-actions-oidc"
  }
}

#
# Shared Golden Path GitHub Actions Trust Policy
#
# This role is intentionally reusable by Golden Path service repositories
# owned by the approved GitHub account.
#
# The GitHub OIDC subject restricts federation to:
#
#   - repositories belonging to the approved GitHub owner
#   - the approved deployment branch
#
# Repository names are dynamic because Backstage creates new repositories,
# therefore the repository component is matched with StringLike.
#
# AWS permissions remain separately restricted by the attached least-privilege
# ECR policy.
#

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid    = "GoldenPathGitHubActionsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_owner}/*:ref:refs/heads/${var.github_branch}"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  max_session_duration = 3600

  tags = {
    Name    = "${var.project_name}-${var.environment}-github-actions-role"
    Owner   = var.github_owner
    Purpose = "GoldenPathCI"
  }
}

#
# ECR Authorization
#
# GetAuthorizationToken does not support repository-level resource scoping.
#

data "aws_iam_policy_document" "github_actions_ecr" {
  statement {
    sid    = "ECRAuthorization"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]
  }

  #
  # Golden Path ECR Namespace
  #
  # Service repositories may only interact with repositories underneath:
  #
  #   enterprise-idp/services/*
  #
  # This allows Backstage-created services to share the platform CI role
  # without granting access to unrelated ECR repositories.
  #

  statement {
    sid    = "GoldenPathRepositoryNamespaceAccess"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:DescribeImages"
    ]

    resources = [
      var.ecr_repository_arn_pattern
    ]
  }
}

resource "aws_iam_policy" "github_actions_ecr" {
  name = "${var.project_name}-${var.environment}-github-actions-ecr"

  description = "Least-privilege ECR access for the Golden Path GitHub Actions workflow."

  policy = data.aws_iam_policy_document.github_actions_ecr.json

  tags = {
    Name    = "${var.project_name}-${var.environment}-github-actions-ecr"
    Purpose = "GoldenPathCI"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}
