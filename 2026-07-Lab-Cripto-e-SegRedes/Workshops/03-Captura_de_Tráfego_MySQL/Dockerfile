FROM mysql:8.0

# Variaveis de ambiente para o root do MySQL
ENV MYSQL_ROOT_PASSWORD=root_secret_2024
ENV MYSQL_ROOT_HOST=%

# Copia o script de inicializacao (executado automaticamente na primeira vez)
COPY init/init.sql /docker-entrypoint-initdb.d/

# Expoe a porta padrao do MySQL
EXPOSE 3306