# ConfigMaps and Secrets

In Kubernetes, **ConfigMaps** and **Secrets** are used to separate configuration data and sensitive credentials from container images, making applications more portable and secure.

---

## 1. ConfigMap vs. Secret

### A. ConfigMap
- **Purpose**: Stores non-confidential configuration data in key-value pairs (e.g., hostnames, port numbers, log levels).
- **Example**: [grade-submission-api-config.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/08-section-eight%28ConfigMap%20and%20Secret%29/grade-submission-api/grade-submission-api-config.yaml)
  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: grade-submission-api-config
  data:
    MONGODB_HOST: mongodb
    MONGODB_PORT: '27017'
  ```

### B. Secret
- **Purpose**: Stores sensitive data such as passwords, API keys, and OAuth tokens.
- **Base64 Encoding**: The values in a Secret manifest's `data` block **must** be Base64-encoded.
  - To encode: `echo -n 'admin' | base64` (outputs `YWRtaW4=`)
  - To decode: `echo 'YWRtaW4=' | base64 --decode` (outputs `admin`)
- **Example**: [grade-submission-api-secret.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/08-section-eight%28ConfigMap%20and%20Secret%29/grade-submission-api/grade-submission-api-secret.yaml)
  ```yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: grade-submission-api-secret
  type: Opaque
  data:
    MONGODB_USER: YWRtaW4=
    MONGODB_PASSWORD: cGFzc3dvcmQxMjM=
  ```

---

## 2. Injecting ConfigMaps & Secrets into Pods

You can inject all keys from a ConfigMap or Secret as environment variables into a Pod's containers using `envFrom`.

**Example configuration in [grade-submission-api-deployment.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/08-section-eight%28ConfigMap%20and%20Secret%29/grade-submission-api/grade-submission-api-deployment.yaml):**
```yaml
spec:
  containers:
  - name: grade-submission-api
    image: rslim087/kubernetes-course-grade-submission-api:stateless-v3
    envFrom:
      - configMapRef:
          name: grade-submission-api-config
      - secretRef:
          name: grade-submission-api-secret
```

---

## 3. Useful Commands

* **List ConfigMaps:**
  ```bash
  kubectl get configmaps
  # Or shorthand:
  kubectl get cm
  ```

* **List Secrets:**
  ```bash
  kubectl get secrets
  ```

* **Create a Secret directly from the CLI (imperative):**
  ```bash
  kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=supersecret
  ```

* **Decode and view secret values:**
  ```bash
  kubectl get secret grade-submission-api-secret -o jsonpath='{.data.MONGODB_PASSWORD}' | base64 --decode
  ```
