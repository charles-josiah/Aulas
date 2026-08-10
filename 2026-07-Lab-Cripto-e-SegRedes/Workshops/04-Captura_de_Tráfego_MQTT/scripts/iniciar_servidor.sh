#!/usr/bin/env bash
# ============================================================
# INICIAR_SERVIDOR.sh - Deploy do broker MQTT no srvdocker01
# Workshop 04: Ataques de Interceptacao e Injecao de Dados em MQTT
#
# Executar NA MAQUINA A (servidor com Docker), no diretorio do
# workshop. Cria o arquivo de usuarios e sobe os containers.
#
# Uso: ./iniciar_servidor.sh
# ============================================================
set -e

echo "=== [1/4] Gerando arquivo de usuarios do Mosquitto (mosquitto.passwd) ==="
# mosquitto_passwd cria o arquivo com hash das senhas (PBKDF2)
# Nota didatica: mesmo com hash no arquivo, a senha viaja em
# TEXTO CLARO no pacote CONNECT durante a autenticacao!
if [ ! -f conf/mosquitto.passwd ]; then
  docker run --rm -v "$PWD/conf:/conf" eclipse-mosquitto:2 \
    mosquitto_passwd -b -c /conf/mosquitto.passwd sensor_camara1 sensor_senha_2024
  docker run --rm -v "$PWD/conf:/conf" eclipse-mosquitto:2 \
    mosquitto_passwd -b /conf/mosquitto.passwd app_dashboard app_dash_2024
  # O arquivo e criado como root:root (o docker run roda como root).
  # O mosquitto roda como uid 1883 no container e nao consegue ler um
  # arquivo root:600 -> "Unable to open pwfile" e restart loop. Passa
  # o arquivo para o mosquitto (1883:1883, modo 600, sem warnings de
  # "world readable"/"owner is not mosquitto"). O chmod/chown manual no
  # host nao funciona - o arquivo nao e do user1:
  docker run --rm -v "$PWD/conf:/conf" alpine \
    sh -c "chown 1883:1883 /conf/mosquitto.passwd && chmod 600 /conf/mosquitto.passwd"
  echo "  -> conf/mosquitto.passwd criado com: sensor_camara1 e app_dashboard"
else
  echo "  -> conf/mosquitto.passwd ja existe, mantendo."
fi

echo ""
echo "=== [2/4] Derrubando containers antigos do lab (se houver) ==="
docker compose down --remove-orphans 2>/dev/null || true

echo ""
echo "=== [3/4] Subindo broker MQTT + dashboard ==="
docker compose up -d --build

echo ""
echo "=== [4/4] Verificando ==="
sleep 5
docker compose ps

echo ""
echo "=== Logs do dashboard (Ctrl+C para sair) ==="
echo "Dica: rode 'docker logs -f laboratorio-mqtt-dashboard' em outro terminal"
docker logs -f laboratorio-mqtt-dashboard
