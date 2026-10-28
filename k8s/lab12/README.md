# Lab 12: Managing Configuration and Sensitive Data with ConfigMaps and Secrets

## 📌 Objective
The goal of this lab is to decouple configuration data and secure sensitive information in a Kubernetes cluster using **ConfigMaps** and **Secrets**, ensuring that non-sensitive variables and credentials (such as MySQL configurations and passwords) are managed securely and efficiently within the `ivolve` namespace.

---

## 🛠️ Prerequisites & Environment
* **Cluster:** Kubernetes Cluster (Single-Node / Master Node)
* **Tool:** `kubectl`
* **Namespace:** `ivolve`

---

## 📝 Lab Steps & Implementation

### 1. Create a Dedicated Namespace
We ensured the `ivolve` namespace existed for isolating our lab resources:
```bash
kubectl create namespace ivolve
2. Create the ConfigMap (ivolvecm)We created a ConfigMap named ivolvecm to store non-sensitive MySQL configuration variables (DB_HOST and DB_USER):   Manifest (configmap.yaml):YAMLapiVersion: v1
kind: ConfigMap
metadata:
  name: ivolvecm
  namespace: ivolve
data:
  DB_HOST: "mysql-headless"
  DB_USER: "app_user"
Apply Command:Bashkubectl apply -f configmap.yaml
3. Create the Secret (ivolvesecret)We created a Secret named ivolvesecret to store sensitive credentials (MYSQL_ROOT_PASSWORD and DB_PASSWORD) encoded using Base64:   Manifest (secret.yaml):YAMLapiVersion: v1
kind: Secret
metadata:
  name: ivolvesecret
  namespace: ivolve
type: Opaque
data:
  MYSQL_ROOT_PASSWORD: "<base64_encoded_root_password>"
  DB_PASSWORD: "<base64_encoded_db_password>"
Apply Command:Bashkubectl apply -f secret.yaml
