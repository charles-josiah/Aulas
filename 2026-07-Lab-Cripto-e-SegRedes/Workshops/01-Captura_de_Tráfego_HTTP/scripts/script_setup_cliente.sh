#!/bin/bash
# script_setup_cliente.sh - Configuração do Cliente para Testes
# Execute este script na MÁQUINA CLIENTE

echo "========================================"
echo "🔧 Configuração do Cliente"
echo "========================================"
echo ""

# Verificar tcpdump
if ! command -v tcpdump &> /dev/null; then
    echo "❌ tcpdump não encontrado!"
    echo ""
    echo "Instalação:"
    echo "  Ubuntu/Debian: sudo apt-get install tcpdump"
    echo "  macOS: brew install tcpdump"
    echo "  Fedora: sudo dnf install tcpdump"
    echo ""
    
    read -p "Deseja instalar tcpdump agora? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y tcpdump
        elif command -v brew &> /dev/null; then
            brew install tcpdump
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tcpdump
        else
            echo "❌ Não foi possível instalar. Instale manualmente."
            exit 1
        fi
    else
        echo "⚠️  tcpdump necessário para captura de tráfego"
    fi
fi

echo "✅ tcpdump encontrado: $(tcpdump --version | head -1)"
echo ""

# Obter IP do servidor
read -p "🌐 IP do servidor Docker: " SERVER_IP

if [ -z "$SERVER_IP" ]; then
    echo "❌ IP do servidor é obrigatório!"
    exit 1
fi

read -p "🚪 Porta do servidor (padrão 5000): " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-5000}

echo ""
echo "========================================"
echo "📝 Configuração Confirmada:"
echo "========================================"
echo "Servidor: $SERVER_IP:$SERVER_PORT"
echo ""

# Perguntar se deseja iniciar captura
read -p "📡 Deseja iniciar a captura agora? (s/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    echo "========================================"
    echo "📡 Iniciando captura de tráfego..."
    echo "========================================"
    echo ""
    echo "Instruções:"
    echo "1. Abra um navegador"
    echo "2. Acesse: http://$SERVER_IP:$SERVER_PORT"
    echo "3. Faça login com admin / 123456"
    echo "4. Pressione Ctrl+C aqui para parar a captura"
    echo ""
    
    # Perguntar onde salvar
    read -p "📁 Nome do arquivo de captura (padrão: traffic.pcap): " CAPTURE_FILE
    CAPTURE_FILE=${CAPTURE_FILE:-traffic.pcap}
    
    # Capturar
    echo ""
    echo "Capturando para: $CAPTURE_FILE"
    echo "Pressione Ctrl+C para parar..."
    echo ""
    
    sudo tcpdump -i any -s 0 -w "$CAPTURE_FILE" "host $SERVER_IP and port $SERVER_PORT"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Captura concluída!"
        echo "📁 Arquivo: $CAPTURE_FILE"
        echo ""
        
        # Perguntar se deseja analisar
        read -p "🔍 Deseja analisar agora? (s/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            echo ""
            echo "========================================"
            echo "🔍 Análise do Tráfego"
            echo "========================================"
            echo ""
            
            # Resumo
            echo "📊 Resumo:"
            tcpdump -r "$CAPTURE_FILE" 2>/dev/null | tail -5
            echo ""
            
            # Buscar credenciais
            echo "🔐 Credenciais capturadas (se houver):"
            tcpdump -r "$CAPTURE_FILE" -A 2>/dev/null | grep -E "username=|password=" || echo "Nenhuma credencial em texto claro."
            echo ""
        fi
        
        echo "✅ Pronto! Abra $CAPTURE_FILE no Wireshark para análise gráfica."
    else
        echo "⚠️  Captura interrompida."
    fi
fi

echo ""
echo "========================================"
echo "⚙️  Configuração concluída!"
echo "========================================"
