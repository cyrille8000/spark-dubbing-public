from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn
import os
from datetime import datetime


# Créer l'instance FastAPI
app = FastAPI(
    title="Mon Serveur Simple",
    description="Un serveur FastAPI simple pour Vast.ai",
    version="1.0.0"
)

# Modèle pour les données POST
class Message(BaseModel):
    text: str
    author: str = "Anonymous"

# Variable globale pour stocker les messages
messages = []

# Route racine
@app.get("/")
async def root():
    return {
        "message": "Bienvenue sur mon serveur FastAPI !",
        "timestamp": datetime.now().isoformat(),
        "status": "online"
    }

# Route pour obtenir tous les messages
@app.get("/messages")
async def get_messages():
    return {
        "messages": messages,
        "total": len(messages)
    }

# Route pour ajouter un message
@app.post("/messages")
async def add_message(message: Message):
    new_message = {
        "id": len(messages) + 1,
        "text": message.text,
        "author": message.author,
        "timestamp": datetime.now().isoformat()
    }
    messages.append(new_message)
    return {
        "success": True,
        "message": "Message ajouté",
        "data": new_message
    }

# Route pour obtenir un message spécifique
@app.get("/messages/{message_id}")
async def get_message(message_id: int):
    if 1 <= message_id <= len(messages):
        return messages[message_id - 1]
    return {"error": "Message non trouvé"}

# Route pour obtenir des infos système
@app.get("/info")
async def get_info():
    return {
        "server": "FastAPI",
        "python_version": "3.x",
        "host": os.getenv("HOST", "0.0.0.0"),
        "port": int(os.getenv("PORT", 8000)),
        "environment": os.getenv("ENVIRONMENT", "development")
    }

# Route de test avec paramètres
@app.get("/hello/{name}")
async def say_hello(name: str, age: int = None):
    response = {"message": f"Bonjour {name} !"}
    if age:
        response["age_info"] = f"Vous avez {age} ans"
    return response

# Route pour tester les requêtes POST
@app.post("/echo")
async def echo_data(data: dict):
    return {
        "received": data,
        "timestamp": datetime.now().isoformat(),
        "echo": "Les données ont été reçues avec succès"
    }

# Fonction principale pour démarrer le serveur
if __name__ == "__main__":
    # Configuration du serveur
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8185))
    
    print(f"🚀 Démarrage du serveur FastAPI...")
    print(f"📍 Adresse: http://{host}:{port}")
    print(f"📚 Documentation: http://{host}:{port}/docs")
    print(f"🔧 ReDoc: http://{host}:{port}/redoc")
    
    # Démarrer le serveur
    uvicorn.run(
        app,
        host=host,
        port=port,
        log_level="info"
    )
