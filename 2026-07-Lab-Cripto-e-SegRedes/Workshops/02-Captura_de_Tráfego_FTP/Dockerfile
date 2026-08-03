FROM python:3.11-slim

WORKDIR /app

# Criar o diretório FTP com arquivos de demonstração
RUN mkdir -p /srv/ftp && \
    echo "Bem-vindo ao laboratorio FTP de seguranca!" > /srv/ftp/boas-vindas.txt && \
    echo "conteudo-secreto-do-laboratorio-ftp" > /srv/ftp/segredo.txt

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY server.py .

# Porta de controle e range passivo (canal de dados)
EXPOSE 21
EXPOSE 30000-30100

CMD ["python", "server.py"]
