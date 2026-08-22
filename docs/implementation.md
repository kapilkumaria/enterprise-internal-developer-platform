# Implementation Guide

## Project Scope

The Enterprise Internal Developer Platform will provide a standardized
developer experience for creating, deploying, securing, and operating
containerized microservices on AWS EKS.

The platform will expose self-service workflows through Backstage while
keeping infrastructure provisioning, security policy, deployment standards,
and platform governance under centralized platform-team control.

## In Scope

The project includes:

- AWS infrastructure provisioned through Terraform
- Amazon EKS
- Amazon ECR
- IAM and Kubernetes workload identity
- Backstage developer portal
- Backstage Software Catalog
- Backstage Software Templates
- GitHub integration
- GitHub Actions reusable CI
- Docker image build
- Trivy security scanning
- Helm application packaging
- GitOps-based deployment
- Argo CD
- External Secrets Operator
- AWS Secrets Manager
- Kyverno policy enforcement
- Prometheus metrics
- Grafana dashboards
- TechDocs
- Developer Golden Paths
- Platform documentation
- Failure testing and troubleshooting

## Initial Golden Path

The first Golden Path will provision a standardized containerized
microservice.

The developer will provide basic metadata such as:

- Service name
- Description
- Owner/team
- Runtime
- Environment

The platform will generate the standardized application structure and
delivery configuration.

## Out of Scope for Initial Release

The initial release will not attempt to implement:

- Multi-cloud deployment
- Production-grade organizational SSO
- Complex cost-management platform
- Full enterprise service mesh
- Multi-region disaster recovery
- Crossplane infrastructure provisioning
- Multiple programming-language Golden Paths
- Full production incident-management integration

These capabilities may be added later if they provide meaningful portfolio
value.

## Success Criteria

The platform will be considered successfully implemented when:

1. A developer can access the Backstage portal.

2. The developer can select a standardized microservice Golden Path.

3. The developer can provide service metadata through a self-service form.

4. Backstage automatically creates a GitHub repository.

5. The generated repository contains standardized:
   - Application structure
   - Dockerfile
   - CI workflow
   - Helm configuration
   - Catalog metadata
   - Documentation structure

6. GitHub Actions automatically:
   - Tests the application
   - Performs security scanning
   - Builds the container image
   - Pushes the image to Amazon ECR

7. Application desired state is managed through Git.

8. Argo CD deploys the application to Amazon EKS.

9. Kubernetes security policies are enforced using Kyverno.

10. Application secrets are retrieved securely from AWS Secrets Manager.

11. Application metrics are available through Prometheus.

12. Operational visibility is available through Grafana.

13. The service is registered and visible in the Backstage Software Catalog.

14. Service documentation is available through TechDocs.

15. GitOps drift can be detected and reconciled automatically.

16. Failure scenarios and troubleshooting procedures are documented.

17. The entire platform infrastructure can be recreated using Infrastructure
    as Code.
