---
title: "Workshop 08: HTTP vs HTTPS — Sniffing com Nginx em Docker"
description: "Workshop prático: suba um servidor nginx em Docker usando os certificados da PKI criada no Workshop 07, exponha a mesma área restrita (login/senha + documento secreto) nas portas 80 (HTTP, sem criptografia) e 443 (HTTPS, com TLS), e capture o tráfego de outra estação com tcpdump para comparar o que um sniffer consegue ler em cada porta."
keywords: ["HTTP", "HTTPS", "TLS", "nginx", "Docker", "tcpdump", "sniffing", "basic auth", "Wireshark", "captura de tráfego", "segurança em redes", "SENAI"]
tags: ["http", "https", "tls", "nginx", "docker", "tcpdump", "sniffing", "basic-auth", "wireshark", "captura-de-trafego", "seguranca-em-redes"]
author: "Charles Alandt"
lang: "pt-BR"
layout: default
---

# Workshop 08: HTTP vs HTTPS — Sniffing com Nginx em Docker

**Tags:** `HTTP` · `HTTPS` · `TLS` · `nginx` · `Docker` · `tcpdump` · `sniffing` · `basic auth` · `Wireshark`

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
> Este workshop foi testado e validado pelo instrutor em ambiente Ubuntu 26.04 LTS com Docker 29.4.3 e nginx:alpine (host `srvdocker01`). Versões diferentes de Docker, nginx ou OpenSSL podem gerar saídas ligeiramente diferentes.
>
> **Fique atento:**
> - A execução é permitida apenas em laboratório isolado (VM dedicada ou diretório de trabalho descartável).
> - As chaves privadas e certificados usados aqui são **apenas para fins didáticos** — nunca reutilize essas chaves em sistemas reais.
> - O documento secreto contém **dados fictícios** — não use senhas ou tokens reais em laboratório.
> - A captura de tráfego deve ser feita **apenas em redes de laboratório** das quais você tem autorização.
> - **Este material é um guia prático.** O passo a passo foi validado no ambiente do instrutor; adaptações podem ser necessárias para seu ambiente específico.

---

## Índice

