# Documentation du module email_tasks

## Introduction
Le module `email_tasks` est une implémentation de tâches Celery permettant d'envoyer des emails de manière asynchrone et de vérifier la santé du système Celery.

## 1. Celery Client (`celery_client.py`)

Le fichier `celery_client.py` définit la classe `CeleryClient`, un client Celery simple qui expose les signatures des tâches `send_mail` et `health_check`, et vérifie la connectivité avec RabbitMQ et le backend de résultats.

### 1.1 Initialisation de Celery

Le client est initialisé avec la configuration suivante :

- **Broker** : `RABBIT_BROKER_URL`
- **Backend** : `RABBIT_BACKEND`
- **Worker Pool** : `RABBIT_WORKER_POOL`
- **Timeout des tâches** : `RABBIT_VISIBILITY_TIMEOUT`

#### Exemple d'utilisation :
```python
from pytune_helpers.celery_client import CeleryClient
celery_client = CeleryClient()
```

### 1.2 Vérification de santé (`health_check`)
La méthode `check_health()` soumet une tâche de vérification et attend le résultat.
```python
health_status = celery_client.check_health()
print(health_status)
```

### 1.3 Envoi d'un email (`send_mail`)
La méthode `send_mail` envoie un email en utilisant Celery et aiosmtplib.
```python
celery_client.send_mail.delay(
    to_email="contact@pytune.com",
    subject="Test Email",
    body="Ceci est un test",
    is_html=False,
    from_email="support@pytune.com"
)
```

## 2. Worker Celery (`email_tasks.py`)

Ce fichier contient les tâches Celery enregistrées sous le nom `email_tasks`.

### 2.1 Configuration du Worker
Le worker est configuré avec :
- **Broker** : `config.RABBIT_BROKER_URL`
- **Backend** : `config.RABBIT_BACKEND`
- **Pool de workers** : `config.RABBIT_WORKER_POOL`

### 2.2 Tâches Celery
#### Envoi d'email (`send_mail`)
```python
@celery_app.task(queue="email_tasks_queue")
def send_mail(to_email, subject, body, is_html=True, from_email=config.FROM_EMAIL):
```
- Envoie un email en utilisant `aiosmtplib`.
- Supporte le format HTML ou texte brut.
- Utilise la configuration SMTP définie dans `config`.

#### Vérification de santé (`health_check`)
```python
@celery_app.task(queue="email_health_tasks_queue")
def health_check():
```
- Vérifie la connexion avec RabbitMQ.
- Teste le backend de stockage des résultats.
- Vérifie la sérialisation/désérialisation des tâches.

## 3. Programme de test (`test_email_tasks.py`)
Le programme de test `test_email_tasks.py` permet de vérifier le bon fonctionnement du module `email_tasks`.

### 3.1 Vérification de santé
```python
celery_client = CeleryClient()
print(f"Health check: {celery_client.health_status}")
```

### 3.2 Envoi d'un email de test
```python
celery_client.send_mail.delay(
    to_email="contact@pytune.com",
    subject="Test Pytune Email Worker",
    body="Test de l'envoi d'email asynchrone avec Celery.",
    is_html=False,
    from_email="support@pytune.com"
)
```

# 4 LANCEMENT
poetry run celery -A email_tasks worker --loglevel=info


## Conclusion
Le module `email_tasks` fournit un moyen simple et efficace d'envoyer des emails de manière asynchrone en utilisant Celery, RabbitMQ et Redis. Il inclut une vérification de l'état du système pour assurer un bon fonctionnement.

