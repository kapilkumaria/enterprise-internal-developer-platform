# Architecture

## Overview

The **Enterprise Internal Developer Platform** is a production-style platform
engineering implementation built on AWS and Kubernetes.

It provides developers with a standardized self-service path for creating,
building, publishing, and deploying application services without requiring
each developer to manually assemble cloud infrastructure, CI/CD pipelines,
Kubernetes manifests, secrets integration, or deployment conventions.

The platform combines:

- Backstage for developer experience and service catalog capabilities
- Terraform for reproducible AWS infrastructure
- Amazon EKS for the Kubernetes runtime
- GitHub for source control
- GitHub Actions for continuous integration
- Amazon ECR for immutable container artifacts
- Argo CD for GitOps-based continuous delivery
- Helm for reusable Kubernetes application packaging
- Amazon RDS for Backstage PostgreSQL persistence
- AWS Secrets Manager and External Secrets Operator for secret delivery
- Amazon EKS Pod Identity and AWS IAM for workload authentication
- AWS Application Load Balancer, ACM, and Route 53 for HTTPS access

---

## Canonical Architecture

![Enterprise Internal Developer Platform Architecture](../diagrams/enterprise-internal-developer-platform-architecture.png)

The architecture intentionally separates the developer experience, CI,
artifact, GitOps, runtime, identity, secrets, networking, and persistence
layers.

This separation reduces coupling and gives each platform component a clearly
defined responsibility.

---

## Architecture Goals

The platform was designed around the following goals:

1. **Developer self-service**
   Developers should be able to create a standardized service through
   Backstage rather than manually assembling delivery infrastructure.

2. **Golden Path standardization**
   New services should inherit an approved repository structure, CI workflow,
   deployment conventions, metadata, and containerization model.

3. **Reproducible infrastructure**
   AWS infrastructure should be declaratively provisioned and rebuildable
   through Terraform.

4. **Separation of CI and CD**
   GitHub Actions should build and publish artifacts, while Argo CD should
   control Kubernetes deployment and reconciliation.

5. **Short-lived cloud authentication**
   CI pipelines and Kubernetes workloads should authenticate to AWS using
   federation and workload identity rather than embedded long-lived AWS
   access keys.

6. **Centralized secret management**
   Application secrets should remain in AWS Secrets Manager and be
   synchronized into Kubernetes only when required.

7. **Private runtime infrastructure**
   Kubernetes worker nodes and the PostgreSQL database should run in private
   network segments.

8. **Operational reproducibility**
   The platform should support provisioning, validation, teardown, and later
   reconstruction from source-controlled configuration.

---

## High-Level Delivery Flow

```text
Developer
    |
    v
Backstage Developer Portal
    |
    v
Software Template / Golden Path
    |
    v
Generated GitHub Repository
    |
    v
GitHub Actions
    |
    +--> Test
    +--> Security Scan
    +--> Container Build
    +--> AWS Authentication through OIDC
    |
    v
Amazon ECR
    |
    v
Immutable Container Image
    |
    v
GitOps Desired State
    |
    v
Argo CD
    |
    v
Amazon EKS
    |
    v
Running Application
```
The developer interacts primarily with Backstage and GitHub.

The platform handles the supporting cloud, identity, secrets, artifact, and
deployment mechanisms behind that workflow.

---

## Architecture Layers

### 1. Developer Experience Layer

Backstage provides the developer-facing entry point into the platform.

Its responsibilities include:

- Software Catalog
- developer portal
- Golden Path Software Templates
- service metadata
- service discovery
- TechDocs
- Kubernetes workload visibility
- self-service application scaffolding

The goal is to reduce cognitive load for application developers.

Instead of requiring developers to understand every implementation detail of
AWS, Terraform, Kubernetes, IAM, container registries, GitOps, and secrets
management, the platform exposes standardized workflows.

---

## 2. Source Control Layer

GitHub is the source-of-truth system for application and platform
configuration.

The platform uses source control for:

- generated application repositories
- application source code
- CI workflow definitions
- Dockerfiles
- Kubernetes configuration
- Helm-based deployment assets
- Backstage catalog metadata
- GitOps desired state
- Terraform configuration
- platform documentation

