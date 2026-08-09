---
title: "Workshop 02: Captura de Tráfego FTP (Senha e Comandos em Texto Claro)"
description: "Workshop prático de segurança: demonstra a captura de senha e comandos FTP em texto claro com tcpdump, Kali Linux e Docker. Aprenda por que SFTP/FTPS é essencial."
keywords: ["segurança da informação", "captura de tráfego", "tcpdump", "FTP", "SFTP", "FTPS", "Kali Linux", "Docker", "pyftpdlib", "credenciais em texto claro", "Wireshark", "segurança em redes", "SENAI"]
tags: ["seguranca-da-informacao", "captura-de-trafego", "tcpdump", "ftp", "sftp", "ftps", "kali-linux", "docker", "wireshark", "seguranca-em-redes"]
author: "Charles Alandt"
lang: "pt-BR"
layout: default
---

# Workshop 02: Captura de Tráfego FTP (Senha e Comandos em Texto Claro)

**Tags:** `segurança da informação` · `captura de tráfego` · `tcpdump` · `FTP` · `SFTP` · `FTPS` · `Kali Linux` · `Docker` · `Wireshark`

**Autor:** Charles Alandt

**Contato:** `echo "Y2hhcmxlcy5hbGFuZHRAZ21haWwuY29tCg==" | base64 -d`

**Uso e atribuição:** este material pode ser copiado, adaptado e utilizado livremente para fins educacionais, desde que a fonte e o autor sejam referenciados.

---

> [!CAUTION]
> **AVISO DE ÉTICA E RESPONSABILIDADE**
> Este conteúdo e ambiente foram elaborados exclusivamente para fins educacionais, laboratoriais e de pesquisa em ambiente controlado.
>
> **Uso estritamente proibido** em sistemas de terceiros, redes públicas ou redes de produção sem autorização formal. O uso deste material em qualquer contexto que viole normas legais, políticas corporativas ou limites do laboratório é de inteira responsabilidade do executor.
>
> **DISCLAIMER DE ESTABILIDADE E SUPORTE:**
> Este laboratório foi testado e validado pelo instrutor em ambiente real (servidor Ubuntu 26.04 + Kali Linux 2026.1). No entanto, o ecossistema de TI (versões de kernel, distribuições Linux, imagens Docker, ferramentas de rede e provedores de virtualização) evolui rapidamente.
>
> **Fique atento:**
> - A execução é permitida apenas em laboratório isolado (VM dedicada, Docker Lab, NAT/Host-Only ou rede segregada).
> - A captura de tráfego de rede deve ser realizada apenas em redes autorizadas e com consentimento dos envolvidos.
> - Ambientes de laboratório são sensíveis e dependentes de hardware, configuração de rede e versões de pacotes.
> - Falhas podem ocorrer devido a drivers, virtualização desativada (BIOS/VT-x/AMD-V), firewall local, ausência de pacotes, containers parados ou conflitos de rede.
> - **Ajustes manuais podem ser necessários** durante o processo para adequar o lab à sua máquina específica.
> - **Este material é apenas um guia de como realizar as atividades.** O passo a passo foi validado no ambiente do instrutor; o "como" pode ser melhorado e ajustes ao seu ambiente podem ser necessários para alcançar o mesmo resultado.

---

## Índice

