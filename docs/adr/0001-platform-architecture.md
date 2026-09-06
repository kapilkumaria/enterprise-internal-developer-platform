# ADR-0001: Internal Developer Platform Architecture

## Status

`Accepted`

## Context

The Enterprise Internal Developer Platform requires a production-oriented
architecture that demonstrates developer self-service while keeping the
platform reproducible, secure, operationally understandable, and appropriate
for a portfolio-scale AWS environment.

The primary objective is not simply to host applications on Kubernetes.

The platform must demonstrate how a platform engineering team can provide
developers with standardized capabilities for:

- service creation
- source-control integration
- continuous integration
- container publication
- GitOps delivery
- documentation
- service catalog registration
- secrets consumption
- workload identity
- Kubernetes runtime visibility

The architecture should also avoid unnecessary multi-cluster complexity while
preserving production-style separation of responsibilities.

## Decision

The platform will use the following architecture:

### Developer Experience

- Backstage Developer Portal
- Backstage Software Catalog
- Backstage Software Templates and Scaffolder
- Backstage TechDocs
- Backstage Kubernetes integration
- GitHub OAuth

### Infrastructure

- AWS `us-east-1`
- dedicated VPC
- public and private subnets
- Amazon EKS
- EKS managed node group
- Amazon RDS PostgreSQL
- Amazon ECR
- Application Load Balancer
- AWS Certificate Manager
- Amazon Route 53
- Terraform
- S3 Terraform remote-state backend

### Identity and Secrets

- AWS IAM
- GitHub Actions OIDC federation
- Amazon EKS Pod Identity
- AWS Secrets Manager
- External Secrets Operator
- Kubernetes RBAC

### CI/CD

- GitHub for source control
- GitHub Actions for continuous integration
- commit-derived immutable container tags
- Amazon ECR for container artifacts
- Argo CD for GitOps continuous delivery
- Helm and Kubernetes manifests for application packaging and deployment

## CI/CD Responsibility Boundary

The platform deliberately separates continuous integration from continuous
delivery.

GitHub Actions is responsible for:

```text
Source
  |
  v
Test
  |
  v
Security Validation
  |
  v
Container Build
  |
  v
Amazon ECR
```
Argo CD is responsible for:

```text
Git Desired State
       |
       v
Argo CD
       |
       v
Amazon EKS
```
This prevents the CI system from becoming the primary Kubernetes deployment
authority.

# Identity Boundary

Different trust mechanisms are used for different workloads.

## CI Workloads

```text
GitHub Actions
      |
      v
GitHub OIDC
      |
      v
AWS IAM Role
      |
      v
Temporary AWS Credentials
```
## Kubernetes Workloads
```text
Kubernetes Pod
      |
      v
EKS Pod Identity
      |
      v
Dedicated IAM Role
      |
      v
Authorized AWS Service
```
Long-lived AWS access keys are therefore not required for the Golden Path CI
workflow or supported AWS-integrated Kubernetes workloads.

## Data and Secret Boundary

Backstage persists application metadata in private Amazon RDS PostgreSQL.

Sensitive integration credentials are stored in AWS Secrets Manager and
delivered to Kubernetes through External Secrets Operator where required.

Secret values are not intended to be stored directly in source-controlled
Kubernetes manifests.

## Networking Boundary

Internet-facing application traffic enters through an AWS Application Load
Balancer.

EKS worker nodes and RDS PostgreSQL remain in private network infrastructure.

Backstage is exposed through HTTPS using:

```text
Route 53
    |
    v
Application Load Balancer
    |
    v
ACM TLS
    |
    v
Kubernetes Ingress
    |
    v
Backstage
```

## Golden Path

The principal developer workflow is:

```text
Developer
    |
    v
Backstage
    |
    v
Software Template
    |
    v
Generated GitHub Repository
    |
    v
GitHub Actions
    |
    v
Amazon ECR
    |
    v
Argo CD
    |
    v
Amazon EKS
```
The platform engineering team owns the reusable platform mechanisms.

Application developers consume those mechanisms through standardized
self-service workflows.

# Consequences

## Positive
- strong developer self-service experience
- standardized Golden Path for new services
- reproducible AWS infrastructure
- clear separation between CI and CD
- short-lived CI authentication through OIDC
- workload-level AWS authorization through EKS Pod Identity
- centralized secret management
- private database and worker-node networking
- GitOps-based deployment reconciliation
- managed PostgreSQL persistence for Backstage
- source-to-container traceability through immutable image tags
- lower operational complexity than a multi-cluster design

## Trade-offs
- a single EKS cluster does not provide cluster-level environment isolation
- Amazon EKS and RDS introduce ongoing infrastructure cost while running
- NAT Gateway and Application Load Balancer resources add AWS cost
- AWS Load Balancer Controller introduces AWS-specific ingress integration
- EKS Pod Identity is specific to Amazon EKS
- the platform team remains responsible for worker capacity, Kubernetes
addons, GitOps configuration, templates, and application-platform
integration
- the architecture intentionally prioritizes the Internal Developer Platform
use case over advanced multi-cluster or autoscaling demonstrations

# Result

The resulting architecture provides a production-oriented Internal Developer
Platform while remaining small enough to build, validate, destroy, and
reconstruct as a portfolio environment.

The architecture demonstrates the platform engineering boundary between
developer self-service and the underlying cloud, Kubernetes, identity,
security, artifact, and GitOps systems.