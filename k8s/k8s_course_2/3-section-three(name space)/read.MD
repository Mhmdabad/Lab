# Kubernetes Namespaces

A Namespace is a logical partition inside a Kubernetes cluster that helps organize and isolate resources. It allows different teams, environments, or projects to share the same physical cluster without configuration conflicts.

---

## 1. How to Create a Namespace
kubectl create namespace <namespace-name>


---

## 2. How to Link a File to a Namespace
You can deploy a Kubernetes resource configuration file to a specific namespace in two ways:

### Option A: Using the CLI Flag
Run the apply command with the `-n` (or `--namespace`) flag:
```bash
kubectl apply -f <filename.yml> -n <namespace-name>
```

### Option B: Specifying it in the YAML Metadata
Define the `namespace` directly under the `metadata` section of your resource file:
```yaml
metadata:
  name: my-resource
  namespace: <namespace-name>
```
Then deploy the file normally:
```bash
kubectl apply -f <filename.yml>
```