- [1. Contexto e Objetivo da Aula](#1-contexto-e-objetivo-da-aula)
- [2. Observação Importante: CLI vs Interface Gráfica](#2-observação-importante-cli-vs-interface-gráfica)
- [3. Arquitetura do Laboratório](#3-arquitetura-do-laboratório)
- [4. Fase 1: Setup do Servidor FTP (srvdocker01)](#4-fase-1-setup-do-servidor-ftp-srvdocker01)
  - [Passo 4.1: Conectar e preparar o diretório](#passo-41-conectar-e-preparar-o-diretório)
  - [Passo 4.2: Criar o servidor FTP (sem TLS)](#passo-42-criar-o-servidor-ftp-sem-tls)
  - [Passo 4.3: Criar o Dockerfile](#passo-43-criar-o-dockerfile)
  - [Passo 4.4: Construir a imagem e iniciar o container](#passo-44-construir-a-imagem-e-iniciar-o-container)
- [5. Fase 2: Setup do Cliente (kali)](#5-fase-2-setup-do-cliente-kali)
  - [Passo 5.1: Conectar e testar conectividade](#passo-51-conectar-e-testar-conectividade)
  - [Passo 5.2: Preparar captura e sudo](#passo-52-preparar-captura-e-sudo)
- [6. Fase 3: Captura do Tráfego FTP](#6-fase-3-captura-do-tráfego-ftp)
  - [Passo 6.1: Iniciar a captura com tcpdump](#passo-61-iniciar-a-captura-com-tcpdump)
  - [Passo 6.2: Gerar tráfego com login e comandos FTP](#passo-62-gerar-tráfego-com-login-e-comandos-ftp)
  - [Passo 6.3: Parar a captura](#passo-63-parar-a-captura)
- [7. Fase 4: Análise e Extração de Credenciais e Comandos](#7-fase-4-análise-e-extração-de-credenciais-e-comandos)
  - [Passo 7.1: Resumo da captura](#passo-71-resumo-da-captura)
  - [Passo 7.2: Extrair credenciais em plaintext](#passo-72-extrair-credenciais-em-plaintext)
  - [Passo 7.3: Visualizar a conversa completa](#passo-73-visualizar-a-conversa-completa)
- [8. Lições Aprendidas: por que SFTP/FTPS importa](#8-lições-aprendidas-por-que-sftpftps-importa)
- [9. Atividade Extra: Análise da Captura no Wireshark (Anatomia do Pacote)](#9-atividade-extra-análise-da-captura-no-wireshark-anatomia-do-pacote)
- [Checklist de Validação do Aluno](#checklist-de-validação-do-aluno)
- [Troubleshooting](#troubleshooting)

---

## 1. Contexto e Objetivo da Aula

Este workshop demonstra, de forma prática e controlada, um problema clássico de segurança: o envio de **credenciais e comandos em texto claro (plaintext)** pelo protocolo **FTP** (File Transfer Protocol) sem qualquer criptografia.

O cenário simula um servidor FTP realista — baseado em `pyftpdlib` (Python) — rodando em um container Docker. Um segundo host (Kali Linux) atua como "observador de rede" e captura todo o tráfego que passa pela rede usando `tcpdump`. Ao final, **a senha e todos os comandos FTP** (USER, PASS, LIST, RETR, STOR, QUIT...) aparecem **em texto claro** na captura, exatamente como um atacante em uma rede local (ou em um Wi-Fi público) conseguiria lê-los.

Premissas do laboratório:

- Duas máquinas na mesma rede: **servidor** (srvdocker01) e **cliente/observador** (kali).
- O servidor roda um container Docker com um servidor FTP **sem TLS/FTPS**.
- O cliente captura o tráfego com `tcpdump` e analisa os pacotes.
- Todos os comandos devem ser executados e validados um a um.
- A atividade deve ocorrer somente dentro da subrede autorizada do laboratório.
- Sempre substitua exemplos como `172.30.234.55` e `172.30.234.56` pelos valores reais encontrados no seu ambiente.

Objetivos de aprendizagem:

1. Configurar um servidor FTP vulnerável em Docker com `pyftpdlib`.
2. Capturar tráfego de rede com `tcpdump`.
3. Identificar senha e comandos em texto claro em capturas FTP.
4. Entender a anatomia de duas conexões: canal de controle (porta 21) e canal de dados (portas passivas).
5. Compreender por que SFTP/FTPS (criptografia) é essencial em qualquer transferência de arquivos.

---

## 2. Observação Importante: CLI vs Interface Gráfica

Neste workshop, todos os passos são executados **via linha de comando (CLI)** com `tcpdump` e o cliente `ftp`. Essa escolha é proposital: a CLI permite documentar cada comando de forma exata e reproduzível, facilitar a criação de textos didáticos, roteiros de aula e scripts automatizados, além de funcionar em qualquer máquina Linux sem depender de interface gráfica.

No entanto, **o mesmo experimento poderia ser feito com interface gráfica**, e é importante que o aluno saiba transitar entre os dois mundos:

- **Ubuntu/Debian (Linux):** instale o Wireshark (`sudo apt install wireshark`), selecione a interface de rede, aplique o filtro `ftp`, faça login com um cliente FTP (ex.: `filezilla` ou `nautilus`) e observe os pacotes. O Wireshark mostra o comando `PASS` com a senha visível em texto claro.
- **Windows:** o `tcpdump` não existe nativamente, então o caminho natural é usar o **Wireshark para Windows** (com o driver Npcap) + um cliente FTP gráfico como o **FileZilla** para conectar no servidor. O resultado é o mesmo: o comando `PASS ftp2024` aparece no Wireshark legível.
- **macOS:** o `tcpdump` já vem com o sistema (ou instale via `brew install tcpdump`), e o Wireshark também está disponível (`brew install --cask wireshark`). No macOS é possível tanto seguir o roteiro CLI deste workshop quanto usar a interface gráfica do Wireshark com um cliente FTP.

Resumindo: **o conceito demonstrado é idêntico em todas as plataformas** — um cliente envia senha e comandos via FTP e um capturador de pacotes os lê na rede. A CLI aqui escolhida facilita a leitura da documentação, a reprodução exata dos comandos e a validação passo a passo; a GUI (Wireshark + cliente gráfico) oferece a mesma evidência com uma visualização mais amigável, ideal para apresentações em sala ou para alunos iniciantes. Se preferir, faça o workshop duas vezes: uma com CLI (como documentado) e outra com Wireshark, e compare os dois resultados.

---

## 3. Arquitetura do Laboratório

```
┌─────────────────────────────────────────────────────────────┐
│              MÁQUINA 1 - SERVIDOR (srvdocker01)              │
│  Host: Ubuntu 26.04 LTS, IP 172.30.234.55                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Docker Container: laboratorio-ftp                    │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  pyftpdlib Server (sem TLS/FTPS)                │  │  │
│  │  │  - Porta 21 (controle)                          │  │  │
│  │  │  - Portas 30000-30100 (dados, modo passivo)     │  │  │
│  │  │  - Credenciais fixas (admin/123456, ...)        │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                             │
                             │  FTP (sem criptografia)
                             │  controle: porta 21
                             │  dados: portas 30000-30100
                             ▼
┌─────────────────────────────────────────────────────────────┐
│              MÁQUINA 2 - CLIENTE (kali)                      │
│  Host: Kali Linux 2026.1, IP 172.30.234.56                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  tcpdump (captura)  +  ftp/curl (gera o tráfego)      │  │
│  │  Captura: USER admin / PASS 123456                   │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

Dados reais do ambiente validado pelo instrutor:

| Item | Valor |
|------|-------|
| Servidor | srvdocker01, Ubuntu 26.04 LTS, kernel 7.0.0-27-generic |
| Cliente | kali, Kali GNU/Linux Rolling 2026.1, kernel 6.18.12+kali-amd64 |
| IP servidor | 172.30.234.55 |
| IP cliente | 172.30.234.56 |
| Container | laboratorio-ftp |
| Porta de controle | 21 (0.0.0.0:21 → 21) |
| Portas de dados (passivo) | 30000-30100 |
| Credenciais FTP | admin/123456, labuser/ftp2024, aluno/senai2024 |

> [!NOTE]
> **Ajuste os endereços IP conforme o seu ambiente!**
> Os IPs acima (`172.30.234.55` e `172.30.234.56`) são do laboratório onde o instrutor validou o workshop. No seu ambiente os endereços serão **diferentes** — o provedor de virtualização (VirtualBox, VMware, Hyper-V, Proxmox, etc.) e o modo de rede escolhido (NAT, Host-Only, Bridge) definem a faixa de IP de cada máquina.
>
> **Como descobrir o IP de cada máquina:**
> - No servidor: `ip -brief address` (ex.: `eth0 UP 192.168.56.101/24`)
> - No cliente: `ip -brief address` (ex.: `eth0 UP 192.168.56.104/24`)
>
> **Regra prática:** ao longo de todo o workshop, substitua `172.30.234.55` pelo IP real do servidor e `172.30.234.56` pelo IP real do cliente/kali. O comando `ip a` (ou `ifconfig`) mostra os endereços de cada máquina.

---

## 4. Fase 1: Setup do Servidor FTP (srvdocker01)

### Passo 4.1: Conectar e preparar o diretório

#### Comando 1: conectar via SSH

```bash
ssh user1@172.30.234.55
```

Flags usadas:

- `user1@172.30.234.55`: usuário e endereço do servidor.
- Se usar chave SSH: `ssh -i ~/.ssh/lab-keys/id_laboratorio user1@172.30.234.55`.

Resultado esperado:

```text
Welcome to Ubuntu 26.04 LTS (GNU/Linux 7.0.0-27-generic x86_64)
user1@srvdocker01:~$
```

#### Comando 2: criar o diretório do laboratório

```bash
sudo mkdir -p /docker/laboratorio-seguranca-ftp
sudo chown -R user1:user1 /docker/laboratorio-seguranca-ftp
cd /docker/laboratorio-seguranca-ftp
```

Análise:

- `/docker` é usado como raiz dos projetos em containers no srvdocker01.
- O `chown` evita usar `sudo` em todo comando dentro do diretório.

#### Comando 3: confirmar Docker ativo

```bash
docker --version
docker ps
```

Resultado esperado:

```text
Docker version 29.4.3, build ...
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS   PORTS   NAMES
```

Análise:

- `docker ps` vazio significa que nenhum container está ativo — vamos criar o primeiro.

---

### Passo 4.2: Criar o servidor FTP (sem TLS)

Crie o arquivo `server.py` com um servidor FTP **sem qualquer criptografia**:

```bash
vi server.py
```

> **Alternativa rápida:** em vez de digitar o código, você pode baixar direto do repositório:
> `curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/server.py`
> (ou acesse o [arquivo no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/server.py))

Conteúdo:

```python
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer
import os

# Credenciais fixas para demonstração
USERS = {
    'admin': '123456',
    'labuser': 'ftp2024',
    'aluno': 'senai2024'
}

authorizer = DummyAuthorizer()
for user, senha in USERS.items():
    authorizer.add_user(user, senha, '/srv/ftp', perm='elradfmwMT')

handler = FTPHandler
handler.authorizer = authorizer
handler.banner = "Laboratorio de Seguranca - FTP SEM TLS/FTPS"

# Portas passivas (canal de dados) — modo passivo
handler.passive_ports = range(30000, 30100)

print("=" * 50)
print("Servidor FTP Laboratorio - Sem FTPS")
print("Acesse: ftp://IP_SERVIDOR:21")
print("Usuarios: admin/123456, labuser/ftp2024, aluno/senai2024")
print("ATENCAO: senha e comandos em PLAINTEXT!")
print("=" * 50)

server = FTPServer(('0.0.0.0', 21), handler)
server.serve_forever()
```

Análise:

- O servidor aceita login e transferências **sem nenhuma criptografia**.
- `perm='elradfmwMT'` concede permissões de leitura/escrita/lista/rename/etc. (detalhe didático: em produção, use a permissão mínima necessária).
- `passive_ports = range(30000, 30100)` define o **canal de dados** usado no modo passivo — vamos capturar as duas conexões (controle + dados).

Crie também o `requirements.txt`:

```bash
vi requirements.txt
```

> **Alternativa rápida:** `curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/requirements.txt` — ou veja o [arquivo no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/requirements.txt).

```text
pyftpdlib==2.0.1
```

---

### Passo 4.3: Criar o Dockerfile

```bash
vi Dockerfile
```

> **Alternativa rápida:** `curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/Dockerfile` — ou veja o [arquivo no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/Dockerfile).

```dockerfile
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
```

Análise:

- Imagem base `python:3.11-slim`: leve e suficiente.
- O container publica a porta 21 (controle) e o range 30000-30100 (dados).
- Cria dois arquivos no diretório FTP: `boas-vindas.txt` e `segredo.txt` — o aluno vai transferi-los e ver a transferência na captura.

---

### Passo 4.4: Construir a imagem e iniciar o container

#### Comando 1: construir a imagem

```bash
cd /docker/laboratorio-seguranca-ftp
docker build -t laboratorio-ftp:latest .
```

Flags usadas:

- `-t laboratorio-ftp:latest`: nome e tag da imagem.
- `.`: usa o Dockerfile do diretório atual.

Resultado esperado (últimas linhas):

```text
 => exporting to image
 => => naming to docker.io/library/laboratorio-ftp:latest
```

#### Comando 2: iniciar o container

```bash
docker run -d --name laboratorio-ftp \
  -p 21:21 \
  -p 30000-30100:30000-30100 \
  laboratorio-ftp:latest
```

Flags usadas:

- `-d`: roda em segundo plano (detached).
- `--name laboratorio-ftp`: nome do container.
- `-p 21:21`: publica a porta de controle FTP.
- `-p 30000-30100:30000-30100`: publica o range de portas do canal de dados (modo passivo).

Resultado esperado:

```text
a992afeafa79...
```

#### Comando 3: verificar que está rodando

```bash
docker ps
```

Resultado esperado:

```text
CONTAINER ID   IMAGE                 COMMAND           STATUS         PORTS                                           NAMES
a992afeafa79   laboratorio-ftp:latest  "python server.py" Up 2 minutes  0.0.0.0:21->21/tcp, 0.0.0.0:30000-30100->30000-30100/tcp   laboratorio-ftp
```

Análise:

- `0.0.0.0:21->21/tcp`: o canal de controle está acessível na rede.
- `0.0.0.0:30000-30100->30000-30100/tcp`: o canal de dados passivo está publicado.
- Confirme também os logs:

```bash
docker logs laboratorio-ftp
```

Resultado esperado:

```text
==================================================
Servidor FTP Laboratorio - Sem FTPS
Acesse: ftp://IP_SERVIDOR:21
Usuarios: admin/123456, labuser/ftp2024, aluno/senai2024
ATENCAO: senha e comandos em PLAINTEXT!
==================================================
[I 2026-08-03 08:00:00] concurrency model: async
[I 2026-08-03 08:00:00] masquerade (NAT) address: None
[I 2026-08-03 08:00:00] passive ports: 30000->30100
[I 2026-08-03 08:00:00] >>> starting FTP server on 0.0.0.0:21, pid=1 <<<
```

> **📁 Arquivos do laboratório no GitHub**
> Todos os arquivos usados nesta fase estão disponíveis no repositório para download/cópia:
>
> | Arquivo | Link |
> |---------|------|
> | `server.py` | [ver no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/server.py) |
> | `requirements.txt` | [ver no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/requirements.txt) |
> | `Dockerfile` | [ver no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/Dockerfile) |
> | `docker-compose.yml` | [ver no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/docker-compose.yml) |
> | `scripts/iniciar_servidor.sh` | [ver no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/scripts/iniciar_servidor.sh) |
> | `scripts/capturar_cliente.sh` | [ver no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/scripts/capturar_cliente.sh) |
> | `scripts/script_setup_servidor.sh` | [ver no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/scripts/script_setup_servidor.sh) |
> | `scripts/script_setup_cliente.sh` | [ver no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/scripts/script_setup_cliente.sh) |
> | `scripts/script_capturar.sh` | [ver no GitHub](https://github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/scripts/script_capturar.sh) |
>
> Dica: para baixar direto no servidor, use `curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP/<arquivo>`.

---

## 5. Fase 2: Setup do Cliente (kali)

### Passo 5.1: Conectar e testar conectividade

#### Comando 1: conectar via SSH

```bash
ssh kali@172.30.234.56
```

Resultado esperado:

```text
kali@kali:~$
```

#### Comando 2: testar conectividade com o servidor

```bash
ping -c 4 172.30.234.55
```

Flags usadas:

- `-c 4`: envia apenas 4 pacotes ICMP.

Resultado esperado (ambiente real do instrutor):

```text
PING 172.30.234.55 (172.30.234.55) 56(84) bytes of data.
64 bytes from 172.30.234.55: icmp_seq=1 ttl=64 time=1.08 ms
64 bytes from 172.30.234.55: icmp_seq=2 ttl=64 time=1.02 ms
64 bytes from 172.30.234.55: icmp_seq=3 ttl=64 time=1.15 ms
64 bytes from 172.30.234.55: icmp_seq=4 ttl=64 time=1.11 ms

--- 172.30.234.55 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
time 1004ms
rtt min/avg/max/mdev = 1.02/1.09/1.15/0.048 ms
```

Análise:

- `0% packet loss` e latência ~1 ms: máquinas vizinhas na mesma rede.

#### Comando 3: confirmar que a porta 21 está aberta

```bash
nc -zv 172.30.234.55 21
```

Flags usadas:

- `-z`: testa a porta sem enviar dados.
- `-v`: modo verboso.

Resultado esperado:

```text
Connection to 172.30.234.55 21 port [tcp/*] succeeded!
```

#### Comando 4: verificar a ferramenta de captura

```bash
tcpdump --version
```

Resultado esperado:

```text
tcpdump version 4.99.6
libpcap version 1.10.x
```

---

### Passo 5.2: Preparar captura e sudo

#### Comando 1: criar diretório de capturas

```bash
mkdir -p ~/laboratorio-capturas
cd ~/laboratorio-capturas
```

#### Comando 2: liberar tcpdump sem senha (opcional, para o laboratório)

```bash
echo "kali ALL=(ALL) NOPASSWD: /usr/bin/tcpdump" | sudo tee /etc/sudoers.d/tcpdump
sudo chmod 440 /etc/sudoers.d/tcpdump
```

Análise:

- Evita digitar senha a cada captura — conveniência didática.
- Em ambiente real, essa regra deve ser revista com cautela.

---

## 6. Fase 3: Captura do Tráfego FTP

### Passo 6.1: Iniciar a captura com tcpdump

No **kali**, dentro de `~/laboratorio-capturas`:

```bash
sudo tcpdump -i any -s 0 -w ftp.pcap "host 172.30.234.55 and (port 21 or portrange 30000-30100)"
```

Flags usadas:

- `-i any`: captura em todas as interfaces de rede.
- `-s 0`: captura o pacote inteiro (snapshot completo, sem truncar).
- `-w ftp.pcap`: grava no arquivo `ftp.pcap` (formato libpcap).
- `"host 172.30.234.55 and (port 21 or portrange 30000-30100)"`: filtro de captura — só tráfego com o servidor, no canal de controle (21) **e** no canal de dados (30000-30100).
- Se a interface específica for conhecida, use `-i eth0` no lugar de `-i any`.

Resultado esperado:

```text
tcpdump: listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
```

Análise:

- O `tcpdump` fica em espera até aparecer tráfego que case com o filtro.
- **Deixe esta janela de terminal aberta** — a captura está rodando.

---

### Passo 6.2: Gerar tráfego com login e comandos FTP

Abra um **segundo terminal** no kali e conecte no servidor FTP. Crie primeiro um arquivo para enviar (upload):

```bash
echo "Arquivo de teste enviado via FTP $(date)" > arquivo-teste.txt
```

Agora conecte com o cliente `ftp` (interativo):

```bash
ftp 172.30.234.55
```

Digite os comandos na sequência (o que você digitar será capturado):

```text
Name (172.30.234.55:kali): admin
331 Password required for admin
Password: 123456
230 User admin logged in.
ftp> ls
ftp> get segredo.txt
ftp> put arquivo-teste.txt
ftp> quit
```

Resultado esperado (trecho):

```text
Connected to 172.30.234.55.
220 Laboratorio de Seguranca - FTP SEM TLS/FTPS
331 Password required for admin
230 User admin logged in.
Remote system type is UNIX.
200 Switching to Binary mode.
227 Entering Passive Mode (172,30,234,55,117,48)
150 Here comes the directory listing
-rw-r--r--   1 root     root           27 Aug  3 08:00 boas-vindas.txt
-rw-r--r--   1 root     root           34 Aug  3 08:00 segredo.txt
226 Directory send OK
200 Switching to Binary mode.
227 Entering Passive Mode (172,30,234,55,117,50)
150 Opening data connection for segredo.txt
226 Transfer complete (34 bytes)
150 Ok to send data.
226 Transfer complete
221 Goodbye.
```

> **Alternativa automatizada (não interativa):** o mesmo fluxo pode ser reproduzido sem digitar, o que também gera a captura:
>
> ```bash
> printf "user admin\npass 123456\nls\nget segredo.txt\nput arquivo-teste.txt\nquit\n" | ftp 172.30.234.55
> ```
>
> **Alternativa com curl:** para demonstrar o mesmo problema com outra ferramenta, baixe e envie arquivos com o `curl`:
>
> ```bash
> curl -u admin:123456 ftp://172.30.234.55/segredo.txt
> curl -u admin:123456 -T arquivo-teste.txt ftp://172.30.234.55/
> ```

Análise:

- O cliente envia `USER admin` e `PASS 123456` **em texto claro** no canal de controle.
- `ls`, `get` e `put` disparam comandos `LIST`, `RETR` e `STOR` — todos visíveis na captura.
- A transferência de dados acontece no **canal de dados** (portas 30000-30100), separado do controle.

---

### Passo 6.3: Parar a captura

Volte ao terminal do `tcpdump` e pressione `Ctrl+C`.

Resultado esperado:

```text
^C
48 packets captured
48 packets received by filter
0 packets dropped by kernel
```

Análise (ambiente real do instrutor):

- `48 packets captured`: a sessão completa (login + ls + download + upload) foi registrada.
- `0 packets dropped by kernel`: nenhum pacote perdido — a evidência está completa.

---

## 7. Fase 4: Análise e Extração de Credenciais e Comandos

### Passo 7.1: Resumo da captura

```bash
sudo tcpdump -r ftp.pcap -n
```

Flags usadas:

- `-r ftp.pcap`: lê do arquivo em vez de capturar ao vivo.
- `-n`: não resolve nomes (mostra IPs e portas numéricas).

Resultado esperado (trecho):

```text
reading from file ftp.pcap, link-type LINUX_SLL2 (Linux cooked v2)
12:31:45.123456 IP 172.30.234.56.54842 > 172.30.234.55.21: Flags [P.], seq 1:12, ack 1, win 502, length 11
12:31:45.124567 IP 172.30.234.55.21 > 172.30.234.56.54842: Flags [.], ack 12, win 509, length 0
12:31:45.125678 IP 172.30.234.55.30001 > 172.30.234.56.54843: Flags [P.], seq 1:35, ack 1, win 502, length 34
...
```

Análise:

- Pacotes na porta `21` carregam os **comandos** (controle).
- Pacotes nas portas `30000-30100` carregam os **dados** (listagem, arquivos).
- Agora vamos olhar **o conteúdo** desses pacotes.

---

### Passo 7.2: Extrair credenciais em plaintext

```bash
sudo tcpdump -r ftp.pcap -A | grep -oE "(USER|PASS) [^[:space:]]+"
```

Flags usadas:

- `-A`: imprime o conteúdo ASCII dos pacotes (payload legível).
- `grep -oE`: extrai apenas o trecho que casa com o padrão.
- `(USER|PASS) [^[:space:]]+`: captura o comando + o argumento (usuário/senha).

Resultado esperado (ambiente real do instrutor):

```text
USER admin
PASS 123456
```

Análise:

- **A senha está totalmente legível** na captura de rede.
- Qualquer pessoa na mesma rede (ou em um ponto de acesso intermediário) conseguiria extraí-la da mesma forma, sem nenhum esforço adicional.
- Esta é a prova central do risco de usar FTP sem criptografia.

---

### Passo 7.3: Visualizar a conversa completa

```bash
sudo tcpdump -r ftp.pcap -A | grep -E "USER|PASS|SYST|PWD|TYPE|PASV|LIST|RETR|STOR|QUIT|220|230|331|227|150|226|221"
```

Resultado esperado:

```text
220 Laboratorio de Seguranca - FTP SEM TLS/FTPS
USER admin
331 Password required for admin
PASS 123456
230 User admin logged in.
SYST
215 UNIX Type: L8
PWD
257 "/" is the current directory
TYPE A
200 Switching to ASCII mode
PASV
227 Entering Passive Mode (172,30,234,55,117,48)
LIST
150 Here comes the directory listing
226 Directory send OK
RETR segredo.txt
150 Opening data connection for segredo.txt
226 Transfer complete (34 bytes)
STOR arquivo-teste.txt
150 Ok to send data.
226 Transfer complete
QUIT
221 Goodbye.
```

Análise:

- A conversa FTP inteira está reproduzida na íntegra: banner, autenticação, comandos e transferências.
- O mesmo conteúdo apareceria no Wireshark em **Follow > TCP Stream** (veja a seção 9).

---

## 8. Lições Aprendidas: por que SFTP/FTPS importa

1. **FTP não criptografa nada.** A senha (`PASS`) e todos os comandos (`USER`, `LIST`, `RETR`, `STOR`...) trafegam em texto claro e podem ser lidos por quem estiver no caminho — assim como o conteúdo dos arquivos transferidos no canal de dados.
2. **O FTP usa dois canais.** O canal de controle (porta 21) negocia a sessão; o canal de dados (portas passivas) transfere os arquivos. Ambos são capturáveis e legíveis.
3. **A captura é passiva e silenciosa.** O servidor nem percebe que o tráfego foi observado — não há detecção trivial no lado da aplicação.
4. **Ameaça real em redes compartilhadas.** Wi-Fi público, hubs de rede e roteadores intermediários são pontos onde a captura acontece.
5. **SFTP e FTPS resolvem o problema na camada de transporte.** Com SFTP (sobre SSH) ou FTPS (FTP sobre TLS), o conteúdo do tráfego viaja criptografado e o `tcpdump` mostraria apenas bytes aparentemente aleatórios, sem senha nem comandos legíveis.
6. **Sempre prefira SFTP/FTPS em produção** (ex.: servidores `vsftpd` com TLS, `openssh-server` com SFTP), nunca FTP puro.

> **🔜 Laboratórios Futuros:**
> A implementação completa de FTPS/SFTP (geração de certificados TLS, configuração de `vsftpd`, comparação de capturas) será abordada em laboratórios posteriores. Neste workshop, o foco é comprovar o risco do plaintext no FTP.

---

## 9. Atividade Extra: Análise da Captura no Wireshark (Anatomia do Pacote)

Agora que você tem o arquivo `ftp.pcap` no kali, leve essa captura para uma máquina com **Wireshark** instalado (Windows, Linux ou macOS) e estude os pacotes em detalhes — é aqui que o "debug visual" do tráfego acontece.

1. **Copie a captura para a outra máquina.** Se estiver no Windows, use o **WinSCP** (SFTP/SCP) para baixar o `ftp.pcap` do kali; em Linux/macOS, use `scp kali@IP_KALI:~/laboratorio-capturas/ftp.pcap .`. O método de cópia fica a seu critério.
2. **Abra o arquivo** no Wireshark: `Arquivo > Abrir` (ou `wireshark ftp.pcap` no terminal).
3. **Filtre o tráfego do laboratório**: aplique o filtro `ftp || ftp-data` (ou `tcp.port == 21`) na barra de filtros — sobra só o que interessa.
4. **Estude a anatomia de um pacote.** Clique em um pacote do `PASS` e observe as camadas empilhadas no painel do meio: **Ethernet II** (endereços MAC), **IPv4** (IPs de origem/destino), **TCP** (portas 54842 → 21, flags e números de sequência) e **FTP** (camada de aplicação com o comando e a senha).
5. **Encontre os pontos principais** — alguns para começar:
   - O pacote com o comando `PASS 123456` (senha em texto claro);
   - O **3-way handshake** TCP (SYN → SYN-ACK → ACK) no início da conexão;
   - O pacote com o comando `USER admin` e a resposta `331 Password required`;
   - O `227 Entering Passive Mode` que anuncia a porta do canal de dados;
   - Os pacotes `ftp-data` com o conteúdo dos arquivos transferidos.
6. **Siga o fluxo completo**: clique com o botão direito no `USER` → **Follow > TCP Stream** — o Wireshark remonta a conversa inteira (requisição + resposta), exatamente como o servidor a viu.
7. **Reconstrua os arquivos transferidos a partir do dump** (seu dump tem tudo para isso!): no kali, o **chaosreader** faz isso automaticamente — `sudo apt install chaosreader && chaosreader ftp.pcap` — ele gera um `index.html` e extrai os arquivos transferidos (o `segredo.txt` que você baixou e o `arquivo-teste.txt` enviado). O **tcpflow** também separa cada fluxo: `tcpflow -r ftp.pcap`.
8. **Reflita:** o dump permitiu recuperar senha, comandos e até os arquivos transferidos porque o FTP trafega em texto claro e a sessão completa foi capturada. Se o servidor usasse SFTP/FTPS, nada disso seria legível — apenas bytes criptografados.

### Como fazer na prática

| Ferramenta | Comando / Ação | Resultado |
|------------|----------------|-----------|
| **chaosreader** (Kali) | `sudo apt install chaosreader && cd ~/laboratorio-capturas && chaosreader ftp.pcap` | Gera `index.html` + reconstrói os arquivos transferidos |
| **Wireshark** | Filtro `ftp \|\| ftp-data` + `Follow > TCP Stream` | Remonta a conversa FTP completa (comandos + respostas) |
| **tcpflow** | `tcpflow -r ftp.pcap` | Extrai cada fluxo TCP em arquivo separado (controle e dados) |
| **Manual** | `tcpdump -r ftp.pcap -A` + `grep -E "USER\|PASS"` | O jeito "bruto", mostrando a anatomia |

> **Dica de estudo:** compare uma conexão FTP deste laboratório com uma conexão **SFTP** (ex.: `sftp user1@172.30.234.55` no kali) — no FTP a senha e os comandos aparecem legíveis; no SFTP, o payload vira bytes criptografados e a estrutura visível para de "fazer sentido". Essa comparação é o resumo visual do porquê este workshop existe.

---

## Checklist de Validação do Aluno

- [ ] Criei o diretório `/docker/laboratorio-seguranca-ftp` no servidor.
- [ ] Criei o `server.py` com `pyftpdlib` sem TLS/FTPS.
- [ ] Construí a imagem com `docker build -t laboratorio-ftp:latest .`
- [ ] Iniciei o container com `docker run -d --name laboratorio-ftp -p 21:21 -p 30000-30100:30000-30100 laboratorio-ftp:latest`
- [ ] Confirmei com `docker ps` as portas `0.0.0.0:21->21/tcp` e `0.0.0.0:30000-30100->30000-30100/tcp`.
- [ ] Testei conectividade do kali com `ping` e `nc -zv` na porta 21.
- [ ] Iniciei a captura com `sudo tcpdump -i any -s 0 -w ftp.pcap "host IP_SERVIDOR and (port 21 or portrange 30000-30100)"`.
- [ ] Gerei tráfego com `ftp` (login, `ls`, `get`, `put`) ou com `curl`.
- [ ] Parei a captura com `Ctrl+C` e conferi `packets captured`.
- [ ] Extraí credenciais com `tcpdump -r ftp.pcap -A | grep -oE "(USER|PASS) ..."`.
- [ ] Visualizei a conversa FTP completa (banner, comandos e respostas) no arquivo .pcap.
- [ ] Expliquei, com minhas palavras, por que SFTP/FTPS é obrigatório.

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| `docker: command not found` no servidor | Instalar Docker e adicionar usuário ao grupo `docker`. |
| Container não inicia | `docker logs laboratorio-ftp` e `docker ps -a` para ver o erro. |
| Porta 21 já em uso | `docker stop laboratorio-ftp`; ou mudar para outra porta com `-p 2121:21`. |
| `nc: Connection refused` na porta 21 | Verificar `docker ps`; conferir se o firewall libera a porta (`sudo ufw allow 21`). |
| tcpdump sem permissão | Usar `sudo tcpdump` ou adicionar usuário ao grupo `pcap`/`wireshark`. |
| `Nenhuma senha em plaintext` | Certifique-se de ter feito login **durante** a captura; confira o filtro `host` e `port`. |
| Captura sem pacotes | Trocar `-i any` pela interface real (`ip a` para descobrir, ex.: `-i eth0`). |
| `ls`/`get` travando (canal de dados) | Conferir se as portas 30000-30100 estão publicadas (`docker ps`) e liberadas no firewall (`sudo ufw allow 30000:30100/tcp`). |
| Login `530 Login incorrect` | Conferir as credenciais no `server.py` (admin/123456, labuser/ftp2024, aluno/senai2024). |

---

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/02-Captura_de_Tráfego_FTP.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>
