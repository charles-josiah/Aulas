#!/usr/bin/env python3
# ============================================================
# DASHBOARD / APLICACAO - aplicacao.py
# Workshop 04: Ataques de Interceptacao e Injecao de Dados em MQTT
#
# Roda DENTRO do container docker (servico "dashboard") e assina
# sensores/#. Cada leitura recebida e impressa no stdout, visivel
# via:  docker logs -f laboratorio-mqtt-dashboard
#
# E a "aplicacao industrial" que consome os dados dos sensores.
# Quando o ATACANTE injeta um payload falso (Fase 3), o aluno ve
# aqui a temperatura subir de ~22C para 99.5C.
#
# A aplicacao valida o campo "token" do JSON (confianca cega no
# dado recebido) - e exatamente isso que o atacante explora.
# ============================================================
import json
import os
import sys
import time

import paho.mqtt.client as mqtt

# --- Configuracao (via variaveis de ambiente do docker-compose) ---
BROKER = os.environ.get("MQTT_HOST", "mosquitto")
PORT = int(os.environ.get("MQTT_PORT", "1883"))
MQTT_USER = os.environ.get("MQTT_USER", "app_dashboard")
MQTT_PASS = os.environ.get("MQTT_PASS", "app_dash_2024")

# Token esperado (a "chave secreta" que a aplicacao valida)
TOKEN_ESPERADO = os.environ.get("SENSOR_TOKEN", "tok_sensor_camara1_7f3a9c")

LIMIAR_ALERTA = 40.0  # acima disso, a aplicacao dispara alerta


# --- Callbacks ----------------------------------------------------
def on_connect(client, userdata, flags, reason_code, properties=None):
    print(f"[DASHBOARD] Conectado ao broker {BROKER}:{PORT} (rc={reason_code})")
    client.subscribe("sensores/#", qos=0)
    print("[DASHBOARD] Assinando 'sensores/#' - aguardando leituras...\n")


def on_message(client, userdata, msg):
    try:
        dados = json.loads(msg.payload.decode())
        valor = dados.get("valor")
        token = dados.get("token")

        # Valida o token (aplicacao confia no dado recebido)
        if token != TOKEN_ESPERADO:
            print(f"[DASHBOARD] [ALERTA] TOKEN INVALIDO no topico '{msg.topic}': {msg.payload.decode()}")
            return

        # Valida o valor (leitura fora do normal = alerta)
        if valor is not None and float(valor) > LIMIAR_ALERTA:
            print(f"[DASHBOARD] [ALERTA] TEMPERATURA CRITICA: {valor}C no topico '{msg.topic}' - ACIONAR RESFRIAMENTO!")
        else:
            print(f"[DASHBOARD] [OK] {msg.topic}: {valor}C (token valido)")
    except Exception as e:
        print(f"[DASHBOARD] [ERRO] payload invalido em '{msg.topic}': {e}")


# --- Main ---------------------------------------------------------
def main():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect
    client.on_message = on_message
    client.username_pw_set(MQTT_USER, MQTT_PASS)

    # Retry de conexao com backoff: na primeira subida do compose, o
    # dashboard pode tentar conectar antes de o broker (e o DNS da rede
    # do compose) estarem prontos -> "Temporary failure in name
    # resolution". Sem este retry, o container cai em Restarting.
    tentativa = 1
    while True:
        try:
            client.connect(BROKER, PORT, 60)
            break
        except (ConnectionRefusedError, OSError) as e:
            print(f"[DASHBOARD] Broker indisponivel (tentativa {tentativa}): {e}. "
                  f"Tentando novamente em {min(tentativa, 5)}s...")
            time.sleep(min(tentativa, 5))
            tentativa += 1
    client.loop_forever()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
