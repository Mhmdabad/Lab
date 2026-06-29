# Helm

**Helm** is a package manager for Kubernetes. Instead of manually writing and applying individual YAML files (Deployment, Service, ConfigMap, Secret, etc.), Helm bundles them all into a single package called a **Chart** that can be installed, upgraded, and rolled back with one command.

---

## 1. Helm Chart Structure

A Helm chart is a folder with a specific layout:

```
grade-submission-api/            # Chart root (chart name)
├── Chart.yaml                   # Chart metadata (name, version, description)
├── values.yaml                  # Default configuration values
└── templates/                   # Kubernetes YAML templates
    ├── deployment.yaml          # Uses {{ .Values.xxx }} placeholders
    ├── service.yaml
    ├── config.yaml
    └── secret.yaml
```

### A. `Chart.yaml` — Chart Metadata
Defines the chart's identity:
```yaml
apiVersion: v2
name: grade-submission-api
description: A Helm chart for deploying the Grade Submission API
version: 1.0.1
```

### B. `values.yaml` — Default Values
Contains all the configurable parameters. These values replace the `{{ .Values.xxx }}` placeholders in the templates:
```yaml
microservice:
  name: grade-submission-api
  namespace: grade-submission
  replicas: 2

workload:
  image: rslim087/kubernetes-course-grade-submission-api:stateless-v3
  port: 3000
```

### C. `templates/` — Kubernetes Manifests with Placeholders
Instead of hardcoding values, templates use Go template syntax:
```yaml
# Before (hardcoded):
replicas: 2

# After (templated):
replicas: {{ .Values.microservice.replicas }}
```
When you run `helm install`, Helm replaces `{{ .Values.microservice.replicas }}` with `2` from `values.yaml`.

---

## 2. Essential Helm Commands

### Chart Lifecycle

```bash
# Install a chart (creates a "release")
helm install <release-name> <chart-path>
helm install grade-api ./grade-submission-api

# Install into a specific namespace
helm install grade-api ./grade-submission-api -n grade-submission

# Override values at install time
helm install grade-api ./grade-submission-api --set microservice.replicas=3

# Override values using a custom values file
helm install grade-api ./grade-submission-api -f custom-values.yaml

# Upgrade an existing release (apply changes)
helm upgrade <release-name> <chart-path>
helm upgrade grade-api ./grade-submission-api

# Uninstall a release (delete all resources)
helm uninstall <release-name>
helm uninstall grade-api
```

### Inspecting Releases

```bash
# List all installed releases
helm list
helm list -n grade-submission

# See the status of a release
helm status <release-name>

# View the release history (useful for rollbacks)
helm history <release-name>
```

### Debugging & Dry Run

```bash
# Render templates locally WITHOUT installing (see the final YAML output)
helm template <release-name> <chart-path>
helm template grade-api ./grade-submission-api

# Dry run against the cluster (validates but doesn't install)
helm install grade-api ./grade-submission-api --dry-run
```

### Rollbacks

```bash
# Roll back to a previous revision
helm rollback <release-name> <revision-number>
helm rollback grade-api 1
```

### Packaging

```bash
# Package a chart into a .tgz archive for sharing
helm package <chart-path>
helm package ./grade-submission-api
# Output: grade-submission-api-1.0.1.tgz
```

---

## 3. Overriding Values (Priority Order)

Helm merges values in this priority (highest wins):

```
1. --set flag             (highest priority)
2. -f custom-values.yaml
3. values.yaml            (lowest priority, defaults)
```

**Example:** Deploy with 5 replicas without editing `values.yaml`:
```bash
helm install grade-api ./grade-submission-api --set microservice.replicas=5
```

---

## 4. Why Use Helm?

| Without Helm | With Helm |
|-------------|-----------|
| Apply 4+ YAML files manually per microservice | `helm install` deploys everything at once |
| Copy-paste YAML for each environment (dev/staging/prod) | Use different `values.yaml` per environment |
| No easy rollback | `helm rollback` reverts to any previous version |
| Hard to share configurations | Package as `.tgz` and share or publish to a chart repo |
