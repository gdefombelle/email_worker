# Utiliser Python 3.12 slim pour une image légère
FROM python:3.12-slim

# Installer Poetry
RUN pip install poetry

# Définir le dossier de travail
WORKDIR /app

# Copier les fichiers Poetry
COPY pyproject.toml poetry.lock ./

# Copier les packages internes
COPY ../pytune_logger /app/pytune_logger
COPY ../pytune_configuration /app/pytune_configuration

# Configurer Poetry pour utiliser les dépendances locales
RUN poetry config virtualenvs.create false
RUN poetry install --no-root --no-dev

# Copier le code source de `email_tasks`
COPY . .

# Exposer le port (si besoin)
EXPOSE 5000

# Démarrer Celery
CMD ["poetry", "run", "celery", "-A", "email_tasks", "worker", "--loglevel=info"]
