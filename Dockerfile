# Étape 1 : Utiliser Python 3.12.3 comme base
FROM python:3.12.3-slim

# Étape 2 : Définir le dossier de travail
WORKDIR /app

# Étape 3 : Installer Poetry proprement
RUN pip install --no-cache-dir poetry

# Étape 4 : Copier tout le projet dans /app
COPY . /app/

# Étape 5 : Installer les dépendances (sans installer l’app elle-même)
# Ajout des dépendances nécessaires pour psycopg2
RUN apt-get update && apt-get install -y libpq-dev gcc
RUN poetry install --no-root

# Étape 6 : Commande finale pour exécuter Celery
CMD ["poetry", "run", "celery", "-A", "email_tasks", "worker", "--loglevel=info"]
