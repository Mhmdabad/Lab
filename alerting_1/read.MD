# Prometheus Alerting - Complete Guide

This folder contains a full alerting stack: **Prometheus** (monitoring & rules), **Alertmanager** (routing & notifications), and **Grafana** (dashboards).

---

## Folder Structure

```
alerting_1/
├── .env                        # Environment variables (API_HOST)
├── docker-compose.yml          # Defines all services
├── prometheus.template.yml     # Prometheus config template (uses ${API_HOST})
├── prometheus.yml              # Auto-generated from template (do not edit manually)
├── alert_rules.yml             # Alert rules (WHEN to fire alerts)
├── alertmanager.yml            # Alertmanager config (WHERE to send alerts)
└── read.MD                     # This file
```

---

## How It All Connects

```
 Your Server (DigitalOcean)
 ┌────────────────────────────┐
 │  Node.js API (:443/metrics)│──┐
 │  Node Exporter (:9100)     │──┤
 └────────────────────────────┘  │
                                 │ scrapes metrics every 15s
                                 ▼
                          ┌─────────────┐
                          │  Prometheus  │ ← evaluates alert_rules.yml every 15s
                          │  :6060       │
                          └──────┬──────┘
                                 │ sends FIRED alerts
                                 ▼
                         ┌──────────────┐
                         │ Alertmanager │ ← routes alerts based on alertmanager.yml
                         │ :9093        │
                         └──────┬───────┘
                                │ sends notifications
                                ▼
                    Slack / Discord / Email / Webhook
```

---

## File-by-File Explanation

---

### 1. `docker-compose.yml`

Defines 4 services:

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| `prometheus-config-init` | `busybox` | - | Replaces `${API_HOST}` in the template to generate `prometheus.yml` |
| `prometheus` | `prom/prometheus` | `6060` → `9090` | Scrapes metrics and evaluates alert rules |
| `alertmanager` | `prom/alertmanager` | `9093` → `9093` | Receives fired alerts and routes them to receivers |
| `grafana` | `grafana/grafana` | `5050` → `3000` | Visualization dashboards |

---

### 2. `prometheus.template.yml`

This is the Prometheus configuration. It has 4 main sections:

#### A. `global`
```yaml
global:
  scrape_interval: 15s        # How often to pull metrics from targets
  evaluation_interval: 15s    # How often to check alert rules
```

#### B. `alerting`
```yaml
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - "alertmanager:9093"   # Points to Alertmanager container
```
This tells Prometheus: *"When an alert fires, send it to Alertmanager at this address."*

#### C. `rule_files`
```yaml
rule_files:
  - "alert_rules.yml"    # Load our alert rules
```

#### D. `scrape_configs`
```yaml
scrape_configs:
  - job_name: "nodejs-app"      # Scrape your backend API metrics
  - job_name: "node-exporter"   # Scrape server hardware metrics
```

---

### 3. `alert_rules.yml`

This file defines **WHEN** alerts should fire. Rules are organized in **groups**.

#### Alert Lifecycle:
```
Inactive → Pending → Firing
```
- **Inactive**: The condition (`expr`) is NOT true
- **Pending**: The condition IS true, but the `for` duration hasn't passed yet
- **Firing**: The condition has been true for the full `for` duration → alert is sent to Alertmanager

#### Server Alerts (from Node Exporter):

| Alert Name | What It Detects | Threshold | Duration |
|------------|-----------------|-----------|----------|
| `HighCpuUsage` | CPU usage too high | > 85% | 5 minutes |
| `HighMemoryUsage` | Memory running out | > 85% used | 5 minutes |
| `DiskSpaceLow` | Disk filling up | > 80% full | 10 minutes |
| `ServerDown` | Server unreachable | target down | 1 minute |

#### Application Alerts (from Node.js API):

| Alert Name | What It Detects | Threshold | Duration |
|------------|-----------------|-----------|----------|
| `ApiDown` | API is unreachable | target down | 1 minute |
| `HighHttpErrorRate` | Too many 5xx errors | > 5% of requests | 5 minutes |
| `SlowApiResponse` | Slow response times | p95 > 2 seconds | 5 minutes |

#### Anatomy of a Rule:
```yaml
- alert: HighCpuUsage                    # Name of the alert
  expr: <PromQL expression> > 85         # The condition (using PromQL)
  for: 5m                               # How long the condition must be true
  labels:
    severity: warning                    # Custom label (used for routing)
  annotations:
    summary: "Short description"         # Human-readable info
    description: "Detailed message"      # Can include {{ $value }} for current metric
```

---

### 4. `alertmanager.yml`

This file defines **WHERE** and **HOW** alerts are delivered. It has 3 main sections:

#### A. Route (Routing Tree)
```yaml
route:
  group_by: ["alertname"]     # Group alerts with the same name together
  group_wait: 30s             # Wait 30s to batch alerts in the same group
  group_interval: 5m          # Wait 5m before sending updates
  repeat_interval: 4h         # Re-send same alert every 4 hours
  receiver: "default-webhook" # Default catch-all receiver

  routes:                     # Child routes (checked in order)
    - match:
        severity: critical    # If severity=critical → use critical receiver
      receiver: "critical-webhook"
```

**How routing works (like an if/else):**
```
Incoming Alert
  │
  ├─ severity == "critical"?  → Send to "critical-webhook"
  ├─ severity == "warning"?   → Send to "default-webhook"
  └─ (no match)               → Send to "default-webhook" (catch-all)
```

#### B. Receivers
```yaml
receivers:
  - name: "default-webhook"
    webhook_configs:
      - url: "http://localhost:5001/"    # Replace with real Slack/Discord webhook
        send_resolved: true             # Also notify when alert is resolved
```

#### C. Inhibition Rules
```yaml
inhibit_rules:
  - source_match:
      alertname: "ServerDown"           # IF this alert is firing...
    target_match_re:
      alertname: "HighCpuUsage|..."     # SUPPRESS these alerts
    equal: ["instance"]                 # Only if same server instance
```

**Why?** If the entire server is down, you don't also need 5 more alerts saying CPU is high, memory is high, and disk is full. You already know.

---

## Quick Start

```bash
# 1. Navigate to the folder
cd alerting_1

# 2. Start all services
docker-compose up -d

# 3. Access the UIs
#    Prometheus:    http://localhost:6060
#    Alertmanager:  http://localhost:9093
#    Grafana:       http://localhost:5050  (admin/admin)

# 4. In Grafana, add Prometheus as a data source:
#    URL: http://prometheus:9090
```

---

## Where to See Alerts

| Location | URL | What You See |
|----------|-----|--------------|
| Prometheus UI → Alerts tab | `http://localhost:6060/alerts` | All rules and their state (Inactive/Pending/Firing) |
| Alertmanager UI | `http://localhost:9093` | Currently firing alerts, silences |
| Grafana | `http://localhost:5050` | Dashboards and alert panels |
