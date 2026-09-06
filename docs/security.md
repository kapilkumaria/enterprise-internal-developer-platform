# Security Architecture

## Overview

Security in the **Enterprise Internal Developer Platform** is implemented
across multiple layers rather than relying on a single security control.

The platform applies security controls to:

- CI/CD authentication
- AWS IAM
- Kubernetes workload identity
- secrets management
- Kubernetes authorization
- network architecture
- database access
- external HTTPS exposure
- container delivery
- GitOps access
- Terraform state
- developer self-service workflows

The core design principle is:

> provide each system with the minimum identity, network access, and secret
> exposure required to perform its responsibility.

---

## Security Model

The platform uses different security mechanisms for different trust
boundaries.

```text
Developer
    |
    v
GitHub / Backstage Authentication
    |
    v
-------------------------------------------------
CI Trust Boundary
GitHub Actions -> OIDC -> AWS IAM
-------------------------------------------------
    |
    v
Amazon ECR
    |
    v
-------------------------------------------------
Runtime Trust Boundary
Kubernetes Pod -> EKS Pod Identity -> AWS IAM
-------------------------------------------------
    |
    +--> AWS Secrets Manager
    |
    +--> AWS APIs
    |
    v
Amazon EKS
    |
    v
-------------------------------------------------
Data / Network Trust Boundary
Private Networking -> Amazon RDS PostgreSQL
-------------------------------------------------
```
This prevents one credential or identity mechanism from becoming the
universal trust mechanism for the entire platform.

---

# 1. GitHub Actions Authentication

### Problem

CI pipelines often require AWS access for operations such as publishing
container images.

A traditional implementation may store:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```
as long-lived CI secrets.

This creates several risks:

- credential leakage
- manual key rotation
- credentials surviving longer than the CI job
- secret duplication across repositories
- increased blast radius

The platform therefore does not depend on static AWS access keys for the
Golden Path CI workflow.

---

## GitHub OIDC Federation

GitHub Actions authenticates to AWS using OpenID Connect.

```text
GitHub Actions
      |
      v
GitHub OIDC Token
      |
      v
AWS IAM OIDC Provider
      |
      v
IAM Trust Policy
      |
      v
