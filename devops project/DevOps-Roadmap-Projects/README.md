# DevOps Roadmap — Hands-On Projects (Stages 6–9)

Learning projects built from the **DevOps Learning Roadmap** (Cloud Jam, improved edition),
with security tooling from the **DevSecOps Learning Roadmap** integrated throughout.

> These are **learning projects**. They are designed to be read, run, and broken.
> Every file is commented so you can understand *why*, not just *what*.

## Layout

| Stage | Topic | Projects | DevSecOps tools integrated |
|-------|-------|----------|----------------------------|
| **06** | Infrastructure as Code | Terraform + Ansible (1 project) | Checkov, tfsec, Trivy, Gitleaks |
| **07** | CI/CD Pipelines | Same pipeline × 3 tools (GitHub Actions, GitLab CI, Jenkins) | Gitleaks, Semgrep, Trivy |
| **08** | Containerization | 3 projects: Docker · Kubernetes · Helm | Trivy (image + IaC), Grype |
| **09** | Monitoring & Observability | Prometheus + Grafana + Loki + OpenTelemetry (1 project) | — |

```
DevOps-Roadmap-Projects/
├── stage-06-infrastructure-as-code/   # Terraform + Ansible + IaC scanning
├── stage-07-cicd-pipelines/           # One app, three pipeline implementations
├── stage-08-containerization/
│   ├── project-1-docker/              # Images, containers, Dockerfile, compose
│   ├── project-2-kubernetes/          # Deployments, services, namespaces, probes
│   └── project-3-helm/                # Reusable chart with values-driven config
└── stage-09-monitoring-observability/ # Metrics, logs, traces, dashboards
```

## How the DevSecOps roadmap maps in

The DevSecOps roadmap says *"you don't need every tool — Trivy alone covers steps 3, 5 and 6."*
This repo follows that advice and reuses a small set of tools across stages:

- **Gitleaks** — secret scanning (Stages 6, 7)
- **Semgrep** — SAST / static analysis (Stage 7)
- **Trivy** — dependencies (SCA), container images, and IaC misconfig (Stages 6, 7, 8)
- **Checkov / tfsec** — Terraform & Kubernetes manifest scanning (Stages 6, 8)
- **Grype** — alternative image scanner (Stage 8)

The DevSecOps "one secure pipeline" is realised in Stage 07:
`Commit → Gitleaks → Semgrep → Trivy (deps) → build → Trivy (image) → Checkov (IaC) → deploy`.

## Prerequisites

You don't need all of these — each stage's README lists exactly what it uses.

- Docker Desktop (WSL2 backend on Windows)
- Terraform ≥ 1.5, Ansible ≥ 2.15
- `kubectl` + a local cluster (kind / minikube / Docker Desktop Kubernetes)
- Helm ≥ 3.12
- Trivy, Checkov, Gitleaks, Semgrep (all free, all optional to install)

## Suggested order

Do them in numeric order — each stage assumes the concepts from the one before.
Start every stage by reading its `README.md`.
