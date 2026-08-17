import express from "express";
import type { Request, Response } from "express";
import winston from "winston";
// @ts-ignore
import SplunkStreamEvent from "winston-splunk-httplogger";
import dotenv from 'dotenv';

dotenv.config();

const app = express();
app.use(express.json());

const splunkStream = new SplunkStreamEvent({
  splunk: {
    token: process.env.splunkToken,
    url: process.env.splunkURL,
    index: "node_js_test",
  },
});

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    splunkStream,
  ],
});

app.post("/test", (req: Request, res: Response) => {
  const { username } = req.body;

  if (!username) {
    logger.warn("Missing username in request", {
      ip: req.ip,
      endpoint: "/test",
    });
    return res.status(400).json({ error: "Username is required" });
  }

  logger.info("User validated successfully", {
    username,
    endpoint: "/test",
  });
  return res.status(200).json({ success: true });
});

const port = 4000;
app.listen(port, () => {
  logger.info(`Server listening on port ${port}`, { port });
});