- [1. Abertura e Objetivos](#1-abertura-e-objetivos)
- [2. Fundamentos Conceituais](#2-fundamentos-conceituais)
  - [2.1 O que o sniffer enxerga em cada porta](#21-o-que-o-sniffer-enxerga-em-cada-porta)
  - [2.2 Basic Auth: a senha "escondida" em base64](#22-basic-auth-a-senha-escondida-em-base64)
  - [2.3 Por que o mesmo conteúdo, duas portas?](#23-por-que-o-mesmo-conteúdo-duas-portas)
- [3. Pré-requisitos](#3-pré-requisitos)
- [4. Laboratório](#4-laboratório)
  - [Etapa 1: Estrutura de diretórios](#etapa-1-estrutura-de-diretórios)
  - [Etapa 2: Configuração do nginx (portas 80 e 443)](#etapa-2-configuração-do-nginx-portas-80-e-443)
  - [Etapa 3: Área restrita com login e senha](#etapa-3-área-restrita-com-login-e-senha)
  - [Etapa 4: O documento secreto](#etapa-4-o-documento-secreto)
  - [Etapa 5: Copiando os certificados da nossa PKI](#etapa-5-copiando-os-certificados-da-nossa-pki)
  - [Etapa 6: Subindo o container com Docker Compose](#etapa-6-subindo-o-container-com-docker-compose)
  - [Etapa 7: Validando HTTP e HTTPS](#etapa-7-validando-http-e-https)
  - [Etapa 8: Sniffing — capturando o tráfego de outra estação](#etapa-8-sniffing--capturando-o-tráfego-de-outra-estação)
  - [Etapa 9: Analisando os pacotes — a prova](#etapa-9-analisando-os-pacotes--a-prova)
  - [Etapa 10: Decodificando a senha capturada](#etapa-10-decodificando-a-senha-capturada)
- [5. Perguntas para reflexão](#5-perguntas-para-reflexão)
- [6. Troubleshooting](#6-troubleshooting)
- [7. Conclusão](#7-conclusão)

---

## 1. Abertura e Objetivos

No Workshop 07 você montou uma mini-Autoridade Certificadora (`AC-Raiz-Empresa`) com OpenSSL e emitiu um certificado para o servidor `servidor.local`. Agora vamos dar o próximo passo: **colocar esse certificado para trabalhar de verdade** em um servidor web nginx rodando em Docker — e provar, com um sniffer, a diferença entre HTTP e HTTPS.

### Objetivos deste workshop

Ao final deste workshop, você será capaz de:

1. **Subir um servidor nginx em Docker** usando certificados de uma PKI própria;
2. **Configurar duas portas** servindo o mesmo conteúdo: porta 80 (HTTP, sem criptografia) e porta 443 (HTTPS, com TLS);
3. **Proteger uma área restrita** com login e senha (basic auth) nas duas portas;
4. **Capturar o tráfego** com `tcpdump` de outra estação;
5. **Comparar os pacotes** e identificar o que um sniffer consegue ler em cada porta;
6. **Decodificar a senha** capturada no HTTP e perceber por que o HTTPS existe.

> [!NOTE]
> Este workshop usa os certificados gerados no **Workshop 07** (`servidor.crt`, `servidor.key` e `ca.crt`). Se você ainda não fez o Workshop 07, volte e complete-o primeiro — ou gere uma PKI própria seguindo as Etapas 4 e 5 daquele material.

---

## 2. Fundamentos Conceituais

### 2.1 O que o sniffer enxerga em cada porta

Um sniffer (como `tcpdump` ou Wireshark) captura os pacotes que trafegam na rede. O que ele consegue **ler** depende do protocolo:

| Porta | Protocolo | O que o sniffer vê |
|-------|-----------|--------------------|
| 80 | HTTP | **Tudo**: URL, cabeçalhos, cookies, senha (base64), conteúdo do documento |
| 443 | HTTPS (TLS) | **Quase nada**: só o handshake (ClientHello/ServerHello), o nome do servidor (SNI) e bytes criptografados |

O HTTP envia os dados **em claro** (plaintext). O HTTPS primeiro estabelece um túnel TLS (com o certificado que você criou no Workshop 07) e só então envia os dados — **criptografados**.

### 2.2 Basic Auth: a senha "escondida" em base64

O basic auth é o mecanismo mais simples de autenticação HTTP. O navegador envia o cabeçalho:

```
Authorization: Basic YWx1bm86U2VuaGFAMTIz
```

O valor depois de `Basic` é apenas `usuario:senha` **codificado em base64** — não é criptografia! Qualquer pessoa pode decodificar:

```bash
echo "YWx1bm86U2VuaGFAMTIz" | base64 -d
# resultado: aluno:Senha@123
```

> [!WARNING]
> **Base64 não é criptografia.** É apenas uma codificação para representar bytes em texto. Decodificar é trivial — o sniffer faz isso em um clique no Wireshark.

### 2.3 Por que o mesmo conteúdo, duas portas?

O laboratório serve o **mesmo documento secreto** nas duas portas de propósito: para você ver com os próprios olhos que o conteúdo é idêntico — mas o que trafega na rede é completamente diferente. A única diferença entre as duas portas é o **túnel TLS** da porta 443.

---

## 3. Pré-requisitos

| Item | Requisito |
|------|-----------|
| Workshop 07 | Concluído — você tem `servidor.crt`, `servidor.key` e `ca.crt` |
| Docker | Instalado e com permissão para o seu usuário (grupo `docker`) |
| Docker Compose | Plugin instalado (`docker compose version`) |
| Portas livres | 80 e 443 sem outros serviços |
| Outra estação | Uma segunda máquina na mesma rede para sniffar (ou a própria estação, capturando o tráfego de saída) |

> [!NOTE]
> No ambiente do instrutor, o servidor é `srvdocker01` (IP `172.30.234.55`) e o usuário `user1` pertence ao grupo `docker`. Os certificados do Workshop 07 estão em `/tmp/lab-w7-user1/`.

---

## 4. Laboratório

### Etapa 1: Estrutura de diretórios

Crie a estrutura do laboratório (neste exemplo, em `/tmp/lab-nginx-tls/`):

```bash
mkdir -p /tmp/lab-nginx-tls/nginx/conf.d
mkdir -p /tmp/lab-nginx-tls/nginx/html/secreto
mkdir -p /tmp/lab-nginx-tls/pki
```

```
lab-nginx-tls/
├── docker-compose.yml
├── nginx/
│   ├── conf.d/
│   │   └── default.conf      # server blocks das portas 80 e 443
│   ├── htpasswd              # usuário/senha da área restrita
│   └── html/
│       ├── index.html
│       └── secreto/
│           └── documento-secreto.txt
└── pki/                      # certificados do Workshop 07
    ├── servidor.crt
    ├── servidor.key
    └── ca.crt
```

#### Baixando os arquivos prontos do repositório (alternativa à digitação manual)

Os arquivos de configuração deste laboratório (`docker-compose.yml`, `default.conf`, `index.html`, `documento-secreto.txt` e `htpasswd`) estão publicados no repositório da disciplina. Escolha **uma** das opções abaixo:

**Opção A — clone completo do repositório (mais simples):**

```bash
git clone --depth 1 https://github.com/charles-josiah/Aulas.git
cd Aulas/2026-07-Lab-Cripto-e-SegRedes/Workshops/08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker
```

**Opção B — sparse checkout (baixa apenas a pasta do laboratório):**

```bash
git clone --depth 1 --filter=blob:none --sparse https://github.com/charles-josiah/Aulas.git
cd Aulas
git sparse-checkout set 2026-07-Lab-Cripto-e-SegRedes/Workshops/08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker
```

**Opção C — baixar arquivo por arquivo com `curl` (sem precisar de git):**

```bash
mkdir -p lab-nginx-tls/nginx/conf.d lab-nginx-tls/nginx/html/secreto
BASE=https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker
curl -o lab-nginx-tls/docker-compose.yml                    "$BASE/docker-compose.yml"
curl -o lab-nginx-tls/nginx/conf.d/default.conf             "$BASE/nginx/conf.d/default.conf"
curl -o lab-nginx-tls/nginx/html/index.html                 "$BASE/nginx/html/index.html"
curl -o lab-nginx-tls/nginx/html/secreto/documento-secreto.txt "$BASE/nginx/html/secreto/documento-secreto.txt"
curl -o lab-nginx-tls/nginx/htpasswd                        "$BASE/nginx/htpasswd"
```

> [!IMPORTANT]
> **Os certificados NÃO estão no repositório** (por segurança — a chave privada nunca deve ser versionada). A pasta `pki/` você cria na **Etapa 5**, copiando os certificados gerados no seu próprio Workshop 07. Os arquivos baixados aqui são apenas as configurações e o conteúdo do site.

> [!NOTE]
> O `htpasswd` baixado já contém o usuário `aluno` com a senha `Senha@123` (hash `apr1`). Se preferir gerar o seu, refaça a Etapa 3 — o arquivo será sobrescrito com o seu hash.

### Etapa 2: Configuração do nginx (portas 80 e 443)

Crie o arquivo `nginx/conf.d/default.conf` com **dois** server blocks: um para a porta 80 (HTTP) e outro para a porta 443 (HTTPS). Ambos servem o mesmo conteúdo e protegem a mesma área `/secreto/` com basic auth.

```nginx
# ============================================================================
# LABORATÓRIO: HTTP vs HTTPS — nginx com certificado da nossa própria CA
# (AC-Raiz-Empresa, criada no Workshop 07)
#
# Duas portas servindo o MESMO conteúdo:
#   - Porta 80  -> HTTP  (SEM criptografia)  -> pacotes legíveis
#   - Porta 443 -> HTTPS (TLS com o certificado do servidor.local)
#                  -> pacotes criptografados
# ============================================================================

# ----------------------------------------------------------------------------
# PORTA 80 — HTTP SEM CRIPTOGRAFIA
# ----------------------------------------------------------------------------
server {
    listen       80;
    server_name  servidor.local localhost 172.30.234.55;

    location / {
        root   /usr/share/nginx/html;
        index  index.html;
    }

    # Área secreta — protegida por senha, MAS sem criptografia
    location /secreto/ {
        alias  /usr/share/nginx/html/secreto/;
        auth_basic           "AREA RESTRITA (HTTP - SEM criptografia)";
        auth_basic_user_file /etc/nginx/htpasswd;
    }
}

# ----------------------------------------------------------------------------
# PORTA 443 — HTTPS COM TLS
# ----------------------------------------------------------------------------
server {
    listen       443 ssl;
    server_name  servidor.local localhost 172.30.234.55;

    # Certificado emitido pela nossa CA (Workshop 07) + chave privada
    ssl_certificate         /etc/nginx/pki/servidor.crt;
    ssl_certificate_key     /etc/nginx/pki/servidor.key;
    # CA que emitiu o certificado (para clientes que validam a cadeia)
    ssl_trusted_certificate /etc/nginx/pki/ca.crt;

    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_session_cache   shared:SSL:10m;

    location / {
        root   /usr/share/nginx/html;
        index  index.html;
    }

    # Área secreta — protegida por senha DENTRO do túnel TLS
    location /secreto/ {
        alias  /usr/share/nginx/html/secreto/;
        auth_basic           "AREA RESTRITA (HTTPS - criptografado)";
        auth_basic_user_file /etc/nginx/htpasswd;
    }
}
```

> [!NOTE]
> Troque `172.30.234.55` pelo IP do **seu** servidor. O `server_name` precisa bater com o SAN do certificado (no Workshop 07, o certificado foi emitido com `DNS:servidor.local, DNS:localhost, IP:127.0.0.1, IP:<IP-do-servidor>`).

### Etapa 3: Área restrita com login e senha

Gere o arquivo `nginx/htpasswd` com o hash da senha. O nginx aceita hashes `apr1` (formato Apache), que podem ser gerados com o próprio OpenSSL — sem precisar instalar o `apache2-utils`:

```bash
# usuário: aluno | senha: Senha@123
HASH=$(openssl passwd -apr1 'Senha@123')
printf 'aluno:%s\n' "$HASH" > /tmp/lab-nginx-tls/nginx/htpasswd
cat /tmp/lab-nginx-tls/nginx/htpasswd
# aluno:$apr1$EXp90TdA$qoa4mn2hVAyatI.XPJ9OM1
```

> [!NOTE]
> A senha `Senha@123` é **fictícia e exclusiva para o laboratório**. Em um ambiente real, use senhas fortes e nunca as compartilhe. O hash `apr1` é resistente a leitura direta, mas a senha viaja em claro no HTTP — é exatamente isso que vamos provar no sniffing.

### Etapa 4: O documento secreto

Crie o arquivo `nginx/html/secreto/documento-secreto.txt` com dados **fictícios**:

```text
================================================================
 DOCUMENTO CONFIDENCIAL — PROIBIDA A DIVULGAÇÃO
================================================================
 Este arquivo é servido nas DUAS portas do laboratório:

   PORTA 80  -> HTTP  -> o conteúdo abaixo viaja EM CLARO na rede
   PORTA 443 -> HTTPS -> o conteúdo abaixo viaja CRIPTOGRAFADO

 Se você está lendo isto pelo HTTP, qualquer pessoa na rede
 (com um sniffer) consegue ler também. Se está lendo pelo HTTPS,
 só você e o servidor conseguem.

----------------------------------------------------------------
 DADOS SENSÍVEIS (FICTÍCIOS — apenas para o laboratório)
----------------------------------------------------------------
 Usuário do banco de dados:  admin_bd
 Senha do banco de dados:    P@ssw0rd!2026
 Token de API interna:       sk_lab_7f3a9c2e8b1d4a6f
 Chave de acesso ao cofre:   AKIA-LAB-9f8e7d6c5b4a
================================================================
```

E uma página inicial simples (`nginx/html/index.html`) com links para as duas portas, para facilitar a navegação no navegador.

### Etapa 5: Copiando os certificados da nossa PKI

Copie os certificados do Workshop 07 para a pasta `pki/`:

```bash
cp /tmp/lab-w7-user1/servidor/servidor.crt /tmp/lab-nginx-tls/pki/
cp /tmp/lab-w7-user1/servidor/servidor.key /tmp/lab-nginx-tls/pki/
cp /tmp/lab-w7-user1/ca/ca.crt            /tmp/lab-nginx-tls/pki/
```

> [!WARNING]
> **Nunca suba `servidor.key` para o git ou compartilhe.** A chave privada é o segredo mais sensível da PKI. No laboratório ela fica apenas no servidor, dentro da pasta do lab (e o container a lê via bind mount, somente leitura).

### Etapa 6: Subindo o container com Docker Compose

Crie o `docker-compose.yml`:

```yaml
services:
  nginx-tls:
    image: nginx:alpine
    container_name: lab-nginx-tls
    restart: unless-stopped
    ports:
      - "80:80"    # HTTP  -> SEM criptografia (pacotes legíveis)
      - "443:443"  # HTTPS -> TLS com o certificado da nossa CA
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/htpasswd:/etc/nginx/htpasswd:ro
      - ./nginx/html:/usr/share/nginx/html:ro
      - ./pki:/etc/nginx/pki:ro
```

Suba o container:

```bash
cd /tmp/lab-nginx-tls
docker compose up -d
docker ps --filter name=lab-nginx-tls
```

Saída esperada:

```
NAMES           STATUS                  PORTS
lab-nginx-tls   Up Less than a second   0.0.0.0:80->80/tcp, [::]:80->80/tcp, 0.0.0.0:443->443/tcp, [::]:443->443/tcp
```

### Etapa 7: Validando HTTP e HTTPS

Teste as duas portas com `curl`:

```bash
# 1. Página inicial (HTTP)
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://172.30.234.55/

# 2. Documento secreto SEM senha -> deve dar 401 (não autorizado)
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://172.30.234.55/secreto/documento-secreto.txt

# 3. Documento secreto COM senha (HTTP — em claro)
curl -s -u aluno:Senha@123 http://172.30.234.55/secreto/documento-secreto.txt

# 4. Documento secreto COM senha (HTTPS — validando a cadeia com a nossa CA)
curl -s --cacert pki/ca.crt --resolve servidor.local:443:172.30.234.55 \
     -u aluno:Senha@123 https://servidor.local/secreto/documento-secreto.txt

# 5. Handshake TLS: protocolo, cipher e validação da cadeia
echo | openssl s_client -connect 172.30.234.55:443 -servername servidor.local \
     -CAfile pki/ca.crt 2>/dev/null | grep -E "Protocol|Cipher|Verify return"
```

Saída esperada (validada no ambiente do instrutor):

```
HTTP 200                                    # 1. index no HTTP
HTTP 401                                    # 2. sem senha -> negado
DOCUMENTO CONFIDENCIAL...                   # 3. doc em claro no HTTP
DOCUMENTO CONFIDENCIAL...                   # 4. mesmo doc, agora via TLS
New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
Protocol: TLSv1.3
Verify return code: 0 (ok)                  # 5. cadeia validada pela nossa CA
```

> [!NOTE]
> O `--resolve servidor.local:443:172.30.234.55` faz o `curl` usar o nome `servidor.local` (que está no SAN do certificado) apontando para o IP do servidor, sem precisar mexer no DNS.

### Etapa 8: Sniffing — capturando o tráfego de outra estação

Agora a parte principal. Em uma **outra estação** da mesma rede (ou na própria estação, capturando o tráfego de saída), capture o tráfego das portas 80 e 443:

```bash
# Na estação de sniffing
sudo tcpdump -i en0 -A -s 0 'port 80 or port 443' -w captura.pcap
```

Em outro terminal da mesma estação, gere tráfego nas duas portas:

```bash
# Requisição HTTP (porta 80) — senha e documento em claro
curl -u aluno:Senha@123 http://172.30.234.55/secreto/documento-secreto.txt

# Requisição HTTPS (porta 443) — tudo criptografado
curl -k -u aluno:Senha@123 https://172.30.234.55/secreto/documento-secreto.txt
```

> [!NOTE]
> O `-k` no HTTPS é só porque a estação ainda não confia na nossa CA. Para validar a cadeia de verdade, importe o `ca.crt` no cofre de certificados da estação (ou use `--cacert ca.crt`).

Interrompa a captura com `Ctrl+C` e analise o arquivo:

```bash
# O que o sniffer leu no HTTP
tcpdump -r captura.pcap -A 'port 80'

# O que o sniffer leu no HTTPS
tcpdump -r captura.pcap -A 'port 443'
```

### Etapa 9: Analisando os pacotes — a prova

Captura real feita no ambiente do instrutor (servidor `srvdocker01`, sniffer rodando em container com `NET_RAW`):

**Porta 80 (HTTP)** — o sniffer lê **tudo**:

```
GET /secreto/documento-secreto.txt HTTP/1.1
Authorization: Basic YWx1bm86U2VuaGFAMTIz     ← senha em base64!
...
 DOCUMENTO CONFIDENCIAL ... PROIBIDA A DIVULGA....O
 Senha do banco de dados:    P@ssw0rd!2026     ← doc inteiro em claro
 Token de API interna:       sk_lab_7f3a9c2e8b1d4a6f
```

**Porta 443 (HTTPS)** — o sniffer só vê o handshake:

```
...9. ...3.....=.<.5./...servidor.local...    ← só o SNI (nome do servidor)
```

O restante são **bytes criptografados** — impossíveis de ler sem a chave de sessão TLS.

### Etapa 10: Decodificando a senha capturada

Para fechar o argumento, decodifique o base64 capturado no pacote HTTP:

```bash
echo "YWx1bm86U2VuaGFAMTIz" | base64 -d
# resultado: aluno:Senha@123
```

🤔 **Pense um pouco:** o sniffer capturou a senha **literal** (`aluno:Senha@123`) em um único comando. No HTTPS, a mesma senha trafegou criptografada — o sniffer não conseguiu ler nada além do nome do servidor. É exatamente por isso que o HTTPS existe.

---

## 5. Perguntas para reflexão

1. O que exatamente o sniffer consegue ler no HTTP que não consegue no HTTPS?
2. O base64 é criptografia? Por quê?
3. No HTTPS, o sniffer ainda vê o nome do servidor (SNI). Por que isso acontece e o que isso significa para a privacidade?
4. Se a senha viaja em claro no HTTP, o que mais pode estar viajando em claro em um site sem HTTPS (cookies, tokens de sessão, dados de formulário)?
5. Por que o certificado do servidor é importante para o HTTPS funcionar? O que aconteceria se o servidor usasse um certificado autoassinado e o cliente não confiasse na CA?

---

## 6. Troubleshooting

| Problema | Solução |
|----------|---------|
| `docker compose up -d` falha com porta em uso | Verificar com `ss -tln \| grep -E ":(80\|443) "` e encerrar o serviço que ocupa a porta |
| `curl` no HTTPS reclama do certificado | Esperado — nossa CA não é pública. Usar `--cacert pki/ca.crt` ou `-k` (apenas para teste) |
| `Verify return code: 20` no `s_client` | O cliente não confia na CA — passar `-CAfile pki/ca.crt` |
| `Verify return code: 62` (hostname mismatch) | O nome acessado não está no SAN — usar `--resolve servidor.local:443:<IP>` ou acessar pelo nome do SAN |
| `tcpdump` não captura nada | Confirmar a interface correta (`-i en0`, `-i eth0`, `-i any`) e que o tráfego realmente passa pela estação |
| `tcpdump` pede senha de root | Usar `sudo` ou, em Docker, rodar um container com `--cap-add NET_RAW --network host` |
| Container não sobe e o log mostra `Permission denied` na chave | A chave `servidor.key` precisa ser legível pelo processo do nginx — conferir permissões (`chmod 600` e dono correto) |
| Navegador mostra "sua conexão não é privada" | Esperado — importar o `ca.crt` da nossa CA no cofre do navegador/sistema para validar a cadeia |

---

## 7. Conclusão

Neste workshop você:

1. **Subiu um nginx em Docker** servindo HTTP e HTTPS com o certificado da PKI criada no Workshop 07;
2. **Protegeu uma área restrita** com login e senha nas duas portas;
3. **Capturou o tráfego** com `tcpdump` e **comparou os pacotes**:
   - No **HTTP**, o sniffer leu a senha (base64) e o documento secreto inteiro;
   - No **HTTPS**, o sniffer só viu o handshake TLS e bytes criptografados;
4. **Decodificou a senha** capturada, provando que base64 não é segurança.

A lição central: **criptografia de transporte (TLS/HTTPS) protege os dados em trânsito** — e é por isso que qualquer sistema que lida com senhas, tokens ou dados pessoais deve usar HTTPS em todas as portas, nunca apenas em algumas.

**Próximos passos sugeridos:**

- Repita o laboratório com o Wireshark (interface gráfica) e use "Follow HTTP Stream" para ver a requisição inteira em claro;
- Configure o nginx para **redirecionar** a porta 80 para a 443 (`return 301 https://$host$request_uri;`) e observe que o HTTP passa a servir apenas o redirecionamento;
- Teste o mesmo laboratório com `testssl.sh` (do Workshop 07) para auditar a configuração TLS do nginx;
- Explore o que mais o sniffer vê no HTTPS: o SNI, o tamanho dos pacotes e o certificado enviado no handshake.