# Documentation : Dockerisation du Worker Celery (email_worker)

## Introduction
Ce document décrit étape par étape le processus de dockerisation du worker Celery `email_worker`, qui permet d'envoyer des emails de manière asynchrone en utilisant RabbitMQ et Redis.

---

## Prérequis
- Un compte **Docker Hub** configuré
- Un **repository GitHub** contenant le projet `email_worker`
- Docker installé sur la machine de développement et sur le serveur cible
- Un serveur configuré avec les services nécessaires :
  - RabbitMQ
  - Redis
  - PostgreSQL (si utilisé par l'application)

---

## Étape 1 : Préparation du Projet
### 1.1. Structure du projet
Le projet `email_worker` contient les fichiers suivants :
```
email_worker/
│   .dockerignore
│   celery_client.py
│   docker-compose.yml
│   Dockerfile
│   email_tasks.py
│   poetry.lock
│   pyproject.toml
│   README.md
│
├── docs/
│   ├── email_tasks.md
│
└── __pycache__/
```

### 1.2. Configuration de `pyproject.toml`
Vérifiez que le fichier `pyproject.toml` contient les bonnes dépendances :
```toml
[tool.poetry]
name = "email_worker"
version = "1.1.2"
description = "Dockerized - for async email sending, using RabbitMQ, Celery, and Redis"
authors = ["Gabriel de Fombelle <gabriel.de.fombelle@gmail.com>"]
license = "MIT"
readme = "README.md"
packages = [{ include = "worker" }]

[tool.poetry.dependencies]
python = "^3.12"
celery = "^5.0.5"
kombu = "^5.2.0"
pika = "^1.2.1"
aiosmtplib = "^1.1.7"
python-multipart = "^0.0.5"
pytune_helpers = { git = "https://github.com/gdefombelle/pytune_helpers.git" }
pytune_configuration = { git = "https://github.com/gdefombelle/pytune_configuration.git" }
simple_logger = { git = "https://github.com/gdefombelle/simple_logger.git" }

[tool.poetry.dev-dependencies]
pytest = "^7.2.2"
black = "^23.0.0"
isort = "^5.12.0"

[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"

[tool.poetry.scripts]
email-worker = "worker.email_worker:main"
```

---

## Étape 2 : Création du `Dockerfile`
Créer un fichier `Dockerfile` dans le répertoire racine du projet :
```dockerfile
# Étape 1 : Utiliser une image Python récente
FROM python:3.12.3-slim

# Étape 2 : Définir le dossier de travail
WORKDIR /app

# Étape 3 : Installer Poetry proprement
RUN pip install --no-cache-dir poetry

# Étape 4 : Copier le code source
COPY . /app/

# Étape 5 : Installer les dépendances
RUN apt-get update && apt-get install -y libpq-dev gcc
RUN poetry install --no-root

# Étape 6 : Définir la commande de lancement de Celery
CMD ["poetry", "run", "celery", "-A", "email_tasks", "worker", "--loglevel=info"]
```

---

## Étape 3 : Construction et Publication de l'Image Docker

### 3.1. Construction de l'image
Exécuter la commande suivante pour construire l'image Docker :
```sh
docker build -t gdefombelle/email_worker:latest .
```

### 3.2. Connexion à Docker Hub
```sh
docker login
```

### 3.3. Pousser l'image sur Docker Hub
```sh
docker push gdefombelle/email_worker:latest
```

---

## Étape 4 : Déploiement sur le Serveur
### 4.1. Connexion au Serveur
```sh
ssh user@serveur-ip
```

### 4.2. Récupération et Exécution de l'Image Docker
```sh
docker pull gdefombelle/email_worker:latest
```

### 4.3. Définition des Variables d'Environnement
Créer un fichier `.env` :
```sh
echo 'CONFIG_MANAGER_PWD=Ezpath24_
CONFIG_MANAGER_USER=config_manager
DB_HOST=127.0.0.1
DB_PORT=5432
REDIS_HOST=localhost
REDIS_URL=redis://127.0.0.1:6379
REDIS_PORT=6379
OPENSEARCH_HOST=http://127.0.0.1:9200
OPENSEARCH_PASSWORD=MyStr0ngP@ss2024!
RABBIT_BROKER_URL=pyamqp://admin:MyStr0ngP@ss2024!@localhost//
RABBIT_BACKEND=redis://127.0.0.1:6379/0' > .env
```

### 4.4. Exécution du Conteneur Docker
```sh
docker run -d --name email_worker --network host --env-file .env gdefombelle/email_worker:latest
```

### 4.5. Vérification
```sh
docker ps
```
Si tout est correct, le container `email_worker` doit être listé.

### 4.6. Consultation des logs
```sh
docker logs email_worker
```

---

## Conclusion
Vous avez maintenant un worker Celery déployé dans un conteneur Docker, capable de gérer l’envoi d’emails de manière asynchrone via RabbitMQ et Redis.

**Prochaines étapes :**
- Configurer **Docker Compose** pour automatiser le lancement des services
- Mettre en place un système de **monitoring** des tâches Celery
- Sécuriser et optimiser les configurations pour la production

🎉 **Félicitations !** 🎉

