# ADR-0003: Use Amazon EKS as the Kubernetes Runtime

## Status

Accepted

## Context

The Enterprise Internal Developer Platform requires a runtime capable of
hosting both platform services and developer-generated workloads.

The runtime must support components including:

- Backstage
- Argo CD
- External Secrets Operator
- AWS Load Balancer Controller
- Golden Path application workloads
- Kubernetes-native configuration and security controls

The runtime must also integrate with:

- AWS IAM
- Amazon VPC
- Amazon ECR
- AWS Secrets Manager
- Elastic Load Balancing
- Terraform
- GitOps tooling

The project is intended to demonstrate platform engineering and Internal
Developer Platform capabilities rather than the operational mechanics of
building a Kubernetes control plane from scratch.

## Considered Options

Three primary runtime approaches were considered:

1. self-managed Kubernetes on Amazon EC2
2. Amazon ECS
3. Amazon EKS

---

## Option 1 — Self-Managed Kubernetes on EC2

Running Kubernetes directly on EC2 would provide maximum control over the
cluster.

However, the platform team would also become responsible for operating the
Kubernetes control plane.

That would introduce responsibilities such as:

- API server management
- etcd management
- control-plane availability
- control-plane patching
- Kubernetes version upgrades
- certificate management
- control-plane recovery
- additional high-availability design

Those responsibilities are valuable in some environments but are not the
primary objective of this project.

The project is focused on the developer platform layer rather than
self-managed Kubernetes control-plane engineering.

Therefore this option was rejected.

---

## Option 2 — Amazon ECS

Amazon ECS would provide a simpler AWS-native container runtime and reduce
some Kubernetes operational complexity.

However, several major platform components selected for this architecture are
Kubernetes-native.

Examples include:

- Argo CD
- External Secrets Operator
- Kubernetes RBAC
- Kubernetes ServiceAccounts
- Kubernetes Ingress
- Helm-based platform components
- Kubernetes-native Backstage workload integration

Using ECS would substantially change the architecture and reduce the ability
to demonstrate the Kubernetes-based platform engineering patterns targeted by
the project.

Therefore this option was rejected.

---

## Option 3 — Amazon EKS

Amazon EKS provides a managed Kubernetes control plane while retaining the
standard Kubernetes API and ecosystem.

It allows AWS to manage the Kubernetes control-plane infrastructure while the
platform team remains responsible for the platform layer above it.

This aligns directly with the project's objectives.

## Decision

The platform will use **Amazon EKS** as its Kubernetes runtime.

The implementation uses:

- Amazon EKS managed control plane
- EKS managed node group
- Amazon VPC CNI
- CoreDNS
- kube-proxy
- EKS Pod Identity Agent
- private worker-node networking
- AWS IAM integration
- Amazon ECR integration
- Kubernetes ServiceAccounts and RBAC
- AWS Load Balancer Controller
- External Secrets Operator
- Argo CD

## Managed Control Plane

Amazon EKS moves responsibility for operating the Kubernetes control-plane
infrastructure to AWS.

This reduces the need for the platform team to directly operate:

- etcd
- Kubernetes API server infrastructure
- control-plane nodes
- control-plane high availability

The platform team can therefore focus on higher-level concerns such as:

- developer self-service
- Golden Paths
- workload identity
- GitOps
- secrets management
- application delivery
- Kubernetes authorization
- platform integrations

## Managed Worker Capacity

The implementation uses an EKS managed node group.

AWS manages portions of the EC2 node-group lifecycle while the platform team
continues to control:

- instance configuration
- scaling parameters
- IAM role
- subnet placement
- Kubernetes workload scheduling
- node lifecycle configuration

This provides a useful balance between managed infrastructure and
platform-team control.

## Kubernetes Ecosystem Compatibility

Using EKS preserves compatibility with standard Kubernetes tooling.

The project uses Kubernetes-native technologies including:

- Argo CD
- Helm
- External Secrets Operator
- AWS Load Balancer Controller
- Kubernetes RBAC
- Kubernetes ServiceAccounts
- Kubernetes Ingress

This allows the platform to use established cloud-native patterns rather than
creating AWS-specific replacements for each capability.

## Backstage Runtime

Backstage runs as a Kubernetes workload inside EKS.

This allows the developer portal itself to be managed using the same runtime
patterns provided to application workloads.

The Backstage deployment uses Kubernetes resources for:

- Deployment
- Service
- ServiceAccount
- RBAC
- Ingress
- runtime secrets

This also allows Backstage to integrate with the Kubernetes API using
controlled service-account permissions.

## GitOps Integration

Amazon EKS provides the runtime reconciled by Argo CD.

The deployment model is:

```text
Git Desired State
       |
       v
Argo CD
       |
       v
Kubernetes API
       |
       v
Amazon EKS
       |
       v
Application Workloads
```
This provides a clean separation between CI artifact creation and Kubernetes
continuous delivery.

