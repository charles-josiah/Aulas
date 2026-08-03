#!/bin/bash
# capturar_cliente.sh - Script para capturar tráfego na máquina cliente
# Execute na MÁQUINA CLIENTE

echo "╔═══════════════════════════════════════════════════╗"
echo "║  📡 Captura de Tráfego HTTP - Cliente              ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Verificar tcpdump
if ! command -v tcpdump &> /dev/null; then
    echo "❌ tcpdump não encontrado!"
    echo ""
    echo "Instale com:"
    echo "  Ubuntu/Debian: sudo apt-get install tcpdump"
    echo "  macOS: brew install tcpdump"
    echo "  Fedora/CentOS: sudo dnf install tcpdump"
    exit 1
fi

echo "✅ tcpdump encontrado"
echo ""

# Solicitar IP do servidor
read -p "🌐 Digite o IP do servidor Docker: " SERVER_IP

if [ -z "$SERVER_IP" ]; then
    echo "❌ IP do servidor é obrigatório!"
    exit 1
fi

read -p "🚪 Porta do servidor (padrão: 5000): " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-5000}

echo ""
echo "══════════════════════════════════════════════════════════"
echo "📋 Configuração da Captura:"
echo "══════════════════════════════════════════════════════════"
echo "Servidor: $SERVER_IP:$SERVER_PORT"
echo ""

read -p "📁 Arquivo de saída (padrão: traffic.pcap): " OUTPUT_FILE
OUTPUT_FILE=${OUTPUT_FILE:-traffic.pcap}

echo ""
echo "══════════════════════════════════════════════════════════"
echo "📖 INSTRUÇÕES:"
echo "══════════════════════════════════════════════════════════"
echo ""
echo "1. Este script vai iniciar a captura de tráfego"
echo "2. Abra um navegador e acesse: http://$SERVER_IP:$SERVER_PORT"
echo "3. Faça login com:"
echo "   • Usuário: admin"
echo "   • Senha: 123456"
echo "4. Após o login, volte aqui e pressione Ctrl+C para parar"
echo "5. O script irá mostrar as credenciais capturadas"
echo ""
echo "══════════════════════════════════════════════════════════"
echo ""

read -p "Pressione Enter para iniciar a captura..."
echo ""

echo "📡 Capturando tráfego..."
echo "📁 Arquivo: $OUTPUT_FILE"
echo "🎯 Filtro: host $SERVER_IP and port $SERVER_PORT"
echo ""
echo "⚠️  Nota: Captura em todas as interfaces (-i any)."
echo "   Se houver problemas, especifique a interface:"
echo "   Exemplo: sudo tcpdump -i eth0 -w $OUTPUT_FILE host $SERVER_IP"
echo ""
echo "Aguardando tráfego... (Pressione Ctrl+C para parar)"
echo ""

# Iniciar captura
# -i any: captura em todas as interfaces (pode não funcionar em alguns sistemas)
# Alternativa: especificar interface manualmente com -i eth0 ou -i wlan0
sudo tcpdump -i any -s 0 -w "$OUTPUT_FILE" "host $SERVER_IP and port $SERVER_PORT"

# Após captura (Ctrl+C)
echo ""
echo "══════════════════════════════════════════════════════════"
echo "✅ CAPTURA FINALIZADA!"
echo "══════════════════════════════════════════════════════════"
echo ""
echo "📁 Arquivo salvo: $OUTPUT_FILE"
echo ""

# Verificar tamanho
if [ -f "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
    echo "📦 Tamanho: $(($FILE_SIZE / 1024)) KB"
    echo ""
fi

# Perguntar se deseja analisar
read -p "🔍 Deseja analisar as credenciais capturadas agora? (s/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    echo "══════════════════════════════════════════════════════════"
    echo "🔍 ANÁLISE DO TRÁFEGO CAPTURADO"
    echo "══════════════════════════════════════════════════════════"
    echo ""
    
    echo "📊 Resumo dos pacotes:"
    echo "────────────────────────────────────────────────────────"
    sudo tcpdump -r "$OUTPUT_FILE" -n 2>/dev/null | tail -10
    echo ""
    
    echo "🔐 Dados HTTP capturados:"
    echo "────────────────────────────────────────────────────────"
    sudo tcpdump -r "$OUTPUT_FILE" -A 2>/dev/null | grep -E "POST|HTTP|username|password" | head -20
    echo ""
    
    echo "🎯 Tentando extrair credenciais:"
    echo "────────────────────────────────────────────────────────"
    CREDS=$(sudo tcpdump -r "$OUTPUT_FILE" -A 2>/dev/null | grep -o "username=[^&]*&password=[^[:space:]]*" | head -5)
    
    if [ -n "$CREDS" ]; then
        echo "✅ CREDENCIAIS ENCONTRADAS EM PLAINTEXT:"
        echo ""
        echo "$CREDS"
        echo ""
        echo "⚠️  ISTO DEMONSTRA QUE:"
        echo "   • HTTP sem HTTPS expõe todas as credenciais"
        echo "   • Qualquer pessoa na rede pode capturar"
        echo "   • É essencial usar HTTPS para proteger dados"
    else
        echo "⚠️  Nenhuma credencial em plaintext encontrada."
        echo "   Tente fazer login novamente."
    fi
    echo ""
fi

echo "══════════════════════════════════════════════════════════"
echo "📊 Para análise completa, use:"
echo "══════════════════════════════════════════════════════════"
echo "• Wireshark: wireshark $OUTPUT_FILE"
echo "• tcpdump completo: tcpdump -r $OUTPUT_FILE -X"
echo "• Filtrar POST: tcpdump -r $OUTPUT_FILE -A | grep POST"
echo ""
