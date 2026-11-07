# Lab 15: Node.js Application Deployment with ClusterIP Service

### 1) Create Application Deployment Manifest (ivolve-app-deployment.yaml)
Create `ivolve-app-deployment.yaml` in namespace `ivolve`:
- `2` replicas using image `peter2976/ivolveapp`.
- Environment variables passed from `ivolvecm` and `ivolvesecret`.
- Node selector `project: "ivolve"` and toleration `workload=ivolveApp:NoSchedule`.
- `initContainers` with `mysql:8.0` to initialize the `ivolve` database and grant user permissions.

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
        command: ['sh', '-c', 'mysql -h ivolvedbsvc.ivolve.svc.cluster.local -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS ivolve; GRANT ALL PRIVILEGES ON ivolve.* TO \x27$DB_USER\x27@\x27%\x27; FLUSH PRIVILEGES;"']
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
```

Apply the Deployment:
```bash
kubectl apply -f ivolve-app-deployment.yaml
```

---

### 2) Create ClusterIP Service Manifest (ivolve-app-svc.yaml)
Create `ivolve-app-svc.yaml` exposing the application within the cluster:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: ivolveappsvc
  namespace: ivolve
spec:
  type: ClusterIP
  selector:
    app: ivolveapp
  ports:
  - port: 80
    targetPort: 3000
```

Apply the ClusterIP Service:
```bash
kubectl apply -f ivolve-app-svc.yaml
```

---

### 3) Verify Deployment and Service Status
Verify the deployment and running application pods:
```bash
kubectl get deployment ivolveapp -n ivolve
```
```
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
ivolveapp   2/2     0            2           21h
```

```bash
kubectl get pods -l app=ivolveapp -n ivolve -o wide
```
```
NAME                         READY   STATUS    RESTARTS      AGE   IP              NODE              NOMINATED NODE   READINESS GATES
ivolveapp-6b57965ff9-n2f4h   1/1     Running   1 (13m ago)   15m   192.168.64.23   ip-172-31-26-17   <none>           <none>
ivolveapp-74cbcbb976-4nx9r   1/1     Running   1 (13m ago)   15m   192.168.64.22   ip-172-31-26-17   <none>           <none>
```

Verify ClusterIP Service and endpoints:
```bash
kubectl get svc ivolveappsvc -n ivolve
```
```
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
ivolveappsvc   ClusterIP   10.104.179.198   <none>        80/TCP    21h
```

```bash
kubectl get endpoints ivolveappsvc -n ivolve
```
```
NAME           ENDPOINTS                               AGE
ivolveappsvc   192.168.64.22:3000,192.168.64.23:3000   21h
```

---

### 4) Verify Database and User Privileges in MySQL
Connect manually to MySQL to verify that `ivolve` database exists and `ivolve_user` has required privileges:
```bash
kubectl exec -it ivolvedb-0 -n ivolve -- mysql -u ivolve_user -pDbPassword456 -e "SHOW DATABASES; SHOW GRANTS FOR 'ivolve_user'@'%';"
```
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| ivolve             |
| performance_schema |
+--------------------+
+---------------------------------------------------------+
| Grants for ivolve_user@%                                |
+---------------------------------------------------------+
| GRANT USAGE ON *.* TO `ivolve_user`@`%`                 |
| GRANT ALL PRIVILEGES ON `ivolve`.* TO `ivolve_user`@`%` |
+---------------------------------------------------------+
```

---

### 5) Check Application Logs for MySQL Connectivity
Check the logs of the running Node.js pods:
```bash
kubectl logs -l app=ivolveapp -c nodeapp -n ivolve --tail=3
```
```
🔄 Attempting to connect to MySQL...
✅ Connected to MySQL and 'ivolve' DB found.
🚀 Server started on http://0.0.0.0:3000
```

---

### 6) Test ClusterIP Service Connectivity
Send an HTTP request to the ClusterIP Service:
```bash
curl -s -I http://10.104.179.198:80
```
```
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=UTF-8
```
