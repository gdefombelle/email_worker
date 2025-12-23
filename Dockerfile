# ===============================
# Étape 1 : Build avec UV
# ===============================
FROM --platform=linux/amd64 python:3.12-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install uv

WORKDIR /app

# 👉 Copie du workspace ROOT (OBLIGATOIRE)
COPY pyproject.toml uv.lock ./

# 👉 Copie de TOUT le repo (packages + workers)
COPY src ./src

# 👉 Se placer dans le worker
WORKDIR /app/src/workers/email_worker

# 👉 Installer les deps VIA le workspace
RUN uv sync --no-dev


# ===============================
# Étape 2 : Image finale
# ===============================
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app /app

# 👉 Exécution DANS le worker
WORKDIR /app/src/workers/email_worker

# CMD ["/app/.venv/bin/celery","-A","worker","worker","-Q","email_tasks_queue,email_health_tasks_queue","--loglevel=info","-P","solo"]
CMD ["/app/.venv/bin/celery","-A","worker.email_tasks","worker","-Q","email_tasks_queue,email_health_tasks_queue","--loglevel=info","-P","solo"]