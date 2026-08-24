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
# GitHub Actions trust policy
#
# Initially restricted to one repository and the main branch.
#

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid    = "GitHubActionsAssumeRole"
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
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}:ref:refs/heads/${var.github_branch}"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  max_session_duration = 3600

  tags = {
    Name       = "${var.project_name}-${var.environment}-github-actions-role"
    Repository = "${var.github_owner}/${var.github_repository}"
    Purpose    = "GoldenPathCI"
  }
}

#
# ECR authorization token
#
# GetAuthorizationToken cannot be scoped to a single repository ARN.
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
  # Repository-specific image push/pull permissions
  #

  statement {
    sid    = "GoldenPathRepositoryAccess"
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
      var.ecr_repository_arn
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
