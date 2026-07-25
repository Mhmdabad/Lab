"""A tiny Flask API — the thing our three pipelines build, test, and deploy.

Deliberately small so the focus stays on the pipeline, not the app.
"""
from flask import Flask, jsonify

app = Flask(__name__)


def add(a: int, b: int) -> int:
    """Pure function so we have something meaningful to unit-test."""
    return a + b


@app.get("/")
def index():
    return jsonify(service="devops-roadmap-stage-07", status="ok")


@app.get("/health")
def health():
    # CI/CD & Kubernetes probes hit this.
    return jsonify(status="healthy"), 200


@app.get("/add/<int:a>/<int:b>")
def add_route(a: int, b: int):
    return jsonify(result=add(a, b))


if __name__ == "__main__":
    # 0.0.0.0 so it's reachable from outside the container.
    app.run(host="0.0.0.0", port=8080)