Backstage scaffolding creates standardized repositories rather than allowing
every application team to invent its own structure.

---

## 3. Continuous Integration Layer

GitHub Actions provides continuous integration.

The CI pipeline is responsible for:

```text
Source
  |
  v
Dependency Installation
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
AWS Authentication
  |
  v
Amazon ECR Push
```
AWS authentication uses GitHub Actions OIDC federation.

The workflow exchanges the GitHub-issued OIDC token for temporary AWS
credentials through AWS IAM.

This avoids storing persistent AWS access keys in GitHub repository secrets.

The resulting image is published to Amazon ECR using an immutable
commit-derived tag.

---

## 4. Artifact Layer

Amazon ECR provides the container artifact boundary between CI and runtime
deployment.

GitHub Actions publishes application images to ECR.

Argo CD and the Kubernetes runtime consume the resulting image reference.

This creates a clear separation between:

```
CI
Source -> Build -> Test -> Scan -> Publish
```
and:

```
CD
Desired State -> Reconcile -> Deploy
```
The build pipeline does not directly perform imperative production-style
Kubernetes deployments.

---

## 5. GitOps Layer

Argo CD provides continuous delivery through declarative GitOps
reconciliation.

Its responsibilities include:

- observing Git-hosted desired state
- detecting configuration changes
- synchronizing Kubernetes resources
- reporting synchronization status
- reporting application health
- reconciling drift
- managing the generated Golden Path application

The validated Golden Path application reached:

```text
Sync Status:   Synced
Health Status: Healthy
```
This design makes Git the deployment control plane rather than requiring
GitHub Actions to directly modify the Kubernetes cluster.

---

## 6. Kubernetes Runtime Layer

Amazon EKS provides the managed Kubernetes runtime.

The platform uses:

- Amazon EKS managed control plane
- managed node group
- private worker nodes
- VPC CNI
- CoreDNS
- kube-proxy
- EKS Pod Identity Agent

Platform workloads running in the cluster include:

- Backstage
- Argo CD
- External Secrets Operator
- AWS Load Balancer Controller
- generated Golden Path services

Application workloads are isolated using Kubernetes namespaces and
Kubernetes-native deployment resources.

---

## AWS Network Architecture

The platform VPC uses:

`10.50.0.0/16`

The network design separates internet-facing infrastructure from runtime
workloads.

```text
Internet
   |
   v
Route 53
   |
   v
Application Load Balancer
   |
   v
Public Subnets
   |
   v
Amazon EKS
   |
   v
Private Worker Nodes
```
The platform includes:

- multiple Availability Zones
- public subnets
- private subnets
- Internet Gateway
- NAT Gateway
- route tables
- security groups

The managed Kubernetes worker nodes run without public IP addresses.

Outbound internet access required by private workloads is provided through
the NAT path rather than direct public addressing.

---

## Backstage Exposure Architecture

Backstage runs as a Kubernetes workload inside Amazon EKS.

External access follows:

```text
User
  |
  v
backstage.kapilkumaria.com
  |
  v
Amazon Route 53
  |
  v
AWS Application Load Balancer
  |
  v
HTTPS / ACM Certificate
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
The AWS Load Balancer Controller provisions and manages the ALB integration
from Kubernetes.

The final target health and HTTPS endpoint were validated before teardown.

---

## Data Layer

Backstage stores persistent application metadata in Amazon RDS PostgreSQL.

The database is placed in private network infrastructure and is not exposed
as a public application endpoint.

```text
Backstage
    |
    v
Private Network
    |
    v
Amazon RDS PostgreSQL
```
The RDS service manages the database master credential through AWS Secrets
Manager rather than requiring Terraform to persist the plaintext password in
configuration.

---

## Identity Architecture

The platform deliberately uses separate identity mechanisms for external CI
and in-cluster workloads.

## GitHub Actions Identity

```text
GitHub Actions
      |
      v
GitHub OIDC Token
      |
      v
AWS IAM Trust Policy
      |
      v
Temporary AWS Credentials
      |
      v
Amazon ECR
```
The final IAM trust policy was aligned with the GitHub account's customized
OIDC subject claims.

This allows the Golden Path CI workflow to authenticate to AWS without
long-lived AWS credentials.

## Kubernetes Workload Identity

```text
Kubernetes Workload
      |
      v
