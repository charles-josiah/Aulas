#!/bin/bash
# iniciar_servidor.sh - Script para iniciar o servidor no Docker
# Execute na MÁQUINA SERVIDOR

echo "╔═══════════════════════════════════════════════════╗"
echo "║  🧪 Laboratório de Segurança - Servidor Docker    ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado!"
    echo "Instale: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar Docker Compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo "❌ Docker Compose não encontrado!"
    exit 1
fi

echo "✅ Docker: $(docker --version)"
echo "✅ Docker Compose: $($DOCKER_COMPOSE --version 2>/dev/null || echo 'plugin nativo')"
echo ""

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Verificar arquivos necessários
if [ ! -f "Dockerfile" ] || [ ! -f "docker-compose.yml" ] || [ ! -f "server.py" ]; then
    echo "❌ Arquivos necessários não encontrados!"
    echo "Certifique-se de que está no diretório correto."
    exit 1
fi

# Parar container existente
echo "🧹 Limpando containers antigos..."
$DOCKER_COMPOSE down 2>/dev/null

# Construir e iniciar
echo "📦 Construindo imagem Docker..."
$DOCKER_COMPOSE build

if [ $? -ne 0 ]; then
    echo "❌ Erro ao construir imagem!"
    exit 1
fi

echo ""
echo "🚀 Iniciando servidor..."
$DOCKER_COMPOSE up -d

if [ $? -ne 0 ]; then
    echo "❌ Erro ao iniciar servidor!"
    exit 1
fi

# Aguardar inicialização
sleep 3

# Verificar se está rodando
if docker ps | grep -q "laboratorio-servidor"; then
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║           ✅ SERVIDOR INICIADO COM SUCESSO!       ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    
    # Obter IP do host
    HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || ipconfig getifaddr en0 2>/dev/null || echo "SEU_IP_AQUI")
    
    echo "🌐 Acesse no navegador: http://$HOST_IP:5000"
    echo "   Ou localmente: http://localhost:5000"
    echo ""
    echo "👤 Credenciais de teste:"
    echo "   • admin / 123456"
    echo "   • usuario / senha123"
    echo "   • aluno / senai2024"
    echo ""
    echo "📋 Comandos úteis:"
    echo "   • Ver logs: docker logs laboratorio-servidor"
    echo "   • Parar: $DOCKER_COMPOSE down"
    echo "   • Status: docker ps"
    echo ""
    
    # Salvar IP em arquivo para referência
    echo "SERVER_IP=$HOST_IP" > .env
    echo "SERVER_PORT=5000" >> .env
    echo "✅ Configuração salva em .env"
    echo ""
    
    echo "══════════════════════════════════════════════════════════"
    echo "⚠️  AVISO: Este servidor NÃO usa HTTPS!"
    echo "   Credenciais são transmitidas em PLAINTEXT!"
    echo "   Use apenas para fins educacionais."
    echo "══════════════════════════════════════════════════════════"
else
    echo "❌ Container não está rodando!"
    echo "Verifique os logs: docker logs laboratorio-servidor"
    exit 1
fi
