# Rolling Updates and Rollbacks

Deployments in Kubernetes support rolling updates and rollbacks, allowing you to update applications with zero downtime and easily revert to a previous working version if an update fails.

---

## 1. Rolling Updates

A **Rolling Update** gradually replaces instances of the old version of your application with the new version.

### Strategy Configuration
You configure the behavior of rolling updates using the `spec.strategy` block:
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 50%  # Max pods that can be offline during the update.
    maxSurge: 1          # Max pods created beyond the desired replica count.
```

- **`maxUnavailable`**: Defines the maximum number of pods that can be unavailable during the update. It can be an absolute number (e.g., `1`) or a percentage (e.g., `50%`).
- **`maxSurge`**: Defines the maximum number of pods that can be created over the desired replica count. (e.g., if replicas is 2 and maxSurge is 1, a maximum of 3 pods can exist during the update).

### Triggering a Rolling Update
An update is triggered whenever you modify the Pod template (such as updating the container `image` or changing resource limits) and run `kubectl apply`:
```bash
kubectl apply -f grade-submission-api-deployment.yaml
```
Alternatively, update the image directly using the CLI:
```bash
kubectl set image deployment/grade-submission-api grade-submission-api=rslim087/kubernetes-course-grade-submission-api:stateful -n grade-submission
```

---

## 2. Rollbacks

If a new version has bugs or crashes, you can roll back to a previous revision.

### Undo a Rollout (Rollback)
Roll back to the immediate previous version:
```bash
kubectl rollout undo deployment/grade-submission-api -n grade-submission
```

### Roll back to a Specific Revision
1. View the deployment history to find the revision number:
   ```bash
   kubectl rollout history deployment/grade-submission-api -n grade-submission
   ```
2. Roll back to a specific revision (e.g., revision 1):
   ```bash
   kubectl rollout undo deployment/grade-submission-api --to-revision=1 -n grade-submission
   ```

---

## 3. Useful Commands

* **Check the status of a rollout:**
  ```bash
  kubectl rollout status deployment/grade-submission-api -n grade-submission
  ```

* **View rollout history details:**
  ```bash
  kubectl rollout history deployment/grade-submission-api -n grade-submission
  ```

* **Pause a rolling update:**
  ```bash
  kubectl rollout pause deployment/grade-submission-api -n grade-submission
  ```

* **Resume a paused rolling update:**
  ```bash
  kubectl rollout resume deployment/grade-submission-api -n grade-submission
  ```
