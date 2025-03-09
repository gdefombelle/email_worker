from celery import Celery
import aiosmtplib
from email.mime.text import MIMEText
from os import getenv
from pytune_configuration.sync_config_singleton import config, SimpleConfig

if config is None:
    config = SimpleConfig()

## lancemeent local celery -A email_tasks worker --loglevel=info


# Configuration de Celery
celery_app = Celery(
    "email_tasks",
    broker = config.RABBIT_BROKER_URL,
    backend = config.RABBIT_BACKEND,
)

# Configuration additionnelle
celery_app.conf.update(
    worker_pool=config.RABBIT_WORKER_POOL,
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    broker_transport_options={"visibility_timeout": config.RABBIT_VISIBILITY_TIMEOUT},
    timezone="UTC",  # Fuseau horaire
    enable_utc=True,  # Activer UTC
)

@celery_app.task(queue="email_tasks_queue")
def send_mail(to_email, subject, body, is_html=True, from_email=config.FROM_EMAIL):
    import asyncio  # Nécessaire pour exécuter une coroutine dans une fonction non-async

    async def async_send():
        try:
            # Préparer le message email
            msg = MIMEText(body, "html" if is_html else "plain")
            msg["Subject"] = subject
            msg["From"] = from_email if from_email else  config.FROM_EMAIL
            msg["To"] = to_email

            # Configuration SMTP
            smtp_server = config.SMTP_SERVER
            smtp_port = config.SMTP_SERVER_PORT
            smtp_user = config.SMTP_USER
            smtp_password = config.SMTP_PASSWORD

            # Envoi de l'email avec aiosmtplib
            response = await aiosmtplib.send(
                msg,  # Passez le message comme argument positionnel
                hostname=smtp_server,
                port=smtp_port,
                username=smtp_user,
                password=smtp_password,
                start_tls=True,
            )
            return f"Email envoyé à {to_email} avec réponse : {response}"
        except Exception as e:
            return f"Erreur lors de l'envoi de l'email : {str(e)}"

    # Exécuter la coroutine async_send dans une boucle d'événements
    return asyncio.run(async_send())


@celery_app.task(queue="email_health_tasks_queue")
def health_check():
    """
    Performs a health check for the Celery system:
    - Verifies connectivity with RabbitMQ
    - Tests the backend functionality (e.g., RPC or Redis)
    - Validates serialization and deserialization of complex data
    """
    try:
        # Retrieve the backend type
        backend_type = celery_app.conf.result_backend.split(":")[0].upper()

        # Complex object for serialization testing
        test_data = {
            "status": "test",
            "message": "This is a serialization test",
            "details": {
                "key1": 123,
                "key2": [1, 2, 3],
                "key3": {"nested_key": "nested_value"},
            },
        }

        # Store and retrieve data to test backend functionality
        celery_app.backend.store_result("test-task", test_data, "SUCCESS")
        backend_check = celery_app.backend.get_result("test-task")

        # Verify that retrieved data matches the stored data
        if backend_check != test_data:
            raise Exception("Serialization/deserialization issue detected with the backend")

        return {
            "status": "OK",
            "message": f"Celery is operational with RabbitMQ and backend: {backend_type}.",
        }
    except Exception as e:
        return {
            "status": "ERROR",
            "message": f"Health check failed: {str(e)} using backend: {backend_type}",
        }
