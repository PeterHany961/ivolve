# Lab 13: Persistent Storage Setup for Application Logging

### 1) Create PersistentVolume Manifest (ivolve-pv.yaml)
Create `ivolve-pv.yaml` defining a hostPath PersistentVolume named `ivolvepv` with `1Gi` capacity, `ReadWriteMany` access mode, and `Retain` policy:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ivolvepv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/app-logs
```

Apply the PersistentVolume:
```bash
kubectl apply -f ivolve-pv.yaml
```

---

### 2) Create PersistentVolumeClaim Manifest (ivolve-pvc.yaml)
Create `ivolve-pvc.yaml` requesting `1Gi` storage with `ReadWriteMany` access mode without any StorageClass (`storageClassName: ""`):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ivolvepvc
  namespace: ivolve
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: ""
```

Apply the PersistentVolumeClaim:
```bash
kubectl apply -f ivolve-pvc.yaml
```

---

### 3) Verify PersistentVolume and Claim Status
Verify that `ivolvepv` and `ivolvepvc` are created and status is `Bound`:
```bash
kubectl get pv ivolvepv
```
```
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
ivolvepv   1Gi        RWX            Retain           Bound    ivolve/ivolvepvc                  <unset>                          42h
```

```bash
kubectl get pvc ivolvepvc -n ivolve
```
```
NAME        STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
ivolvepvc   Bound    ivolvepv   1Gi        RWX                           <unset>                 42h
```

---

### 4) Verify Binding Details
Inspect the PersistentVolumeClaim to confirm binding to `ivolvepv`:
```bash
kubectl describe pvc ivolvepvc -n ivolve
```
```
Name:          ivolvepvc
Namespace:     ivolve
StorageClass:  
Status:        Bound
Volume:        ivolvepv
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
Capacity:      1Gi
Access Modes:  RWX
VolumeMode:    Filesystem
Used By:       <none>
```
