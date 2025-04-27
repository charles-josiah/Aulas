
# Wiki - Aulas de Redes, DHCP, Criptografia e Serviços

## 🔢 Ativando o IP Forwarding

O IP forwarding permite que um sistema Linux atue como roteador, repassando pacotes de uma interface de rede para outra. Esse procedimento é fundamental para servidores que realizam roteamento entre redes internas e externas.

### Ativação Temporária
```bash
sysctl -w net.ipv4.ip_forward=1
```
**Comentário:** Ativa o roteamento de pacotes entre interfaces imediatamente.

### Desativação Temporária
```bash
echo 0 > /proc/sys/net/ipv4/ip_forward
```
**Comentário:** Desativa o roteamento sem reboot.

### Ativação Permanente
Editar `/etc/sysctl.conf`:
```bash
vi /etc/sysctl.conf
net.ipv4.ip_forward = 1
```
**Comentário:** Deixa o roteamento ativo mesmo após reboot.

Salvar e sair (`:wq!`).

### Aplicar Mudanças
```bash
sudo sysctl -p
```
**Comentário:** Aplica as mudanças feitas no sysctl.conf.

### Visualizar Rotas
```bash
ip route show
```
**Comentário:** Mostra as rotas conhecidas no sistema.

---

## 🌐 Links úteis para Criptografia

Ferramentas para simular geração de hashes, criptografia e encoding:
- [Repositório de Aulas GitHub](https://github.com/charles-josiah/Aulas/blob/master/2024-Lab-Cripto-e-SegRedes/README.md)
- [Anycript.com](https://anycript.com/crypto)
- [MD5.cz](https://www.md5.cz/)
- [MD5Hashing.net](https://md5hashing.net/hash/md5)
- [Cryptii - AES Encryption](https://cryptii.com/pipes/aes-encryption)
- [Base64 Decode](https://www.base64decode.org/)

**Comentário:** Testes de integridade e transformação de dados.

---

## 🌐 Configurando Servidor DHCP

### Instalação
```bash
apt-get install isc-dhcp-server
```
**Comentário:** Instala o serviço DHCP.

### Configuração IPv4 (`/etc/dhcp/dhcpd.conf`)
```bash
option domain-name "intranet.faznada.lan";

subnet 172.31.234.0 netmask 255.255.255.0 {}

subnet 192.168.123.0 netmask 255.255.255.0 {
  range 192.168.123.10 192.168.123.100;
  option routers 192.168.123.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  default-lease-time 600;
  max-lease-time 7200;
}
```
**Comentário:** Define escopos de IP e configuração de rede.

### Configuração IPv6 (`/etc/dhcp/dhcpd6.conf`)
```bash
subnet6 2804:4d98:166:4c00::/64 {
  range6 2804:4d98:166:4c00::100 2804:4d98:166:4c00::200;
  option dhcp6.name-servers 2804:4d98:166:4c00::1;
}
subnet6 fd00:1234:5678:abcd::/64 {
  range6 fd00:1234:5678:abcd::100 fd00:1234:5678:abcd::200;
  option dhcp6.name-servers fd00:1234:5678:abcd::1;
}
```
**Comentário:** Configura DHCP para redes IPv6 públicas e privadas (ULA).

---

## 🔧 Instalando o Serviço de Logs

```bash
apt-get install rsyslog
```
**Comentário:** Instala e ativa o sistema de registro de logs do Linux.

---

## 🛀 Configurando Interfaces de Rede

### Método Clássico `/etc/network/interfaces`
```bash
auto lo
iface lo inet loopback

allow-hotplug enp0s3
iface enp0s3 inet dhcp

auto enp0s8
iface enp0s8 inet static
  address 192.168.123.1
  netmask 255.255.255.0
```
**Comentário:** Define IPs usando o método tradicional do Debian.

---

### Método Moderno (`Netplan`)

Arquivo `/etc/netplan/01-netcfg.yaml`:
```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: yes
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.123.1/24
      gateway4: 192.168.123.254
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```
Aplicar mudanças:
```bash
netplan apply
```
**Comentário:** Configuração moderna usada no Ubuntu 18.04+.

---

## 📣 Ping com Payload Customizado

```bash
ping -p 73616920666f7261206d616c616e64726f 192.168.123.255 -b
```
**Comentário:** Envia uma mensagem em hexadecimal ("sai fora malandro") para todos hosts da rede.

---

## 🔫 Ferramentas de Varredura de Rede

- Detectar sistemas operacionais:
```bash
nmap -O 172.30.234.0/24
```
- Scan de hosts vivos:
```bash
nmap -sP 172.30.234.0/24
```
**Comentário:** Ferramentas de auditoria de rede com `nmap`.

---

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
- **Site3** - `/var/www/html/site3` ➔ `facebooki.com`
- **Login** - `/var/www/html/login` ➔ `login.faznada.xyz`
- **phpMyAdmin** - `/usr/share/phpmyadmin` ➔ `phpmyadmin.faznada.xyz`

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