Amazon EKS Pod Identity
      |
      v
AWS IAM Role
      |
      v
Authorized AWS Service
```
Dedicated workload identities were used for platform components that require
AWS API access.

This keeps AWS permissions separate from the EKS worker-node identity.

---

## Secrets Architecture

AWS Secrets Manager is the authoritative store for sensitive application
credentials.

External Secrets Operator provides the bridge between AWS Secrets Manager
and Kubernetes.

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
External Secrets authenticates to AWS through workload identity rather than
static AWS keys.

This keeps secret values out of:

- Git repositories
- Terraform configuration
- Kubernetes manifests committed to source control

GitHub OAuth and GitHub integration credentials used by Backstage were also
stored in AWS Secrets Manager and delivered to the runtime through the
platform secret-management design.

---

## Infrastructure as Code Architecture

Terraform provisions the AWS infrastructure required by the platform.

Major Terraform-managed components include:

- VPC and networking
- Amazon EKS
- managed node group
- EKS managed addons
- Amazon RDS PostgreSQL
- Amazon ECR
- AWS IAM roles and policies
- EKS Pod Identity associations
- GitHub Actions OIDC federation
- supporting security configuration

Terraform state uses a dedicated S3 backend.

The backend infrastructure is intentionally separated from the runtime stack
so the platform can be destroyed while retaining the state foundation needed
for future reconstruction.

---

## Infrastructure Lifecycle

The project explicitly validated the full infrastructure lifecycle:

```text
Terraform Configuration
        |
        v
Provision
        |
        v
Platform Validation
        |
        v
Terraform Drift Check
        |
        v
Controlled Teardown
        |
        v
Residual Resource Verification
```
Before teardown, Terraform returned:

```
No changes. Your infrastructure matches the configuration.
```
The platform was then intentionally destroyed to eliminate ongoing AWS
runtime charges.

Post-destroy verification confirmed that Project 5 runtime infrastructure,
including EKS, ECR, the project VPC, NAT gateways, load balancers, and
project Secrets Manager resources, had been removed.

The Terraform bootstrap/state infrastructure was intentionally retained.

---

## Durable and Ephemeral Resources

### Durable Resources

Resources intentionally designed to survive normal runtime reconstruction
include:

- Terraform source configuration
- Git repositories
- documentation and evidence
- Terraform remote-state foundation

### Ephemeral Runtime Resources

Resources that can be recreated from source-controlled configuration include:

- VPC runtime networking
- Amazon EKS
- managed worker nodes
- Amazon RDS PostgreSQL
- Amazon ECR repositories
- runtime IAM associations
- Kubernetes platform workloads
- application workloads
- Application Load Balancer resources

This distinction demonstrates that the platform is treated as reproducible
infrastructure rather than as manually maintained cloud state.

---

## Architecture Validation Evidence

Representative evidence is retained under:

```
docs/images/screenshots/
docs/evidence/
```
Key architecture evidence includes:

**Terraform provisioning completed successfully.**

**Amazon EKS managed worker nodes reached Ready state.**

**External Secrets successfully synchronized AWS-managed secrets into Kubernetes.**

**Argo CD applications reached synchronized and healthy state.**

ALB Target Health

**The Backstage ALB target was healthy before final platform teardown.**

---

## Architectural Outcome

The resulting platform demonstrates an end-to-end platform engineering
architecture in which:

- developers consume standardized self-service capabilities through Backstage
- repositories are generated through an opinionated Golden Path
- GitHub Actions performs continuous integration
- GitHub OIDC provides short-lived AWS authentication
- Amazon ECR provides immutable container artifacts
- Argo CD performs declarative continuous delivery
- Amazon EKS provides the managed Kubernetes runtime
- EKS Pod Identity separates application IAM permissions from node identity
- AWS Secrets Manager centralizes secret storage
- External Secrets delivers secrets safely into Kubernetes
- Amazon RDS provides private PostgreSQL persistence
- Terraform makes the cloud platform reproducible
- controlled teardown validates infrastructure lifecycle ownership

The architecture is designed to model the responsibilities and operating
patterns expected from a production-oriented Internal Developer Platform
rather than a standalone Kubernetes application.
