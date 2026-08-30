# Security Architecture

## Overview

Security is implemented as a layered platform capability rather than a single deployment-stage check.

The platform addresses:

- human-to-cloud authentication
- workload identity
- CI authentication
- secret management
- container security
- network isolation
- database exposure
- artifact integrity

---

## 1. GitHub Actions Authentication

GitHub Actions authenticates to AWS using OpenID Connect federation.

This avoids storing long-lived AWS access keys in GitHub secrets.

```text
GitHub Actions
      |
      | OIDC token
      v
AWS IAM
      |
      | AssumeRole
      v
Temporary AWS credentials
```
---

## 2. Kubernetes Workload Identity

EKS Pod Identity allows Kubernetes workloads to assume dedicated IAM roles.

This avoids embedding AWS credentials inside:

- container images
- ConfigMaps
- Kubernetes Secrets
- source repositories

---

## 3. Secrets Management

AWS Secrets Manager acts as the external source of truth.

External Secrets retrieves approved secrets and synchronizes them into Kubernetes.

```text
AWS Secrets Manager
       |
       | IAM / Pod Identity
       v
External Secrets
       |
       v
Kubernetes Secret
       |
       v
Application
```
---

## 4. Database Security

The Backstage PostgreSQL database is:

- deployed in private networking
- not publicly accessible
- encrypted at rest
- protected using security groups
- configured with AWS-managed master credentials

---

## 5. Container Security

Container images are scanned using Trivy.

Security reports are retained under:
`security-reports/`

---

## 6. Network Security

The architecture separates public ingress from private workloads.

Worker nodes and RDS do not require direct public exposure.

---

## Security Design Principle

The platform follows the principle:

> Applications should receive only the identity, network access and secrets required to perform their function.

This reduces credential exposure and limits blast radius.