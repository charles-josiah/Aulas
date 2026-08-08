#!/bin/bash
# script_setup_servidor.sh - Setup do servidor MySQL no Docker
# Execute na MAQUINA SERVIDOR

echo "╔═══════════════════════════════════════════════════╗"
echo "║  🧪 Setup Servidor MySQL - Laboratorio de Seguranca ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

if ! command -v docker &> /dev/null; then
    echo "❌ Docker nao encontrado!"
    exit 1
fi

echo "✅ Docker: $(docker --version)"
echo ""

echo "📁 Criando /docker/laboratorio-seguranca-mysql..."
sudo mkdir -p /docker/laboratorio-seguranca-mysql
sudo chown -R "$USER":"$USER" /docker/laboratorio-seguranca-mysql
cd /docker/laboratorio-seguranca-mysql || exit 1

echo "📥 Baixando arquivos do repositorio..."
BASE_URL="https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/03-Captura_de_Trafego_MySQL"

mkdir -p init scripts
for FILE in Dockerfile docker-compose.yml; do
    echo "   → $FILE"
    curl -sfO "$BASE_URL/$FILE" || { echo "❌ Falha ao baixar $FILE"; exit 1; }
done

echo "   → init/init.sql"
curl -sfO "$BASE_URL/init/init.sql" && mv init.sql init/
echo "   → init/comandos-dba.sql"
curl -sfO "$BASE_URL/init/comandos-dba.sql" && mv comandos-dba.sql init/

for SCRIPT in iniciar_servidor.sh script_setup_cliente.sh capturar_cliente.sh; do
    echo "   → scripts/$SCRIPT"
    curl -sfO "$BASE_URL/scripts/$SCRIPT" && mv "$SCRIPT" scripts/ || { echo "❌ Falha ao baixar $SCRIPT"; exit 1; }
done
chmod +x scripts/*.sh

echo ""
echo "✅ Setup do servidor concluido!"
echo "   Proximo passo: ./scripts/iniciar_servidor.sh"