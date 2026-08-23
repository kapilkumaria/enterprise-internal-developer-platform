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

module "ecr_backstage" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  repository_name = "${var.project_name}/backstage"
}

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  allowed_security_group_ids = [
    module.eks.cluster_security_group_id
  ]

  database_name   = "backstage"
  master_username = "backstageadmin"

  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  backup_retention_period = 7
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "ReadBackstageDatabaseSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      module.rds.master_user_secret_arn,
      "arn:aws:secretsmanager:us-east-1:931058976119:secret:enterprise-idp/dev/backstage-github-oauth-7zALAU"
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

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name = module.eks.cluster_name

  namespace       = "external-secrets"
  service_account = "external-secrets"

  role_arn = module.iam.external_secrets_role_arn
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.project_name}-${var.environment}-aws-load-balancer-controller"
  description = "IAM permissions required by the AWS Load Balancer Controller."

  policy = file("${path.root}/../../policies/aws-load-balancer-controller-iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = module.iam.aws_load_balancer_controller_role_name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

resource "aws_eks_pod_identity_association" "aws_load_balancer_controller" {
  cluster_name = module.eks.cluster_name

  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"

  role_arn = module.iam.aws_load_balancer_controller_role_arn
}
