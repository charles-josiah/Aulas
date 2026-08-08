#!/bin/bash
# iniciar_servidor.sh - Script para iniciar o servidor MySQL no Docker
# Execute na MÁQUINA SERVIDOR (srvdocker01)

echo "╔═══════════════════════════════════════════════════╗"
echo "║  🧪 Laboratório MySQL - Servidor Docker           ║"
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
if [ ! -f "Dockerfile" ] || [ ! -f "docker-compose.yml" ]; then
    echo "❌ Arquivos necessários não encontrados!"
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
echo "🚀 Iniciando MySQL..."
$DOCKER_COMPOSE up -d

if [ $? -ne 0 ]; then
    echo "❌ Erro ao iniciar MySQL!"
    exit 1
fi

echo "⏳ Aguardando MySQL inicializar (pode levar ~20s)..."
for i in {1..40}; do
    sleep 1
    if docker exec laboratorio-mysql mysql -uroot -proot_secret_2024 -e "SELECT 1" &>/dev/null; then
        echo "✅ MySQL pronto!"
        break
    fi
    echo -n "."
done
echo ""

# Verificar
if docker ps | grep -q "laboratorio-mysql"; then
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║        ✅ SERVIDOR MYSQL INICIADO COM SUCESSO!    ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""

    # Obter IP do host
    HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || ipconfig getifaddr en0 2>/dev/null || echo "SEU_IP_AQUI")

    echo "🌐 Conecte via MySQL: mysql -h $HOST_IP -u dba_user -p"
    echo "   Senha: dba_secret_2024"
    echo ""
    echo "👤 Usuários criados:"
    echo "   • dba_user / dba_secret_2024   (DBA - super-usuário)"
    echo "   • app_user / app_secret_2024   (app - SELECT/INSERT/UPDATE em app_db.clientes)"
    echo "   • rel_user / rel_secret_2024   (relatórios - SELECT em app_db.clientes)"
    echo ""
    echo "📊 Banco: app_db / Tabela: clientes (5 registros)"
    echo ""
    echo "📋 Comandos úteis:"
    echo "   • Ver logs: docker logs laboratorio-mysql"
    echo "   • Parar: $DOCKER_COMPOSE down"
    echo "   • Status: docker ps"
    echo ""

    # Salvar IP em arquivo para referência
    echo "SERVER_IP=$HOST_IP" > .env
    echo "SERVER_PORT=3306" >> .env
    echo "✅ Configuração salva em .env"
    echo ""

    echo "══════════════════════════════════════════════════════════"
    echo "⚠️  AVISO: Este servidor NÃO usa TLS/SSL!"
    echo "   Senhas, queries e dados trafegam em PLAINTEXT!"
    echo "   Use apenas para fins educacionais."
    echo "══════════════════════════════════════════════════════════"
else
    echo "❌ Container não está rodando!"
    echo "Verifique os logs: docker logs laboratorio-mysql"
    exit 1
fi