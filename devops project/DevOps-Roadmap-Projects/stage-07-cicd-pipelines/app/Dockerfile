# Multi-stage, non-root, slim image — the artifact all three pipelines build.
FROM python:3.12-slim AS base

# Don't write .pyc files; unbuffered logs stream straight to the pipeline.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install deps first so Docker caches this layer when only code changes.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Security: run as an unprivileged user, never root (Trivy/Checkov check this).
RUN useradd --create-home --uid 10001 appuser
USER appuser

EXPOSE 8080

# Container-level healthcheck hitting the /health endpoint.
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0) if urllib.request.urlopen('http://localhost:8080/health').status==200 else sys.exit(1)"

CMD ["python", "app.py"]
