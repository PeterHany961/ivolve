# Lab 14: StatefulSet with Headless Service

### 1) Create Headless Service Manifest (ivolve-headless-svc.yaml)
Create `ivolve-headless-svc.yaml` defining a headless service named `ivolvedbsvc` in the `ivolve` namespace:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: ivolvedbsvc
  namespace: ivolve
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

Apply the Headless Service:
```bash
kubectl apply -f ivolve-headless-svc.yaml
```

---

### 2) Create StatefulSet Manifest (ivolve-statefulset.yaml)
Create `ivolve-statefulset.yaml` defining the `ivolvedb` StatefulSet in namespace `ivolve`:
- Single replica running `mysql:8.0`.
- Environment variables injected from `ivolvecm` and `ivolvesecret`.
- Node selector targeting node with label `project: "ivolve"`.
- Toleration for taint `workload=ivolveApp:NoSchedule`.
- `volumeClaimTemplates` mounting `/var/lib/mysql`.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: ivolvedb
  namespace: ivolve
spec:
  serviceName: "ivolvedbsvc"
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      nodeSelector:
        project: "ivolve"
      tolerations:
      - key: "workload"
        operator: "Equal"
        value: "ivolveApp"
        effect: "NoSchedule"
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
          name: mysql
        envFrom:
        - configMapRef:
            name: ivolvecm
        - secretRef:
            name: ivolvesecret
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: [ "ReadWriteMany" ]
      storageClassName: ""
      resources:
        requests:
          storage: 1Gi
```

Apply the StatefulSet:
```bash
kubectl apply -f ivolve-statefulset.yaml
```

---

### 3) Verify StatefulSet and Pod Creation
Verify the StatefulSet and running pod status:
```bash
kubectl get statefulset ivolvedb -n ivolve
```
```
NAME       READY   AGE
ivolvedb   1/1     16h
```

```bash
kubectl get pods -l app=mysql -n ivolve -o wide
```
```
NAME         READY   STATUS    RESTARTS       AGE   IP              NODE              NOMINATED NODE   READINESS GATES
ivolvedb-0   1/1     Running   17 (13m ago)   15h   192.168.64.19   ip-172-31-26-17   <none>           <none>
```

Verify the Headless Service:
```bash
kubectl get svc ivolvedbsvc -n ivolve
```
```
NAME          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
ivolvedbsvc   ClusterIP   None         <none>        3306/TCP   23h
```

---

### 4) Confirm Database Is Operational via MySQL Client
Connect directly inside the `ivolvedb-0` pod using MySQL client:
```bash
kubectl exec -it ivolvedb-0 -n ivolve -- mysql -u root -pRootPassword123 -e "SHOW DATABASES;"
```
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| ivolve             |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
```

---

### 5) Verify MySQL Pod DNS Resolution Inside Cluster
Resolve the headless service DNS record directly inside the cluster:
```bash
kubectl exec -it ivolvedb-0 -n ivolve -- getent hosts ivolvedb-0.ivolvedbsvc
```
```
192.168.64.19   ivolvedb-0.ivolvedbsvc.ivolve.svc.cluster.local
```
