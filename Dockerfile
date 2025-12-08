# ===============================
# Étape 1 : Build avec UV
# ===============================
FROM python:3.12-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install uv

WORKDIR /app

# Copier le pyproject du worker
COPY src/workers/email_worker/pyproject.toml ./pyproject.toml

# Copier les packages internes
COPY src/packages ./packages

# Copier le code du worker
COPY src/workers/email_worker ./

# Installer (sans dev)
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

CMD ["/app/.venv/bin/celery", "-A", "email_tasks", "worker", "--loglevel=info"]