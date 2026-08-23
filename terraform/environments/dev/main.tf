module "networking" {
  source = "../../modules/networking"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnet_cidrs = var.public_subnet_cidrs

  private_subnet_cidrs = var.private_subnet_cidrs
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment

  kubernetes_version = var.kubernetes_version

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn

  vpc_cni_role_arn = module.iam.vpc_cni_role_arn

  private_subnet_ids = module.networking.private_subnet_ids

  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
}

#
# Backstage ECR Repository
#

module "ecr_backstage" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  repository_name = "${var.project_name}/backstage"
}

#
# Golden Path Service ECR Repository
#

module "ecr_golden_path_demo" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  repository_name = "${var.project_name}/services/${var.golden_path_repository}"

  image_tag_mutability = "IMMUTABLE"
}

#
# GitHub Actions OIDC Federation
#

module "github_actions_oidc" {
  source = "../../modules/github-actions-oidc"

  project_name = var.project_name
  environment  = var.environment

  github_owner         = var.github_owner
  github_owner_id      = var.github_owner_id
  github_repository    = var.golden_path_repository
  github_repository_id = var.golden_path_repository_id
  github_branch        = "main"

  ecr_repository_arn = module.ecr_golden_path_demo.repository_arn
}

#
# Backstage PostgreSQL Database
#

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  allowed_security_group_ids = {
    eks_cluster = module.eks.cluster_security_group_id
  }

  database_name   = "backstage"
  master_username = "backstageadmin"

  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  backup_retention_period = 7
}

#
# AWS Account Metadata
#
# Used to construct account-scoped Secrets Manager ARNs without
# hard-coding the AWS account ID.
#

data "aws_caller_identity" "current" {}

#
# Argo CD GitHub Repository Credential Secret
#
# Terraform creates the Secrets Manager secret itself, but intentionally
# does NOT manage the PAT value. This prevents the GitHub PAT from being
# written into Terraform state.
#
# The secret value will be populated separately and consumed by
# External Secrets Operator.
#

resource "aws_secretsmanager_secret" "argocd_github" {
  name        = "${var.project_name}/${var.environment}/argocd-github"
  description = "GitHub repository credentials consumed by Argo CD through External Secrets Operator."

  recovery_window_in_days = 0

  tags = {
    Name    = "${var.project_name}-${var.environment}-argocd-github"
    Purpose = "ArgoCDRepositoryAuthentication"
  }
}

#
# External Secrets Operator IAM Policy
#
# ESO receives only read access to explicitly approved platform secrets.
#
# Secrets Manager appends a random suffix to secret ARNs, therefore
# wildcard suffixes are used only for the specific approved Backstage
# secret-name prefixes.
#

data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "ReadApprovedPlatformSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      module.rds.master_user_secret_arn,

      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/${var.environment}/backstage-github-oauth-*",

      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/${var.environment}/backstage-github-integration-*",

      aws_secretsmanager_secret.argocd_github.arn
    ]
  }
}




resource "aws_iam_policy" "external_secrets" {
  name = "${var.project_name}-${var.environment}-external-secrets"

  description = "Allows External Secrets Operator to read Backstage RDS credentials."

  policy = data.aws_iam_policy_document.external_secrets.json
}






resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = module.iam.external_secrets_role_name
  policy_arn = aws_iam_policy.external_secrets.arn
}

#
# External Secrets Operator EKS Pod Identity
#

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name = module.eks.cluster_name

  namespace       = "external-secrets"
  service_account = "external-secrets"

  role_arn = module.iam.external_secrets_role_arn
}

#
# AWS Load Balancer Controller IAM Policy
#

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.project_name}-${var.environment}-aws-load-balancer-controller"
  description = "IAM permissions required by the AWS Load Balancer Controller."

  policy = file("${path.root}/../../policies/aws-load-balancer-controller-iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = module.iam.aws_load_balancer_controller_role_name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

#
# AWS Load Balancer Controller EKS Pod Identity
#

resource "aws_eks_pod_identity_association" "aws_load_balancer_controller" {
  cluster_name = module.eks.cluster_name

  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"

  role_arn = module.iam.aws_load_balancer_controller_role_arn
}
