# Ingress and Ingress Controllers

In Kubernetes, **Ingress** manages external access to the services inside a cluster, typically handling HTTP and HTTPS traffic.

---

## 1. What is Ingress vs. Ingress Controller?

- **Ingress Resource**: A set of routing rules (defined in YAML) that specifies how external HTTP/HTTPS traffic should be routed to internal Kubernetes Services.
- **Ingress Controller**: The actual load balancer/reverse proxy running in the cluster (e.g., NGINX Ingress Controller) that reads the Ingress rules and routes the incoming traffic accordingly.

### Why use Ingress instead of NodePort?
Instead of exposing dozens of services via individual random NodePorts (e.g. `32000`, `31045`), Ingress allows you to route all external traffic through a single entry point (port `80`/`443`) and route to different backend services based on the requested host domain or URL path.

---

## 2. Ingress Configuration

Here is how Ingress is declared in [grade-submission-portal-ingress.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/10-section-ten%28Ingress%20Controller%29/grade-submission-portal/grade-submission-portal-ingress.yaml):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grade-submission-portal-ingress
  namespace: grade-submission
spec:
  ingressClassName: nginx
  rules:     
  - http:
      paths:
      - pathType: Prefix
        path: "/"    
        backend:
          service:
            name: grade-submission-portal
            port: 
              number: 5001
```

### Key Parameters:
- **`ingressClassName`**: Indicates which controller should implement this ingress ruleset (e.g., `nginx`).
- **`rules`**: Configures the HTTP routing behavior.
- **`path`**: The URL path prefix to match. Here, `/` matches all incoming requests.
- **`backend.service`**: The target Service name (`grade-submission-portal`) and `port` (`5001`) to forward matching requests.

---

## 3. Useful Commands

* **List Ingress resources in the namespace:**
  ```bash
  kubectl get ingress -n grade-submission
  # Or:
  kubectl get ing -n grade-submission
  ```
  *(Look for the `ADDRESS` column to see the external IP or domain assigned to the Ingress).*

* **Describe Ingress configuration and backend status:**
  ```bash
  kubectl describe ingress grade-submission-portal-ingress -n grade-submission
  ```
11111
