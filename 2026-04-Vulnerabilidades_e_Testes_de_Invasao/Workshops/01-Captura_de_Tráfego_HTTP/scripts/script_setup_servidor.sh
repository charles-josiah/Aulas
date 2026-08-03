#!/bin/bash
# script_setup_servidor.sh - Configuração do Servidor Docker
# Execute este script na MÁQUINA SERVIDOR

echo "========================================"
echo "🔧 Configuração do Servidor Docker"
echo "========================================"
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado!"
    echo "Instale Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✅ Docker encontrado: $(docker --version)"
echo ""

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  docker-compose não encontrado"
    echo "Tentando usar 'docker compose' (plugin nativo)..."
    DOCKER_COMPOSE_CMD="docker compose"
else
    DOCKER_COMPOSE_CMD="docker-compose"
    echo "✅ docker-compose encontrado"
fi
echo ""

# Diretório atual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📍 Diretório: $SCRIPT_DIR"
echo ""

# Verificar arquivos
if [ ! -f "Dockerfile" ] || [ ! -f "docker-compose.yml" ] || [ ! -f "server.py" ]; then
    echo "❌ Arquivos necessários não encontrados!"
    echo "Este script deve ser executado no diretório Docker/"
    exit 1
fi

echo "✅ Arquivos encontrados"
echo ""

# Perguntar porta
read -p "🚪 Porta do servidor (padrão 5000): " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-5000}

# Perguntar nome da imagem
read -p "📦 Nome da imagem (padrão laboratorio-servidor): " IMAGE_NAME
IMAGE_NAME=${IMAGE_NAME:-laboratorio-servidor}

echo ""
echo "========================================"
echo "🚀 Construindo a imagem..."
echo "========================================"

# Construir imagem
docker build -t "$IMAGE_NAME" .

if [ $? -ne 0 ]; then
    echo "❌ Erro na construção da imagem!"
    exit 1
fi

echo ""
echo "✅ Imagem construída com sucesso"
echo ""

# Perguntar se deseja iniciar
read -p "▶️  Deseja iniciar o servidor agora? (s/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    echo "========================================"
    echo "▶️  Iniciando servidor..."
    echo "========================================"
    echo ""
    
    # Verificar se já existe container e parar
    if [ "$DOCKER_COMPOSE_CMD" = "docker-compose" ]; then
        if docker-compose ps | grep -q "$IMAGE_NAME"; then
            echo "Parando container anterior..."
            docker-compose down
        fi
    fi
    
    # Iniciar servidor
    if [ "$DOCKER_COMPOSE_CMD" = "docker-compose" ]; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Servidor iniciado!"
        echo ""
        
        # Obter IP do container
        CONTAINER_IP=$(docker inspect "$IMAGE_NAME" | grep -m1 '"IPAddress"' | sed 's/.*: "//;s/".*//')
        
        if [ -z "$CONTAINER_IP" ]; then
            CONTAINER_IP="localhost"
        fi
        
        echo "🌐 Acesse: http://$CONTAINER_IP:$SERVER_PORT"
        echo "👤 Credenciais: admin / 123456"
        echo ""
        echo "📦 Container ID: $IMAGE_NAME"
        echo "📊 Logs: docker logs $IMAGE_NAME"
        echo ""
        
        # Salvar configuração
        cat > .env << EOF
SERVER_HOST=$CONTAINER_IP
SERVER_PORT=$SERVER_PORT
EOF
        
        echo "✅ Configuração salva em .env"
    else
        echo "❌ Erro ao iniciar servidor!"
        exit 1
    fi
fi

echo ""
echo "========================================"
echo "⚙️  Configuração concluída!"
echo "========================================"
