# Lab 16: Pod Resource Management with CPU and Memory Requests and Limits

### 1) Update Deployment Manifest with CPU and Memory Requests and Limits
Update the `nodeapp` container specification in `ivolve-app-deployment.yaml`:
- **Requests**:
  - `cpu`: `1` (1 vCPU)
  - `memory`: `1Gi`
- **Limits**:
  - `cpu`: `2` (2 vCPUs)
  - `memory`: `2Gi`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ivolveapp
  namespace: ivolve
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ivolveapp
  template:
    metadata:
      labels:
        app: ivolveapp
    spec:
      nodeSelector:
        project: "ivolve"
      tolerations:
      - key: "workload"
        operator: "Equal"
        value: "ivolveApp"
        effect: "NoSchedule"
      initContainers:
      - name: init-db
        image: mysql:8.0
        command: ['sh', '-c', 'mysql -h ivolvedbsvc.ivolve.svc.cluster.local -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS ivolve;"']
        envFrom:
        - configMapRef:
            name: ivolvecm
        - secretRef:
            name: ivolvesecret
      containers:
      - name: nodeapp
        image: peter2976/ivolveapp
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: ivolvecm
        - secretRef:
            name: ivolvesecret
        resources:
          requests:
            cpu: "1"
            memory: "1Gi"
          limits:
            cpu: "2"
            memory: "2Gi"
```

Apply the updated deployment:
```bash
kubectl apply -f ivolve-app-deployment.yaml
```

---

### 2) Verify Applied Resource Requests and Limits
Verify the resource limits and requests on the deployment's ReplicaSet:
```bash
kubectl describe rs ivolveapp-8498b9df4c -n ivolve | grep -A 8 "Limits:"
```
```
    Limits:
      cpu:     2
      memory:  2Gi
    Requests:
      cpu:     1
      memory:  1Gi
```

Or inspect via `kubectl describe pod`:
```bash
kubectl describe pod -l app=ivolveapp -n ivolve | grep -A 8 "Limits:"
```

---

### 3) Monitor Real-Time Resource Usage
Monitor real-time resource consumption using `kubectl top pod` (requires metrics-server):
```bash
kubectl top pod -n ivolve
```
```bash
kubectl top pod -l app=ivolveapp -n ivolve
```
*(Note: If metrics-server is not enabled in the cluster, `kubectl top pod` returns `error: Metrics API not available` until metrics-server is deployed).*
