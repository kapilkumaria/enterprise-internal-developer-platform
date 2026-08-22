# ADR-0001: Initial Internal Developer Platform Architecture

## Status

Accepted

## Context

The platform requires a production-style architecture that demonstrates
developer self-service without introducing unnecessary infrastructure
complexity or cost.

The primary objective is to demonstrate Internal Developer Platform and
Platform Engineering capabilities rather than repeat previously implemented
multi-cluster Kubernetes patterns.

## Decision

The initial platform will use:

- AWS us-east-1
- One development EKS cluster
- EKS Managed Node Groups
- Backstage running on EKS
- Amazon RDS PostgreSQL for Backstage persistence
- GitHub for source control
- GitHub Actions for CI
- Amazon ECR for images
- Argo CD for GitOps CD
- Helm for application packaging
- AWS Secrets Manager with External Secrets Operator
- Kyverno for policy enforcement
- Prometheus and Grafana for observability
- AWS Load Balancer Controller for ingress
- Terraform for infrastructure provisioning

## Consequences

### Positive

- Production-oriented architecture
- Clear separation of CI and CD
- Managed database lifecycle
- Secure secrets architecture
- Reusable application standards
- Strong developer self-service story
- Lower infrastructure complexity than a multi-cluster design

### Trade-offs

- Single-cluster architecture does not provide environment-level isolation
- RDS adds additional infrastructure cost
- AWS Load Balancer Controller introduces AWS-specific ingress coupling
- Advanced autoscaling is intentionally deferred
