# Liveness and Readiness Probes

Probes are health checks performed by the kubelet on a container to monitor its state and ensure application reliability.

---

## 1. Liveness vs. Readiness Probes

### A. Liveness Probe
- **Purpose**: Checks if the application inside the container is still alive/running.
- **Action on Failure**: If the liveness probe fails, the kubelet kills the container, and the container restarts according to its restart policy.
- **Example configuration in [grade-submission-api-deployment.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/06-section-six%28Liveness%20and%20Readiness%20Probes%29/grade-submission-api-deployment.yaml)**:
  ```yaml
  livenessProbe:
    httpGet:
      path: /healthz
      port: 3000
    initialDelaySeconds: 15
    periodSeconds: 5
  ```

### B. Readiness Probe
- **Purpose**: Checks if the container is ready to accept and handle network traffic.
- **Action on Failure**: If the readiness probe fails, the endpoints controller removes the Pod's IP address from all Services. No traffic will be routed to the Pod until it passes.
- **Example configuration in [grade-submission-api-deployment.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/06-section-six%28Liveness%20and%20Readiness%20Probes%29/grade-submission-api-deployment.yaml)**:
  ```yaml
  readinessProbe:
    httpGet:
      path: /readyz
      port: 3000
    initialDelaySeconds: 10
    periodSeconds: 5
  ```

---

## 2. Probe Parameters Explained

- **`httpGet`**: Specifies that the health check is performed via an HTTP GET request to the given `path` and `port`. A response status code between `200` and `399` indicates success.
- **`initialDelaySeconds`**: How many seconds to wait after the container starts before performing the first probe (allows the app time to boot up).
- **`periodSeconds`**: How often (in seconds) the probe is performed.

---

## 3. Useful Commands

* **Describe Pod details (view probe status, restarts, and health check failures):**
  ```bash
  kubectl describe pod <pod-name> -n grade-submission
  ```
  *(Check the **Events** section at the bottom of the output for probe failure warning logs).*

* **Monitor Pod status and restarts in real-time:**
  ```bash
  kubectl get pods -n grade-submission -w
  ```
