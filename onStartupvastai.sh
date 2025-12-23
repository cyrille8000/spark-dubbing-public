#!/bin/bash

apt update 
service ssh stop
apt remove openssh-server -y
apt purge openssh-server -y
echo "🚀 [$(date)] Démarrage du script On-start de DubbingSpark..."

# Créer le répertoire de travail
WORK_DIR="/workspace/dubbingspark"
mkdir -p $WORK_DIR
cd $WORK_DIR

echo "📍 Répertoire de travail: $(pwd)"

# Télécharger et exécuter le script principal
echo "📥 Téléchargement du script principal..."
curl -sSL https://raw.githubusercontent.com/cyrille8000/spark-dubbing-public/main/entrypoint.sh -o main_script.sh

if [ -f main_script.sh ]; then
    echo "✅ Script téléchargé avec succès"
    chmod +x main_script.sh
    echo "🎯 Exécution du script principal..."
    ./main_script.sh
else
    echo "❌ Échec du téléchargement, création d'un serveur simple..."
fi