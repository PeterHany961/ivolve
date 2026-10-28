# Kubernetes Node Isolation: Taints and Labels

Hi, I'm Peter Hany MecheiL, a Junior Cloud & DevOps Engineer. This document outlines the process of isolating a Kubernetes worker node using taints and labels for targeted workload scheduling.

## Objective
- Apply a taint to a worker node to prevent pods from being scheduled on it unless they have a matching toleration.
- Apply a label to the same node to identify it for targeted pod scheduling.
- Verify the configurations.

## Implementation Steps

### 1. Applying the Taint
To restrict standard workloads from being scheduled on the worker node, I applied a NoSchedule taint with the key `workload` and value `ivolveApp`:
```bash
kubectl taint nodes ip-172-31-26-17 workload=ivolveApp:NoSchedule
2. Applying the Label
To enable targeted scheduling for specific workloads, I assigned a custom label project=ivolve to the worker node:

Bash
kubectl label nodes ip-172-31-26-17 project=ivolve
3. Verification
Confirmed the taint was applied successfully:

Bash
kubectl describe node ip-172-31-26-17 | grep Taints
Confirmed the label was attached correctly:

Bash
kubectl get nodes --show-labels
Contact
LinkedIn: Peter Hany MecheiL

Email: phany8353@gmail.com
