# Troubleshooting and Engineering Lessons

## Purpose

This document records significant engineering problems encountered while implementing the Internal Developer Platform.

Each incident is documented using:

```text
Problem
Symptoms
Investigation
Root Cause
Resolution
Validation
Engineering Lesson
```
---

# Issue 1 — EKS Worker Nodes Failed to Become Ready

## Problem

EKS worker nodes were provisioned but Kubernetes reported them as NotReady.

## Symptoms

Observed symptoms included unhealthy networking components and workloads unable to schedule normally.

## Investigation

The investigation focused on:

- EKS node-group health
- VPC CNI
- `aws-node`
- IAM permissions
- EKS addon compatibility
- Kubernetes events

## Root Cause

The EKS infrastructure itself was provisioned successfully, but the Kubernetes networking layer was not healthy.

The managed worker nodes appeared in the EKS node group but remained `NotReady`. Investigation showed the `aws-node` containers from the Amazon VPC CNI repeatedly restarting, while CoreDNS remained Pending because healthy Kubernetes networking was not yet available.

The investigation also exposed two implementation requirements: EKS managed-addon versions needed to be resolved using supported AWS addon-version discovery, and AWS-integrated workloads required an explicit identity model rather than relying on broad worker-node permissions.

## Resolution

The EKS addon implementation was corrected to resolve supported addon versions through AWS EKS addon-version data sources.

The VPC CNI was deployed as an EKS managed addon with the required AWS IAM configuration, and the EKS Pod Identity Agent was enabled for AWS-integrated Kubernetes workloads.

The cluster was then validated at both infrastructure and Kubernetes layers using EKS status, node readiness, addon health, `aws-node`, CoreDNS and Kubernetes events.

## Validation

Validation included:
```text
kubectl get nodes
kubectl get pods -n kube-system
kubectl get events -A
```
## Engineering Lesson

Node-group state alone does not prove Kubernetes runtime health. Infrastructure-level validation must be combined with Kubernetes-level readiness checks.

---

# Issue 2 — EKS Addon Version Configuration

## Problem

Terraform rejected unsupported addon configuration during the initial EKS implementation.

## Root Cause

Addon version discovery and resource configuration were implemented incorrectly for the AWS provider/API behavior being used.

## Resolution

Addon versions were resolved using supported EKS addon version data sources and subsequently supplied to the addon resources.

## Engineering Lesson

Cloud-managed addons should not assume that Kubernetes version compatibility automatically means the newest arbitrary addon release is safe or supported. Version discovery should be explicit.

---

# Issue 3 — Workload Identity / AWS Permissions

## Problem

Platform workloads required AWS API access without embedding long-lived credentials.

## Resolution

Dedicated IAM roles and EKS Pod Identity associations were implemented.

## Engineering Lesson

Kubernetes service identity and AWS authorization should be explicitly mapped rather than relying on node-level IAM permissions.

---

# Issue 4 — RDS Credential Lifecycle

## Problem

Recreating RDS changes the AWS-managed database secret identity.

## Risk

A Kubernetes configuration referencing the previous secret could become stale after infrastructure reconstruction.

## Resolution

The current Terraform/RDS secret output is used during platform bootstrap rather than relying on an obsolete static ARN.

## Engineering Lesson

Dynamic infrastructure identifiers should be propagated through automation rather than copied permanently into downstream configuration.

---

# Issue 5 — Infrastructure Teardown Dependencies

## Problem

AWS networking cannot be removed while EKS-created resources continue to reference VPC resources.

## Resolution

Infrastructure was destroyed in dependency order:

```text
Applications
   ↓
Platform controllers
   ↓
EKS
   ↓
RDS
   ↓
Networking
```
## Engineering Lesson

Terraform dependency graphs handle managed resources, but externally created cloud resources can introduce lifecycle dependencies that must be explicitly audited before teardown.

---

# Operational Lessons

The project reinforced that successful cloud-resource provisioning is only the first validation layer.

A production-style platform should validate the complete dependency chain from infrastructure through application runtime:

- Terraform configuration and drift
- AWS infrastructure health
- EKS control-plane state
- worker-node readiness
- Kubernetes networking
- managed addons
- workload identity
- platform controllers
- GitOps reconciliation
- application health

A healthy AWS resource does not automatically prove that the Kubernetes platform or application layer is healthy.
