#!/bin/bash
# script_capturar.sh - Script simples de captura para cliente (kali)
# Usage: ./script_capturar.sh SERVER_IP [PORT]

echo "========================================"
echo "📡 Captura de Tráfego FTP"
echo "========================================"
echo ""

SERVER_IP=$1
SERVER_PORT=${2:-21}

if [ -z "$SERVER_IP" ]; then
    echo "❌ Uso: ./script_capturar.sh <SERVER_IP> [PORT]"
    echo ""
    echo "Exemplo:"
    echo "  ./script_capturar.sh 192.168.1.100 21"
    echo ""
    exit 1
fi

# Verificar tcpdump
if ! command -v tcpdump &> /dev/null; then
    echo "❌ tcpdump não encontrado!"
    exit 1
fi

read -p "📁 Nome do arquivo de saída (ftp.pcap): " CAPTURE_FILE
CAPTURE_FILE=${CAPTURE_FILE:-ftp.pcap}

echo ""
echo "Capturando tráfego para: $SERVER_IP:$SERVER_PORT"
echo "Arquivo: $CAPTURE_FILE"
echo ""
echo "Instruções:"
echo "1. Conecte: ftp $SERVER_IP"
echo "2. Login com admin / 123456"
echo "3. Pressione Ctrl+C para parar"
echo ""

sudo tcpdump -i any -s 0 -w "$CAPTURE_FILE" "host $SERVER_IP and port $SERVER_PORT"
