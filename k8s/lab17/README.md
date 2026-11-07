# Lab 17: Control Pod-to-Pod Traffic via Network Policy

### 1) Create NetworkPolicy Manifest (ivolve-networkpolicy.yaml)
Create `ivolve-networkpolicy.yaml` in namespace `ivolve`:
- **Name**: `ivolvenp`
- **Pod Selector**: Targets MySQL pods (`app: mysql` or `app: ivolvedb`).
- **Policy Types**: Only `Ingress`.
- **Ingress Rule**:
  - Allows incoming traffic exclusively from pods labeled `app: ivolveapp`.
  - Restricts access strictly to MySQL port `3306` over TCP.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ivolvenp
  namespace: ivolve
spec:
  podSelector:
    matchLabels:
      app: mysql
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: ivolveapp
    ports:
    - protocol: TCP
      port: 3306
```

Apply the NetworkPolicy:
```bash
kubectl apply -f ivolve-networkpolicy.yaml
```

---

### 2) Verify NetworkPolicy Configuration
Confirm that the NetworkPolicy is applied in the `ivolve` namespace:
```bash
kubectl get networkpolicy ivolvenp -n ivolve
```
```
NAME       POD-SELECTOR   AGE
ivolvenp   app=mysql      15h
```

Inspect the policy specifications:
```bash
kubectl describe networkpolicy ivolvenp -n ivolve
```
```
Name:         ivolvenp
Namespace:    ivolve
Created on:   Sat, 07 Nov 2026 05:17:55 +0000
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     app=mysql
  Allowing ingress traffic:
    To Port: 3306/TCP
    From:
      PodSelector: app=ivolveapp
  Not affecting egress traffic
  Policy Types: Ingress
```

---

### 3) Verify Allowed Ingress from Authorized Application Pods
Test connectivity from an authorized application pod (`app=ivolveapp`) to MySQL on port `3306`:
```bash
kubectl exec -it pod/ivolveapp-6b57965ff9-n2f4h -n ivolve -c nodeapp -- node -e 'const net = require("net"); const s = net.createConnection(3306, "ivolvedbsvc.ivolve.svc.cluster.local", () => { console.log("MySQL port 3306 reachable!"); s.end(); });'
```
```
MySQL port 3306 reachable!
```

---

### 4) Verify Traffic Isolation for Unauthorized Sources
Check that traffic from non-matching pods or sources outside the allowed pod selector cannot establish unauthorized connections directly to MySQL port 3306.
