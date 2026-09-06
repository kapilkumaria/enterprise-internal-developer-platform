# Developer Workflow

## Objective

The Enterprise Internal Developer Platform provides developers with a
standardized **Golden Path** for creating and delivering services.

The purpose of the workflow is to reduce developer cognitive load.

Instead of requiring every developer to understand and manually configure:

- repository structure
- Docker build conventions
- CI pipelines
- AWS authentication
- Amazon ECR publishing
- Kubernetes manifests
- Helm packaging
- GitOps deployment
- secrets integration
- platform metadata
- Backstage catalog registration

the platform exposes a repeatable self-service workflow through Backstage.

---

## Traditional Developer Workflow

Without an Internal Developer Platform, a developer may need to perform many
platform tasks manually before an application can run:

```text
Create repository
      |
      v
Choose project structure
      |
      v
Create Dockerfile
      |
      v
Create CI pipeline
      |
      v
Configure AWS credentials
      |
      v
Create container registry
      |
      v
Create Kubernetes manifests
      |
      v
Configure deployment process
      |
      v
Configure secrets
      |
      v
Register service documentation
      |
      v
Deploy application
```
This creates several operational problems:

- inconsistent repository structures
- duplicated CI/CD logic
- inconsistent security controls
- long onboarding times
- dependency on platform specialists
- configuration drift
- difficulty enforcing organizational standards
- increased risk from manually managed cloud credentials

The Golden Path implemented in this project standardizes these concerns.

---

# Golden Path

The Golden Path is an opinionated, reusable service-creation workflow exposed
through the Backstage Developer Portal.

The complete developer experience is:

```text
Developer
    |
    v
Backstage
    |
    v
Software Template
    |
    v
Generated GitHub Repository
    |
    v
GitHub Actions
    |
    v
Amazon ECR
    |
    v
GitOps Desired State
    |
    v
Argo CD
    |
    v
Amazon EKS
    |
    v
Running Service
```
The platform engineering team owns the implementation of the path.

The application developer consumes the path.

---

## Step 1 — Open Backstage

The developer begins in the Backstage Developer Portal.

Backstage acts as the entry point into the platform and exposes:

- the Software Catalog
- Software Templates
- TechDocs
- registered services
- Kubernetes workload information
- standardized developer workflows

The developer does not need direct knowledge of the underlying Terraform,
IAM, EKS, Argo CD, or AWS Secrets Manager configuration to create a service.

---

## Step 2 — Discover Existing Services

The Backstage Software Catalog provides a centralized inventory of registered
software components.

Developers can use the catalog to identify:

- services
- owners
- systems
- metadata
- documentation
- Kubernetes workloads

The project validated that generated Golden Path services were successfully
registered in the Software Catalog.

The catalog allows the platform to move from infrastructure-centric
operations toward a service-oriented developer experience.

---

## Step 3 — Select the Software Template

The developer selects the approved Golden Path Software Template.

The template represents the platform team's recommended service pattern.

Rather than providing a completely unrestricted service generator, the
template provides an opinionated baseline that encodes platform standards.

The template can standardize:

- service naming
- ownership metadata
- repository structure
- containerization
- CI workflow
- deployment configuration
- Backstage catalog metadata
- developer documentation

This is one of the primary mechanisms through which the platform engineering
team turns organizational standards into reusable developer capabilities.

---

## Step 4 — Supply Service Metadata

The developer provides the required service information through the
Backstage Scaffolder interface.

Typical metadata includes:

- service name
- service description
- owner
- target repository
- component metadata

The platform uses this information to generate a standardized service rather
than requiring developers to manually reproduce boilerplate configuration.

---

## Step 5 — Backstage Scaffolder Executes

Backstage processes the Software Template and creates the required service
assets.

The successful scaffolding workflow was validated during the project.

The scaffolder transforms developer input into a standardized,
source-controlled service repository.

This converts platform engineering knowledge into an automated developer
workflow.

---

## Step 6 — Generate the GitHub Repository

The Golden Path publishes the generated service to GitHub.

The generated repository includes a standardized implementation baseline such
as:

- application source code
- package metadata
- automated tests
- Dockerfile
- GitHub Actions workflow
- Backstage catalog metadata
- documentation
- deployment-related configuration

The developer therefore starts from a working platform-approved foundation
rather than an empty repository.

---

## Step 7 — Continuous Integration Starts Automatically

A commit to the generated repository triggers GitHub Actions.

The CI workflow performs the build and validation lifecycle.

```text
Git Commit
    |
    v
GitHub Actions
    |
    +--> Install Dependencies
    |
    +--> Run Tests
    |
    +--> Security Validation
    |
    +--> Build Container Image
    |
    +--> Authenticate to AWS
    |
    +--> Push Image to Amazon ECR
```
The final workflow was validated using a clean successful CI run.

---

## Step 8 — Authenticate to AWS Without Static Credentials

GitHub Actions authenticates to AWS through OpenID Connect federation.

The workflow does not require permanent AWS access keys stored in GitHub.

The authentication flow is:

```text
GitHub Actions
      |
      v
GitHub OIDC Token
      |
      v
AWS IAM Trust Policy
      |
      v
Temporary AWS Credentials
```
During implementation, the GitHub account used customized OIDC subject
claims.

The IAM trust policy was corrected to match the actual token subject format,
after which CI authentication succeeded.

This failure and remediation were intentionally retained as engineering
evidence.

---

## Step 9 — Build and Publish the Container Artifact

After successful validation, GitHub Actions builds the application container
image.

The image is published to Amazon ECR.

The platform uses a commit-derived immutable image tag rather than relying
only on a mutable tag such as latest.

Conceptually:

