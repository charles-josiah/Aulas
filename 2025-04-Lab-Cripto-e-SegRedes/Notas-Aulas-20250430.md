
# Projeto Docker Compose: PHP + Apache + MariaDB + phpMyAdmin

Este projeto configura um ambiente de desenvolvimento web utilizando Docker Compose com três serviços principais:

- PHP 7.3 com Apache
- MariaDB 10.5.2
- phpMyAdmin

---

## 📦 Pré-requisitos

- Sistema baseado em Debian/Ubuntu
- Docker e Docker Compose instalados

### Instalação:
```bash
apt install docker docker-compose
systemctl enable --now docker
```

---

## 📁 Estrutura de Diretórios

Criação do diretório para os arquivos da aplicação:
```bash
mkdir -p linuxconfig/DocumentRoot
```

Dentro de `DocumentRoot`, você pode criar um `index.php` como exemplo:
```php
<?php
phpinfo();
?>
```

---

## 🐳 docker-compose.yml

```yaml
version: '3.7'

services:
  php-httpd:
    image: php:7.3-apache
    ports:
      - "80:80"
    volumes:
      - "./DocumentRoot:/var/www/html"

  mariadb:
    image: mariadb:10.5.2
    volumes:
      - mariadb-volume:/var/lib/mysql
    environment:
      TZ: "Europe/Rome"
      MYSQL_ALLOW_EMPTY_PASSWORD: "no"
      MYSQL_ROOT_PASSWORD: "rootpwd"
      MYSQL_USER: 'testuser'
      MYSQL_PASSWORD: 'testpassword'
      MYSQL_DATABASE: 'testdb'

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    links:
      - 'mariadb:db'
    ports:
      - "8081:80"

volumes:
  mariadb-volume:
```

---

## 🚀 Como Executar

Para iniciar os containers:
```bash
docker-compose up -d
```

Para visualizar os logs:
```bash
docker-compose logs -f
```

Para parar e remover os containers:
```bash
docker-compose down
```

---

## 🌐 Acessos

- Aplicação Web: [http://localhost](http://localhost)
- phpMyAdmin: [http://localhost:8081](http://localhost:8081)

---

## 🗂 Estrutura Esperada

```
.
├── docker-compose.yml
└── DocumentRoot/
    └── index.php
```

---

## 📌 Observações

- O volume `mariadb-volume` garante persistência dos dados do banco.
- O alias `db` no phpMyAdmin é usado para conectar ao container MariaDB.
