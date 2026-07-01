# Kubernetes Operators

A **Kubernetes Operator** is a method of packaging, deploying, and managing a Kubernetes application. It extends the native Kubernetes API to manage complex, stateful applications (like databases, queues, or monitoring stacks) automatically.

---

## 1. Core Concepts

### A. CRD (Custom Resource Definition)
Kubernetes has native resources like Pods, Services, and Deployments. A **CRD** allows you to define your own custom resources (e.g. `MongoDBCommunity`) that behave exactly like native objects.

### B. Controller (The Operator)
The Operator is a custom control loop (running inside a Pod) that actively monitors your custom resources. When it detects a new resource, it automatically creates and manages all the underlying low-level Kubernetes resources needed to run it.

---

## 2. Example: MongoDB Community Operator

In [mongodb-grade-submission.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/13-section-thirteen%28Kubernetes%20Operators%29/mongodb/mongodb-grade-submission.yaml), we declare a custom resource:

```yaml
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: mongodb-grade-submission
  namespace: mongodb
spec:
  members: 1
  type: ReplicaSet
  version: "6.0.5"
  # ... (users, auth, security configs)
```

### Why does this create so many resources?
When you apply this file, you do not write YAML for services, statefulsets, or secrets. Instead, the running **MongoDB Community Operator** reads this manifest and automatically creates and manages:
- **StatefulSet**: To manage the database pod lifecycle and volume attachments.
- **Services**: To route cluster traffic to the database.
- **ConfigMaps & Secrets**: To configure internal settings and user credentials securely.
- **PVC (Persistent Volume Claims)**: To request storage disks dynamically.

---

## 3. Useful Commands for Operators

* **List all Custom Resource Definitions (CRDs) registered in your cluster:**
  ```bash
  kubectl get crds
  ```

* **List MongoDB custom resources:**
  ```bash
  kubectl get mongodbcommunity -n mongodb
  # Or shorthand:
  kubectl get mdb -n mongodb
  ```

* **Inspect the state, status, and event history of the database:**
  ```bash
  kubectl describe mongodbcommunity mongodb-grade-submission -n mongodb
  ```
