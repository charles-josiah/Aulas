---
title: "Workshop 10: Detecção e Resposta a Incidentes com Suricata e Wazuh (Blue Team)"
description: "Workshop prático: monte um mini-SOC com Suricata (IDS de rede) e Wazuh (SIEM/HIDS) rodando em Docker nas duas máquinas do laboratório, injete os próprios ataques dos Workshops 01–04 e veja os alertas dispararem em tempo real — fechando a UC com o papel que falta: quem detecta e responde quando a criptografia não basta."
keywords: ["Suricata", "Wazuh", "IDS", "SIEM", "HIDS", "detecção de intrusos", "resposta a incidentes", "blue team", "eve.json", "regras de detecção", "Docker", "segurança em redes", "SENAI"]
tags: ["suricata", "wazuh", "ids", "siem", "hids", "deteccao-de-intrusos", "resposta-a-incidentes", "blue-team", "eve-json", "regras-de-deteccao", "docker", "seguranca-em-redes"]
author: "Charles Alandt"
lang: "pt-BR"
layout: default
---

# Workshop 10: Detecção e Resposta a Incidentes com Suricata e Wazuh (Blue Team)

**Tags:** `Suricata` · `Wazuh` · `IDS` · `SIEM` · `HIDS` · `detecção de intrusos` · `resposta a incidentes` · `blue team` · `eve.json` · `regras de detecção` · `Docker`

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
> A estrutura espelha os Workshops 01–09. **Todas as etapas foram validadas em ambiente real em 23/09/2026** — Suricata (Etapas 1.2, 2, 3, 3b, 4, 6 e 7) e Wazuh (Etapas 1.3, 1.4, 5 e 8), com saídas reais preenchidas. O único ponto de atenção é a RAM do `srvdocker01` no primeiro bootstrap do Wazuh (OOM — ver Troubleshooting). Versões de Suricata, Wazuh e Docker mudam com frequência; confira as versões vigentes antes de publicar.
>
> **Fique atento:**
> - A execução é permitida apenas em laboratório isolado (VM dedicada ou diretório de trabalho descartável).
> - Os ataques injetados neste workshop são **contra os próprios containers vulneráveis do laboratório** — nunca contra sistemas reais.
> - O Wazuh completo é pesado (~4 GB de RAM só para ele) — confira os requisitos na Seção 3.4 antes de subir.
> - **Este material é um guia prático.** O passo a passo será validado no ambiente do instrutor; adaptações podem ser necessárias para seu ambiente específico.

---

## Índice

