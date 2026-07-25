"""A Flask app instrumented for all THREE pillars of observability:

  1. METRICS  -> Prometheus  (via prometheus_client, exposed at /metrics)
  2. LOGS     -> Loki        (stdout JSON, shipped by Promtail)
  3. TRACES   -> Tempo       (via OpenTelemetry OTLP -> otel-collector)

Keep this file next to requirements.txt; the Dockerfile builds it.
"""
import logging
import random
import time

from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware

# --- OpenTelemetry tracing setup ------------------------------------------
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor

# Send spans to the OpenTelemetry Collector (service name from compose).
resource = Resource.create({"service.name": "observability-demo"})
provider = TracerProvider(resource=resource)
provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="otel-collector:4317", insecure=True))
)
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)

# --- Structured logging (Promtail scrapes container stdout) ---------------
logging.basicConfig(
    level=logging.INFO,
    format='{"level":"%(levelname)s","logger":"%(name)s","msg":"%(message)s"}',
)
log = logging.getLogger("app")

app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)  # auto-create a span per request

# --- Prometheus metrics ---------------------------------------------------
REQUESTS = Counter(
    "app_requests_total", "Total HTTP requests", ["method", "endpoint", "http_status"]
)
LATENCY = Histogram(
    "app_request_latency_seconds", "Request latency in seconds", ["endpoint"]
)


@app.after_request
def record_metrics(response):
    REQUESTS.labels(request.method, request.path, response.status_code).inc()
    return response


@app.get("/")
def index():
    log.info("index handled")
    return jsonify(service="observability-demo", status="ok")


@app.get("/health")
def health():
    return jsonify(status="healthy"), 200


@app.get("/work")
def work():
    """Simulate variable-latency work so the metrics/traces are interesting."""
    with LATENCY.labels("/work").time():
        with tracer.start_as_current_span("do-work") as span:
            delay = random.uniform(0.05, 0.5)
            span.set_attribute("work.delay_seconds", delay)
            time.sleep(delay)
            log.info(f"work completed in {delay:.3f}s")
    return jsonify(done=True, took_seconds=round(delay, 3))


@app.get("/error")
def error():
    """Randomly fail so you can see error rates on the dashboard."""
    if random.random() < 0.5:
        log.error("simulated failure")
        return jsonify(error="simulated failure"), 500
    return jsonify(status="ok")


# Mount Prometheus /metrics alongside the Flask app.
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {"/metrics": make_wsgi_app()})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
