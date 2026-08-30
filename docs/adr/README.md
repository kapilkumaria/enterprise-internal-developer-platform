# Architecture Decision Records

Architecture Decision Records (ADRs) capture significant technical decisions made while designing and implementing the Enterprise Internal Developer Platform.

They document the architectural context, selected approach, trade-offs and consequences of important platform decisions.

| ADR | Decision | Status |
|---|---|---|
| [ADR-0001](0001-platform-architecture.md) | Initial Internal Developer Platform architecture | Accepted |
| [ADR-0002](0002-eks-workload-identity.md) | Use EKS Pod Identity for AWS workload authentication | Accepted |
| [ADR-0003](0003-use-amazon-eks.md) | Use Amazon EKS as the Kubernetes runtime | Accepted |

## Why ADRs Are Used

Platform engineering involves architectural decisions that affect security, developer experience, operational complexity and infrastructure cost.

Maintaining ADRs provides:

- architectural traceability
- documented engineering rationale
- visibility into trade-offs
- historical context for future platform changes
- evidence that infrastructure decisions were intentional rather than incidental

The ADRs in this repository represent the major architectural decisions made during implementation of the platform.
