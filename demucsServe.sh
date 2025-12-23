apt update -y
apt install -y unzip
apt install -y ffmpeg
    
BASE_URL="https://files.dubbingspark.com/b0e526cc7578d1e1986ae652f06fd499e22360f5/d5abd690f1c69f4a889039ddd4aa88d8"

CURRENT_USER=$(whoami)

# Cloner le repo spark-dubbing-public
git clone https://github.com/cyrille8000/spark-dubbing-public.git
cd spark-dubbing-public/mvsep/

echo "Creating necessary directories..."
mkdir -p ./models ./results
mkdir -p /.cache/torch/hub/checkpoints
mkdir -p /home/$CURRENT_USER/.cache/torch/hub/checkpoints

echo "🚀 Configuration complète de l'environnement..."

# ========== TÉLÉCHARGEMENT ET PLACEMENT DES MODÈLES ==========
echo "📥 Téléchargement des modèles..."
for part in aa ab ac; do
    echo "⬇️  models_part_$part"
    wget -q -O "models_part_$part" "$BASE_URL/models_part_$part"
    if [ $? -ne 0 ]; then
        echo "❌ Échec téléchargement models_part_$part"
        exit 1
    fi
done

echo "🔧 Reconstitution du ZIP modèles..."
cat models_part_* > models_complete.zip

# Vérifier l'intégrité du ZIP modèles
echo "🔍 Vérification ZIP modèles..."
unzip -t models_complete.zip > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ ZIP modèles corrompu"
    exit 1
fi

echo "📂 Extraction et placement des modèles..."
unzip -q models_complete.zip -d temp_models/

mkdir -p /models-cache
mkdir -p "$HOME/.cache/torch/hub/checkpoints"

echo "📍 Placement des modèles aux bons emplacements..."
if [ -f "temp_models/04573f0d-f3cf25b2.th" ]; then
    cp "temp_models/04573f0d-f3cf25b2.th" "/models-cache/"
    cp "temp_models/04573f0d-f3cf25b2.th" "./models/"
    cp "temp_models/04573f0d-f3cf25b2.th" "$HOME/.cache/torch/hub/checkpoints/"
    echo "✅ 04573f0d-f3cf25b2.th placé"
fi

for kim_model in "Kim_Vocal_2.onnx" "Kim_Inst.onnx"; do
    if [ -f "temp_models/$kim_model" ]; then
        cp "temp_models/$kim_model" "/models-cache/"
        cp "temp_models/$kim_model" "./models/"
        echo "✅ $kim_model placé"
    fi
done

for model in "f7e0c4bc-ba3fe64a.th" "d12395a8-e57c48e6.th" "92cfc3b6-ef3bcb9c.th" "955717e8-8726e21a.th" "5c90dfd2-34c22ccb.th" "75fc33f5-1941ce65.th"; do
    if [ -f "temp_models/$model" ]; then
        cp "temp_models/$model" "$HOME/.cache/torch/hub/checkpoints/"
        echo "✅ $model placé"
    fi
done

# Nettoyer les modèles temporaires
rm -f models_part_* models_complete.zip
rm -rf temp_models/

# ========== TÉLÉCHARGEMENT ET INSTALLATION DES PACKAGES PYTHON ==========
echo "📥 Détection de la version Python..."
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}{sys.version_info.minor}')")
echo "🐍 Version Python détectée: ${PYTHON_VERSION}"

# Versions supportées
SUPPORTED_VERSIONS="39 310 311 312 313"

# Vérifier si la version est supportée
if ! echo "$SUPPORTED_VERSIONS" | grep -qw "$PYTHON_VERSION"; then
    echo "⚠️  Version Python ${PYTHON_VERSION} non supportée"
    echo "📋 Versions supportées: $SUPPORTED_VERSIONS"
    echo "🔧 Installation de Python 3.10 en cours..."

    # Installer les dépendances de compilation
    apt install -y build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev \
        libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    # Télécharger et compiler Python 3.10
    cd /tmp
    wget -q https://www.python.org/ftp/python/3.10.14/Python-3.10.14.tgz
    tar -xzf Python-3.10.14.tgz
    cd Python-3.10.14
    ./configure --enable-optimizations --prefix=/usr/local
    make -j$(nproc)
    make altinstall

    # Créer les liens symboliques
    ln -sf /usr/local/bin/python3.10 /usr/bin/python3
    ln -sf /usr/local/bin/python3.10 /usr/bin/python
    ln -sf /usr/local/bin/pip3.10 /usr/bin/pip
    ln -sf /usr/local/bin/pip3.10 /usr/bin/pip3

    # Nettoyer
    cd /tmp
    rm -rf Python-3.10.14 Python-3.10.14.tgz

    # Retourner au dossier mvsep
    cd /workspace/spark-dubbing-public/mvsep 2>/dev/null || cd ~/spark-dubbing-public/mvsep 2>/dev/null || cd spark-dubbing-public/mvsep

    # Mettre à jour la version
    PYTHON_VERSION="310"
    echo "✅ Python 3.10 installé avec succès"
    python3 --version