```text
Source Commit
      |
      v
Container Build
      |
      v
Immutable SHA-Based Tag
      |
      v
Amazon ECR
```
This provides traceability between source code and the resulting artifact.

---

## Step 10 — Separate Continuous Integration from Deployment

The platform intentionally separates CI from CD.

GitHub Actions is responsible for:

```text
Build
Test
Scan
Publish
```
Argo CD is responsible for:

Observe
Compare
Reconcile
Deploy

This is an important architectural decision.

GitHub Actions does not require broad imperative Kubernetes deployment access
for normal application delivery.

Instead, deployment state is represented declaratively and reconciled by
Argo CD.

---

## Step 11 — GitOps Deployment Through Argo CD

Argo CD observes the GitOps configuration and reconciles the desired
application state into Amazon EKS.

```text
Git Desired State
       |
       v
Argo CD
       |
       v
Compare Desired vs Actual
       |
       v
Synchronize
       |
       v
Amazon EKS
```
The generated Golden Path application was validated as:

```text
Synced
Healthy
```
Argo CD also provides operational visibility into managed applications.

---

## Step 12 — Application Runs on Amazon EKS

The generated application runs as a Kubernetes workload on Amazon EKS.

The runtime platform provides:

- managed Kubernetes control plane
- managed worker nodes
- private worker networking
- Kubernetes service discovery
- namespace isolation
- workload identity
- secrets integration
- GitOps reconciliation

The developer does not need to manually create or maintain the cluster.

Platform infrastructure remains a responsibility of the platform engineering
layer.

---

## Step 13 — Runtime Secrets Are Delivered Securely

Sensitive runtime configuration is stored in AWS Secrets Manager.

External Secrets Operator synchronizes authorized secrets into Kubernetes.

```text
AWS Secrets Manager
       |
       v
External Secrets Operator
       |
       v
Kubernetes Secret
       |
       v
Application Workload
```
External Secrets authenticates through Amazon EKS Pod Identity rather than
using static AWS credentials.

The design keeps secret values out of source-controlled Kubernetes manifests.

---

## Step 14 — Platform Services Use Workload Identity

Platform workloads requiring access to AWS services use dedicated IAM
identities.

Examples include:

- External Secrets Operator
- AWS Load Balancer Controller

The platform uses Amazon EKS Pod Identity so application permissions are not
implicitly inherited from the worker-node role.

This creates a clearer security boundary:

```text
Kubernetes Workload
       |
       v
EKS Pod Identity
       |
       v
Dedicated IAM Role
       |
       v
Authorized AWS API
```
---

## Step 15 — Developer Uses the Service Through the Platform

Once the service is running, the developer continues to interact with the
platform through familiar developer-facing interfaces:

- GitHub for source changes
- GitHub Actions for CI status
- Backstage for service discovery and documentation
- Argo CD for GitOps deployment visibility
- Kubernetes information exposed through Backstage

The developer does not need to manually operate Terraform or administer EKS
for normal application development.

---

## End-to-End Developer Experience

The final implemented workflow is:

```text
1. Developer opens Backstage
                |
                v
2. Selects approved Software Template
                |
                v
3. Supplies service metadata
                |
                v
4. Backstage scaffolds application
                |
                v
5. GitHub repository is created
                |
                v
6. Developer commits code
                |
                v
7. GitHub Actions runs tests and validation
                |
                v
8. GitHub OIDC obtains temporary AWS credentials
                |
                v
9. Container image is built
                |
                v
10. Immutable image is pushed to Amazon ECR
                |
                v
11. GitOps desired state is reconciled
                |
                v
12. Argo CD deploys to Amazon EKS
                |
                v
13. Application runs on Kubernetes
                |
                v
14. Backstage catalog provides ongoing visibility
```
---

## Platform Team vs Application Team Responsibilities

A key goal of an Internal Developer Platform is to establish a useful
separation of responsibilities.

| Platform Engineering Team         | Application Developer             |
| --------------------------------- | --------------------------------- |
| Maintains Backstage               | Selects approved template         |
| Maintains Golden Path templates   | Supplies application metadata     |
| Maintains Terraform modules       | Develops application code         |
| Operates EKS platform             | Commits source changes            |
| Defines CI standards              | Reviews CI results                |
| Maintains GitHub OIDC integration | Does not manage AWS static keys   |
| Operates Argo CD                  | Uses GitOps delivery workflow     |
| Maintains workload identity       | Does not manage worker-node IAM   |
| Maintains secrets integration     | Consumes approved runtime secrets |
| Maintains networking and ingress  | Focuses on application behavior   |


The objective is not to hide infrastructure completely.

The objective is to provide sensible abstractions so developers interact
with infrastructure through standardized platform capabilities rather than
reimplementing those capabilities themselves.

---

## Developer Experience Validation

The platform validated the complete Golden Path lifecycle:

- Backstage Developer Portal was reachable over HTTPS
- Software Template was available
- service creation workflow executed successfully
- Backstage Scaffolder completed successfully
- GitHub repository was generated
- generated service appeared in the Backstage catalog
- GitHub Actions executed automatically
- GitHub OIDC authentication to AWS succeeded
- immutable application image was published to Amazon ECR
- Argo CD reconciled the generated service
- application became Synced and Healthy
- Kubernetes workloads were operational

Representative final platform evidence:

---

## Engineering Outcome

The Golden Path demonstrates the central value of platform engineering:

> standardize the difficult and repetitive infrastructure concerns once,
> then expose them as reusable self-service capabilities to application teams.

The resulting workflow allows developers to move from service creation to a
production-style Kubernetes deployment while the platform enforces consistent
delivery, identity, security, and deployment patterns behind the scenes.