# Kubernetes Deployments

A **Deployment** is a declarative resource that manages a set of identical Pods (replicas). It ensures that a specified number of pods are running, healthy, and up-to-date, providing automated scaling, self-healing, and rolling updates.

---

## 1. How to Create/Apply a Deployment
You deploy a configuration file (like [grade-submission-api-deployment.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/04-section-four%28deployment%29/grade-submission-api-deployment.yaml)) using the CLI command:
```bash
kubectl apply -f <deployment-file.yaml>
```

---

## 2. Key Concepts in a Deployment

### A. Replicas & Scaling
The `spec.replicas` field specifies how many copies of the Pod should run. Kubernetes will automatically scale up or down to match this number.
```yaml
spec:
  replicas: 2 # <-- Launches 2 identical Pods
```

### B. Self-Healing
If a Pod managed by a Deployment crashes or the node it's running on dies, the Deployment controller automatically creates a new one to maintain the desired number of replicas.

### C. Pod Template & Selector
- **`spec.template`**: Defines the blueprint for the Pods (container image, ports, resources).
- **`spec.selector.matchLabels`**: Matches the labels defined in the Pod template so the Deployment controller knows which Pods it is responsible for managing.

---

## 3. Useful Commands

* **List all deployments:**
  ```bash
  kubectl get deployments
  # Or:
  kubectl get deploy
  ```

* **Scale a deployment manually:**
  ```bash
  kubectl scale deployment <deployment-name> --replicas=<number>
  ```

* **Check the rollout status of a deployment:**
  ```bash
  kubectl rollout status deployment/<deployment-name>
  ```
