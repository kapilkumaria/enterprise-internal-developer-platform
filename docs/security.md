# Security Architecture

## Security Principles

The platform will follow these principles:

- Least privilege
- No secrets committed to Git
- Workload identity instead of static cloud credentials
- Vulnerability scanning before deployment
- Kubernetes workloads run as non-root where possible
- Resource requests and limits required
- Privileged containers prohibited
- Infrastructure managed through code
- GitOps used as the source of deployment truth
- Security policies enforced automatically
- Platform defaults should be secure by design

## Planned Security Controls

### Infrastructure

- Terraform-managed IAM
- Restricted network access
- Remote Terraform state
- IAM least privilege

### CI

- Trivy filesystem scanning
- Trivy image scanning
- Dependency/security checks

### Container

- Non-root execution
- Minimal application images
- Image vulnerability scanning

### Kubernetes

- Kyverno policy enforcement
- Resource requests and limits
- SecurityContext requirements
- Privileged container restrictions

### Secrets

AWS Secrets Manager
        |
        v
External Secrets Operator
        |
        v
Kubernetes Secret
        |
        v
Application

Static AWS credentials will not be stored inside application repositories.
