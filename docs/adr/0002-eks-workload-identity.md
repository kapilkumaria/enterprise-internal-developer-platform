# ADR-0002: Use EKS Pod Identity for AWS Workload Authentication

## Status

Accepted

## Context

Kubernetes workloads running on Amazon EKS require access to selected AWS
services.

Examples in this platform include:

- External Secrets Operator accessing AWS Secrets Manager
- AWS Load Balancer Controller interacting with AWS load-balancing APIs
- platform workloads that may require controlled AWS API access

The platform requires a workload authentication mechanism that does not
depend on:

- static AWS access keys
- credentials embedded in application source
- credentials stored in container images
- credentials committed to Kubernetes manifests
- broad AWS permissions inherited from the EC2 worker-node IAM role

Using the worker-node role for workload permissions would make the node an
authorization boundary for multiple unrelated workloads.

That would increase the blast radius of the node IAM role and make
least-privilege authorization more difficult to enforce.

## Decision

The platform will use **Amazon EKS Pod Identity** for supported Kubernetes
workloads that require access to AWS services.

Each AWS-integrated workload will use:

1. a Kubernetes ServiceAccount
2. an EKS Pod Identity association
3. a dedicated AWS IAM role
4. an IAM policy containing the permissions required by that workload

The resulting identity path is:

```text
Kubernetes Pod
      |
      v
Kubernetes ServiceAccount
      |
      v
EKS Pod Identity Agent
      |
      v
EKS Pod Identity Association
      |
      v
Dedicated IAM Role
      |
      v
Authorized AWS Service
```

## Identity Separation

The platform maintains separate AWS identities for the major execution
boundaries.

## EKS Control Plane

```text
Amazon EKS
    |
    v
EKS Cluster IAM Role
```
## Worker Nodes

```text
EC2 Worker Node
      |
      v
EKS Node IAM Role
```
## Kubernetes Workloads

```text
Application / Platform Pod
          |
          v
Kubernetes ServiceAccount
          |
          v
EKS Pod Identity
          |
          v
Workload-Specific IAM Role
```
The worker-node role therefore does not become the default identity for
AWS-integrated Kubernetes workloads.

## Initial Platform Consumers

The implemented platform uses workload-level AWS identity for components
including:

- External Secrets Operator
- AWS Load Balancer Controller

These components require different AWS capabilities and therefore should not
share one broad AWS permission model.

## External Secrets Operator

External Secrets Operator requires controlled access to AWS Secrets Manager.

The identity path is:
```text
External Secrets Operator
          |
          v
Kubernetes ServiceAccount
          |
          v
EKS Pod Identity
          |
          v
Dedicated IAM Role
          |
          v
AWS Secrets Manager
```
The IAM policy grants the Secrets Manager operations required by the
implemented secret discovery and retrieval workflow.

This allows Kubernetes workloads to consume externally managed secrets
without storing long-lived AWS credentials inside the cluster.

## AWS Load Balancer Controller

AWS Load Balancer Controller requires access to AWS APIs for managing
load-balancing infrastructure associated with Kubernetes ingress resources.

The controller uses its own Kubernetes service account and AWS workload
identity rather than depending on the EC2 node role for those permissions.

This keeps infrastructure-controller permissions separate from worker-node
permissions.

## Why Not Static AWS Credentials?

Static access keys would introduce:

- long-lived credentials
- manual rotation requirements
- secret-distribution requirements
- increased risk of credential leakage
- potential credentials in CI/CD or Kubernetes secret stores
- larger operational burden

EKS Pod Identity instead provides temporary AWS credentials through the AWS
identity system.

## Why Not Use the Worker-Node IAM Role?

Attaching all required AWS permissions to the worker-node role would be
simpler initially, but it would weaken workload isolation.

Multiple pods can execute on the same node.

If AWS authorization is concentrated on the node role, workloads may gain
access to AWS capabilities unrelated to their own responsibility.

Workload-specific IAM roles provide a clearer security boundary.

## Why EKS Pod Identity?

EKS Pod Identity was selected because the platform is already based on
Amazon EKS and the mechanism provides AWS-native workload identity without
requiring applications to manage AWS credentials directly.

The model supports:

- temporary credentials
- IAM-based authorization
- service-account-level identity association
- separation from EC2 worker credentials
- centralized IAM policy management
- reduced secret-management overhead

## Security Benefits

The decision provides:

- no long-lived AWS access keys for supported Kubernetes workloads
- temporary AWS credentials
- workload-level authorization
- separation from worker-node IAM permissions
- independent IAM policies for platform components
- reduced credential exposure
- centralized AWS IAM governance
- improved least-privilege design

## Operational Benefits

Workload identity also improves operations.

IAM policy changes can be managed independently from:

- application container images
- EC2 worker-node credentials
- manually distributed AWS access keys

This makes authorization changes easier to review and audit.

## Platform Dependency

EKS Pod Identity requires the EKS Pod Identity Agent to be available in the
cluster.

The agent therefore becomes part of the platform's required EKS addon set.

The addon was included and validated as part of the final EKS environment.

## Trade-offs

### Positive
- temporary AWS credentials
- workload-specific IAM roles
- separation between pod and node permissions
- no application-managed AWS access keys
- centralized IAM authorization
- reduced credential-rotation burden
- native integration with Amazon EKS

### Negative
- introduces dependency on the EKS Pod Identity Agent
- specific to Amazon EKS
- requires service-account and IAM association management
- applications and controllers must use compatible AWS credential-provider
behavior
- IAM policy design remains a platform-team responsibility

## Consequences

Platform engineers must explicitly define which Kubernetes workloads require
AWS access.

For each workload, the platform should determine:

```text
What AWS service is required?
          |
          v
Which AWS API operations are required?
          |
          v
Which Kubernetes ServiceAccount owns the identity?
          |
          v
Which IAM role should represent that workload?
          |
          v
What is the minimum IAM policy required?
```
This creates additional configuration compared with placing all permissions
on the worker-node role, but produces a substantially clearer security model.

## Validation

The final platform validated EKS Pod Identity as part of the working runtime.

External Secrets Operator successfully accessed AWS Secrets Manager using
workload identity and synchronized the required Kubernetes secrets.

AWS Load Balancer Controller also operated using its dedicated AWS workload
identity as part of the Backstage ingress implementation.

The final EKS addon set included the EKS Pod Identity Agent.

## Result

Amazon EKS Pod Identity provides the platform with workload-level AWS
authentication while maintaining separation between:

- Kubernetes workloads
- EC2 worker nodes
- the EKS control plane
- CI/CD workloads

The decision supports the platform's broader security principle of assigning
AWS permissions to the smallest practical execution identity rather than
sharing broad credentials across the environment.