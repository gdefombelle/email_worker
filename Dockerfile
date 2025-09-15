FROM python:3.12.3-slim

WORKDIR /app

RUN apt-get update && apt-get install -y libpq-dev gcc && \
    pip install --no-cache-dir poetry && \
    rm -rf /var/lib/apt/lists/*

# Copie d'abord les manifests pour le cache
COPY pyproject.toml poetry.lock README.md ./
RUN poetry install --without dev --no-root

# Puis le reste du code
COPY . .

# IMPORTANT : vise bien le module/variable Celery de ta nouvelle arbo
# Si ta variable s'appelle "celery_app" :

CMD ["poetry", "run", "celery", "-A", "worker.email_worker:app", "worker", "--loglevel=info"]

