# Stage 08 · Project 2 — Kubernetes

**Roadmap goals covered:**
- Kubernetes: architecture, deployments, namespaces, pod management

**DevSecOps integrated:** Trivy config (K8s manifest misconfig scanning), Pod/container
`securityContext` hardening (non-root, read-only rootfs, dropped capabilities).

---

## Architecture in one picture

```
        kubectl ──▶  API server  ──▶  etcd (cluster state)
                        │
        ┌───────────────┼────────────────┐
   scheduler       controller-mgr     (control plane)
        │
   ┌────┴─────────── worker nodes ───────────┐
   │  kubelet + container runtime            │
   │   └─ Pod ─ Pod ─ Pod   (your containers)│
   └─────────────────────────────────────────┘

Deployment  ──manages──▶  ReplicaSet  ──manages──▶  Pods
Service     ──routes traffic to──────────────────▶  Pods (by label)
Ingress     ──routes external HTTP to───────────▶  Service
```

You declare **desired state** in YAML; Kubernetes continuously reconciles reality to match.

---

## What's here (apply in order — files are numbered)

| File | Kind | Concept |
|------|------|---------|
| `00-namespace.yaml` | Namespace | isolate everything in `roadmap-demo` |
| `01-configmap.yaml` | ConfigMap | non-secret config as env vars |
| `02-secret.yaml` | Secret | sensitive config (base64) |
| `03-deployment.yaml` | Deployment | 3 replicas, probes, resources, **securityContext** |
| `04-service.yaml` | Service | stable IP, load-balances across Pods |
| `05-hpa.yaml` | HorizontalPodAutoscaler | scale 3→10 on CPU |
| `06-ingress.yaml` | Ingress | external HTTP routing |

Uses the `nginxinc/nginx-unprivileged` image so it runs **as non-root** and needs no
registry push — it works on any local cluster.

---

## Get a local cluster (pick one)

```bash
# Docker Desktop: Settings → Kubernetes → Enable
# or kind:
kind create cluster --name roadmap
# or minikube:
minikube start
```

## Deploy & manage (essential kubectl)

```bash
kubectl apply -f manifests/                     # create everything
kubectl get all -n roadmap-demo                 # see Pods/Deployment/Service/HPA
kubectl get pods -n roadmap-demo -o wide        # pod placement
kubectl describe deploy/web -n roadmap-demo     # events, rollout status
kubectl logs -l app.kubernetes.io/name=web -n roadmap-demo

# Pod management
kubectl scale deploy/web --replicas=5 -n roadmap-demo
kubectl rollout restart deploy/web -n roadmap-demo
kubectl rollout status  deploy/web -n roadmap-demo
kubectl delete pod -l app.kubernetes.io/name=web -n roadmap-demo   # watch self-healing

# Reach the app (ClusterIP is internal)
kubectl port-forward svc/web 8080:80 -n roadmap-demo
#   → open http://localhost:8080

kubectl delete -f manifests/                    # tear down
```

---

## Scan the manifests (DevSecOps)

```bash
trivy config manifests/
```

On this project Trivy reports only **LOW/MEDIUM** informational findings:

- `KSV-0125` *untrusted registry* (MEDIUM) — expected; we pull from Docker Hub, not a
  private trusted registry. In prod you'd mirror images into your own registry.
- `KSV-0020 / KSV-0021` *UID/GID ≤ 10000* (LOW) — nginx-unprivileged runs as UID 101.

There are **no HIGH/CRITICAL** findings because the Deployment already sets
`runAsNonRoot`, `readOnlyRootFilesystem`, `allowPrivilegeEscalation: false`, drops all
capabilities, and defines resource limits — the things that matter most.

> **Learning exercise:** delete the whole `securityContext` block from the Deployment,
> re-run `trivy config manifests/`, and watch HIGH findings appear. Put it back to fix.
