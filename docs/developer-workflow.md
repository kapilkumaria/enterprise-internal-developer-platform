# Developer Workflow

## Developer Experience Goal

Application developers should not need to understand the implementation
details of Terraform, EKS, Argo CD, IAM, External Secrets, or Kubernetes
platform services to onboard a standard application.

The Internal Developer Platform provides an opinionated Golden Path.

## Standard Developer Workflow

### Step 1 — Access Backstage

The developer opens the internal developer portal.

### Step 2 — Select Create

The developer selects the approved microservice Golden Path.

### Step 3 — Supply Service Metadata

Example:

Service Name: payment-api
Owner: payments-team
Runtime: Python
Environment: dev

### Step 4 — Backstage Scaffolds the Service

Backstage generates the standardized repository structure and registers the
new component in the Software Catalog.

### Step 5 — Continuous Integration

GitHub Actions validates, tests, scans, and builds the application.

### Step 6 — Container Publishing

The validated container image is published to Amazon ECR.

### Step 7 — GitOps Deployment

Application desired-state configuration is stored in Git.

Argo CD detects the desired-state change and reconciles the Kubernetes
cluster.

### Step 8 — Platform Guardrails

Kyverno validates Kubernetes security requirements.

External Secrets securely provides application secrets.

### Step 9 — Runtime

The application runs on Amazon EKS.

### Step 10 — Observability

Prometheus collects application/platform metrics.

Grafana provides dashboards.

### Step 11 — Developer Visibility

Backstage provides a centralized view of:

- Service metadata
- Ownership
- Documentation
- Repository
- Kubernetes resources
- Deployment information
- Relevant operational links
