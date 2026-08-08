FROM mysql:8.0

# Variáveis de ambiente para o root do MySQL
ENV MYSQL_ROOT_PASSWORD=root_secret_2024
ENV MYSQL_ROOT_HOST=%

# Copia o script de inicialização (executado automaticamente na primeira vez)
COPY init/init.sql /docker-entrypoint-initdb.d/

# Expõe a porta padrão do MySQL
EXPOSE 3306