- [1. Abertura e Objetivos](#1-abertura-e-objetivos)
- [2. Fundamentos Conceituais](#2-fundamentos-conceituais)
  - [2.1 Por que "ver o pacote" não basta](#21-por-que-ver-o-pacote-não-basta)
  - [2.2 IDS por assinatura × anomalia — onde entra o Suricata](#22-ids-por-assinatura--anomalia--onde-entra-o-suricata)
  - [2.3 SIEM/HIDS — onde entra o Wazuh](#23-siemhids--onde-entra-o-wazuh)
  - [2.4 O que muda depois do TLS (retomando WS07/08)](#24-o-que-muda-depois-do-tls-retomando-ws0708)
  - [2.5 Do alerta ao incidente](#25-do-alerta-ao-incidente)
- [3. Arquitetura do Laboratório](#3-arquitetura-do-laboratório)
  - [3.1 Onde roda cada peça](#31-onde-roda-cada-peça)
  - [3.2 Diagrama da arquitetura](#32-diagrama-da-arquitetura)
  - [3.3 Decisões de arquitetura e planejamento](#33-decisões-de-arquitetura-e-planejamento)
  - [3.4 Requisitos de hardware](#34-requisitos-de-hardware)
- [4. Preparação do Laboratório (Etapa 1)](#4-preparação-do-laboratório-etapa-1)
  - [Etapa 1.1: Verificar o ambiente dos WS01–04/08](#etapa-11-verificar-o-ambiente-dos-ws010408)
  - [Etapa 1.2: Suricata em Docker no kali](#etapa-12-suricata-em-docker-no-kali)
  - [Etapa 1.3: Wazuh em Docker no srvdocker01](#etapa-13-wazuh-em-docker-no-srvdocker01)
  - [Etapa 1.4: Agente Wazuh no srvdocker01](#etapa-14-agente-wazuh-no-srvdocker01)
- [5. Laboratório Guiado (Etapas 2–10)](#5-laboratório-guiado-etapas-210)
  - [Etapa 2: Prova de vida — primeiro alerta (nmap)](#etapa-2-prova-de-vida--primeiro-alerta-nmap)
  - [Etapa 3: Regra customizada — HTTP em claro (WS01/08)](#etapa-3-regra-customizada--http-em-claro-ws0108)
  - [Etapa 4: Regra customizada — MQTT CONNECT (WS04)](#etapa-4-regra-customizada--mqtt-connect-ws04)
  - [Etapa 5: Wazuh — primeiro alerta de log (SSH/FTP)](#etapa-5-wazuh--primeiro-alerta-de-log-sshftp)
  - [Etapa 6: Correlação — replay do ataque MySQL (WS03)](#etapa-6-correlação--replay-do-ataque-mysql-ws03)
  - [Etapa 7: O que sobra depois do TLS (WS08, porta 443)](#etapa-7-o-que-sobra-depois-do-tls-ws08-porta-443)
  - [Etapa 8: Active response — bloqueio automático](#etapa-8-active-response--bloqueio-automático)
  - [Etapa 9: Runbook manual de resposta a incidente](#etapa-9-runbook-manual-de-resposta-a-incidente)
  - [Etapa 10: Revisão e preparação do Desafio Final](#etapa-10-revisão-e-preparação-do-desafio-final)
- [6. Cenários de Detecção (injeção de ataques)](#6-cenários-de-detecção-injeção-de-ataques)
- [7. Desafio Final](#7-desafio-final)
  - [Cenário](#cenário)
  - [Entregáveis](#entregáveis)
  - [Como abrir o gabarito (comandos no kali ou em qualquer Linux)](#como-abrir-o-gabarito-comandos-no-kali-ou-em-qualquer-linux)
- [8. Fechamento](#8-fechamento)
- [9. Atividade Extra](#9-atividade-extra)
- [10. Troubleshooting](#10-troubleshooting)
- [11. Anexo A — Glossário](#11-anexo-a--glossário)

---

## 1. Abertura e Objetivos

### Contextualização

Nos Workshops 01–04 fomos o **atacante**: farejamos HTTP, FTP, MySQL e MQTT em texto claro. Nos Workshops 05–09 viramos **defensores com criptografia**: GPG, AES/RSA híbrido, PKI própria, TLS. Mas cifrar o canal não significa que alguém está de olho nele. Este workshop fecha a UC nos colocando no papel que falta: **quem detecta e responde quando (ou apesar de) tudo isso falha**.

A diferença central que este workshop quer fixar: nos WS01–04 você **sentou e olhou** os pacotes com tcpdump/tshark (alguém tinha que estar assistindo ao vivo). Aqui, o Suricata e o Wazuh **olham sozinhos, 24/7, e avisam** — você injeta o ataque e vê o alerta nascer sem precisar ficar olhando o pcap.

### Problema corporativo (resumo em uma frase)

> "A empresa cifrou os serviços críticos (WS07/08), mas ninguém percebeu quando um atacante tentou força bruta no FTP às 3h da manhã — porque não existe ninguém, nem nada, olhando os logs."

### Contexto dos Workshops anteriores

Reaproveita a infraestrutura já no ar: containers do WS01 (Flask/HTTP), WS02 (FTP), WS03 (MySQL), WS04 (MQTT) e WS08 (nginx HTTP/HTTPS), todos rodando em `srvdocker01`. O `kali` deixa de ser só atacante e ganha um segundo papel: **sensor de rede** — a mesma `eth0` que você usou com tcpdump nos WS01–04 agora roda o Suricata em Docker.

> [!NOTE]
> **Workshop 07/08:** você cifrou o canal com TLS e viu o sniffer "ficar cego" para o conteúdo. Este workshop mostra o outro lado da moeda: o que **ainda** dá para ver mesmo com TLS (metadados, SNI, JA3, logs do servidor) — e por que monitoramento é o complemento obrigatório da criptografia.

### Objetivos deste workshop

Ao final deste workshop, você será capaz de:

1. Diferenciar **ver o pacote** (tcpdump/tshark, WS01–04) de **ver o alerta** (IDS/SIEM).
2. Subir o **Suricata em Docker** no `kali` como IDS de rede (NIDS) por assinatura.
3. Subir o **Wazuh em Docker** no `srvdocker01` como SIEM/HIDS (manager + agente).
4. Escrever **regras customizadas** de detecção para os próprios ataques dos Workshops 01–04.
5. **Injetar ataques** (nmap, força bruta, exfiltração, spoofing) e ver os alertas dispararem em tempo real no `eve.json` e no Wazuh.
6. Entender o que muda na detecção **depois do TLS** (WS07/08): de conteúdo para metadado/heurística.
7. Praticar o ciclo mínimo de resposta a incidente: **identificar → conter → documentar**.

### Pré-requisitos

- Workshops 01, 03, 04, 07 e 08 concluídos (ambiente `srvdocker01` + `kali` no ar, PKI própria já emitida).
- Docker funcional **nas duas máquinas** (o kali também precisa de Docker para o Suricata).
- Conceitos básicos de monitoramento contínuo, alertas, SIEM/SOAR e resposta a incidentes (referências oficiais: [NIST SP 800-61](https://csrc.nist.gov/pubs/sp/800/61/r2/final), [documentação do Wazuh](https://documentation.wazuh.com/), [documentação do Suricata](https://docs.suricata.io/)).
- RAM: ver requisitos na Seção 3.4.

### Resultado esperado

Ao final, teremos um **mini-SOC funcional** (Suricata + Wazuh) observando os nossos próprios laboratórios anteriores, com pelo menos **duas regras customizadas escritas por nós**, um **script de injeção de ataques** que dispara alertas em sequência, e um **relatório de incidente** redigido a partir de um ataque real que provocamos.

---

## 2. Fundamentos Conceituais

### 2.1 Por que "ver o pacote" não basta

tcpdump/tshark (WS01–04) exigem alguém sentado analisando ao vivo. Em produção ninguém faz isso 24/7 — precisa de algo que **compare tráfego contra regras e avise sozinho**.

| | tcpdump/tshark (WS01–04) | Suricata (WS10) |
|---|---|---|
| **Papel** | Ferramenta de análise manual | Sensor que analisa sozinho |
| **Quem olha** | Você, ao vivo | O motor de regras, 24/7 |
| **Saída** | pcap para você ler | `eve.json` com alertas estruturados |
| **Escala** | Minutos de captura | Dias/meses de tráfego |

### 2.2 IDS por assinatura × anomalia — onde entra o Suricata

**Suricata** é um NIDS (Network IDS): motor de regras compatível com Snort/ET (Emerging Threats), inspeciona o payload e gera alertas em `eve.json` (JSON por evento). Duas famílias de detecção:

- **Assinatura** (o que faremos): compara o tráfego com padrões conhecidos — "se aparecer `password=` no corpo de um POST HTTP, alerta". Rápido, preciso, mas só detecta o que tem regra.
- **Anomalia/heurística**: compara com um "normal" aprendido — detecta o desconhecido, mas gera falso positivo. (Prepara a Etapa 7, tráfego cifrado.)

### 2.3 SIEM/HIDS — onde entra o Wazuh

**Wazuh** = agente (HIDS, roda no host, lê logs/arquivos/integridade) + manager (correlaciona, dispara regras, dashboard). Diferença central pro Suricata:

| | Suricata | Wazuh |
|---|---|---|
| **Olha** | O que **passou na rede** | O que **aconteceu na máquina** |
| **Fonte** | Pacotes (eth0) | Logs (`auth.log`, nginx, MySQL), arquivos, processos |
| **Tipo** | NIDS | HIDS + SIEM |
| **Exemplo de alerta** | "scan nmap vindo de 172.30.234.56" | "10 falhas de login SSH em 60s no srvdocker01" |

### 2.4 O que muda depois do TLS (retomando WS07/08)

Com HTTPS o Suricata não lê mais `password=` no payload — mas ainda vê **metadado**: SNI (nome do site no handshake), JA3/JA4 (fingerprint do cliente TLS), volume, frequência, IP de destino. É a ponte pedagógica: *"vocês cifraram no WS07/08 achando que ficou invisível — ficou parcialmente"*.

### 2.5 Do alerta ao incidente

Ciclo curto (baseado no [NIST SP 800-61](https://csrc.nist.gov/pubs/sp/800/61/r2/final) — *Computer Security Incident Handling Guide*): **detectar → conter → erradicar → recuperar → documentar (lições aprendidas)**. O Desafio Final cobre a ponta "documentar".

---

## 3. Arquitetura do Laboratório

### 3.1 Onde roda cada peça

| Peça | Onde | Como | Papel |
|---|---|---|---|
| Containers WS01–04/08 (Flask, FTP, MySQL, MQTT, nginx) | `srvdocker01` | Docker (já existente) | Alvos vulneráveis |
| **Wazuh manager** (+ indexer + dashboard) | `srvdocker01` | Docker (`wazuh-docker` single-node) | SIEM: correlaciona logs, dashboard |
| **Wazuh agente** | `srvdocker01` (host) | pacote `wazuh-agent` no host | HIDS: coleta `auth.log`, logs dos containers |
| **Suricata** | `kali` | Docker (`jasonish/suricata`, `--net=host`) | NIDS: sniffa `eth0`, gera `eve.json` |
| Ferramentas de ataque (nmap, hydra, curl, mosquitto_pub, mysql) | `kali` | nativas (já existentes) | Injetam os ataques |

> [!NOTE]
> **Por que o Suricata no `kali` e não no `srvdocker01`?** Duas razões: (1) o `kali` já é o "observador de rede" dos WS01–04 — a mesma `eth0` que capturava com tcpdump agora roda o Suricata, fechando o ciclo com a mesma topologia; (2) nós **injetamos o ataque e vemos o alerta na mesma máquina**, em tempo real — o fluxo "ação → reação" fica imediato e didático. Em produção, o sensor ficaria no ponto de observação da rede (SPAN/mirror), mas o conceito é o mesmo.

### 3.2 Diagrama da arquitetura

```
┌─────────────────────────────────────────────────────────────────────┐
│                    REDE DO LABORATÓRIO (mesma subrede)              │
│                                                                     │
│  ┌─────────────────────────────┐        ┌─────────────────────────┐ │
│  │  srvdocker01 (Ubuntu+Docker)│        │  kali (Kali+Docker)     │ │
│  │  IP 172.30.234.55           │        │  IP 172.30.234.56       │ │
│  │                             │        │                         │ │
│  │  ┌───────────────────────┐  │        │  ┌───────────────────┐  │ │
│  │  │ WS01 Flask (5000)     │  │        │  │ Suricata (Docker) │  │ │
│  │  │ WS02 FTP (21)         │  │        │  │ --net=host        │  │ │
│  │  │ WS03 MySQL (3306)     │  │        │  │ sniffa eth0       │  │ │
│  │  │ WS04 MQTT (1883)      │  │        │  │ → eve.json        │  │ │
│  │  │ WS08 nginx (80/443)   │  │        │  └───────────────────┘  │ │
│  │  └───────────────────────┘  │        │                         │ │
│  │  ┌───────────────────────┐  │        │  Ferramentas de ataque: │ │
│  │  │ Wazuh manager (Docker)│  │        │  nmap, hydra, curl,     │ │
│  │  │ + indexer + dashboard │  │        │  mosquitto_pub, mysql   │ │
│  │  └───────────────────────┘  │        │                         │ │
│  │  ┌───────────────────────┐  │        │  ATAQUE ──────────────► │ │
│  │  │ Wazuh agente (host)   │  │        │  (tráfego passa pela    │ │
│  │  │ auth.log, logs docker │  │        │   eth0 do kali →        │ │
│  │  └───────────────────────┘  │        │   Suricata vê)          │ │
│  └─────────────────────────────┘        └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.3 Decisões de arquitetura e planejamento

| Tema | Decisão | Justificativa |
|---|---|---|
| Onde mora o Wazuh manager? | **Container no `srvdocker01`** | O `srvdocker01` assume o papel de "srvmonitor" (máquina de monitoramento); não nasce terceira máquina (EAD, 2 VMs já é o nosso padrão). |
| RAM do ambiente | **Full stack** (`wazuh-docker` single-node) se RAM ≥ 8 GB; **modo lite** (manager only) documentado no Troubleshooting | O `srvdocker01` já roda vários containers; OCI Free Tier (4 OCPU/24 GB) aguenta o full. |
| pcap sintético vs. ataque ao vivo | **pcap + logs sintéticos** preparados pelo professor (gabarito fechado) + replay ao vivo opcional | Controle sobre a Solução Comentada; ainda injetamos ataques ao vivo nas Etapas 2–8. |
| 1 ou 2 encontros? | **2 encontros** | É o workshop mais denso (dois serviços novos + correlação + desafio). |

### 3.4 Requisitos de hardware

| Máquina | RAM mínima | Observação |
|---|---|---|
| `srvdocker01` | 8 GB (full Wazuh) / 4 GB (lite) | Wazuh manager + indexer + dashboard é o mais pesado |
| `kali` | 2 GB | Suricata é leve; ferramentas de ataque já existem |
| Disco | +10 GB livres no `srvdocker01` | Imagens Wazuh (~3 GB) + índices |

---

## 4. Preparação do Laboratório (Etapa 1)

### Etapa 1.1: Verificar o ambiente dos WS01–04/08

**Objetivo:** garantir que os alvos vulneráveis estão no ar antes de subir os sensores.

**Comandos (no `srvdocker01`):**

```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

**Resultado esperado (validado em 23/09/2026):** containers `laboratorio-*` (Flask 5000, FTP 21, MySQL 3306, MQTT 1883, nginx 80/443) listados:

```
NAMES                        PORTS
lab-nginx-tls                0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
laboratorio-ftp              0.0.0.0:21->21/tcp, 0.0.0.0:30000-30100->30000-30100/tcp
laboratorio-mqtt-broker      0.0.0.0:1883->1883/tcp
laboratorio-mqtt-dashboard   0.0.0.0:5001->5001/tcp
laboratorio-mysql            0.0.0.0:3306->3306/tcp
laboratorio-servidor         0.0.0.0:5000->5000/tcp
```

**Validação:** subir o que faltar com `docker compose up -d` em cada pasta dos WS01–04/08.

### Etapa 1.2: Suricata em Docker no kali

**Objetivo:** subir o NIDS no `kali` usando a imagem `jasonish/suricata` com `--net=host` (sniffa a `eth0` do host — a mesma interface do tcpdump dos WS01–04).

> [!NOTE]
> **Docker pode não estar instalado no kali.** Dependendo da imagem/versão do Kali
> (ou se a VM foi clonada antes de instalar), o `docker` não vem por padrão. Confira
> com `docker --version`; se falhar, instale (comandos de referência, no `kali`):
>
> ```bash
> # Verificar se já existe
> docker --version || echo "docker NAO instalado"
>
> # Instalar via apt (pacote docker.io do Kali/Debian)
> sudo apt update
> sudo apt install -y docker.io
>
> # Habilitar o serviço e adicionar o usuário ao grupo docker
> sudo systemctl enable --now docker
> sudo usermod -aG docker $USER
>
> # IMPORTANTE: sair e entrar de novo na sessão SSH (ou rodar "newgrp docker")
> # para o grupo docker valer — senão o próximo "docker run" dá
> # "permission denied while trying to connect to the Docker daemon socket"
> newgrp docker
>
> # Validar
> docker --version && docker ps
> ```
>
> Alternativa oficial (script da Docker Inc.): `curl -fsSL https://get.docker.com | sh`
> — instala o `docker-ce` (mais atual que o `docker.io` do apt), mas exige rede para
> o repositório da Docker. Para o laboratório, o `docker.io` do apt é suficiente.

**Comandos (no `kali`):**

```bash
# 1. Criar diretórios de configuração e logs
mkdir -p ~/suricata/{config,logs,rules}

# 2. Subir o container (sniffando a eth0 do host)
docker run -d --name suricata \
  --net=host \
  --cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=SYS_NICE \
  -v ~/suricata/config:/etc/suricata \
  -v ~/suricata/logs:/var/log/suricata \
  -v ~/suricata/rules:/var/lib/suricata/rules \
  jasonish/suricata:7.0 \
  -i eth0

# 3. Baixar o ruleset ET Open (dentro do container)
docker exec suricata suricata-update

# 4. Conferir que está rodando e vendo tráfego
docker logs suricata | tail -20

# 5. AJUSTE OBRIGATÓRIO: HOME_NET = só o servidor (validado em teste real)
#    O padrão [192.168.0.0/16,10.0.0.0/8,172.16.0.0/12] cobre a subrede do
#    laboratório (172.30.234.0/24) → tráfego kali→servidor vira interno→interno
#    e NENHUMA regra de scan dispara. Aponte HOME_NET só para o srvdocker01:
sudo sed -i 's|HOME_NET: "\[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12\]"|HOME_NET: "[172.30.234.55/32]"|' ~/suricata/config/suricata.yaml

# 6. Criar o arquivo de regras locais (usado nas Etapas 2–6)
sudo touch ~/suricata/rules/local.rules
sudo chmod 666 ~/suricata/rules/local.rules

# 7. Incluir local.rules na configuração — ATENÇÃO (validado em teste real):
#    (a) NÃO usar "echo >>" no final do suricata.yaml (quebra o YAML:
#        "Failed to parse configuration file");
#    (b) NÃO usar "sudo bash -c '... >> ~/suricata/...'": o "~" com sudo vira
#        /root e o append falha SILENCIOSAMENTE (o local.rules nunca entra);
#    (c) NÃO acrescentar uma SEGUNDA seção rule-files no final: o loader usa a
#        PRIMEIRA (sem local.rules) e as regras customizadas não carregam
#        (ruleset-stats fica em 52917 e nenhum sid 100000x dispara).
#    O método correto: editar a seção rule-files EXISTENTE, com caminho absoluto:
sudo sed -i 's|^  - suricata.rules$|  - suricata.rules\n  - local.rules|' /home/kali/suricata/config/suricata.yaml

# 8. Reiniciar e conferir que as regras carregaram
docker restart suricata
sleep 15
docker exec suricata suricatasc -c "ruleset-stats"
```

**Explicação dos comandos:**

- `--net=host`: o container usa a interface do host — essencial para o Suricata sniffar a `eth0` real.
- `--cap-add=NET_ADMIN,NET_RAW`: permissões para captura de pacotes e manipulação de interface.
- `-i eth0`: interface monitorada (troque pelo nome real da interface do kali).
- **HOME_NET `[172.30.234.55/32]`**: sem esse ajuste, o scan do kali contra o servidor é tratado como tráfego interno (as duas máquinas estão na mesma subrede do padrão) e as regras `EXTERNAL_NET -> HOME_NET` nunca casam. Validado em teste real: com o padrão, `nmap` não gerava alerta nenhum; com o ajuste, o alerta nasce na hora.
- **`rule-files` (3 armadilhas, todas validadas em teste real)**: o `suricata.yaml` da imagem `jasonish/suricata` já traz `rule-files: - suricata.rules`. (1) `echo >>` no **final do arquivo** quebra o parse (`conf-yaml-loader: Failed to parse configuration file`). (2) `sudo bash -c '... >> ~/suricata/...'` falha **silenciosamente** — com sudo, `~` é `/root`, não `/home/kali`; o append não acontece e não há erro visível (sintoma: ruleset-stats em 52917 e nenhuma regra customizada dispara). (3) acrescentar uma **segunda** seção `rule-files` no final não funciona: o loader usa a primeira (sem `local.rules`). A forma correta é o `sed` do passo 7 (edita a seção existente, caminho absoluto).

**Resultado esperado (validado em 23/09/2026):** log do Suricata mostrando `eth0` como interface de captura e o ruleset carregado:

```
i: suricata: This is Suricata version 7.0.17 RELEASE running in SYSTEM mode
i: detect: 2 rule files processed. 52918 rules successfully loaded, 0 rules failed
i: detect: 52923 signatures processed. 1237 are IP-only rules, ...
```

E o `ruleset-stats` respondendo:

```json
{"message": [{"id": 0, "rules_loaded": 52921, "rules_failed": 0, "rules_skipped": 0}], "return": "OK"}
```

**Validação:** `docker ps` mostra o container `suricata` Up; `ls ~/suricata/logs/` mostra `eve.json`.

### Etapa 1.3: Wazuh em Docker no srvdocker01

**Objetivo:** subir o SIEM (manager + indexer + dashboard) no `srvdocker01` com o deploy oficial single-node.

**Comandos (no `srvdocker01`):**

```bash
# 1. Clonar o deploy oficial — versão vigente em 23/09/2026: v4.14.7
#    (confira a tag mais recente com: git ls-remote --tags origin | grep "v4.1")
git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.7
cd wazuh-docker/single-node

# 2. Ajustar a porta do dashboard: 8443 (a 443 já é do nginx do WS08!)
sed -i 's|443:5601|8443:5601|' docker-compose.yml

# 3. Gerar as senhas (uma vez)
docker compose -f generate-indexer-certs.yml run --rm generator

# 4. Subir a stack
docker compose up -d

# 5. Acompanhar até ficar healthy
docker compose ps
```

**Explicação dos comandos:**

- `wazuh-docker`: repositório oficial com deploy single-node (manager + indexer + dashboard).
- **`8443:5601`:** o dashboard do Wazuh escuta na 5601 interna; no host, a 443 **já está ocupada** pelo `lab-nginx-tls` (WS08) — sem o ajuste, o `docker compose up` falha com `Bind for 0.0.0.0:443 failed: port is already allocated`.
- `generate-indexer-certs.yml`: gera os certificados internos da stack (uma vez só).
- `docker compose up -d`: sobe manager (portas 1514/1515/55000), indexer (9200) e dashboard (8443).

**Resultado esperado (validado em 23/09/2026):** 3 containers Up; dashboard acessível em `https://172.30.234.55:8443` (login `admin` / `SecretPassword` — senhas padrão do `docker-compose.yml`; a API usa `wazuh-wui` / `MyS3cr37P450r.*-`):

```
NAME                            STATUS
single-node-wazuh.dashboard-1   Up
single-node-wazuh.indexer-1     Up
single-node-wazuh.manager-1     Up
```

O indexer inicializa em ~1 min (`docker logs single-node-wazuh.indexer-1` mostra `initialized` / `publish_address`); o dashboard responde `HTTP 302` (redireciona para o login) em `https://172.30.234.55:8443`.

> [!WARNING]
> **RAM — validado em teste real (23/09/2026):** na primeira tentativa, com os containers dos WS01–04/08 no ar, o `srvdocker01` com **13 GiB travou (OOM)** durante o bootstrap do indexer — a VM congelou e precisou ser reiniciada. **Após o reboot, a stack subiu sozinha (restart policy) e o bootstrap completou sem problema** — o OOM ocorre quando o bootstrap disputa RAM com os containers WS. Estratégias seguras:
> - Confirme RAM livre ≥ 8 GiB **além** dos containers WS (`free -h`), ou
> - Pare os containers WS durante o bootstrap (`docker stop laboratorio-* lab-nginx-tls`) e suba-os depois, ou
> - Use o **modo lite** (manager only) abaixo se a RAM for < 8 GiB.
>
> **Modo lite (RAM < 8 GB):** suba só o manager:
> ```bash
> docker run -d --name wazuh-manager \
>   -p 1514:1514/udp -p 1515:1515/tcp -p 55000:55000/tcp \
>   -v wazuh_manager:/var/ossec \
>   wazuh/wazuh-manager:4.14.7
> ```
> Os alertas continuam visíveis via API/CLI (`/var/ossec/bin/wazuh-logtest`, `alerts.json`), sem dashboard. Detalhes no Troubleshooting.

### Etapa 1.4: Agente Wazuh no srvdocker01

**Objetivo:** instalar o agente (HIDS) no host `srvdocker01` e registrá-lo no manager — é ele que coleta `auth.log` e os logs dos containers.

**Comandos (no `srvdocker01`):**

```bash
# 1. Adicionar o repositório oficial do Wazuh (método vigente — o antigo
#    "wazuh-install.sh ... agent" retorna 403 no packages.wazuh.com)
sudo apt-get install -y gnupg apt-transport-https
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring \
  --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && \
  sudo chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | \
  sudo tee /etc/apt/sources.list.d/wazuh.list
sudo apt-get update

# 2. Instalar o agente — a versão DEVE ser <= a do manager (4.14.7 = 4.14.7)
sudo apt-get install -y wazuh-agent

# 3. Apontar para o manager — ATENÇÃO: o WAZUH_MANAGER do passo de instalação
#    NÃO aplicou no teste real (o ossec.conf ficou com o placeholder
#    "MANAGER_IP"). Corrigir manualmente:
sudo sed -i 's|<address>MANAGER_IP</address>|<address>172.30.234.55</address>|' /var/ossec/etc/ossec.conf

# 4. Registrar no manager (gera a chave do agente)
sudo /var/ossec/bin/agent-auth -m 172.30.234.55 -A srvdocker01

# 5. Iniciar o agente
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

**Explicação dos comandos:**

- **Repo `4.x/apt`:** o repositório é rolling (sempre a última versão da série 4.x — em 23/09/2026: 4.14.7). Para fixar uma versão: `apt-get install wazuh-agent=4.14.7-1`.
- **Versão do agente = versão do manager:** a compatibilidade exige manager ≥ agente.
- **`sed` no `<address>`:** validado em teste real — as variáveis `WAZUH_MANAGER`/`WAZUH_AGENT_NAME` na instalação **não** alteraram o `ossec.conf` (ficou `MANAGER_IP`). O `sed` acima é o passo confiável.
- **`agent-auth`:** registra o agente no manager (resposta `Valid key received`). Não adicionar `<agent_name>` no `ossec.conf` — é elemento inválido e o agente falha ao iniciar (`Invalid element in the configuration: 'agent_name'`); o nome vem do `-A` do `agent-auth`.

**Resultado esperado (validado em 23/09/2026):** agente `srvdocker01` **Active** no manager:

```
000 wazuh.manager active 127.0.0.1
001 srvdocker01 active 172.30.234.55
```

**Validação:** `docker compose exec wazuh-manager /var/ossec/bin/manage_agents -l` lista o agente registrado; `sudo systemctl status wazuh-agent` mostra `active (running)`.

---

## 5. Laboratório Guiado (Etapas 2–10)

### Etapa 2: Prova de vida — primeiro alerta (nmap)

**Objetivo:** gerar o primeiro alerta do Suricata com um scan de reconhecimento — prova de que o sensor enxerga o tráfego.

**Conceito:** o ruleset ET Open **não traz mais regras de SYN scan habilitadas** — as regras `ET SCAN` de portscan/SYN estão comentadas no ruleset atual (validado em 23/09/2026: das 274 regras `ET SCAN` habilitadas, quase todas são de User-Agent de scanners web — Mirai, ZmEu, Zmap — e nenhuma detecta SYN scan genérico). Por isso escrevemos a primeira regra customizada já aqui: um **threshold** que conta pacotes SYN de uma mesma origem em 5 segundos — exatamente o padrão de um `nmap -sS`. (Bônus didático: a Etapa 2 já ensina `threshold`, e as Etapas 3–6 ensinam conteúdo.)

**Comandos (no `kali`):**

```bash
# 1. Adicionar a regra de scan ao local.rules (criado na Etapa 1.2)
cat >> ~/suricata/rules/local.rules << 'EOF'
alert tcp any any -> any any (msg:"SCAN NMAP SYN - WS10"; flags:S; \
  threshold: type both, track by_src, count 20, seconds 5; \
  classtype:attempted-recon; sid:1000004; rev:1;)
EOF

docker exec suricata suricatasc -c reload-rules

# 2. Terminal 1 (kali): acompanhar os alertas em tempo real
tail -f ~/suricata/logs/eve.json | jq 'select(.event_type=="alert") | {ts: .timestamp, sig: .alert.signature, src: .src_ip, dst: .dst_ip}'

# 3. Terminal 2 (kali): injetar o ataque
nmap -sS -p 1-1000 172.30.234.55
```

**Explicação dos comandos:**

- `flags:S`: só pacotes com o flag SYN (primeiro passo do handshake — o que o `nmap -sS` envia).
- `threshold: type both, track by_src, count 20, seconds 5`: se a **mesma origem** mandar 20+ SYN em 5 segundos, alerta uma vez (e suprime repetições). É o padrão clássico de detecção de scan.
- `tail -f ... | jq`: filtra só eventos do tipo `alert` do `eve.json` e mostra assinatura + IPs.
- `nmap -sS`: scan SYN contra o `srvdocker01` — o tráfego passa pela `eth0` do kali, que o Suricata monitora.

**Resultado esperado (validado em 23/09/2026):** alerta no Terminal 1 em tempo real, com `src_ip=172.30.234.56` (kali) e `dst_ip=172.30.234.55` (servidor):

```
# nmap (Terminal 2) — o scan em si:
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-09-23 02:24 UTC
22/tcp open  ssh
80/tcp open  http
Nmap done: 1 IP address (1 host up) scanned in 0.15 seconds

# eve.json (Terminal 1) — o alerta:
{"ts": "2026-09-23T02:24:10.608436+0000", "sig": "SCAN NMAP SYN - WS10", "src": "172.30.234.56", "dst": "172.30.234.55"}
```

🤔 **Pense um pouco:** por que o Suricata, rodando na própria máquina atacante, consegue ver o ataque? *(Porque o tráfego de saída também passa pela `eth0` — a mesma interface que você usava com tcpdump nos WS01–04. O sensor não distingue "meu tráfego" de "tráfego alheio": ele vê tudo que passa pela interface.)*

### Etapa 3: Regra customizada — HTTP em claro (WS01/08)

**Objetivo:** escrever a primeira regra própria — detectar credenciais HTTP em texto claro, o ataque do WS01 (porta 5000) e do WS08 (porta 80, basic auth).

**Conceito:** regras Suricata têm a forma `action protocol src -> dst (opções)`. Para HTTP, o Suricata tem o **app-layer parser** — dá para inspecionar o corpo da requisição com `http_client_body`.

**Comandos (no `kali`):**

```bash
# 1. Criar o arquivo de regras locais
cat > ~/suricata/rules/local.rules << 'EOF'
alert http any any -> any any (msg:"CREDENCIAL HTTP EM TEXTO CLARO - WS01/08"; \
  flow:to_server,established; \
  content:"password="; http_client_body; \
  classtype:web-application-attack; sid:1000001; rev:1;)
EOF

# 2. Recarregar as regras (o local.rules já está na config — Etapa 1.2)
docker exec suricata suricatasc -c reload-rules

# 3. Injetar o ataque (login do WS01) — ATENÇÃO: o endpoint é a RAIZ "/",
#    não "/login" (validado em teste real: POST /login retorna 404)
curl -s -X POST http://172.30.234.55:5000/ -d "username=admin&password=123456"
```

**Explicação dos comandos:**

- `alert http`: regra para o parser HTTP do Suricata (não é `tcp` puro — usa o app-layer).
- `content:"password="; http_client_body`: procura a string no corpo da requisição HTTP.
- `sid:1000001`: identificador único da regra (use a faixa 1000000+ para regras locais, fora das faixas ET/Snort).
- `suricatasc -c reload-rules`: recarrega as regras sem reiniciar o container.
- **`POST /` (raiz):** o app Flask do WS01 serve o login na rota `/` — `POST /login` retorna `404`. O corpo `username=admin&password=123456` é o que a regra procura (`password=` no `http_client_body`).

**Resultado esperado (validado em 23/09/2026):** alerta `CREDENCIAL HTTP EM TEXTO CLARO - WS01/08` no `eve.json` após o `curl`:

```json
{"ts": "2026-09-23T00:57:48.692633+0000", "sig": "CREDENCIAL HTTP EM TEXTO CLARO - WS01/08", "src": "172.30.234.56", "dst": "172.30.234.55"}
```

**Validação — repetir contra o HTTPS do WS08 (porta 443):**

```bash
curl -sk -u aluno:Senha@123 https://servidor.local/
```

**Resultado esperado (validado em 23/09/2026):** **nenhum** alerta de conteúdo (o payload está cifrado). Guarde isso para a Etapa 7.

### Etapa 4: Regra customizada — MQTT CONNECT (WS04)

**Objetivo:** escrever a segunda regra própria — detectar o CONNECT do MQTT em claro (WS04), que carrega usuário/senha no pacote.

**Conceito:** MQTT não é HTTP — a regra usa `tcp` puro e conteúdo **binário** do protocolo: o primeiro byte `0x10` (tipo CONNECT) e o nome do protocolo `MQTT` logo em seguida. Ótimo ponto para discutir a diferença entre inspecionar texto (Etapa 3) e bytes (Etapa 4).

**Comandos (no `kali`):**

```bash
# 1. Adicionar a regra MQTT — ATENÇÃO à sintaxe: "-> any 1883" (a porta é o
#    destino; "-> any any 1883" é inválido e a regra falha no parse)
cat >> ~/suricata/rules/local.rules << 'EOF'
alert tcp any any -> any 1883 (msg:"MQTT CONNECT EM CLARO - WS04"; \
  flow:to_server,established; \
  content:"|10|"; depth:1; \
  content:"MQTT"; within:10; \
  classtype:attempted-recon; sid:1000002; rev:1;)
EOF

docker exec suricata suricatasc -c reload-rules

# 2. Injetar o ataque (spoofing de sensor do WS04) — credenciais reais do WS04
cd ~/Aulas/2026-07-Lab-Cripto-e-SegRedes/Workshops/04-Captura_de_Tráfego_MQTT/scripts
python3 atacante.py   # ou mosquitto_pub com as credenciais do sensor:
mosquitto_pub -h 172.30.234.55 -p 1883 \
  -u sensor_camara1 -P sensor_senha_2024 \
  -t "sensores/camara1/temperatura" \
  -m '{"sensor":"camara1","metrica":"temperatura","valor":99.5,"unidade":"C","token":"tok_sensor_camara1_7f3a9c","timestamp":1}'
```

**Explicação dos comandos:**

- `content:"|10|"; depth:1`: primeiro byte do pacote = `0x10` (tipo CONNECT do MQTT).
- `content:"MQTT"; within:10`: o nome do protocolo aparece nos 10 bytes seguintes.
- `flow:to_server`: só tráfego indo para o broker (porta 1883).
- **`-> any 1883`:** a porta de destino vai no último campo do cabeçalho — `any any 1883` (três campos) é erro de sintaxe e a regra é descartada (`rules_failed: 1`).
- **Credenciais `sensor_camara1`/`sensor_senha_2024`:** são as do WS04 (o broker tem `allow_anonymous false`; `aluno/senai2024` é do WS01/02 e é rejeitado com `not authorised`). O alerta dispara mesmo com credencial errada (o CONNECT packet trafega em claro), mas com a credencial certa o `mosquitto_pub` conecta de verdade (exit 0).

**Resultado esperado (validado em 23/09/2026):** alerta `MQTT CONNECT EM CLARO - WS04` no `eve.json` quando o `atacante.py` (ou `mosquitto_pub`) conecta no broker:

```json
{"ts": "2026-09-23T01:01:28.019741+0000", "sig": "MQTT CONNECT EM CLARO - WS04", "src": "172.30.234.56", "dst": "172.30.234.55"}
```

🤔 **Pense um pouco:** por que a regra MQTT usa `tcp` e a regra HTTP usa `http`? *(Porque o Suricata tem parser de aplicação para HTTP (entende a estrutura da requisição), mas não para MQTT — então a regra trabalha no nível de bytes do TCP.)*

### Etapa 5: Wazuh — primeiro alerta de log (SSH/FTP)

**Objetivo:** ver o Wazuh disparar alertas a partir de **logs**, não de pacotes — o mesmo ataque visto pelo lado da máquina.

**Conceito:** o agente coleta `auth.log` (SSH) e os logs dos containers (FTP/nginx/MySQL). O manager correlaciona e aplica regras prontas (ex.: múltiplas falhas de autenticação em curto intervalo).

**Comandos (no `kali`):**

```bash
# Força bruta SSH contra o srvdocker01 (30 tentativas rápidas)
# ATENÇÃO 1: o kali tem chave autorizada no srvdocker01 — sem as flags abaixo,
# o SSH autentica por publickey e NENHUMA falha é gerada (validado em teste
# real: o MOTD aparecia e o auth.log registrava "Accepted publickey").
# ATENÇÃO 2: o OpenSSH 9.8+ do servidor tem PerSourcePenalties (anti-força-
# bruta embutido) — após ~7 falhas ele derruba as conexões por ~17s ("drop
# connection ... penalty: failed authentication"). Com 10 tentativas a regra
# 5551 (frequência 8) NÃO dispara (validado: 7 falhas → só 5760).
# ATENÇÃO 3 (validado em revalidação 23/09): a regra 5551 conta os matches da
# 5503 (PAM) em janela deslizante de 180s. Com 15 tentativas, o PerSourcePenalties
# derruba as últimas → só ~7-9 falhas reais → 5503 dispara 7× → 5551 NÃO dispara
# (mesmo repetindo a rodada: a janela de 180s "empurra" os eventos antigos para
# fora). Use 30 tentativas: as falhas reais passam de 8 na janela e o 5551 dispara.
for i in $(seq 1 30); do
  sshpass -p "senha_errada$i" ssh -o StrictHostKeyChecking=no \
    -o PubkeyAuthentication=no -o PreferredAuthentications=password \
    user1@172.30.234.55 2>/dev/null
done
```

**Resultado esperado (validado em 23/09/2026):** no `auth.log` do srvdocker01, 10× `Failed password for user1 from 172.30.234.56`; no Wazuh, a sequência de alertas:

```
# auth.log (srvdocker01) — o que o agente coleta:
Sep 23 02:25:32 srvdocker01 sshd-session[37545]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=172.30.234.56  user=user1
Sep 23 02:25:34 srvdocker01 sshd-session[37548]: Failed password for user1 from 172.30.234.56 port 41058 ssh2
Sep 23 02:25:37 srvdocker01 sshd-session[37551]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=172.30.234.56  user=user1
... (10x no total)

# Wazuh (alerts.json) — a sequência de alertas:
2026-09-23T02:25:34 | rule 5760 | lvl 5  | sshd: authentication failed.   | src 172.30.234.56
2026-09-23T02:25:38 | rule 5760 | lvl 5  | sshd: authentication failed.   | src 172.30.234.56
... (7x rule 5760) ...
2026-09-23T02:25:54 | rule 5551 | lvl 10 | PAM: Multiple failed logins in a small period of time. | src 172.30.234.56
2026-09-23T02:25:55 | rule 651  | lvl 3  | Host Blocked by firewall-drop Active Response | src 172.30.234.56
```

A regra **5551 (lvl 10)** é a detecção de força bruta (frequência de falhas em curto intervalo) — mapeada para MITRE ATT&CK **T1110 Brute Force** (Credential Access). O alerta completo que o manager envia ao active response mostra a anatomia (JSON do `/var/ossec/logs/active-responses.log`):

```json
{"version":1,"origin":{"name":"node01","module":"wazuh-execd"},
 "parameters":{"alert":{"timestamp":"2026-09-23T02:25:54.619+0000",
   "rule":{"level":10,"description":"PAM: Multiple failed logins in a small period of time.",
           "id":"5551","mitre":{"id":["T1110"],"tactic":["Credential Access"],"technique":["Brute Force"]},
           "frequency":8,"groups":["pam","syslog","authentication_failures"],
           "pci_dss":["10.2.4","10.2.5","11.4"],"nist_800_53":["AU.14","AC.7","SI.4"]},
   "agent":{"id":"001","name":"srvdocker01","ip":"172.30.234.55"},
   "data":{"srcip":"172.30.234.56","dstuser":"user1"},
   "location":"journald"}},
 "program":"active-response/bin/firewall-drop"}
```

**Validação:** `docker exec single-node-wazuh.manager-1 sh -c "tail -f /var/ossec/logs/alerts/alerts.json"` mostra os alertas em tempo real.

### Etapa 6: Correlação — replay do ataque MySQL (WS03)

**Objetivo:** o momento "aha" do workshop: o **mesmo ataque** visto por dois ângulos — Suricata (rede) e Wazuh (log).

**Conceito:** a exfiltração do WS03 (query fora do padrão, dump de tabela) gera alerta de **rede** no Suricata (assinatura de query) e alerta de **log** no Wazuh (autenticação/query registrada no MySQL).

**Comandos (no `kali`):**

```bash
# 1. Regra customizada de exfiltração MySQL (sid:1000003) — detecta o padrão
#    de dump de tabela inteira ("SELECT * FROM") no payload TCP
cat >> ~/suricata/rules/local.rules << 'EOF'
alert tcp any any -> any 3306 (msg:"EXFILTRACAO MYSQL - SELECT * FROM - WS03"; \
  flow:to_server,established; \
  content:"SELECT * FROM"; nocase; \
  classtype:attempted-recon; sid:1000003; rev:1;)
EOF

docker exec suricata suricatasc -c reload-rules

# 2. Replay do ataque do WS03 (exfiltração via mysql client) — credenciais
#    REAIS do WS03 (root/root_secret_2024) + --skip-ssl (o MySQL 8 do WS03
#    tem TLS por padrão e o cliente do kali rejeita o cert self-signed)
mysql -h 172.30.234.55 -u root -proot_secret_2024 --skip-ssl \
  -e "SELECT * FROM app_db.clientes;"
```

**Explicação dos comandos:**

- `content:"SELECT * FROM"; nocase`: padrão de dump de tabela inteira (exfiltração). O payload real visto na rede é `SELECT * FROM app_db.clientes` — por isso a regra casa no trecho `SELECT * FROM` (a query completa varia com o schema).
- **Credenciais `root`/`root_secret_2024`:** são as do WS03 (`dba_user`/`dba_secret_2024` também funcionam). `aluno/senai2024` é do WS01/02 e não existe no MySQL.
- **`--skip-ssl`:** o MySQL 8 do WS03 tem TLS habilitado por padrão; sem a flag, o cliente do kali aborta com `ERROR 2026 (HY000): TLS/SSL error: self-signed certificate in certificate chain`.
- **`app_db.clientes`:** o banco do WS03 é `app_db` — `SELECT * FROM clientes` (sem schema) falha porque o usuário não tem default database.

> [!NOTE]
> **A tabela `app_db.clientes` vem do WS03.** Se o aluno pulou o WS03 (ou o banco foi recriado), a tabela precisa existir para este cenário. No WS03, a criação está na **Seção 3.2.1 "Criar banco e tabela"** e a população na **Seção 3.2.2 "Inserir dados sensíveis"** (`03-Captura_de_Tráfego_MySQL.md`). Comandos de referência:
>
> ```sql
> CREATE DATABASE IF NOT EXISTS app_db;
> USE app_db;
> CREATE TABLE IF NOT EXISTS clientes (
>   id INT AUTO_INCREMENT PRIMARY KEY,
>   nome VARCHAR(100) NOT NULL,
>   cpf VARCHAR(14) NOT NULL,
>   email VARCHAR(120) NOT NULL,
>   senha_hash VARCHAR(255) NOT NULL,
>   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
> );
> INSERT INTO clientes (nome, cpf, email, senha_hash) VALUES
>   ('Maria Silva',      '123.456.789-00', 'maria.silva@exemplo.com',   SHA2('senha_maria_2024', 256)),
>   ('Joao Santos',       '987.654.321-00', 'joao.santos@exemplo.com',   SHA2('senha_joao_2024', 256)),
>   ('Ana Oliveira',     '456.789.123-00', 'ana.oliveira@exemplo.com',  SHA2('senha_ana_2024', 256));
> ```
>
> O dump real do WS10 (validado em 23/09/2026) mostrou 4 registros — o `Pedro Costa` foi adicionado à parte numa execução posterior; os 3 INSERTs acima são o mínimo para o cenário funcionar.

**Resultado esperado (validado em 23/09/2026):** lado a lado:
- Suricata (`eve.json`): alerta customizado `EXFILTRACAO MYSQL - SELECT * FROM - WS03` **e** a regra ET `ET SCAN Suspicious inbound to mySQL port 3306` (sid=2010937):

```json
{"ts": "2026-09-23T02:24:19.830263+0000", "sig": "ET SCAN Suspicious inbound to mySQL port 3306", "src": "172.30.234.56", "dst": "172.30.234.55"}
{"ts": "2026-09-23T02:24:19.860613+0000", "sig": "EXFILTRACAO MYSQL - SELECT * FROM - WS03", "src": "172.30.234.56", "dst": "172.30.234.55"}
```

- O dump em si (o que o atacante viu — 4 registros de clientes com CPF e hash de senha):

```
+----+--------------+-----------------+------------------------+--------------------------------------------------+
| id | nome         | cpf             | email                  | senha_hash                                       |
+----+--------------+-----------------+------------------------+--------------------------------------------------+
|  1 | Maria Silva  | 123.456.789-00  | maria.silva@exemplo.com| 397a352b716a1794f4b4d434d777fe1061e6f2516a8b0fb5e806782c9dba2f71 |
|  2 | Joao Santos  | 987.654.321-00  | joao.santos@exemplo.com| 48e2d14a46f867c7edbae7208156c2ccb494afc3317855ddef371c9f7833401e |
|  3 | Ana Oliveira | 456.789.123-00  | ana.oliveira@exemplo.com| b0e6faaef271dc4f5f85428530e112951d281fb2d43b5270c4ea7e1c56282ed3 |
|  4 | Pedro Costa  | 789.123.456-00  | pedro.costa@exemplo.com| 41ae439edab5aa9ce81ba71ae1dad538c06f1ce29f9a04b89c815ef08a1f5e86 |
+----+--------------+-----------------+------------------------+--------------------------------------------------+
```
- Wazuh (dashboard): **correlação de log** — o mesmo IP/horário aparece nos eventos do agente (ex.: falhas de autenticação SSH da Etapa 5). Para o log do MySQL em si chegar ao Wazuh, é preciso o `docker_listener` (os logs do container não são monitorados por padrão — ver Troubleshooting).

**Validação:** comparar `timestamp` dos dois alertas — devem ser o mesmo ataque, dois sensores.

### Etapa 7: O que sobra depois do TLS (WS08, porta 443)

**Objetivo:** fechar o ciclo aberto no WS07/08 — o que o sensor ainda enxerga quando o conteúdo está cifrado.

**Conceito:** com HTTPS, o Suricata não lê payload, mas vê o **handshake**: SNI (nome do servidor), JA3/JA4 (fingerprint do cliente TLS), volume e frequência. O Wazuh ainda vê, no log do nginx, o IP e o horário de cada acesso.

**Comandos (no `kali`):**

```bash
# Acessos HTTPS legítimos (certificado da PKI do WS07) — use o HOSTNAME
# servidor.local (já no /etc/hosts do kali), não o IP: por IP o curl não
# envia SNI e o evento tls fica com sni=null
for i in $(seq 1 20); do curl -sk https://servidor.local/ > /dev/null; done

# Ver o que o Suricata registrou do handshake
jq 'select(.event_type=="tls") | {sni: .tls.sni, ja3: .tls.ja3.hash, src: .src_ip}' ~/suricata/logs/eve.json | tail -5
```

**Resultado esperado (validado em 23/09/2026):** eventos `tls` no `eve.json` com SNI/JA3, mas **sem** alerta de conteúdo (a regra `sid:1000001` não dispara):

```json
{"sni": "servidor.local", "ja3": "1d573f07cf9592c93700cd3f524279e0", "src": "172.30.234.56"}
```

No Wazuh, o log do nginx mostra os acessos.

> [!NOTE]
> **Por que `servidor.local` e não o IP?** O SNI (Server Name Indication) só é enviado quando o cliente informa um nome de host. Com `curl https://172.30.234.55/` o handshake vai sem SNI (`sni=null`) — o evento `tls` ainda aparece (com JA3), mas o nome do site não. O `/etc/hosts` do kali já mapeia `172.30.234.55 servidor.local` (configurado no WS07/08).

🤔 **Pense um pouco:** o que um atacante ainda consegue "ver" sobre um site HTTPS? *(O nome do site no SNI, o fingerprint do cliente (JA3), o volume e o padrão de tráfego — metadados. Por isso existem técnicas como ECH (Encrypted Client Hello) e por isso monitoramento de metadados é uma área inteira de detecção.)*

### Etapa 8: Active response — bloqueio automático

**Objetivo:** automatizar a contenção — o Wazuh bloqueando o IP atacante via `iptables`/`ipset` após N falhas.

**Conceito:** active response é o "SOAR mínimo": o manager detecta o padrão (ex.: 10 falhas de FTP em 60s) e executa um comando no agente (bloquear o IP).

**Comandos (no `srvdocker01`):** configurar o active response em **dois lugares** — no agente (comando + regra) e no manager (regra que dispara). Validado em 23/09/2026 com a regra de força bruta SSH **5551** (o FTP do WS02 não chega ao Wazuh por padrão — os logs do container não são monitorados; ver Troubleshooting).

**1. No agente** (`/var/ossec/etc/ossec.conf`, dentro de `<ossec_config>`):

```xml
<command>
  <name>firewall-drop</name>
  <executable>firewall-drop</executable>  <!-- sem .sh: é um binário -->
  <timeout_allowed>yes</timeout_allowed>
</command>

<active-response>
  <command>firewall-drop</command>
  <location>local</location>
  <rules_id>5551</rules_id>  <!-- força bruta SSH (PAM multiple failed logins) -->
  <timeout>300</timeout>
</active-response>
```

**2. No manager** (`config/wazuh_cluster/wazuh_manager.conf` do `wazuh-docker/single-node` — o arquivo é montado no container; o bloco padrão vem comentado):

```xml
<active-response>
  <command>firewall-drop</command>
  <location>local</location>
  <rules_id>5551</rules_id>
  <timeout>300</timeout>
</active-response>
```

**3. Reiniciar agente e manager:**

```bash
sudo systemctl restart wazuh-agent
docker restart single-node-wazuh.manager-1
```

**Resultado esperado (validado em 23/09/2026):** após o replay da força bruta SSH (Etapa 5), o IP do kali fica bloqueado por 5 minutos:

```
# iptables -L INPUT -n
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
DROP       all  --  172.30.234.56        0.0.0.0/0
```

E o Wazuh registra o bloqueio (regra 651) e, 300s depois, o desbloqueio automático (regra 652):

```
2026-09-23T02:15:35 | rule 5551 | lvl 10 | PAM: Multiple failed logins in a small period of time.
2026-09-23T02:15:35 | rule 651  | lvl 3  | Host Blocked by firewall-drop Active Response
2026-09-23T02:20:36 | rule 652  | lvl 3  | Host Unblocked by firewall-drop Active Response
```

**Prova do bloqueio efetivo (do kali):** `ssh` → `Connection timed out`; `ping` → `100% packet loss`. O `firewall-drop` é um binário que gerencia o timeout internamente (remove a regra após 300s — o `iptables -L` volta a ficar sem a linha DROP e o kali volta a acessar).

> [!NOTE]
> **Anatomia da regra 5551 (validado no ruleset):** `<rule id="5551" level="10" frequency="8" timeframe="180">` com `<if_matched_sid>5503</if_matched_sid>` e `<same_source_ip />` — ou seja, ela conta os matches da **5503** (PAM: User login failed), **não** da 5760 (sshd), e usa janela deslizante de **180s**. Consequência prática: a força bruta precisa gerar **8+ eventos 5503 da mesma origem em 180s** — é por isso que a Etapa 5 usa 30 tentativas (o PerSourcePenalties do OpenSSH 9.8+ derruba as conexões após ~7 falhas e limita as falhas reais a ~7–9 por rodada; ver Troubleshooting).

### Etapa 9: Runbook manual de resposta a incidente

**Objetivo:** praticar o ciclo **identificar → conter → documentar** sem automação — o que o analista faz enquanto o active response não existe.

**Conteúdo (roteiro curto de resposta a incidente, baseado no [NIST SP 800-61](https://csrc.nist.gov/pubs/sp/800/61/r2/final)):**

1. **Identificar:** qual alerta? qual sensor? qual IP/credencial?
2. **Conter:** isolar o host (`docker stop` do serviço atingido), bloquear o IP.
3. **Erradicar:** revogar a credencial vazada (WS01–04), trocar senhas.
4. **Recuperar:** subir o serviço de novo, validar.
5. **Documentar:** linha do tempo + lições aprendidas (base do Desafio Final).

### Etapa 10: Revisão e preparação do Desafio Final

**Objetivo:** consolidar — revisar os alertas gerados nas Etapas 2–8, conferir o que cada sensor viu, e nos preparar para o Desafio Final (Seção 7).

---

## 6. Cenários de Detecção (injeção de ataques)

Equivalente ao bloco "Ataques e Falhas" dos Workshops 05–07, só que do lado azul — **nós injetamos o ataque e temos que fazer a detecção disparar**.

| # | Ataque injetado (do kali) | Alvo | Alerta esperado | Sensor | Regra |
|---|---|---|---|---|---|
| 1 | `nmap -sS` (reconhecimento) | `srvdocker01` | `SCAN NMAP SYN - WS10` | Suricata | custom `sid:1000004` (threshold) |
| 2 | `curl` login HTTP (WS01) | porta 5000 | `CREDENCIAL HTTP EM TEXTO CLARO` | Suricata | custom `sid:1000001` |
| 3 | Força bruta FTP (WS02, hydra/loop) | porta 21 | Múltiplos `530` + falhas de login | Wazuh (+ Suricata ET FTP) | pronta + custom |

> [!NOTE]
> **Cenário 3 (FTP):** validado em 23/09/2026 — as falhas FTP aparecem no `docker logs laboratorio-ftp` (`USER 'aluno' failed login`), mas **não geram alerta no Wazuh por padrão**: o agente não monitora logs de container. Para o cenário funcionar no Wazuh, configurar o `docker_listener` (wodle) no agente ou usar a força bruta SSH (Etapa 5, validada).
| 4 | Exfiltração MySQL (WS03) | porta 3306 | `EXFILTRACAO MYSQL` (rede) + `ET SCAN ... mySQL port` + log (host) | Suricata + Wazuh | custom `sid:1000003` + ET 2010937 |
| 5 | Spoofing de sensor MQTT (WS04) | porta 1883 | `MQTT CONNECT EM CLARO` | Suricata | custom `sid:1000002` |
| 6 | HTTPS legítimo (WS08) | porta 443 | **Não deve** alertar conteúdo (tuning/falso positivo) | Suricata | — |

> [!NOTE]
> **Cenário 1 (nmap):** validado em 23/09/2026 — as regras `ET SCAN` de SYN scan estão **desabilitadas** no ruleset ET Open atual; o alerta vem da regra customizada `sid:1000004` (threshold de SYN, Etapa 2).

> [!TIP]
> **Script de injeção (`injetar_ataques.sh`):** um único script no `kali` que dispara os 5 ataques em sequência (com pausas), enquanto acompanhamos os alertas nascendo no `eve.json` e no Wazuh. Ideal para demonstração ao vivo e para revisar sozinho. **Validado de ponta a ponta em 23/09/2026** (arquivo: `10-Deteccao_Resposta_Incidentes_Suricata_Wazuh/scripts/injetar_ataques.sh`):
>
> ```bash
> #!/usr/bin/env bash
> # injetar_ataques.sh — WS10: dispara os 5 ataques em sequência (do kali)
> # Uso: bash injetar_ataques.sh
> # Pré-requisitos: nmap, curl, mosquitto-clients, mysql-client, sshpass
> set -u
> SRV=172.30.234.55; KALI=172.30.234.56
>
> echo ">>> [1/5] RECONHECIMENTO — nmap -sS (Suricata sid:1000004)"
> nmap -sS -Pn -p 1-100 "$SRV"; sleep 5
>
> echo ">>> [2/5] CREDENCIAL HTTP EM CLARO — login WS01 (sid:1000001)"
> curl -s -X POST "http://$SRV:5000/" -d "username=admin&password=123456" \
>   | grep -o "<h1>[^<]*</h1>"; sleep 5
>
> echo ">>> [3/5] EXFILTRACAO MYSQL — dump WS03 (sid:1000003 + ET 2010937)"
> mysql -h "$SRV" -u root -proot_secret_2024 --skip-ssl \
>   -e "SELECT * FROM app_db.clientes;" | head -3; sleep 5
>
> echo ">>> [4/5] SPOOFING MQTT — sensor WS04 (sid:1000002)"
> mosquitto_pub -h "$SRV" -p 1883 -u sensor_camara1 -P sensor_senha_2024 \
>   -t "sensores/camara1/temperatura" \
>   -m '{"sensor":"camara1","metrica":"temperatura","valor":99.5,"unidade":"C","token":"tok_sensor_camara1_7f3a9c","timestamp":1}'; sleep 5
>
> echo ">>> [5/5] FORCA BRUTA SSH — 30 tentativas (Wazuh 5760 + 5551 -> AR)"
> for i in $(seq 1 30); do
>   sshpass -p "senha_errada_$i" ssh -o PubkeyAuthentication=no \
>     -o PreferredAuthentications=password -o StrictHostKeyChecking=no \
>     -o ConnectTimeout=5 user1@"$SRV" "echo OK" 2>/dev/null
> done
> ```
>
> **Saída real (23/09/2026, execução completa):** os 5 ataques rodaram em ~1 min e os alertas nasceram na ordem esperada — `1000004` (nmap), `1000001` (HTTP), `1000002` (MQTT, 2×), `2010937` + `1000003` (MySQL) e, no Wazuh, `5760`×7 + `5551` (lvl 10, T1110) que disparou o `firewall-drop` (regra 651) — o kali ficou bloqueado 300s (ping 100% loss, SSH `Connection timed out`), com o `652` (desbloqueio) ao fim do timeout. Bônus: a força bruta também gerou alertas no Suricata (`ET SCAN Potential SSH Scan` + `SURICATA SSH invalid banner`).
>
> > [!NOTE]
> > **Por que 30 tentativas e não 15?** Validado em revalidação (23/09/2026): com 15 tentativas, o PerSourcePenalties do OpenSSH 9.8+ derruba as conexões após ~7 falhas → só ~7–9 falhas reais → a regra 5551 (que conta os matches da 5503/PAM em janela deslizante de 180s) **não dispara** — mesmo repetindo a rodada, a janela "empurra" os eventos antigos para fora. Com 30 tentativas, as falhas reais passam de 8 na janela e o 5551 → 651 (bloqueio) dispara de forma confiável.

---

## 7. Desafio Final

### Cenário

Assumimos o plantão do SOC. Recebemos um **pacote de evidências** (pcap + logs) de um incidente que já aconteceu — combinação de ataques dos Workshops 01–04 embutidos num único capture, **preparado pelo professor** (gabarito fechado).

**Arquivos de evidência (nesta pasta do workshop):**

| Arquivo | Conteúdo | Origem |
|---|---|---|
| `desafio_final_gabarito.enc` | **Gabarito cifrado** (pcap + logs + solução comentada) | professor |
| `desafio_final_chave.sig` | Chave AES do gabarito, **assinada com a chave privada** do professor | professor |
| `chaves/ws10_desafio_final.pub` | **Chave pública** para abrir o gabarito | professor |

> [!IMPORTANT]
> **Como funciona o gabarito cifrado (modelo de assinatura digital):**
> O professor cifrou o gabarito com um **envelope híbrido**: o pacote (pcap + logs + solução)
> foi cifrado com **AES-256** (rápido, serve para arquivos grandes) e a chave AES foi
> "fechada" com a **chave privada RSA 4096** do professor (`openssl pkeyutl -sign`).
> Para abrir, o aluno usa a **chave pública** (`openssl pkeyutl -verifyrecover`) — o único
> par que "destrava" o que a privada fechou. Isso prova **autoria** (só o professor tem a
> privada) e exercita o modelo assimétrico na prática: **privada fecha, pública abre**.
> Nota: como a chave pública é pública, qualquer pessoa com acesso ao repositório consegue
> abrir — a "proteção" aqui é didática (exercício de criptografia), não um cofre.

### Entregáveis

1. **Identificação:** quais ataques estão no pcap? (reconhecimento, exfiltração, força bruta, spoofing?)
2. **Linha do tempo:** ordem dos eventos com timestamps.
3. **IOCs:** IPs, credenciais expostas, portas, assinaturas de alerta.
4. **Relatório de incidente:** resumo executivo + detalhamento + recomendações (formato baseado no [NIST SP 800-61](https://csrc.nist.gov/pubs/sp/800/61/r2/final)).

### Como abrir o gabarito (comandos no kali ou em qualquer Linux)

```bash
# 1. Baixar os 3 arquivos do repositório (ou já estão na pasta do workshop)
#    desafio_final_gabarito.enc, desafio_final_chave.sig, chaves/ws10_desafio_final.pub

# 2. Converter a chave pública do formato OpenSSH para PEM (PKCS#8 — o pkeyutl
#    exige "BEGIN PUBLIC KEY"; o formato PKCS#1 "RSA PUBLIC KEY" falha)
ssh-keygen -f ws10_desafio_final.pub -e -m PKCS8 > ws10_desafio_final_pub.pem

# 3. "Destravar" a chave AES com a chave pública (verifyrecover = abrir o que a privada fechou)
openssl pkeyutl -verifyrecover -pubin -inkey ws10_desafio_final_pub.pem \
  -in desafio_final_chave.sig -out aes_key.hex

# 4. Decifrar o gabarito com a chave AES recuperada
openssl enc -d -aes-256-cbc -salt -pbkdf2 -in desafio_final_gabarito.enc \
  -out gabarito.tar.gz -pass file:aes_key.hex

# 5. Extrair e ler a solução
tar -xzf gabarito.tar.gz
cat gabarito/SOLUCAO_COMENTADA.md
```

**O que tem dentro do gabarito:** `desafio_final.pcap` (525 pacotes — a captura real dos 5 ataques), `eve.json` (alertas do Suricata), `alerts.json` (alertas do Wazuh), `auth.log` (log SSH do srvdocker01) e `SOLUCAO_COMENTADA.md` (identificação, linha do tempo, IOCs e o relatório NIST SP 800-61 completo).

> [!TIP]
> **Dica de análise (sem abrir o gabarito):** o pcap foi capturado com
> `tcpdump -i eth0 -s 0 -w desafio_final.pcap "host 172.30.234.55"` durante a execução do
> `injetar_ataques.sh`. Para analisar: `tcpdump -r desafio_final.pcap -nn` (visão geral),
> `tshark -r desafio_final.pcap -Y "tcp.port==5000" -T fields -e http.request.uri` (HTTP),
> `tshark -r desafio_final.pcap -Y "mysql.query" -T fields -e mysql.query` (MySQL).

---

## 8. Fechamento

Fecha o arco de três atos da UC:

- **Ato 1 (WS01–04):** atacar o que está exposto.
- **Ato 2 (WS05–09):** defender cifrando.
- **Ato 3 (WS10):** enxergar o que ainda dá pra ver — e perceber que cifrar não é o fim da história de segurança, é o começo da parte que exige monitoramento.

---

## 9. Atividade Extra

- Esboçar um **playbook de SOAR** (resposta automatizada) para o Cenário 4 (exfiltração MySQL) — ainda que sem ferramenta de SOAR de verdade, só o fluxo de decisão.
- Gancho para **DRP/BIA/RTO/RPO** (continuidade de negócios — ver [NIST SP 800-34](https://csrc.nist.gov/pubs/sp/800/34/r1/final)): "e se o `srvdocker01` saísse do ar de verdade agora?"
- **Opcional:** rodar o Suricata em modo IPS (inline) — o que muda na arquitetura? (Discussão, sem implementação.)

---

## 10. Troubleshooting

*(Validado em teste real em 23/09/2026 — sintomas e soluções abaixo foram reproduzidos no laboratório.)*

| Sintoma | Causa provável | Solução |
|---|---|---|
| Suricata não gera alerta nenhum | Interface errada ou tráfego não passa pela `eth0` | Conferir `docker logs suricata`; trocar `-i eth0` pela interface real (`ip a`); conferir modo promíscuo |
| `nmap` não gera alerta de scan (mesmo com o tráfego visível nos flows) | **HOME_NET padrão cobre a subrede do laboratório** → tráfego kali→servidor é interno→interno | Ajustar `HOME_NET: "[172.30.234.55/32]"` no `suricata.yaml` (Etapa 1.2, passo 5) e reiniciar o container |
| Nenhuma regra `ET SCAN` de SYN scan dispara | **Regras ET SCAN SYN estão comentadas/desabilitadas** no ruleset ET Open atual (só restam regras de User-Agent de scanners web) | Usar regra customizada com `threshold` (sid:1000004, Etapa 2) |
| `echo "- local.rules" >> suricata.yaml` quebra o Suricata (`Failed to parse configuration file`) | A linha foi adicionada no **final** do arquivo, fora da seção `rule-files` | Adicionar a seção completa `default-rule-path` + `rule-files` no final (Etapa 1.2, passo 7) ou editar a seção `rule-files` existente |
| Regra customizada não dispara | Regra não carregada ou sintaxe errada | `docker exec suricata suricata -T -c /etc/suricata/suricata.yaml` (teste de config); conferir `suricatasc -c "ruleset-stats"` (campo `rules_failed`) |
| Regra MQTT falha no parse (`rules_failed: 1`) | Sintaxe `-> any any 1883` (três campos) | Corrigir para `-> any 1883` (Etapa 4) |
| `curl POST /login` retorna 404 | O app Flask do WS01 serve o login na raiz `/` | Usar `curl -X POST http://172.30.234.55:5000/` (Etapa 3) |
| `mysql` aborta com `TLS/SSL error: self-signed certificate` | MySQL 8 do WS03 tem TLS por padrão; cliente do kali rejeita o cert self-signed | Adicionar `--skip-ssl` ao comando (Etapa 6) |
| `mysql` dá `Access denied` para `aluno/senai2024` | Credenciais do WS01/02; o WS03 usa `root/root_secret_2024` e `dba_user/dba_secret_2024` | Usar as credenciais do WS03 (Etapa 6) |
| Evento `tls` com `sni=null` | `curl` por IP não envia SNI | Usar `https://servidor.local/` (hostname no `/etc/hosts` do kali) — Etapa 7 |
| `docker compose up` falha: `Bind for 0.0.0.0:443 failed: port is already allocated` | Porta 443 ocupada pelo nginx do WS08 | Trocar para `8443:5601` no `docker-compose.yml` (Etapa 1.3) |
| `packages.wazuh.com/4.x/wazuh-install.sh` retorna 403 | Script antigo removido do CDN | Usar o repo apt com `WAZUH_MANAGER` (Etapa 1.4) |
| Agente instalado mas `ossec.conf` com `MANAGER_IP` | As variáveis `WAZUH_MANAGER`/`WAZUH_AGENT_NAME` do install **não aplicam** no teste real | `sed` no `<address>` + `agent-auth -m <IP> -A <nome>` (Etapa 1.4) |
| Agente falha ao iniciar: `Invalid element in the configuration: 'agent_name'` | `<agent_name>` não é elemento válido do `<client>` no `ossec.conf` | Remover a linha; o nome vem do `-A` do `agent-auth` (Etapa 1.4) |
| Força bruta SSH não gera falhas (o MOTD aparece e o auth.log registra `Accepted publickey`) | O kali tem **chave autorizada** no srvdocker01 — o SSH autentica por publickey antes da senha | Forçar senha: `-o PubkeyAuthentication=no -o PreferredAuthentications=password` (Etapa 5) |
| Força bruta gera só `5760` e a regra `5551` (frequência 8) não dispara | **OpenSSH 9.8+ PerSourcePenalties**: após ~7 falhas o servidor derruba as conexões por ~17s (`srclimit_penalise` no auth.log) — com 10 tentativas só ~7 viram falha; e a 5551 conta os matches da **5503** (PAM) em janela deslizante de **180s** — com 15 tentativas a janela nunca acumula 8 (validado em revalidação 23/09) | Usar **30 tentativas** (validado: 8+ falhas na janela → 5551 + active response) — Etapa 5 |
| Active response não dispara (alerta 5551 nasce, mas sem DROP no iptables) | O bloco `<active-response>` precisa estar no **manager** também (o padrão vem comentado) | Adicionar o bloco em `config/wazuh_cluster/wazuh_manager.conf` + reiniciar o manager (Etapa 8) |
| Força bruta FTP (WS02) não gera alerta no Wazuh | Os logs do container `laboratorio-ftp` vão para o stdout do Docker — o agente não os monitora por padrão | Usar a força bruta SSH (auth.log é monitorado) ou configurar o `docker_listener` do Wazuh |
| `firewall-drop` não executa: `Binary not found` | O executável é `firewall-drop` (binário), não `firewall-drop.sh` | Usar `<executable>firewall-drop</executable>` (Etapa 8) |
| **VM do srvdocker01 congela durante o bootstrap do Wazuh** | **OOM: indexer do OpenSearch consome toda a RAM** (validado: 13 GiB com os containers WS no ar não bastou) | Reiniciar a VM (a stack sobe sozinha e o bootstrap completa); parar os containers WS durante o bootstrap, ou reduzir o heap do indexer (`OPENSEARCH_JAVA_OPTS=-Xms2g -Xmx2g`), ou usar o modo lite (Etapa 1.3) |
| `eve.json` não existe | Container sem permissão de escrita no volume | Conferir `-v ~/suricata/logs:/var/log/suricata` e permissões do diretório |
| Wazuh não sobe / trava no `wazuh-install.sh` | RAM insuficiente (indexer é o mais pesado) | Modo lite (manager only, Seção 4 Etapa 1.3) |
| Agente não aparece como Active | Chave de registro ou firewall entre as máquinas | `agent-auth` de novo; liberar portas 1514/1515/55000 |
| Dashboard não abre | Certificados do indexer não gerados | Rodar `generate-indexer-certs.yml` de novo e `docker compose up -d` |

---

## 11. Anexo A — Glossário

| Termo | Definição |
|---|---|
| **IDS** | Intrusion Detection System — detecta e alerta, não bloqueia |
| **IPS** | Intrusion Prevention System — detecta e bloqueia (inline) |
| **NIDS** | IDS de rede — analisa pacotes (Suricata) |
| **HIDS** | IDS de host — analisa logs/arquivos da máquina (Wazuh agente) |
| **SIEM** | Correlaciona e centraliza logs/alertas de várias fontes (Wazuh manager) |
| **SOAR** | Automação de resposta (active response é o "SOAR mínimo") |
| **IOC** | Indicator of Compromise — evidência de comprometimento (IP, hash, assinatura) |
| **eve.json** | Formato JSON por evento do Suricata (alertas, tls, http, etc.) |
| **JA3/JA4** | Fingerprint do handshake TLS do cliente |
| **SNI** | Server Name Indication — nome do site no handshake TLS |
| **Active response** | Ação automática do Wazuh (ex.: bloquear IP) |
| **MITRE ATT&CK** | Base de conhecimento de táticas/ técnicas de ataque (ex.: T1110 Brute Force) — usada para classificar alertas |
| **NIST SP 800-61** | Guia de resposta a incidentes (identificar → conter → erradicar → recuperar → lições) |
| **Falso positivo** | Alerta sem ataque real (ex.: HTTPS legítimo alertando conteúdo) |
| **Threshold** | Limite de ocorrências por intervalo (ex.: regra de scan só alerta após N pacotes SYN) |
| **Wodle** | Módulo do agente Wazuh (ex.: `docker_listener` monitora logs de containers) |
| **Ruleset** | Conjunto de regras (ET Open no Suricata; regras 5xxx/6xx no Wazuh) |

---

<p align="right">
  <sub>Disciplina de Criptografia e Segurança em Redes — 2026/07</sub><br>
  <sub>Charles Alandt</sub>
</p>

<p align="right">
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/10-Deteccao_Resposta_Incidentes_Suricata_Wazuh.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>

:wq!