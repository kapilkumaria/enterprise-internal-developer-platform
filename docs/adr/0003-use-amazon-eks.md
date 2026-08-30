# ADR-0003: Use Amazon EKS as the Kubernetes Runtime

## Status

Accepted

## Context

The Internal Developer Platform requires a Kubernetes runtime for hosting:

- Backstage
- Argo CD
- External Secrets Operator
- AWS Load Balancer Controller
- application workloads generated through the Golden Path
- supporting platform services

The Kubernetes platform must integrate closely with AWS networking, IAM, container registries and managed infrastructure services.

Possible approaches included:

1. self-managed Kubernetes on EC2
2. Amazon ECS
3. Amazon EKS

## Decision

Amazon EKS will be used as the Kubernetes runtime for the Enterprise Internal Developer Platform.

EKS provides an AWS-managed Kubernetes control plane while allowing the platform to retain standard Kubernetes APIs and ecosystem tooling.

The implementation uses:

- Amazon EKS managed control plane
- EKS managed node groups
- Amazon VPC CNI
- CoreDNS
- kube-proxy
- EKS Pod Identity Agent
- private worker-node networking
- IAM integration
- Amazon ECR integration

## Reasons

### Managed Control Plane

AWS manages Kubernetes control-plane availability, upgrades and underlying control-plane infrastructure.

This reduces the operational burden compared with maintaining Kubernetes control-plane nodes directly.

### Kubernetes Ecosystem Compatibility

Using Kubernetes allows the platform to integrate with:

- Argo CD
- Helm
- External Secrets Operator
- AWS Load Balancer Controller
- Backstage
- Kubernetes-native security controls

### AWS Integration

EKS provides native integration with:

- IAM
- EKS Pod Identity
- Amazon VPC
- Amazon ECR
- Elastic Load Balancing
- CloudWatch
- AWS Secrets Manager

### Separation of Responsibilities

AWS manages the Kubernetes control plane while the platform team retains responsibility for:

- worker capacity
- workload configuration
- cluster addons
- GitOps
- security controls
- application lifecycle

## Consequences

### Positive

- reduced Kubernetes control-plane operational overhead
- standard Kubernetes APIs
- compatibility with cloud-native tooling
- strong AWS IAM integration
- managed cluster lifecycle
- suitable foundation for GitOps and platform engineering

### Negative

- EKS control-plane cost
- AWS-specific infrastructure dependencies
- worker-node and addon lifecycle still require platform ownership
- networking and IAM configuration remain operationally significant

## Result

Amazon EKS provides the Kubernetes abstraction required by the Internal Developer Platform while allowing the project to focus on platform engineering capabilities rather than self-managing Kubernetes control-plane infrastructure.
