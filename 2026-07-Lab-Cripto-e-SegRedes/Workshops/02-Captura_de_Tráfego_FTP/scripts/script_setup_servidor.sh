#!/bin/bash
# script_setup_servidor.sh - Script de setup do servidor FTP no Docker
# Execute na MÁQUINA SERVIDOR

echo "╔═══════════════════════════════════════════════════╗"
echo "║  🧪 Setup Servidor FTP - Laboratório de Segurança ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado!"
    echo "Instale: https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✅ Docker: $(docker --version)"
echo ""

# Criar diretório do laboratório
echo "📁 Criando /docker/laboratorio-seguranca-ftp..."
sudo mkdir -p /docker/laboratorio-seguranca-ftp
sudo chown -R "$USER":"$USER" /docker/laboratorio-seguranca-ftp

cd /docker/laboratorio-seguranca-ftp || exit 1

# Baixar arquivos do repositório (GitHub)
echo "📥 Baixando arquivos do repositório..."
BASE_URL="https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP"

for FILE in server.py requirements.txt Dockerfile docker-compose.yml; do
    echo "   → $FILE"
    curl -sfO "$BASE_URL/$FILE" || { echo "❌ Falha ao baixar $FILE"; exit 1; }
done

# Criar scripts/ e baixar scripts
mkdir -p scripts
for SCRIPT in iniciar_servidor.sh script_setup_cliente.sh script_capturar.sh; do
    echo "   → scripts/$SCRIPT"
    curl -sfO "$BASE_URL/scripts/$SCRIPT" && mv "$SCRIPT" scripts/ || { echo "❌ Falha ao baixar $SCRIPT"; exit 1; }
done
chmod +x scripts/*.sh

echo ""
echo "📄 Arquivos criados:"
ls -la
ls -la scripts/

echo ""
echo "✅ Setup do servidor concluído!"
echo "   Próximo passo: ./scripts/iniciar_servidor.sh"
