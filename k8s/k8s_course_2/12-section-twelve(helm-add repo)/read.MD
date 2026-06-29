# Helm Repositories & Installing Remote Charts

In section 11 we created our own Helm charts locally. In this section, we use **Helm repositories** to install pre-built, community-maintained charts (like MongoDB from Bitnami) instead of writing all the YAML ourselves.

---

## 1. What is a Helm Repository?

A Helm repository is a remote server that hosts packaged Helm charts. Think of it like npm for Node.js or pip for Python — but for Kubernetes applications. Organizations like **Bitnami** publish production-ready charts for databases, caches, message brokers, etc.

---

## 2. `helm repo add` — Register a Repository

Before you can install charts from a remote repository, you must add it to your local Helm client:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

This tells Helm: *"Register a repository called `bitnami` at this URL."*

### Other Useful Repo Commands:

```bash
# List all registered repositories
helm repo list

# Pull the latest chart index from all repos
helm repo update

# Remove a repository
helm repo remove bitnami
```

---

## 3. `helm install` from a Remote Repo

Once the repo is added, you can install any chart from it using the syntax `repo-name/chart-name`:

```bash
helm install mongodb bitnami/mongodb --version 19.1.15 -f .\values.yaml -n mongodb
```

### Breaking Down the Command:

| Part | Meaning |
|------|---------|
| `helm install` | Install a new Helm release |
| `mongodb` | The **release name** (your custom name for this installation) |
| `bitnami/mongodb` | The **chart reference** (`repo-name/chart-name`) |
| `--version 19.1.15` | Pin to a specific chart version (important for reproducibility) |
| `-f .\values.yaml` | Override default chart values with your custom values file |
| `-n mongodb` | Install into the `mongodb` namespace |

---

## 4. Custom `values.yaml` for MongoDB

Instead of accepting all Bitnami defaults, we override specific settings in [values.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/12-section-twelve%28helm-add%20repo%29/mongodb/values.yaml):

```yaml
useStatefulSet: true        # Use StatefulSet instead of Deployment (data persistence)

auth:
  enabled: false            # Disable authentication (for development only)

image:
  registry: docker.io
  repository: mongo
  tag: 6.0.4-jammy          # Use a specific MongoDB version

persistence:
  mountPath: /data/db       # Where MongoDB stores its data
```

These values override the chart's built-in `values.yaml`. You only need to specify the values you want to **change** — everything else keeps its default.

---

## 5. How the API Connects to MongoDB

In [grade-submission-api/values.yaml](file:///c:/Users/97253/Desktop/Lab/k8s/k8s_course_2/12-section-twelve%28helm-add%20repo%29/grade-submission-api/values.yaml), the connection string uses Kubernetes DNS:

```yaml
secrets:
  MONGODB_URI: 'mongodb://mongodb.mongodb.svc.cluster.local:27017'
```

### DNS Breakdown:
```
mongodb.mongodb.svc.cluster.local:27017
   │       │       │        │       │
   │       │       │        │       └── MongoDB default port
   │       │       │        └── Cluster domain
   │       │       └── It's a Service
   │       └── Namespace where MongoDB is installed
   └── Service name (same as the Helm release name)
```

---

## 6. Useful Commands for Managing Remote Chart Releases

```bash
# Search for charts in a repo
helm search repo bitnami/mongodb

# See ALL configurable values for a chart (before installing)
helm show values bitnami/mongodb --version 19.1.15

# List installed releases across all namespaces
helm list -A

# Upgrade an existing release with new values
helm upgrade mongodb bitnami/mongodb --version 19.1.15 -f .\values.yaml -n mongodb

# Uninstall the release
helm uninstall mongodb -n mongodb
```
