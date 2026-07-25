# Stage 09 — Monitoring & Observability

**Roadmap goals covered:**
- Prometheus + Grafana: metrics collection and dashboards
- Centralized logging: Grafana **Loki** (the roadmap's ELK alternative)
- Distributed tracing with **OpenTelemetry** — now industry standard

This is the stage the original roadmap admitted it *"mentioned in theory but never taught."*
Here it's a real, runnable stack covering all **three pillars of observability**.

---

## The three pillars

| Pillar | Question it answers | Tool here | Sent by |
|--------|--------------------|-----------|---------|
| **Metrics** | *Is it healthy? How fast? How many errors?* | Prometheus | app `/metrics` |
| **Logs** | *What exactly happened on this request?* | Loki | Promtail (from stdout) |
| **Traces** | *Where did the time go across services?* | Tempo | OpenTelemetry → Collector |

**Grafana** ties all three together in one UI.

```
                     ┌───────────── Grafana (dashboards) ─────────────┐
                     │                    :3000                        │
        metrics ─────┤ Prometheus :9090                                │
   app  logs   ──────┤ Loki :3100  ◀── Promtail ◀── docker logs        │
  :8000  traces ─────┤ Tempo :3200 ◀── OTel Collector :4317 ◀── app    │
                     └─────────────────────────────────────────────────┘
```

---

## What's here

| Path | Role |
|------|------|
| `app/` | Flask app instrumented for metrics + logs + traces |
| `prometheus/prometheus.yml` | scrape config (pulls `app:8000/metrics`) |
| `loki/` + `promtail/` | log storage + shipper |
| `tempo/` + `otel-collector/` | trace storage + OTLP pipeline |
| `grafana/provisioning/` | auto-configured datasources + dashboard loader |
| `grafana/dashboards/app-dashboard.json` | pre-built dashboard (rates, errors, p95, logs) |
| `docker-compose.yml` | starts all 7 services together |
| `generate-load.sh` | traffic generator so the graphs come alive |

---

## Run it

```bash
docker compose up --build          # start the whole stack (needs Docker running)
./generate-load.sh                 # in a 2nd terminal — generate traffic
```

Then open:

| URL | What you'll see |
|-----|-----------------|
| http://localhost:3000 | **Grafana** → dashboard "Observability Demo — App" (metrics + logs) |
| http://localhost:9090 | Prometheus — try query `rate(app_requests_total[1m])` |
| http://localhost:8000/metrics | the raw metrics the app exposes |

**See traces:** in Grafana → Explore → select **Tempo** → *Search* → run a query to
list recent traces from `/work`, and click one to see its spans.

Tear down: `docker compose down -v`.

---

## What to explore (learning path)

1. **Metrics:** in Prometheus, graph `histogram_quantile(0.95, sum by (le) (rate(app_request_latency_seconds_bucket[5m])))` — that's your p95 latency.
2. **Logs:** in Grafana Explore → Loki → `{container=~".*app.*"} |= "error"` to filter to errors only.
3. **Traces:** hit `/work` and find its trace in Tempo — see the `do-work` child span and its `work.delay_seconds` attribute.
4. **Correlate:** this is the whole point of observability — start from a spike on the
   metrics dashboard, jump to the logs at that time, then to the trace of a slow request.

## Endpoints on the app

| Endpoint | Purpose |
|----------|---------|
| `/` | simple OK response (logs a line) |
| `/work` | variable-latency work → interesting histograms + traces |
| `/error` | fails ~50% of the time → drives the error-rate panel |
| `/health` | liveness |
| `/metrics` | Prometheus scrape target |
