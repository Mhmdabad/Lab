# Kubernetes Services

A **Service** is an abstraction that defines a logical set of Pods and a policy by which to access them. Since Pods are ephemeral and their IP addresses change, Services provide a stable IP address and DNS name to route traffic to them.

---

## 1. How Services Work (Selectors & Ports)
Services use a `selector` to match labels on Pods and route traffic to them:
- **`port`**: The port that the Service itself listens on.
- **`targetPort`**: The port on the Pod/container where traffic is forwarded.

---

## 2. Service Types Used in this Section

### A. ClusterIP (Default)
Exposes the Service on an internal IP address within the cluster. It is only accessible from inside the Kubernetes cluster.
- **Example**: [grade-submission-api-service.yml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/2-section-two%28service%29/grade-submission-api-service.yml)
- **Use case**: Database, backend APIs, or internal microservices that shouldn't be exposed directly to the internet.

### B. NodePort
Exposes the Service on each Node's IP address at a static port (typically between `30000` and `32767`). This makes the Service accessible from outside the cluster.
- **Example**: [grade-submission-portal-service.yml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/2-section-two%28service%29/grade-submission-portal-service.yml)
- **Use case**: Web frontends or portals where external clients need to access the app directly via Node IP and Port.

---

## 3. Basic Commands
* **List all services in the current namespace:**
  ```bash
  kubectl get services
  # Or:
  kubectl get svc
  ```
* **Describe a specific service details (endpoints, selector, etc.):**
  ```bash
  kubectl describe service <service-name>
  ```
