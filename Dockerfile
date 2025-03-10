# Utilisation d'une image Python 3.12.3 spécifique
FROM python:3.12.3-slim

# Définition des variables d'environnement pour éviter les tampons stdout
ENV PYTHONUNBUFFERED 1

# Installation de Poetry
RUN pip install --no-cache-dir poetry

# Définition du dossier de travail
WORKDIR /app

# Copie des fichiers nécessaires
COPY pyproject.toml poetry.lock ./

# Installation des dépendances avec Poetry
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction --no-ansi

# Copie du code source
COPY . .

# Commande pour démarrer le worker Celery
CMD ["celery", "-A", "email_tasks", "worker", "--loglevel=info"]
