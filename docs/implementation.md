# Implementation Guide

## Purpose

This document describes how the **Enterprise Internal Developer Platform**
was implemented and validated.

The platform was built as a production-style AWS Internal Developer Platform
using Terraform, Amazon EKS, Backstage, GitHub Actions, Amazon ECR, Argo CD,
External Secrets Operator, Amazon RDS PostgreSQL, and AWS-native identity and
networking services.

The implementation was intentionally structured so that infrastructure,
platform services, developer experience, continuous integration, GitOps
delivery, secrets, and identity remain separate concerns.

---

## 1. Repository Foundation

The repository separates infrastructure, Kubernetes platform configuration,
Backstage application code, GitOps configuration, reusable templates,
security artifacts, documentation, and evidence.

Major areas include:

```text
.
├── backstage/
├── diagrams/
├── docs/
├── gitops/
├── helm/
├── kubernetes/
├── scripts/
├── security-reports/
├── templates/
└── terraform/
```
This structure keeps platform concerns explicit rather than placing all
configuration into a single directory.

---

## 2. Terraform Remote State Foundation

Terraform state is stored remotely using an Amazon S3 backend.

The bootstrap layer is separated from the runtime infrastructure so the
runtime platform can be destroyed without destroying the state foundation
required for future reconstruction.

The bootstrap configuration provides:

- dedicated S3 state storage
- bucket versioning
- server-side encryption
- public-access blocking
- ownership controls

This state infrastructure was intentionally retained after final runtime
teardown.

---

## 3. AWS Networking

The development platform uses a dedicated VPC:

`10.50.0.0/16`

The network implementation includes:

- public subnets
- private subnets
- multiple Availability Zones
- Internet Gateway
- NAT Gateway
- public and private route tables
- security-group controls

The design places Kubernetes worker nodes and database infrastructure in
private network segments.

Internet-facing access is provided through controlled ingress rather than by
assigning public addresses directly to worker nodes.

---

## 4. Amazon EKS

Amazon EKS provides the Kubernetes runtime.

The implementation includes:

- managed EKS control plane
- managed node group
- private worker networking
- VPC CNI
- CoreDNS
- kube-proxy
- EKS Pod Identity Agent

The cluster used the project name:

`enterprise-idp-dev`

During final validation, both managed worker nodes reached Ready state.

Required EKS managed addons were also validated as active.

---

## 5. EKS Workload Identity

AWS permissions required by Kubernetes workloads are separated from the
worker-node IAM role.

The platform uses Amazon EKS Pod Identity for AWS-aware platform
components.

This was used for workloads including:

- External Secrets Operator
- AWS Load Balancer Controller

The authentication pattern is:

```text
Kubernetes Service Account
        |
        v
EKS Pod Identity Association
        |
        v
Dedicated IAM Role
        |
        v
Authorized AWS API
```
This avoids granting application-specific AWS permissions to the underlying
EKS node role.

---

## 6. Amazon RDS PostgreSQL

Backstage uses Amazon RDS PostgreSQL for persistent application metadata.

The database implementation uses:

- private networking
- controlled security-group access
- PostgreSQL
- AWS-managed master credentials
- AWS Secrets Manager integration

The RDS master password is managed by AWS rather than being defined as
plaintext Terraform input.

During Backstage integration, PostgreSQL SSL requirements were explicitly
handled in the production configuration.

---

## 7. Amazon ECR

Amazon ECR stores container artifacts produced by the platform.

The implementation includes container repositories for platform and generated
application images.

Backstage was built as a container image and published to ECR.

The Golden Path CI workflow also publishes generated service images to ECR.

Application images use commit-derived tags to provide source-to-artifact
traceability.

Example delivery model:

```text
Git Commit
    |
    v
GitHub Actions
    |
    v
Container Build
    |
    v
SHA-Tagged Image
    |
    v
Amazon ECR
```
---

## 8. External Secrets Operator

External Secrets Operator provides Kubernetes workloads with controlled
access to secrets stored in AWS Secrets Manager.