Temporary AWS Credentials
```
The AWS OIDC provider is:

`token.actions.githubusercontent.com`

with the expected audience:

`sts.amazonaws.com`

The resulting credentials are temporary and scoped through the IAM role
assumed by the workflow.

---

## OIDC Trust Restriction

The IAM role does not trust arbitrary GitHub workloads.

The final implementation restricts the OIDC subject to the intended GitHub
owner and branch.

The GitHub account used customized OIDC subject claims containing immutable
owner and repository identifiers.

The observed subject format required a trust pattern equivalent to:

`repo:kapilkumaria@42500918/*@*:ref:refs/heads/main`

The trust policy was updated to match that actual identity format.

This is stronger than simply allowing any GitHub Actions workflow to assume
the role.

---

## OIDC Failure and Remediation

During implementation, CI initially failed to assume the AWS IAM role.

The issue was traced to a mismatch between the IAM trust policy and the
actual customized GitHub OIDC `sub` claim.

The trust policy was corrected.

The workflow subsequently authenticated successfully.

This validation demonstrates that the federation path was tested using the
actual token identity rather than assumed from a generic GitHub OIDC example.

---

# 2. Kubernetes Workload Identity

CI identity and runtime workload identity are intentionally separate.

Kubernetes workloads use Amazon EKS Pod Identity when they require access
to AWS APIs.

```text
Kubernetes Pod
      |
      v
Kubernetes Service Account
      |
      v
EKS Pod Identity Association
      |
      v
Dedicated IAM Role
      |
      v
AWS Service
```
This avoids using the EKS worker-node IAM role as the application identity.

---

## Why Separate Node and Workload Permissions?

If AWS permissions are attached broadly to the node role, multiple pods
running on the same worker may inherit an unnecessarily large AWS permission
boundary.

Using workload-specific IAM roles allows the platform to reason about
permissions at the workload level.

The project used workload identity for AWS-integrated platform components
including:

- External Secrets Operator
- AWS Load Balancer Controller

This provides clearer IAM ownership and reduces unnecessary permission
sharing between workloads.

---

# 3. Secrets Management

AWS Secrets Manager is the authoritative external secret store for sensitive
platform credentials.

The platform avoids storing secret values directly in:

- Git repositories
- Terraform source configuration
- committed Kubernetes manifests
- application source code

The secret delivery architecture is:

```text
AWS Secrets Manager
       |
       v
EKS Pod Identity
       |
       v
External Secrets Operator
       |
       v
Kubernetes Secret
       |
       v
Authorized Application
```
External Secrets Operator retrieves secrets using its dedicated AWS identity.

---

## External Secrets Validation

Secret synchronization was validated successfully.

The implementation included AWS permissions required by External Secrets for
secret discovery and retrieval while keeping the identity separate from the
worker-node role.

---

## Backstage Secrets

Sensitive Backstage integrations were stored in AWS Secrets Manager.

These included:

- GitHub OAuth credentials
- GitHub integration token

The application consumes the required values at runtime rather than storing
them in the Backstage source repository.

---

## Argo CD Repository Credentials

Argo CD requires credentials to access the private Git repository used by
the platform.

Those credentials were also integrated with AWS Secrets Manager and External
Secrets rather than being committed directly to GitOps configuration.

This applies the same secret-management pattern to both application and
platform components.

---

# 4. RDS Credential Security

Backstage uses Amazon RDS PostgreSQL.

The database master password is managed by Amazon RDS through AWS Secrets
Manager.

Terraform configures RDS to manage the master credential instead of defining
the plaintext password as a Terraform variable.

This reduces the risk of database credentials being exposed through:

- Terraform source
- shell history
- committed variable files
- manually maintained configuration

The database connection also uses PostgreSQL SSL.

---

# 5. Network Security

The AWS network architecture separates public ingress infrastructure from
private runtime infrastructure.

The VPC uses:

`10.50.0.0/16`

and contains public and private subnets.

The intended traffic model is:

```text
Internet
   |
   v
Application Load Balancer
   |
   v
Controlled Kubernetes Ingress
   |
   v
Private EKS Worker Nodes
   |
   +--> Application Workloads
   |
   +--> Backstage
   |
   v
Private RDS PostgreSQL
```
EKS worker nodes are not exposed through public node IP addresses.

RDS is also deployed in private network infrastructure.

---

## NAT and Outbound Connectivity

Private workloads can require outbound access for operations such as
dependency retrieval or external API communication.

Outbound connectivity is provided through the VPC NAT path.

This allows private workloads to initiate required outbound connections
without making those worker nodes directly internet-addressable.

---

# 6. Database Network Isolation

Amazon RDS PostgreSQL is not used as an internet-facing database.

Database connectivity is restricted through private networking and security
group relationships.

Conceptually:

```text
Internet
   X
   |
   | No direct application database exposure
   |
Private RDS PostgreSQL
       ^
       |
Authorized Backstage Connectivity
```
This reduces the externally reachable attack surface of the persistence
layer.

---

# 7. HTTPS and TLS

The Backstage developer portal is exposed through HTTPS.

The production-style endpoint used:

`https://backstage.kapilkumaria.com`

The ingress path includes:

```text
Route 53
    |
    v
AWS Application Load Balancer
    |
    v
AWS Certificate Manager
    |
    v
HTTPS
    |
    v
Kubernetes Ingress
    |
    v
Backstage
```
TLS termination protects traffic between external users and the public
application endpoint.

The ALB backend target was also validated as healthy.

ALB Target Healthy

---

# 8. Kubernetes RBAC

Backstage requires Kubernetes API access to display workload information.

The implementation does not grant Backstage cluster-administrator
permissions.

Instead, Backstage uses:

- a dedicated Kubernetes ServiceAccount
- namespaced read-only Role
- RoleBinding
- explicitly validated permissions

The required access was verified using Kubernetes authorization checks.

This applies least privilege at the Kubernetes API layer.

---

# 9. Backstage Authentication

GitHub OAuth provides user authentication to the Backstage developer portal.

The authentication flow is:

```text
Developer
    |
    v
Backstage
    |
    v
GitHub OAuth
    |
    v
Authenticated GitHub Identity
    |
    v
Backstage Catalog User
```
The authenticated user is resolved against a Backstage catalog identity.

This prevents production access from relying on the scaffold application's
guest authentication model.

---

# 10. Container Security

The Golden Path CI workflow incorporates security validation as part of the
delivery process.

Trivy is used for container/security scanning within the project delivery
model.

Security validation is positioned before artifact promotion so that scanning
is part of CI rather than an entirely separate manual activity.

The broader artifact lifecycle is:

```text
Source
   |
   v
Tests
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
Container artifacts are published using commit-derived immutable tags.

This improves traceability between:

`Git Commit <-> CI Run <-> Container Image`

The project does not claim an image-signing or Notation implementation.

---

# 11. GitOps Security Boundary

The platform separates CI from Kubernetes deployment.

GitHub Actions is responsible for building and publishing artifacts.

Argo CD is responsible for deployment reconciliation.

```text
GitHub Actions
      |
      v
Amazon ECR

Git Desired State
      |
      v
Argo CD
      |
      v
Amazon EKS
```
This avoids making the CI pipeline the primary Kubernetes deployment
authority.

Argo CD provides a dedicated reconciliation boundary for cluster delivery.

---

# 12. Argo CD Private Repository Authentication

Argo CD accesses private GitHub configuration using repository credentials.

The credentials are delivered through the platform's external secret
management mechanism.

This avoids embedding GitHub credentials directly inside committed Argo CD
manifests.

The final applications were validated as healthy and synchronized.

---

# 13. Terraform State Security

Terraform state is stored in a dedicated S3 backend.

The bootstrap implementation includes controls such as:

- server-side encryption
- S3 versioning
- public-access blocking
- ownership controls

Terraform state is not committed to the Git repository.

The bootstrap/state layer is separated from the runtime environment.

This allows runtime infrastructure to be destroyed while retaining the
state-management foundation.

---

# 14. Infrastructure Reproducibility as a Security Control

Reproducible infrastructure also contributes to security.

The platform infrastructure is defined through Terraform rather than relying
on undocumented manual cloud configuration.

Before final teardown, Terraform reported:

`No changes. Your infrastructure matches the configuration.`

This demonstrated alignment between Terraform configuration and the live
Terraform-managed environment at the final validation checkpoint.

Reproducibility makes security controls reviewable and reduces dependence on
untracked console changes.

---

# 15. Secret Lifecycle During Teardown

Runtime secrets were treated as part of the disposable runtime environment.

After evidence capture, Project 5 Secrets Manager resources were removed
along with the runtime platform.

Post-destroy validation confirmed that the project Secrets Manager resources
included in the teardown verification were no longer present.

This prevents abandoned runtime credentials from remaining after the
environment has been retired.

---

# 16. Security Responsibilities by Layer

| Layer                            | Primary Security Control                      |
| -------------------------------- | --------------------------------------------- |
| Developer authentication         | GitHub OAuth                                  |
| CI-to-AWS authentication         | GitHub Actions OIDC                           |
| CI authorization                 | Dedicated AWS IAM role                        |
| Kubernetes-to-AWS authentication | EKS Pod Identity                              |
| AWS authorization                | Workload-specific IAM roles and policies      |
| Secret storage                   | AWS Secrets Manager                           |
| Kubernetes secret delivery       | External Secrets Operator                     |
| Kubernetes API access            | ServiceAccount + RBAC                         |
| Database access                  | Private networking + security groups          |
| External application access      | ALB + ACM HTTPS                               |
| Worker-node exposure             | Private networking                            |
| Container delivery               | CI security validation + immutable image tags |
| Kubernetes delivery              | Argo CD GitOps                                |
| Terraform state                  | Encrypted/versioned S3 backend                |


---

# 17. Security Failure Testing and Troubleshooting

Security controls were validated through real implementation failures rather
than only static configuration review.

Examples included:

## GitHub OIDC Trust Failure

The initial IAM trust did not match the actual customized GitHub OIDC
subject.

The failure was diagnosed using the real token claims and corrected.

## External Secrets IAM Permissions

External Secrets required additional AWS Secrets Manager discovery
permissions for the implemented secret lookup mechanism.

The IAM policy was corrected and secret synchronization subsequently
succeeded.

## PostgreSQL SSL

Backstage initially attempted a database connection incompatible with the
RDS PostgreSQL SSL requirement.

The production database configuration was corrected to use SSL.

## GitHub Integration Permissions

TechDocs exposed an insufficient GitHub token permission.

The fine-grained token permissions were corrected rather than replacing the
integration with an unnecessarily broad credential.

These cases demonstrate iterative least-privilege engineering: grant the
capability required by the workload rather than bypassing the security
control.

---

# 18. Security Evidence

Representative visual evidence includes:

```text
docs/images/screenshots/external-secrets-synchronized.png
docs/images/screenshots/github-actions-ci-oidc-failure.png
docs/images/screenshots/github-actions-oidc-trust-fixed.png
docs/images/screenshots/github-actions-ci-oidc-success.png
docs/images/screenshots/backstage-https-tls-health.png
docs/images/screenshots/backstage-alb-target-healthy.png
docs/images/screenshots/rds-postgresql-private.png
docs/images/screenshots/golden-path-ecr-ci-image.png
```
Additional source-controlled evidence exists throughout:
```
terraform/
kubernetes/
gitops/
backstage/
docs/evidence/
```
---

# 19. Security Outcome

The final platform demonstrates defense in depth across the developer and
runtime lifecycle.

Key outcomes include:

- no static AWS access keys required by Golden Path CI
- short-lived AWS authentication through GitHub OIDC
- GitHub OIDC trust restricted to the intended identity pattern
- Kubernetes workloads use dedicated AWS identities
- worker-node IAM is separated from workload IAM
- secrets remain externally managed in AWS Secrets Manager
- External Secrets delivers authorized secrets into Kubernetes
- Backstage Kubernetes access uses scoped RBAC
- PostgreSQL runs in private infrastructure
- worker nodes run in private network segments
- Backstage is exposed through HTTPS using ALB and ACM
- CI includes security validation
- container artifacts use immutable commit-derived tags
- GitOps separates build authority from deployment reconciliation
- Terraform state uses a protected remote backend
- runtime secrets are removed during controlled teardown

Security is therefore treated as an architectural property of the Internal
Developer Platform rather than as a single tool or final pipeline stage.
