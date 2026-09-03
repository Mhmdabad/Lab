const express = require("express");
const client = require("prom-client");

const app = express();

app.use(express.json());

// --------------------------
// Prometheus registry
// --------------------------

const register = new client.Registry();

// Node.js process/runtime metrics
client.collectDefaultMetrics({
  register,
});

// --------------------------
// Custom metrics
// --------------------------

const httpRequests = new client.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"],
  registers: [register],
});

const httpDuration = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "HTTP request duration in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.05, 0.1, 0.3, 0.5, 1, 2, 5],
  registers: [register],
});

// --------------------------
// Metrics middleware
// --------------------------

app.use((req, res, next) => {
  // Ignore monitoring endpoints
  if (req.path === "/metrics" || req.path === "/alerts") {
    return next();
  }

  const end = httpDuration.startTimer();

  res.on("finish", () => {
    const labels = {
      method: req.method,
      route: req.route?.path || "unknown",
      status_code: String(res.statusCode),
    };

    httpRequests.inc(labels);
    end(labels);
  });

  next();
});

// --------------------------
// Normal API
// --------------------------

app.get("/api/users", (req, res) => {
  res.json([
    { id: 1, name: "John" },
    { id: 2, name: "Sarah" },
  ]);
});

// --------------------------
// Health endpoint
// --------------------------

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
  });
});

// --------------------------
// Alertmanager webhook
// --------------------------

app.post("/alerts", (req, res) => {
  console.log("\n===== ALERT RECEIVED =====");

  console.log(JSON.stringify(req.body, null, 2));

  console.log("==========================\n");

  res.sendStatus(200);
});

// --------------------------
// Prometheus metrics
// --------------------------

app.get("/metrics", async (req, res) => {
  try {
    res.set("Content-Type", register.contentType);

    res.end(await register.metrics());
  } catch (error) {
    console.error(error);

    res.status(500).end();
  }
});

// --------------------------

app.listen(3000, () => {
  console.log("Node app listening on port 3000");
});