# Horizontal Pod Autoscaler (HPA)

The **Horizontal Pod Autoscaler (HPA)** automatically scales the number of Pod replicas in a Deployment, ReplicaSet, or StatefulSet up or down based on resource metrics like CPU or memory utilization.

---

## 1. Prerequisites for HPA

For the HPA to function properly:
1. **Metrics Server**: A metrics collection agent (like Kubernetes Metrics Server) must be running in the cluster to provide resource utilization data.
2. **Resource Requests**: The target container definitions **must** declare resource `requests` (e.g., CPU requests). Without this, the HPA cannot calculate the percentage of resource utilization and will fail to scale.

---

## 2. HPA Configuration

Here is how HPA is declared in [grade-submission-portal-hpa.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/09-section-nine%28Horizontal%20Pod%20Autoscaler%29/grade-submission-portal/grade-submission-portal-hpa.yaml):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: grade-submission-portal-hpa
  namespace: grade-submission
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: grade-submission-portal
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

### Key Parameters:
- **`scaleTargetRef`**: Points to the target workload to scale (in this case, the `grade-submission-portal` Deployment).
- **`minReplicas` & `maxReplicas`**: The minimum and maximum limits for scaling.
- **`metrics`**: The target threshold rules. Here, it scales up when average CPU utilization across all Pods exceeds **50%** of their requested CPU.

---

## 3. Useful Commands

* **List all HPAs:**
  ```bash
  kubectl get hpa -n grade-submission
  ```
  *(Look at the `TARGETS` column to see the current/target utilization. E.g., `0%/50%`).*

* **Get detailed HPA status and scaling events history:**
  ```bash
  kubectl describe hpa grade-submission-portal-hpa -n grade-submission
  ```

* **Create an HPA imperatively via CLI:**
  ```bash
  kubectl autoscale deployment grade-submission-portal --cpu-percent=50 --min=1 --max=10 -n grade-submission
  ```
