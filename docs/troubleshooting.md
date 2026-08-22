## EKS Managed Node Group Stuck During Creation

### Symptoms

The EKS control plane became `ACTIVE`, but the managed node group remained
in `CREATING` state for more than 25 minutes.

Terraform eventually had to be interrupted while waiting for node-group
creation.

EC2 instances had successfully launched, but Kubernetes showed:

STATUS
NotReady
NotReady


The aws-node VPC CNI pods were repeatedly entering:
```
CrashLoopBackOff
```
CoreDNS pods remained pending.

## Investigation

The worker EC2 instances were verified as running successfully across both
private subnets.

The EKS worker IAM role contained:

- AmazonEKSWorkerNodePolicy
- AmazonEC2ContainerRegistryPullOnly

The node IAM trust relationship correctly allowed:
```
ec2.amazonaws.com
```
Running:
```
kubectl describe pod <aws-node-pod> -n kube-system
```
revealed:
```
MissingIAMPermissions

Unauthorized operation:
failed to call ec2:DescribeNetworkInterfaces
```
## Root Cause

The Amazon VPC CNI requires AWS EC2 permissions to manage network interfaces
and pod IP addresses.

Those permissions are provided by:
```
AmazonEKS_CNI_Policy
```
The policy had intentionally not been attached to the EC2 worker-node role
because workload-level least privilege was desired.

However, the VPC CNI had not yet been configured with its own IAM role.

As a result:
```
aws-node
    ↓
EC2 API
    ↓
AccessDenied
    ↓
CNI unavailable
    ↓
Nodes NotReady
    ↓
Managed Node Group CREATE_FAILED
```
## Resolution

A dedicated IAM role was created for the VPC CNI.

The role trusts:
```
pods.eks.amazonaws.com
```
and receives:
```
AmazonEKS_CNI_Policy
```
The VPC CNI add-on was configured with an EKS Pod Identity association for:
```
Namespace: kube-system
ServiceAccount: aws-node
```
Terraform dependency ordering was also corrected so that:
```
EKS Cluster
    ↓
Pod Identity Agent
    ↓
VPC CNI + Pod Identity
    ↓
Managed Node Group
    ↓
CoreDNS / kube-proxy
```
The failed node group was then replaced.

## Validation

The replacement nodes became:
```
Ready
```
and all core components became healthy:
```
aws-node                 Running
coredns                  Running
kube-proxy               Running
eks-pod-identity-agent   Running
```
## Lessons Learned
- A running EC2 instance does not mean an EKS node is healthy.
- Troubleshooting should follow the lifecycle from EC2 launch to kubelet
registration to CNI initialization.
- Kubernetes describe events often expose the exact AWS API permission
causing a failure.
- VPC CNI permissions should be isolated from the general EC2 node role.
- EKS Pod Identity provides a cleaner least-privilege model.
- Terraform resource dependency ordering matters during cluster bootstrap.
```
This is a strong senior-level troubleshooting example.

---

# 6. Commit Phase 6

Now:

```bash
cd ~/Projects/enterprise-internal-developer-platform

terraform fmt -recursive terraform/

git status
git diff
```
Then:
```
git add .

git commit -m "infra: provision EKS cluster with Pod Identity networking"

git push origin main
```
Verify:
```
git status
git log --oneline -6
```
