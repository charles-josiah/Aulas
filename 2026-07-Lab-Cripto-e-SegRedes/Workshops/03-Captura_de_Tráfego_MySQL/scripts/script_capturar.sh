#!/bin/bash
# script_capturar.sh - Script simples de captura para cliente (kali)
# Usage: ./script_capturar.sh SERVER_IP [PORT]

echo "========================================"
echo "📡 Captura de Tráfego MySQL"
echo "========================================"
echo ""

SERVER_IP=$1
SERVER_PORT=${2:-3306}

if [ -z "$SERVER_IP" ]; then
    echo "❌ Uso: ./script_capturar.sh <SERVER_IP> [PORT]"
    echo ""
    echo "Exemplo:"
    echo "  ./script_capturar.sh 192.168.1.100 3306"
    echo ""
    exit 1
fi

# Verificar tcpdump
if ! command -v tcpdump &> /dev/null; then
    echo "❌ tcpdump não encontrado!"
    exit 1
fi

read -p "📁 Nome do arquivo de saída (mysql.pcap): " CAPTURE_FILE
CAPTURE_FILE=${CAPTURE_FILE:-mysql.pcap}

echo ""
echo "Capturando tráfego MySQL para: $SERVER_IP:$SERVER_PORT"
echo "Arquivo: $CAPTURE_FILE"
echo ""
echo "Instruções:"
echo "1. Abra outro terminal e conecte: mysql -h $SERVER_IP -u dba_user -p"
echo "2. Execute comandos SQL (CREATE USER, GRANT, INSERT, SELECT...)"
echo "3. Volte aqui e pressione Ctrl+C para parar"
echo ""

sudo tcpdump -i any -s 0 -w "$CAPTURE_FILE" "host $SERVER_IP and port $SERVER_PORT"
