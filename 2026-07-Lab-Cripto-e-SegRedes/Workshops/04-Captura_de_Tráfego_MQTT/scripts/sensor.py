#!/usr/bin/env python3
# ============================================================
# SENSOR LEGITIMO - sensor.py
# Workshop 04: Ataques de Interceptacao e Injecao de Dados em MQTT
#
# Simula um sensor de telemetria (temperatura) que publica dados
# JSON no topico sensores/camara1/temperatura do broker MQTT.
#
# ATENCAO DIDATICA:
#   - As credenciais (usuario/senha) vao no CONNECT em TEXTO CLARO
#   - O "token" de autenticacao de aplicacao viaja DENTRO do JSON,
#     tambem em TEXTO CLARO
#   -> ambos podem ser sniffados na rede (Fase 2 do roteiro)
#
# Uso:  python3 sensor.py [IP_BROKER]
# ============================================================
import json
import os
import random
import sys
import time

import paho.mqtt.client as mqtt

# --- Configuracao -------------------------------------------------
BROKER = sys.argv[1] if len(sys.argv) > 1 else "172.30.234.55"
PORT = 1883

TOPICO = "sensores/camara1/temperatura"

# Credenciais do Mosquitto (CONNECT - vai em texto claro na rede!)
MQTT_USER = os.environ.get("SENSOR_USER", "sensor_camara1")
MQTT_PASS = os.environ.get("SENSOR_PASS", "sensor_senha_2024")

# Token de autenticacao "de aplicacao" (viaja dentro do JSON)
TOKEN = os.environ.get("SENSOR_TOKEN", "tok_sensor_camara1_7f3a9c")

INTERVALO = 5  # segundos entre publicacoes


# --- Callbacks ----------------------------------------------------
def on_connect(client, userdata, flags, reason_code, properties=None):
    print(f"[SENSOR] Conectado ao broker {BROKER}:{PORT} (rc={reason_code})")


# --- Main ---------------------------------------------------------
def main():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect
    client.username_pw_set(MQTT_USER, MQTT_PASS)
    client.connect(BROKER, PORT, 60)
    client.loop_start()

    print(f"[SENSOR] Publicando em '{TOPICO}' a cada {INTERVALO}s...")
    print("[SENSOR] Pressione Ctrl+C para parar.\n")
    try:
        while True:
            payload = {
                "sensor": "camara1",
                "metrica": "temperatura",
                "valor": round(random.uniform(20.0, 26.0), 1),  # temperatura normal
                "unidade": "C",
                "token": TOKEN,  # autenticacao de aplicacao (plaintext!)
                "timestamp": int(time.time()),
            }
            client.publish(TOPICO, json.dumps(payload), qos=0)
            print(f"[SENSOR] publicado: {json.dumps(payload)}")
            time.sleep(INTERVALO)
    except KeyboardInterrupt:
        print("\n[SENSOR] Encerrando.")
    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()
