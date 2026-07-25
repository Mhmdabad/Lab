"""A small Flask app that counts visits in Redis.

Two containers (app + redis) so docker-compose has something real to orchestrate.
"""
import os
from flask import Flask, jsonify
import redis

app = Flask(__name__)

# Connection details come from the environment — the 12-factor way. In compose,
# REDIS_HOST is the service name "redis"; locally it defaults to localhost.
r = redis.Redis(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=int(os.getenv("REDIS_PORT", "6379")),
    decode_responses=True,
)


@app.get("/")
def index():
    try:
        count = r.incr("visits")
        return jsonify(message="Hello from Docker!", visits=count)
    except redis.exceptions.RedisError:
        # Degrade gracefully if Redis isn't up — the app still answers.
        return jsonify(message="Hello from Docker!", visits="redis-unavailable")


@app.get("/health")
def health():
    return jsonify(status="healthy"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
