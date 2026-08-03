#!/bin/bash
# script_capturar.sh - Script simples de captura para cliente
# Usage: ./script_capturar.sh SERVER_IP [PORT]

echo "========================================"
echo "📡 Captura de Tráfego HTTP"
echo "========================================"
echo ""

SERVER_IP=$1
SERVER_PORT=${2:-5000}

if [ -z "$SERVER_IP" ]; then
    echo "❌ Uso: ./script_capturar.sh <SERVER_IP> [PORT]"
    echo ""
    echo "Exemplo:"
    echo "  ./script_capturar.sh 192.168.1.100 5000"
    echo ""
    exit 1
fi

# Verificar tcpdump
if ! command -v tcpdump &> /dev/null; then
    echo "❌ tcpdump não encontrado!"
    exit 1
fi

read -p "📁 Nome do arquivo de saída (traffic.pcap): " CAPTURE_FILE
CAPTURE_FILE=${CAPTURE_FILE:-traffic.pcap}

echo ""
echo "Capturando tráfego para: $SERVER_IP:$SERVER_PORT"
echo "Arquivo: $CAPTURE_FILE"
echo ""
echo "Instruções:"
echo "1. Acesse: http://$SERVER_IP:$SERVER_PORT"
echo "2. Faça login com admin / 123456"
echo "3. Pressione Ctrl+C para parar"
echo ""

sudo tcpdump -i any -s 0 -w "$CAPTURE_FILE" "host $SERVER_IP and port $SERVER_PORT"
