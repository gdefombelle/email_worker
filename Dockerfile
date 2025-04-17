FROM python:3.12.3-slim

WORKDIR /app

# Install system deps and poetry in one layer
RUN apt-get update && apt-get install -y libpq-dev gcc && \
    pip install --no-cache-dir poetry

COPY . /app/

# Install only prod dependencies
RUN poetry install --without dev --no-root

CMD ["poetry", "run", "celery", "-A", "email_tasks", "worker", "--loglevel=info"]
