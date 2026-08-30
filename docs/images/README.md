# Project Evidence Screenshot Index

This directory contains visual runtime evidence for the Enterprise Internal Developer Platform.

Screenshots are grouped by engineering capability rather than by capture date.

## Infrastructure

| Screenshot | Purpose |
|---|---|
| `infrastructure/terraform-apply-complete.png` | Terraform infrastructure creation completed successfully |
| `infrastructure/eks-cluster-active.png` | Amazon EKS control plane is ACTIVE |
| `infrastructure/eks-nodes-ready.png` | Managed Kubernetes worker nodes are Ready |
| `infrastructure/eks-addons-active.png` | Required EKS managed addons are ACTIVE |
| `infrastructure/rds-postgresql-private.png` | Backstage PostgreSQL RDS instance is available and private |

## Backstage

| Screenshot | Purpose |
|---|---|
| `backstage/backstage-kubernetes-runtime.png` | Backstage Kubernetes deployment/pod runtime |
| `backstage/backstage-developer-portal.png` | Backstage developer portal |
| `backstage/backstage-software-catalog.png` | Backstage Software Catalog |

## Golden Path

| Screenshot | Purpose |
|---|---|
| `golden-path/backstage-software-template.png` | Enterprise service template |
| `golden-path/golden-path-service-creation.png` | Developer Golden Path workflow |
| `golden-path/generated-service-repository.png` | Repository generated through Backstage |

## CI/CD

| Screenshot | Purpose |
|---|---|
| `cicd/github-actions-ci-success.png` | Successful service CI pipeline |
| `cicd/ecr-application-image.png` | Immutable container artifact in Amazon ECR |

## GitOps

| Screenshot | Purpose |
|---|---|
| `gitops/argocd-applications-healthy.png` | Platform Argo CD applications synchronized and healthy |
| `gitops/argocd-golden-path-application.png` | Golden Path service managed by Argo CD |

## Security

| Screenshot | Purpose |
|---|---|
| `security/external-secrets-synchronized.png` | External Secrets synchronized successfully |
| `security/eks-pod-identity.png` | AWS workload identity configuration |
| `security/trivy-image-scan.png` | Container vulnerability scanning evidence |

## Final Validation

| Screenshot | Purpose |
|---|---|
| `final/generated-service-running.png` | Golden Path application successfully running |
| `final/platform-final-validation.png` | Final end-to-end platform validation |
