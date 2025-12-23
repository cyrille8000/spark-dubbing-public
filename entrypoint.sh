#!/bin/bash

echo "🚀 Démarrage du serveur FastAPI personnalisé..."

# Configuration
WORK_DIR="/workspace/app"
REPO_URL="https://raw.githubusercontent.com/cyrille8000/spark-dubbing-public/main"

# Créer le répertoire de travail
mkdir -p $WORK_DIR
cd $WORK_DIR

# Télécharger les fichiers
echo "📥 Téléchargement des fichiers..."
curl -f -o server.py $REPO_URL/server.py
curl -f -o requirements.txt $REPO_URL/requirements.txt

# Installer les dépendances
echo "📦 Installation des dépendances..."
pip install -r requirements.txt

# Démarrer le serveur
echo "🎯 Démarrage du serveur..."
export HOST=0.0.0.0
export PORT=8185

which python3
python3 server.py
