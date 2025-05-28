# Aula Pratica - Ambientes Vulneraveis para Testes com Scanners

<hr>

## Observacoes

- Nunca utilize essas ferramentas ou ambientes em redes de terceiros sem autorizacao explicita.
- Sempre isole os ambientes vulneraveis em maquinas virtuais ou redes internas controladas.

<hr>

## Topologia proposta
<center>

![image](https://github.com/user-attachments/assets/9f3f202a-090b-4077-83f8-052decbea686)


</center>

### Topologia de Laboratorio de Seguranca - Ambiente Isolado

A topologia apresentada representa um ambiente controlado para testes de seguranca da informacao, ideal para escaneamento de vulnerabilidades e validacao de ferramentas ofensivas e defensivas.

### Componentes da Topologia

- **MS2 (Metasploitable2):** Maquina virtual com diversas falhas conhecidas, usada como alvo em testes de exploracao.
- **DVWA (Damn Vulnerable Web App):** Aplicacao web vulneravel escrita em PHP/MySQL.
- **Vulhub:** Colecao de containers Docker com CVEs especificos para exploracao.
- **Kali:** Distribuicao Linux voltada para testes de invasao e seguranca ofensiva.
- **FW (Firewall):** Componente intermediario que controla o trafego entre a rede de laboratorio e a internet.
- **Docker:** Host destinado a subir aplicações e testes via docker.
- **Nuvem (Internet):** Simbolo de conexao externa controlada.

## Vantagens da Arquitetura

- **Isolamento completo:** Alvos vulneraveis estao em rede separada, sem contato com a rede de producao.
- **Controle de trafego:** O firewall pode restringir acessos externos e simular ataques internos.
- **Facilidade de escalabilidade:** Novas VMs ou containers podem ser adicionados facilmente.
- **Ambiente seguro para testes reais:** Permite exercicios praticos com ferramentas como Nmap, Nikto, Nessus, sqlmap, etc.

## Recomendacoes Tecnicas

- Configure a rede virtual como NAT ou Host-only para evitar exposicao externa.
- Garanta que apenas o Kali tenha acesso controlado a internet.
- Utilize ferramentas como `iptables`, `ufw` ou `pfSense` para configurar o FW.


## Ditribuições e Imagens utilizadas

### 1. Metasploitable2 - Maquina Virtual Vulneravel

**Link para download:**
https://sourceforge.net/projects/metasploitable/

**Descricao:**
Distribuicao Linux projetada com diversas falhas propositalmente. Ideal para testes com Nmap, Nessus, OpenVAS, etc.

**Credenciais padrao:**
- Usuario: msfadmin
- Senha: msfadmin

**Requisitos:**
- VMware ou VirtualBox
- Alocar 1 GB de RAM e pelo menos 10 GB de disco

---

### 2. DVWA - Damn Vulnerable Web Application

**Repositorio GitHub:**
https://github.com/digininja/DVWA

**Descricao:**
Aplicacao web vulneravel escrita em PHP/MySQL. Simula diversas falhas: SQL Injection, XSS, CSRF, etc.

**Passos para instalacao (Linux com Apache e MySQL):**

```bash
git clone https://github.com/digininja/DVWA.git
sudo cp -r DVWA /var/www/html/
sudo chown -R www-data:www-data /var/www/html/DVWA
sudo service apache2 start
sudo service mysql start
```

**Configuracao:**  
Edite o arquivo `config/config.inc.php` para ajustar as credenciais do MySQL.

**Banco de dados:**  
Acesse http://localhost/DVWA/setup.php e clique em "Create / Reset Database".

---

### 3. Vulhub - Ambientes Docker com CVEs

**Repositorio GitHub:**  
https://github.com/vulhub/vulhub

**Descricao:**  
Projeto com dezenas de ambientes vulneraveis prontos, usando Docker e docker-compose.

**Instalacao:**

```bash
git clone https://github.com/vulhub/vulhub.git
cd vulhub/wordpress/CVE-2019-8942
docker-compose up -d
```

**Requisitos:**  
- Docker instalado  
- Docker Compose

**Exemplo de uso:**  
Ambiente WordPress vulneravel a CVE-2019-8942 sera exposto nas portas padroes para testes com ferramentas como Nikto, Nmap, etc...

---

### 4. Kali Linux - Distribuicao para Testes de Invasao

**Site oficial:**  
https://www.kali.org/

**Descricao:**  
Distribuicao baseada em Debian voltada para profissionais de seguranca. Contem centenas de ferramentas pre-instaladas, incluindo Nmap, Nikto, Burp Suite, Metasploit, John the Ripper, e muito mais.

**Instalacao:**  
- Pode ser usada como maquina virtual, pendrive bootavel ou instalada diretamente  
- Disponivel para download em ISO, VMs pre-configuradas e imagens ARM

**Ferramentas populares no Kali:**  
- `nmap` - scanner de portas  
- `nikto` - scanner de vulnerabilidades web  
- `sqlmap` - injecao SQL automatizada  
- `burpsuite` - proxy de interceptacao para testes web  
- `wpscan` - scanner de vulnerabilidades em WordPress  
- `hydra` - ataques de forca bruta a senhas

**Comando exemplo para Nmap no Kali:**

```bash
nmap -sV -p- 192.168.0.10
```
---

# Iniciando Laboratorios

**Gravacao Youtude do deploy dos servidores**
 - Parte 1 - https://youtu.be/-lkHJ9oY3u0
 - Parte 2 - https://youtu.be/ErhBy_LBRPI

**Links com scripts para configuracoes iniciais**
 - https://github.com/charles-josiah/scriptz/blob/master/setup-router-only-for-lab.sh
 - https://github.com/charles-josiah/scriptz/blob/master/howto-install-docker-ubuntu-2404.md

**Tabela de hosts**

| Nome da VM     | IP Interno     | IP Externo     | Interface Externa | Interface Interna | CPU(s) | Memoria (MB) |
|:--------------:|:--------------:|:--------------:|:-----------------:|:-----------------:|:------:|:-------------:|
| FW - LAB       | 192.168.100.1  | DHCP           | enp2              | eth0              |   1    |    1024       |
| kali           | 192.168.100.12  | 10.0.2.15      |                   | ens3              |   2    |    4096       |
| dvwa           | 192.168.100.14  | -              | -                 | eth0              |   1    |    1024       |
| Vulhub         | 192.168.100.15  | -              | -                 | eth0              |   1    |    1024       |
| MS2            | 192.168.100.16  | -              | -                 | eth0              |   1    |    1024       |
| Docker         | 192.168.100.17  | -              | -                 | eth0              |   1    |    2048       |
| Serv-Base      | 192.168.100.18  | -              | -                 | eth0              |   1    |    2048       |



**Tabela de Redes do Virtual BOX**

| Interface de rede VBox     | Rede Interna    | Rede Externa    |
|:--------------:|:--------------:|:--------------:|
| Rede-LAB     |  X  |    |
| Bridged      |   |  X  |


## Fazendo os primeiros scans
Depois de localizar e acessar o Kali Linux e iniciar o MS2
Fazer um scan, bacana como exemplo abaixo...

### NMAP

#### O que é o Nmap?

**Nmap (Network Mapper)** é uma ferramenta de código aberto usada para descobrir hosts e serviços em uma rede. Ela realiza mapeamento de portas, identifica sistemas operacionais, versões de serviços e possiveis vulnerabilidades.

---

##### O que o Nmap pode fazer?

- Descobrir quais dispositivos estao ativos em uma rede
- Identificar portas abertas
- Descobrir servicos e suas versoes como Apache, SSH, etc.
- Identificar o sistema operacional do host
- Rodar scripts NSE para verificar vulnerabilidades conhecidas

---

##### Exemplos basicos de uso

###### 1. Scan simples de host

```bash
nmap 192.168.0.10
```
> Escaneia as 1000 portas mais comuns do host.

---

###### 2. Scan de todas as portas

```bash
nmap -p- 192.168.0.10
```
> Verifica todas as 65535 portas TCP.

---

###### 3. Descobrir versoes de servicos

```bash
nmap -sV 192.168.0.10
```
> Retorna nome e versao de cada servico nas portas abertas.

---

###### 4. Scan agressivo com SO e traceroute

```bash
nmap -A 192.168.0.10
```
> Faz detecao de sistema operacional, traceroute, versao de servicos e scripts NSE.

---

###### 5. Verificar vulnerabilidades com script

```bash
nmap --script vuln -p 21 192.168.0.10
```
> Usa o motor de scripts para verificar vulnerabilidades conhecidas no servico FTP.

---

###### 6. Verificar todos os hosts ativos em uma rede

```bash
nmap -sn 192.168.0.0/24
```
> Faz varredura de todos os 256 IPs possíveis no range 192.168.0.0/24 e retorna somente os hosts ativos.

---

###### 7. Exibir somente os IPs ativos

```bash
nmap -sn 192.168.0.0/24 | grep "Nmap scan report"
```
> Mostra apenas os IPs dos hosts ativos, eliminando o restante da saída do comando.

---

###### 8. Verificar se o host está ativo mesmo com ICMP bloqueado

```bash
nmap -Pn 192.168.0.10
```
> Usa o modo "no ping": assume que o host está ativo e tenta escanear as portas, mesmo sem resposta ao ICMP.

---

###### 9. Verificar se o host está ativo mesmo com ICMP bloqueado

```bash
nmap -Pn 192.168.0.10
```
> Usa o modo "no ping": assume que o host está ativo e tenta escanear as portas, mesmo sem resposta ao ICMP.

---

###### 10. Verificar todos os hosts e detectar seus nomes (DNS)

```bash
nmap -sP 192.168.0.10
```
> Similar ao -sn, mas também tenta resolver o nome DNS de cada IP. Útil para identificar dispositivos nomeados na rede.

---






###### Opcoes uteis

| Opcao              | Descricao                                       |
|--------------------|-------------------------------------------------|
| `-sS`              | TCP SYN scan (modo furtivo)                     |
| `-O`               | Tenta identificar o sistema operacional         |
| `-Pn`              | Ignora ping; assume que o host esta ativo       |
| `-T4`              | Acelera o escaneamento (uso comum em LAN)       |
| `-oN resultado.txt`| Salva o resultado em arquivo texto              |

---

###### Documentacao oficial

- https://nmap.org/book/
- https://nmap.org/nsedoc/





```bash
nmap -sV -p- 192.168.100.12
```
Resultado:

![image](https://github.com/user-attachments/assets/72facb9d-8ea3-4e50-b3ac-ec2c8a10d9ff)

Coisa mais linda :D :D :D 
Varias portas para testarmos forte...


