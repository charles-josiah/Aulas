#!/bin/bash
# capturar_cliente.sh - Script de captura para o cliente (kali)
# Usage: ./capturar_cliente.sh SERVER_IP

echo "========================================"
echo "📡 Captura de Trafego MySQL"
echo "========================================"
echo ""

SERVER_IP=$1

if [ -z "$SERVER_IP" ]; then
    echo "❌ Uso: ./capturar_cliente.sh <SERVER_IP>"
    echo ""
    echo "Exemplo:"
    echo "  ./capturar_cliente.sh 192.168.1.100"
    echo ""
    exit 1
fi

# Verificar tcpdump
if ! command -v tcpdump &> /dev/null; then
    echo "❌ tcpdump nao encontrado!"
    exit 1
fi

# Verificar tshark (recomendado para extracao de queries MySQL)
if ! command -v tshark &> /dev/null; then
    echo "⚠️  tshark nao encontrado (recomendado para analise)."
    echo "   Instale: sudo apt install tshark"
fi

read -p "📁 Nome do arquivo de saida (mysql.pcap): " CAPTURE_FILE
CAPTURE_FILE=${CAPTURE_FILE:-mysql.pcap}

echo ""
echo "Capturando trafego MySQL para: $SERVER_IP:3306"
echo "Arquivo: $CAPTURE_FILE"
echo ""
echo "Instrucoes:"
echo "1. Em outro terminal: mysql -h $SERVER_IP -u dba_user -p"
echo "2. Senha: dba_secret_2024"
echo "3. Execute os comandos SQL desejados (DDL, DCL, DML)"
echo "4. Volte aqui e pressione Ctrl+C para parar"
echo ""

sudo tcpdump -i any -s 0 -w "$CAPTURE_FILE" "host $SERVER_IP and port 3306"