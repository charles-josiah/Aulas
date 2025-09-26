## 🏠 Instalação e Configuração do NGINX

### Instalação
```bash
apt-get install nginx
```
**Comentário:** Instala servidor web para hospedar sites.

---

### Arquivo `/etc/nginx/nginx.conf`
```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
  worker_connections 768;
}

http {
  sendfile on;
  tcp_nopush on;
  types_hash_max_size 2048;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;

  access_log /var/log/nginx/access.log;
  gzip on;

  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
```
**Comentário:** Configuração básica com suporte a TLS e compressão Gzip.

---
### 🖥️ Configuração de Sites Virtuais (Virtual Hosts)
No diretório /etc/nginx/sites-enabled/ ficam as configurações específicas de cada site.

#### Exemplo de Virtual Hosts

- **Site1** - `/var/www/html/site1` ➔ `site1.faznada.xyz`
- **Site2** - `/var/www/html/site2` ➔ `site2.faznada.xyz`
- **Site3** - `/var/www/html/site3` ➔ `site2.faznada.xyz`
- **Login** - `/var/www/html/login` ➔ `login.faznada.xyz`

**Comentário:** Cada site configurado com sua `server {}` independente.

#### Exemplo de site básico
```nginx
server {
	listen 80;
	listen [::]:80;

	server_name login.faznada.xyz;

	root /var/www/html/login;

    	index login.php index.php index.html index.htm;

	location / {
	   try_files $uri $uri/ =404;
	}

        location ~ \.php$ {
           include snippets/fastcgi-php.conf;
           fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;  # For most systems, this should work
           fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
           include fastcgi_params;
        }

        location ~ /\.ht {
           deny all;
        }

}
```
- listen 80: O servidor escuta a porta 80 (HTTP).
- root /var/www/html/site1: O diretório onde estão os arquivos do site.
- server_name site1.faznada.xyz: Domínio para acessar esse site.
- index index.html index.htm: Arquivos que serão procurados como página inicial.
- location /: Define o comportamento quando um cliente acessar /, tentando servir o arquivo correspondente, ou retornando erro 404 se não existir.

---


## Etapa 2 – Criar diretórios dos sites

```bash
sudo mkdir -p /var/www/site1.faznada.xyz/public_html
sudo mkdir -p /var/www/site2.faznada.xyz/public_html
sudo mkdir -p /var/www/site3.faznada.xyz/public_html
```

Conteúdo de exemplo:

```bash
echo "<h1>Site 1</h1>" | sudo tee /var/www/site1.faznada.xyz/public_html/index.html
echo "<h1>Site 2</h1>" | sudo tee /var/www/site2.faznada.xyz/public_html/index.html
echo "<h1>Site 3</h1>" | sudo tee /var/www/site3.faznada.xyz/public_html/index.html

```

Permissões:

```bash
sudo chown -R $USER:$USER /var/www/site*
```

---

## Etapa 3 – Criar Virtual Hosts no NGINX

### site1.faznada.xyz

```bash
sudo nano /etc/nginx/sites-available/site1.faznada.xyz
```

```nginx
server {
    listen 80;
    server_name site1.faznada.xyz;
    root /var/www/site1.faznada.xyz/public_html;
    index index.html;
    location / {
        try_files $uri $uri/ =404;
    }
}
```

Repita para site2 e site3 alterando server_name e root.

---

## Etapa 4 – Ativar os sites

```bash
sudo ln -s /etc/nginx/sites-available/site1.faznada.xyz /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/site2.faznada.xyz /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/site3.faznada.xyz /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Etapa 5 – Criar site com autenticação (sem HTTPS)

### Instalar PHP e utilitários

```bash
sudo apt install php-fpm php-cli apache2-utils -y
```

### Criar site com login

```bash
sudo mkdir -p /var/www/siteauth.faznada.xyz/public_html
echo "<?php echo '<h1>Área Restrita em PHP</h1>'; ?>" | sudo tee /var/www/siteauth.faznada.xyz/public_html/index.php
sudo chown -R $USER:$USER /var/www/siteauth.faznada.xyz
```

### Criar senha local

```bash
sudo htpasswd -c /etc/nginx/.htpasswd usuario1
```

### Configurar vhost com autenticação

```bash
sudo nano /etc/nginx/sites-available/siteauth.faznada.xyz
```

```nginx
server {
    listen 80;
    server_name siteauth.faznada.xyz;

    root /var/www/siteauth.faznada.xyz/public_html;
    index index.php;

    location / {
        auth_basic "Área Restrita";
        auth_basic_user_file /etc/nginx/.htpasswd;
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

### Ativar o vhost

```bash
sudo ln -s /etc/nginx/sites-available/siteauth.faznada.xyz /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Etapa 6 – Teste: Captura de Credenciais

Acesse http://siteauth.faznada.xyz pela estação, e use o Kali Linux com tcpdump, Wireshark ou ettercap para capturar a senha em texto claro.

Resultado esperado: a senha aparece visível na rede.

---



<h5><center>
Observação: Este é um guia geral de apoio ao estudo, não um manual definitivo. As etapas devem ser adaptadas ao seu ambiente; não copie comandos sem revisão. Como o laboratório envolve captura e análise de pacotes, credenciais e comandos podem ficar expostos — execute apenas em ambiente controlado e isolado (VMs/laboratório) e com autorização por escrito. Nunca realize esses procedimentos em produção ou em redes de terceiros.
</h5></center>

:wq!