The operator runs inside Amazon EKS and authenticates to AWS through EKS Pod
Identity.

The secret-delivery flow is:

```text
AWS Secrets Manager
       |
       v
External Secrets Operator
       |
       v
Kubernetes Secret
       |
       v
Application Pod
```
The project validated successful secret synchronization.

The implementation avoids committing secret values to Git or embedding them
directly in Kubernetes manifests.

---

## 9. Backstage Developer Portal

Backstage provides the developer-facing interface for the platform.

The production deployment runs as a Kubernetes workload on Amazon EKS.

Implemented capabilities include:

- Software Catalog
- Software Templates
- Scaffolder
- GitHub integration
- GitHub OAuth
- TechDocs
- Kubernetes integration
- service ownership metadata
- generated service registration

Backstage uses Amazon RDS PostgreSQL for persistence.

GitHub OAuth and GitHub integration credentials are stored in AWS Secrets
Manager and synchronized to the runtime rather than committed to source
control.

---

## 10. Backstage Authentication

GitHub OAuth provides developer authentication to Backstage.

The production endpoint used:

`https://backstage.kapilkumaria.com`

The OAuth callback was configured for the Backstage GitHub authentication
provider.

A catalog user entity was created for the authenticated GitHub user, allowing
Backstage to resolve the signed-in identity to a catalog entity.

The implementation also validated ownership information through the
`platform-engineering` group.

---

## 11. Backstage Kubernetes Integration

Backstage was integrated with the in-cluster Kubernetes API.

The integration uses:

- in-cluster Kubernetes connectivity
- service-account authentication
- namespace-scoped read-only RBAC
- Kubernetes metadata annotations and labels

Backstage does not receive administrative Kubernetes privileges.

The service account was explicitly validated for the required read-only
operations.

This allows developers to inspect relevant Kubernetes workload information
through Backstage without turning the developer portal into a privileged
cluster administration interface.

---

## 12. TechDocs

TechDocs provides documentation associated with generated services.

The Golden Path template creates documentation assets including:

```
mkdocs.yml
docs/index.md
```
The Backstage container was extended with the tooling required to build and
serve TechDocs.

During implementation, GitHub integration permissions were corrected so
Backstage could access the repository metadata required for documentation
generation.

The final TechDocs workflow successfully generated and served documentation
through Backstage.

---

## 13. Public HTTPS Exposure

Backstage is exposed using Kubernetes Ingress and the AWS Load Balancer
Controller.

The request path is:

```text
User
  |
  v
Route 53
  |
  v
Application Load Balancer
  |
  v
ACM TLS Certificate
  |
  v
Kubernetes Ingress
  |
  v
Backstage Service
  |
  v
Backstage Pod
```
The public endpoint was validated over HTTPS.

The associated ALB target was also validated as healthy.

ALB target Healthy

---

## 14. Argo CD

Argo CD provides the GitOps continuous-delivery layer.

It was installed into the argocd namespace and configured to manage
application desired state.

The platform validated the generated Golden Path application:

`idp-golden-path-demo`

with:

```
Sync Status:   Synced
Health Status: Healthy
```
Private GitHub repository authentication for Argo CD is delivered through
AWS Secrets Manager and External Secrets rather than hardcoded repository
credentials.

---

## 15. Golden Path Software Template

The Backstage Software Template provides the primary developer self-service
capability.

The template generates a standardized application repository containing the
baseline assets required by the platform.

These include:

- application source
- package metadata
- tests
- Dockerfile
- GitHub Actions workflow
- Backstage catalog metadata
- developer documentation
- deployment-related configuration

The Scaffolder workflow was validated successfully.

A generated repository was then validated in GitHub.

---

## 16. GitHub Actions Continuous Integration

Generated services use GitHub Actions for continuous integration.

The final CI lifecycle performs:

```text
Checkout
   |
   v
Node Setup
   |
   v
Dependency Installation
   |
   v
Tests
   |
   v
AWS OIDC Authentication
   |
   v
Amazon ECR Login
   |
   v
Container Build
   |
   v
Immutable Tag
   |
   v
Amazon ECR Push
```
CI is intentionally responsible for artifact creation rather than direct
imperative deployment to EKS.

---

## 17. GitHub Actions OIDC Federation

GitHub Actions authenticates to AWS through OpenID Connect.

The implementation uses:

`token.actions.githubusercontent.com`

with audience:

`sts.amazonaws.com`

The workflow assumes a dedicated IAM role rather than using long-lived AWS
access keys.

The GitHub account used customized OIDC subject claims containing immutable
owner and repository identifiers.

The final trust pattern was aligned with the observed token format and
restricted to the intended GitHub owner and main branch.

After correction, AWS federation succeeded.

---

## 18. CI and CD Separation

The implementation deliberately separates continuous integration from
continuous delivery.

### GitHub Actions

Responsible for:

- source validation
- tests
- security validation
- container build
- AWS federation
- ECR publication

### Argo CD

Responsible for:

- desired-state observation
- Kubernetes reconciliation
- synchronization
- deployment
- application health reporting

This prevents the CI pipeline from becoming the Kubernetes deployment control
plane.

---

## 19. Terraform Rebuild Validation

The runtime platform was intentionally reconstructed from Terraform during
the project.

This validated that the environment was not dependent on undocumented manual
cloud configuration.

Successful provisioning evidence was captured after the rebuild.

The rebuilt environment was subsequently used for Backstage, Golden Path,
CI/CD, GitOps, and final platform validation.

---

## 20. Terraform Drift Validation

Before final teardown, Terraform was executed using a detailed plan check.

The result was:

`No changes. Your infrastructure matches the configuration.`

This confirmed that the live Terraform-managed runtime infrastructure matched
the source-controlled desired state at the final validation checkpoint.

The captured evidence is retained under:

`docs/evidence/phase-30-terraform-drift-check.txt`

---

## 21. End-to-End Platform Validation

The final validation covered the complete platform lifecycle.

Validated capabilities included:

- Terraform infrastructure provisioning
- EKS worker health
- EKS addon health
- private PostgreSQL
- External Secrets synchronization
- Backstage runtime health
- public HTTPS access
- healthy ALB target
- Backstage authentication
- Backstage Software Catalog
- Golden Path template execution
- generated GitHub repository
- GitHub Actions CI
- GitHub-to-AWS OIDC federation
- immutable ECR image publication
- Argo CD synchronization
- generated application health

Representative final runtime evidence:

---

## 22. Controlled Teardown

After final validation and evidence capture, the runtime infrastructure was
intentionally destroyed to eliminate unnecessary AWS charges.

Pre-destroy evidence was retained for:

- AWS resource inventory
- Kubernetes nodes
- Kubernetes workloads
- services
- ingress
- Argo CD application health

Post-destroy verification confirmed the absence of Project 5 runtime
resources checked across:

- Amazon EKS
- Amazon ECR
- AWS Secrets Manager
- project VPC
- NAT Gateways
- Application Load Balancers
- project-tagged AWS runtime resources

The verification evidence is stored at:

`docs/evidence/destroy/post-destroy-aws-verification.txt`

The Terraform bootstrap S3 state foundation was intentionally retained.

---

## 23. Implementation Outcome

The completed implementation demonstrates a full Internal Developer Platform
lifecycle:

```text
Terraform
   |
   v
AWS Platform
   |
   v
Backstage
   |
   v
Golden Path
   |
   v
GitHub Repository
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
   |
   v
Running Service
```
Supporting capabilities provide:

- workload identity
- secrets management
- private persistence
- HTTPS ingress
- GitOps reconciliation
- catalog registration
- developer documentation
- infrastructure reproducibility
- drift validation
- controlled teardown

The result is a production-oriented platform engineering implementation in
which developers consume standardized self-service capabilities while the
platform team owns the reusable infrastructure, security, identity, and
delivery mechanisms.
