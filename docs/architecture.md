# Architecture

## Architectural Overview

The Enterprise Internal Developer Platform is divided into five logical
layers.

### 1. Developer Experience Layer

Provides the developer-facing interface.

Components:

- Backstage
- Software Catalog
- Software Templates
- TechDocs

### 2. Source and Continuous Integration Layer

Provides source control and application build automation.

Components:

- GitHub
- GitHub Actions
- Trivy
- Docker

### 3. GitOps Delivery Layer

Controls application desired state and Kubernetes deployment.

Components:

- Git repositories
- Argo CD
- Helm

### 4. Runtime Platform Layer

Provides the Kubernetes application runtime.

Components:

- AWS
- Amazon EKS
- Amazon ECR
- Kubernetes

### 5. Platform Services Layer

Provides security, secrets, policy, and observability.

Components:

- AWS Secrets Manager
- External Secrets Operator
- Kyverno
- Prometheus
- Grafana

## High-Level Request Flow

Developer
    |
    v
Backstage
    |
    v
Software Template
    |
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    +--> Test
    |
    +--> Trivy Scan
    |
    +--> Docker Build
    |
    v
Amazon ECR
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
    +--> Kyverno
    |
    +--> External Secrets
    |
    +--> Prometheus
    |
    +--> Grafana

## Architecture Decisions

### Cloud Provider

AWS is used as the cloud platform for the initial implementation.

Primary region:

`us-east-1`

### Environment Strategy

The initial platform release will use a single `dev` environment.

A single EKS cluster is intentionally used because this project focuses on
Internal Developer Platform capabilities rather than demonstrating
multi-environment Kubernetes architecture.

### Kubernetes Runtime

Amazon EKS will host:

- Backstage
- Argo CD
- External Secrets Operator
- Kyverno
- Prometheus
- Grafana
- Demo application workloads

### Backstage Persistence

Backstage will use Amazon RDS PostgreSQL rather than a PostgreSQL pod running
inside the Kubernetes cluster.

This separates application compute from database lifecycle and provides a
more production-oriented architecture.

### Continuous Integration

GitHub Actions will be responsible for:

- Source validation
- Tests
- Security scanning
- Container image build
- Image publishing
- GitOps desired-state updates

GitHub Actions will not directly deploy application workloads to Kubernetes.

### Continuous Delivery

Argo CD will provide Kubernetes continuous delivery using GitOps.

Git will remain the source of truth for Kubernetes desired state.

### Application Packaging

A reusable Helm chart will provide the platform-approved Kubernetes
application standard.

Application teams primarily provide service-specific values while the
platform team maintains deployment templates.

### Secrets Architecture

AWS Secrets Manager will store application secrets.

External Secrets Operator will synchronize required secrets into Kubernetes.

Static cloud credentials will not be stored in application repositories.

### Policy Enforcement

Kyverno will enforce Kubernetes platform guardrails.

Initial policies will include:

- Disallow privileged containers
- Require non-root execution
- Require CPU/memory requests
- Require CPU/memory limits
- Restrict application images to approved registries
- Disallow mutable `latest` image tags

### Observability

Prometheus will provide metrics collection.

Grafana will provide platform and application dashboards.

The goal of observability in this project is to make operational visibility
part of the default developer experience.

### Ingress

The AWS Load Balancer Controller will integrate Kubernetes ingress resources
with an AWS Application Load Balancer.

### Node Infrastructure

Amazon EKS Managed Node Groups will provide the initial worker-node
infrastructure.

Advanced node provisioning such as Karpenter is outside the initial platform
scope.

### Infrastructure as Code

Terraform will manage AWS infrastructure using reusable modules.

The primary modules will include:

- Networking
- EKS
- IAM
- ECR
- RDS
- Secrets

Terraform remote state will be bootstrapped separately from the platform
infrastructure.
