FROM python:3.11-slim

WORKDIR /app

# Instalar tcpdump (opcional, para análise no container)
RUN apt-get update && apt-get install -y tcpdump wireshark-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Criar grupo tcpdump e adicionar usuário nonroot (idempotente: o
# wireshark-common ja cria o grupo tcpdump, por isso groupadd pode falhar)
RUN groupadd -r tcpdump 2>/dev/null || true && \
    id -u tcpdump 2>/dev/null || useradd -r -g tcpdump tcpdump

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY server.py .

# Expor porta 5000
EXPOSE 5000

# Usar usuário não-root para segurança
USER tcpdump

# Comando padrão
CMD ["python", "server.py"]
