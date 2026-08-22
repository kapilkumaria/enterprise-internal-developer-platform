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
