# Project Evidence Screenshot Index

This directory contains visual implementation and validation evidence for the
**Enterprise Internal Developer Platform**.

The canonical portfolio screenshots are stored under:

```text
docs/images/screenshots/
```
The evidence demonstrates infrastructure provisioning, Kubernetes runtime
health, Backstage developer self-service, Golden Path service generation,
CI/CD, GitOps, workload identity, secrets integration, troubleshooting, and
final end-to-end platform validation.

---

## Infrastructure

| Screenshot                                 | Evidence                                                             |
| ------------------------------------------ | -------------------------------------------------------------------- |
| `screenshots/terraform-apply-complete.png` | Successful Terraform provisioning of the AWS platform infrastructure |
| `screenshots/eks-nodes-ready.png`          | Amazon EKS managed worker nodes in Ready state                       |
| `screenshots/eks-addons-active.png`        | Required Amazon EKS managed addons active                            |
| `screenshots/rds-postgresql-private.png`   | Private Amazon RDS PostgreSQL instance supporting Backstage          |

---

## Backstage Developer Portal

| Screenshot                                            | Evidence                                                                                  |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `screenshots/backstage-public-https-ui.png`           | Public Backstage developer portal available over HTTPS                                    |
| `screenshots/backstage-kubernetes-ingress.png`        | Kubernetes Ingress configured for the Backstage workload                                  |
| `screenshots/backstage-https-tls-health.png`          | HTTPS and TLS validation for the Backstage endpoint                                       |
| `screenshots/backstage-alb-target-healthy.png`        | AWS Application Load Balancer target registered and healthy                               |
| `screenshots/backstage-generated-service-catalog.png` | Golden Path-generated services registered in the Backstage Software Catalog               |
| `screenshots/backstage-corrected-image-rollout.png`   | Successful Backstage deployment rollout after application image/configuration remediation |

---

## Golden Path and Developer Self-Service

| Screenshot                                     | Evidence                                                     |
| ---------------------------------------------- | ------------------------------------------------------------ |
| `screenshots/golden-path-preflight.png`        | Golden Path prerequisites validated before service creation  |
| `screenshots/backstage-software-template.png`  | Backstage Software Template available to developers          |
| `screenshots/golden-path-service-creation.png` | Developer self-service service creation workflow             |
| `screenshots/backstage-scaffolder-success.png` | Successful Backstage Scaffolder execution                    |
| `screenshots/generated-service-repository.png` | GitHub repository generated through the Golden Path workflow |

---

## CI/CD and Container Artifacts

| Screenshot                                        | Evidence                                                                               |
| ------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `screenshots/github-actions-ci-oidc-failure.png`  | Initial GitHub Actions AWS OIDC authentication failure captured during troubleshooting |
| `screenshots/github-actions-oidc-trust-fixed.png` | Corrected GitHub Actions OIDC trust configuration                                      |
| `screenshots/github-actions-ci-oidc-success.png`  | Successful GitHub Actions pipeline using AWS OIDC federation                           |
| `screenshots/github-actions-final-clean-ci.png`   | Final production-style CI run after diagnostic steps were removed                      |
| `screenshots/golden-path-ecr-ci-image.png`        | Immutable Golden Path service container image published to Amazon ECR                  |

---

## GitOps

| Screenshot                                       | Evidence                                                                 |
| ------------------------------------------------ | ------------------------------------------------------------------------ |
| `screenshots/argocd-applications-healthy.png`    | Argo CD applications synchronized and healthy                            |
| `screenshots/argocd-golden-path-application.png` | Generated Golden Path application reconciled and managed through Argo CD |

---

## Security and Secrets

| Screenshot                                      | Evidence                                                                                      |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `screenshots/external-secrets-synchronized.png` | External Secrets Operator successfully synchronizing AWS Secrets Manager data into Kubernetes |

Additional security controls including GitHub Actions OIDC federation,
Amazon EKS Pod Identity, IAM role separation, private networking, AWS
Secrets Manager, TLS, and Kubernetes RBAC are documented through source
configuration and textual evidence.

---

## Final Platform Validation

| Screenshot                                       | Evidence                                                            |
| ------------------------------------------------ | ------------------------------------------------------------------- |
| `screenshots/project5-final-platform-health.png` | Final end-to-end platform and Kubernetes workload health validation |

---

## Evidence Philosophy

The screenshots are retained as engineering evidence rather than decorative
documentation.

Together with the command and validation artifacts under docs/evidence/,
they demonstrate:

- reproducible Terraform infrastructure
- operational Amazon EKS workloads
- Backstage developer self-service
- Golden Path service generation
- GitHub Actions continuous integration
- passwordless AWS authentication through GitHub OIDC
- immutable container publication to Amazon ECR
- declarative deployment through Argo CD
- Amazon EKS workload identity
- AWS Secrets Manager integration
- private PostgreSQL persistence
- HTTPS application exposure through an AWS Application Load Balancer
- troubleshooting and remediation of real implementation failures
- final platform validation
- controlled infrastructure teardown

The root project README uses a curated subset of these screenshots. Detailed
documentation uses additional evidence where it provides architectural,
security, implementation, or operational context.