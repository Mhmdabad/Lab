# StatefulSets, Persistent Volumes, and Database Authentication

This section covers running stateful applications (like databases) in Kubernetes, provisioning persistent storage, and setting up database authentication.

---

## 1. StatefulSet vs. Deployment

A **StatefulSet** is used to manage stateful applications (e.g., databases like MongoDB, PostgreSQL). 

Unlike Deployments:
- **Sticky Identity**: Each Pod in a StatefulSet gets a unique, stable network identity and hostname based on its index (e.g., `mongodb-0`, `mongodb-1`).
- **Stable Storage**: Each Pod is linked to its own persistent storage volume that persists even if the Pod is rescheduled to another node.
- **Headless Service**: Defined by `serviceName: mongodb`, which creates DNS records for each individual Pod.

*Reference configuration:* [mongodb-statefulset.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/07-section-seven%28StatefulSet%20and%20Persistent%20Volumes%29/mongodb-statefulset.yaml)

---

## 2. Persistent Volumes & Claims (PVC)

To prevent data loss when database Pods restart or reschedule, Kubernetes uses **Persistent Volumes**.

- **`volumeMounts`**: Mounts a volume to the folder inside the database container where the data is stored (e.g., `/data/db` for MongoDB).
- **`volumeClaimTemplates`**: Automatically claims a specific amount of storage (e.g., `1Gi`) with access modes (like `ReadWriteOnce`) dynamically for each Pod in the StatefulSet:
  ```yaml
  volumeClaimTemplates:
  - metadata:
      name: mongodb-persistent-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
  ```

---

## 3. Database Authentication

To secure the database, we pass credential environment variables to the database, and configure our backend API to match them.

### Step A: Configure the Database Credentials
Define variables in the StatefulSet container spec to initialize the root user/pass:
```yaml
env:
  - name: MONGO_INITDB_ROOT_USERNAME
    value: "admin"
  - name: MONGO_INITDB_ROOT_PASSWORD
    value: "password123"
```

### Step B: Connect the API Backend
In [grade-submission-api-deployment.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/07-section-seven%28StatefulSet%20and%20Persistent%20Volumes%29/grade-submission-api-deployment.yaml), pass matching database host, port, user, and password variables to the application container:
```yaml
env:
  - name: MONGODB_HOST
    value: mongodb
  - name: MONGODB_PORT
    value: '27017'
  - name: MONGODB_USER
    value: admin
  - name: MONGODB_PASSWORD
    value: password123
```

---

## 4. Useful Commands

* **List StatefulSets:**
  ```bash
  kubectl get statefulset -n grade-submission
  # Or:
  kubectl get sts -n grade-submission
  ```

* **List Persistent Volume Claims (PVC):**
  ```bash
  kubectl get pvc -n grade-submission
  ```

* **List Persistent Volumes (PV):**
  ```bash
  kubectl get pv
  ```
