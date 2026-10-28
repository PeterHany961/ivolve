# AWS Kubernetes Cluster Provisioning (kubeadm)

Hi, I'm Peter Hany MecheiL, a Junior Cloud & DevOps Engineer. This repository documents my hands-on project of provisioning and configuring a fully functional two-node Kubernetes cluster from scratch on AWS EC2 instances using kubeadm.

## Project Architecture
- Infrastructure: 2 AWS EC2 Instances (Ubuntu) - t2.small
- Cluster Topology: 1 Control Plane (Master Node), 1 Worker Node
- Container Runtime: containerd
- CNI (Container Network Interface): Calico
- Kubernetes Version: v1.30

## Deployment Steps

### 1. Environment Setup
- Provisioned the EC2 instances and configured AWS Security Groups to allow cluster communication (specifically TCP port 6443 for the API server).
- Disabled swap memory to meet Kubernetes requirements.
- Configured network routing by enabling IPv4 forwarding in sysctl.
- Installed and configured containerd as the primary container runtime on both nodes.

### 2. Control Plane Initialization
- Bootstrapped the master node using the `kubeadm init` command.
- Configured `kubectl` for local administrative access.
- Deployed the Calico network plugin to establish Pod-to-Pod communication across the cluster.

### 3. Worker Node Integration
- Cleaned up any residual configurations using `kubeadm reset`.
- Joined the worker node to the control plane using the generated kubeadm token and discovery certificate hash.

## Troubleshooting & Learnings
During the setup process, I encountered and resolved a few infrastructure and networking challenges:
- API Server Connections: Addressed connection refused errors by upgrading the instance type to t2.small to ensure sufficient memory allocation, and restarted the kubelet and containerd services to stabilize the control plane.
- Network Routing: Resolved fatal preflight errors during the worker node join process by manually configuring and applying `net.ipv4.ip_forward = 1` rules.
- AWS Security Groups: Troubleshot a hanging join command by identifying blocked traffic and modifying the inbound rules to allow traffic on port 6443.

## Contact
- LinkedIn: [Peter Hany MecheiL](https://www.linkedin.com/in/peter-hany-52260a2a7)
- Email: phany8353@gmail.com
