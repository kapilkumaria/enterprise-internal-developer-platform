# ADR-0002: Use EKS Pod Identity for AWS Workload Authentication

## Status

Accepted

## Context

Kubernetes workloads running on Amazon EKS require access to selected AWS
services such as AWS Secrets Manager.

AWS credentials must not be embedded in:

- Source code
- Container images
- Kubernetes manifests
- Kubernetes Secrets
- Git repositories

Granting application permissions through the EC2 worker-node IAM role would
also provide unnecessarily broad permissions to workloads running on those
nodes.

## Decision

The platform will use Amazon EKS Pod Identity for supported Kubernetes
workloads that require AWS permissions.

The platform will use dedicated IAM roles associated with Kubernetes service
accounts.

Initial consumers are expected to include:

- External Secrets Operator
- AWS Load Balancer Controller where applicable
- Platform or application workloads requiring AWS API access

## Identity Separation

EKS control plane:

EKS service
→ EKS cluster IAM role

Worker nodes:

EC2
→ EKS node IAM role

Kubernetes workloads:

Pod
→ Kubernetes ServiceAccount
→ EKS Pod Identity
→ Dedicated IAM role
→ Required AWS service

## Security Benefits

- No static AWS credentials
- Temporary AWS credentials
- Workload-level least privilege
- Separation from the worker-node IAM role
- Central IAM policy management
- Reduced credential-management overhead

## Trade-offs

- Requires the EKS Pod Identity Agent
- Applications must use supported AWS SDK credential-provider versions
- Pod Identity is specific to Amazon EKS

## Consequences

### Positive

- no long-lived AWS access keys are stored in Kubernetes
- permissions can be assigned per workload
- worker-node IAM permissions remain separate from application permissions
- AWS credentials are temporary and automatically rotated
- IAM policies remain centrally governed

### Negative

- the EKS Pod Identity Agent becomes a platform dependency
- workloads must use compatible AWS credential-provider libraries
- the implementation is specific to Amazon EKS

## Result

EKS Pod Identity provides the platform with workload-level AWS authorization while maintaining separation between Kubernetes workloads and EC2 worker-node credentials.
