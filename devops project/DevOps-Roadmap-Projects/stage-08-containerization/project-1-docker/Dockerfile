# CONCEPT: Dockerfile + images + layers.
# Multi-stage build so the final image contains only what runtime needs.

# ---- Stage 1: builder — install deps into a wheel cache -------------------
FROM python:3.12-slim AS builder
WORKDIR /build
COPY app/requirements.txt .
# Build wheels so the final stage installs without a compiler present.
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# ---- Stage 2: runtime — small, clean, non-root ---------------------------
FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    REDIS_HOST=redis

WORKDIR /app

# Copy pre-built wheels from the builder stage and install offline.
COPY --from=builder /wheels /wheels
COPY app/requirements.txt .
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt \
    && rm -rf /wheels

COPY app/app.py .

# Security: create and switch to a non-root user (Trivy/best practice).
RUN useradd --create-home --uid 10001 appuser
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://localhost:5000/health').status==200 else 1)"

CMD ["python", "app.py"]
