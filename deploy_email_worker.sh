#!/usr/bin/env bash
set -e

echo "🚀 PyTune – Deploy EMAIL WORKER"
echo "--------------------------------"

# Dossier du worker (là où se trouve ce script)
WORKER_DIR="$(cd "$(dirname "$0")" && pwd)"

# Racine du projet = remonter 3 niveaux : workers → src → PYTUNE-PLATFORM
PROJECT_ROOT="$(realpath "$WORKER_DIR/../../..")"

echo "📍 Racine déterminée : $PROJECT_ROOT"

if [ ! -d "$PROJECT_ROOT/src" ]; then
    echo "❌ Erreur : le dossier src/ est introuvable dans $PROJECT_ROOT"
    exit 1
fi

echo "📦 Construction Docker : pytune_email_worker"

docker build \
  -f "$WORKER_DIR/Dockerfile" \
  -t pytune_email_worker \
  "$PROJECT_ROOT"

# Vérifier si le réseau existe sinon le créer
if ! docker network inspect pytune_network >/dev/null 2>&1; then
    echo "🌐 Réseau 'pytune_network' absent → création..."
    docker network create pytune_network
else
    echo "🌐 Réseau 'pytune_network' déjà présent"
fi

echo "⛴  Arrêt ancien container (s'il existe)"
docker stop email_worker 2>/dev/null || true
docker rm   email_worker 2>/dev/null || true

echo "🟢 Démarrage container pytune_email_worker"

docker run -d \
  --name email_worker \
  --restart unless-stopped \
  --network pytune_network \
  -v /var/log/pytune:/var/log/pytune \
  pytune_email_worker

echo "🎉 Déploiement email_worker terminé"