## AWS Identity Integration

EKS integrates with AWS IAM and EKS Pod Identity.

This allows AWS-aware Kubernetes workloads to receive dedicated AWS
identities without depending on static credentials.

The resulting model is:

```text
Kubernetes ServiceAccount
          |
          v
EKS Pod Identity
          |
          v
AWS IAM Role
          |
          v
Authorized AWS API
```
This is used by platform components including External Secrets Operator and
AWS Load Balancer Controller.

## AWS Networking Integration

Amazon EKS integrates with the Amazon VPC networking model.

The implementation uses:

- dedicated VPC
- public subnets
- private subnets
- private worker nodes
- Amazon VPC CNI
- NAT-based outbound connectivity
- Application Load Balancer ingress

The Kubernetes worker layer therefore remains private while controlled
internet-facing access is provided through the load-balancing layer.

## Container Registry Integration

Amazon ECR is used as the container registry.

GitHub Actions publishes container images to ECR after authenticating to AWS
through OIDC.

EKS workloads can then consume the corresponding application images from the
AWS container registry.

This provides an integrated artifact path:
```text
GitHub
   |
   v
GitHub Actions
   |
   v
Amazon ECR
   |
   v
Amazon EKS
```

## Secrets Integration

AWS Secrets Manager provides external secret storage.

External Secrets Operator runs inside EKS and synchronizes authorized values
into Kubernetes.

This allows the Kubernetes platform to consume externally managed secrets
without committing sensitive values to Git.

## Separation of Responsibilities

Using EKS establishes a clear responsibility boundary.

### AWS Responsibility

AWS manages the underlying EKS control-plane infrastructure.

### Platform Team Responsibility

The platform team remains responsible for:

- Terraform infrastructure
- worker capacity
- cluster addons
- Kubernetes configuration
- IAM integration
- EKS Pod Identity
- secrets integration
- ingress
- Argo CD
- Backstage
- Golden Path templates
- workload standards
- platform security

### Application Developer Responsibility

Developers consume the standardized platform capabilities for:

- service creation
- application source
- application tests
- service-specific business logic
- service metadata
- application-level configuration

This division supports the Internal Developer Platform operating model.

## Operational Trade-offs

Amazon EKS removes control-plane infrastructure management but does not
eliminate Kubernetes operations.

The platform team must still understand and operate:

- Kubernetes scheduling
- node health
- VPC CNI
- CoreDNS
- kube-proxy
- cluster addons
- IAM integration
- workload identity
- RBAC
- ingress
- GitOps
- application health

This was demonstrated during implementation when node readiness depended on
correct VPC CNI identity and addon configuration.

Managed Kubernetes therefore reduces one category of operational burden
without eliminating platform engineering responsibility.

## Cost Trade-offs

Amazon EKS introduces costs that would not exist in the same form for every
alternative.

The running environment can incur costs from resources including:

- EKS control plane
- EC2 worker nodes
- NAT Gateway
- Application Load Balancer
- Amazon RDS

For a portfolio environment, these resources do not need to remain online
permanently.

The project therefore validates infrastructure reproducibility and controlled
teardown so the runtime environment can be removed after evidence capture.

## Consequences

### Positive
- managed Kubernetes control plane
- standard Kubernetes APIs
- compatibility with cloud-native platform tooling
- strong AWS IAM integration
- EKS Pod Identity support
- native Amazon VPC integration
- straightforward Amazon ECR consumption
- strong foundation for Argo CD GitOps
- suitable runtime for Backstage
- reduced control-plane operational burden
- reusable Kubernetes operational knowledge

### Negative
- EKS control-plane cost
- Kubernetes operational complexity remains
- worker-node lifecycle remains a platform concern
- addon lifecycle remains a platform concern
- AWS-specific networking and identity integration
- NAT, load-balancing, and database resources can increase environment cost
- requires Kubernetes expertise from the platform team

## Validation

The final implementation validated the EKS architecture through a live
environment.

Validation included:

- managed EKS cluster provisioning
- two healthy worker nodes
- required EKS addons active
- EKS Pod Identity Agent active
- Backstage running on EKS
- External Secrets synchronization
- AWS Load Balancer Controller operation
- HTTPS ingress
- Argo CD applications synchronized and healthy
- Golden Path application deployment
- Kubernetes integration with Backstage

The runtime was also successfully destroyed after evidence capture while the
Terraform bootstrap/state foundation was intentionally retained.

## Result

Amazon EKS provides the appropriate runtime for the Enterprise Internal
Developer Platform because it combines a managed Kubernetes control plane
with the Kubernetes APIs and ecosystem required by the platform.

The decision allows the project to concentrate on the higher-value platform
engineering concerns:

```text
Developer Experience
        +
Golden Paths
        +
Identity
        +
Security
        +
GitOps
        +
Application Delivery
        +
Operational Ownership
```
rather than spending the project primarily on self-managed Kubernetes
control-plane operations.