fi

echo "📥 Téléchargement des packages Python compatibles..."
wget -q -O "packages_compatibles.zip" "$BASE_URL/packages_compatibles.zip"
if [ $? -ne 0 ]; then
    echo "❌ Échec téléchargement packages_compatibles.zip"
    exit 1
fi

echo "📥 Téléchargement des packages Python spécifiques..."
wget -q -O "packages_python${PYTHON_VERSION}.zip" "$BASE_URL/packages_python${PYTHON_VERSION}.zip"
if [ $? -ne 0 ]; then
    echo "❌ Échec téléchargement packages_python${PYTHON_VERSION}.zip"
    echo "⚠️  Version Python ${PYTHON_VERSION} non supportée"
    echo "📋 Versions supportées: $SUPPORTED_VERSIONS"
    exit 1
fi

# Vérifier l'intégrité des ZIP packages
echo "🔍 Vérification ZIP packages compatibles..."
unzip -t packages_compatibles.zip > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ ZIP packages compatibles corrompu"
    exit 1
fi

echo "🔍 Vérification ZIP packages spécifiques..."
unzip -t "packages_python${PYTHON_VERSION}.zip" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ ZIP packages spécifiques corrompu"
    exit 1
fi

echo "📦 Extraction et installation des packages Python..."

# Installation des packages compatibles (universels)
echo "🔧 Installation des packages compatibles (universels)..."
unzip -q packages_compatibles.zip
compatible_dir="temp_packages/compatible"
if [ -d "$compatible_dir" ]; then
    package_count=$(ls "$compatible_dir"/* 2>/dev/null | wc -l)
    echo "📋 $package_count packages compatibles trouvés"
    
    for package in "$compatible_dir"/*; do
        if [ -f "$package" ]; then
            package_name=$(basename "$package")
            echo "Installation de $package_name..."
            python3 -m pip install "$package" --no-deps --force-reinstall 2>/dev/null || {
                base_name=$(echo "$package_name" | cut -d'-' -f1)
                echo "⚠️  Échec pour $package_name, installation du package '$base_name' depuis PyPI..."
                python3 -m pip install "$base_name"
            }
        fi
    done
else
    echo "❌ Dossier packages compatibles introuvable"
    exit 1
fi

# Installation des packages spécifiques à la version Python
echo "🔧 Installation des packages spécifiques Python ${PYTHON_VERSION}..."
unzip -q "packages_python${PYTHON_VERSION}.zip"
python_dir="temp_packages/python${PYTHON_VERSION}"
if [ -d "$python_dir" ]; then
    package_count=$(ls "$python_dir"/* 2>/dev/null | wc -l)
    echo "📋 $package_count packages spécifiques trouvés"
    
    for package in "$python_dir"/*; do
        if [ -f "$package" ]; then
            package_name=$(basename "$package")
            echo "Installation de $package_name..."
            python3 -m pip install "$package" --no-deps --force-reinstall 2>/dev/null || {
                base_name=$(echo "$package_name" | cut -d'-' -f1)
                echo "⚠️  Échec pour $package_name, installation du package '$base_name' depuis PyPI..."
                python3 -m pip install "$base_name"
            }
        fi
    done
else
    echo "❌ Dossier packages spécifiques introuvable"
    exit 1
fi

# Installer les dépendances critiques manquantes
echo "🔧 Installation des dépendances critiques..."
python3 -m pip install scikit-learn decorator

echo "🧹 Nettoyage des fichiers temporaires..."
rm -f packages_compatibles.zip
rm -f "packages_python${PYTHON_VERSION}.zip"
rm -rf temp_packages/

echo "✅ Configuration terminée !"
echo "📁 Modèles placés dans /models-cache/ et $HOME/.cache/torch/hub/checkpoints/"
echo "🐍 Packages Python installés avec succès pour la version ${PYTHON_VERSION}"
echo "📊 Installation complète : packages universels + packages spécifiques Python ${PYTHON_VERSION}"