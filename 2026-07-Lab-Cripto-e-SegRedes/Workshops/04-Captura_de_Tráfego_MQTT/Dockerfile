# ============================================================
# Dockerfile - Dashboard (aplicacao) do laboratorio MQTT
# Workshop 04: Ataques de Interceptacao e Injecao de Dados em MQTT
#
# Imagem leve (python slim) + paho-mqtt (cliente MQTT oficial)
# ============================================================
FROM python:3.11-slim

WORKDIR /app

# Cliente MQTT para Python
RUN pip install --no-cache-dir paho-mqtt==2.1.0

# Desativa o buffering do stdout (necessario para "docker logs"
# mostrar as leituras em tempo real)
ENV PYTHONUNBUFFERED=1

# Script do dashboard (aplicacao que consome as leituras dos sensores)
COPY scripts/aplicacao.py /app/aplicacao.py

CMD ["python", "/app/aplicacao.py"]
