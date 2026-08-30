# Developer Workflow

## Objective

The Internal Developer Platform provides developers with a standardized Golden Path for creating and deploying services without requiring them to manually assemble infrastructure and delivery tooling.

---

## Traditional Workflow

Without an IDP, a developer may need to understand:

```text
Docker
Kubernetes
Helm
Terraform
IAM
ECR
GitHub Actions
Argo CD
Secrets
Ingress
AWS networking
```
---

# Golden Path

## Step 1 — Open Backstage

The developer begins in the Backstage portal.

---

## Step 2 — Discover Existing Services

The software catalog provides visibility into registered services and ownership.

---

## Step 3 — Select Software Template

The developer selects the standardized microservice template.

---

## Step 4 — Supply Service Metadata

The developer provides the required service metadata rather than manually creating platform configuration.

---

## Step 5 — Generate Repository

Backstage scaffolds the standardized service repository.

---

## Step 6 — Continuous Integration

GitHub Actions validates the generated service.

The CI workflow can perform:

- dependency installation
- tests
- container build
- security scanning
- ECR authentication
- image publication

---

## Step 7 — Artifact Publication

The resulting image is stored in Amazon ECR.

---

## Step 8 — GitOps Deployment

Argo CD reconciles the desired Kubernetes state.

---

## Step 9 — Application Runtime

The generated service runs on Amazon EKS.

Developer Experience Result

The developer workflow becomes:

```text
Choose template
      ↓
Provide metadata
      ↓
Generate service
      ↓
Commit / Push
      ↓
CI
      ↓
Container artifact
      ↓
GitOps
      ↓
Kubernetes
```
The platform team owns the underlying complexity while application teams consume standardized platform capabilities.
