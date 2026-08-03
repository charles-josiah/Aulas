# Workshop 01: Captura de Tráfego HTTP (Credenciais em Texto Claro)

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

---

## Índice

- [1. Contexto e Objetivo da Aula](#1-contexto-e-objetivo-da-aula)
- [2. Observação Importante: CLI vs Interface Gráfica](#2-observação-importante-cli-vs-interface-gráfica)
- [3. Arquitetura do Laboratório](#3-arquitetura-do-laboratório)
- [4. Fase 1: Setup do Servidor (srvdocker01)](#4-fase-1-setup-do-servidor-srvdocker01)
  - [Passo 4.1: Conectar e preparar o diretório](#passo-41-conectar-e-preparar-o-diretório)
  - [Passo 4.2: Criar o servidor Flask (sem HTTPS)](#passo-42-criar-o-servidor-flask-sem-https)
  - [Passo 4.3: Criar o Dockerfile](#passo-43-criar-o-dockerfile)
  - [Passo 4.4: Construir a imagem e iniciar o container](#passo-44-construir-a-imagem-e-iniciar-o-container)
- [5. Fase 2: Setup do Cliente (kali)](#5-fase-2-setup-do-cliente-kali)
  - [Passo 5.1: Conectar e testar conectividade](#passo-51-conectar-e-testar-conectividade)
  - [Passo 5.2: Preparar captura e sudo](#passo-52-preparar-captura-e-sudo)
- [6. Fase 3: Captura do Tráfego HTTP](#6-fase-3-captura-do-tráfego-http)
  - [Passo 6.1: Iniciar a captura com tcpdump](#passo-61-iniciar-a-captura-com-tcpdump)
  - [Passo 6.2: Gerar tráfego com login via curl](#passo-62-gerar-tráfego-com-login-via-curl)
  - [Passo 6.3: Parar a captura](#passo-63-parar-a-captura)
- [7. Fase 4: Análise e Extração de Credenciais](#7-fase-4-análise-e-extração-de-credenciais)
  - [Passo 7.1: Resumo da captura](#passo-71-resumo-da-captura)
  - [Passo 7.2: Extrair credenciais em plaintext](#passo-72-extrair-credenciais-em-plaintext)
  - [Passo 7.3: Visualizar o request completo](#passo-73-visualizar-o-request-completo)
- [8. Lições Aprendidas: por que HTTPS importa](#8-lições-aprendidas-por-que-https-importa)
- [Checklist de Validação do Aluno](#checklist-de-validação-do-aluno)
- [Comandos de Referência Rápida](#comandos-de-referência-rápida)
- [Troubleshooting](#troubleshooting)

---

## 1. Contexto e Objetivo da Aula

Este workshop demonstra, de forma prática e controlada, um problema clássico de segurança: o envio de credenciais em texto claro (plaintext) pelo protocolo HTTP sem criptografia.

O cenário simula uma aplicação web realista — um sistema de login com Flask — rodando em um container Docker. Um segundo host (Kali Linux) atua como "observador de rede" e captura todo o tráfego que passa pela rede usando `tcpdump`. Ao final, as credenciais digitadas no formulário aparecem **em texto claro** na captura, exatamente como um atacante em uma rede local (ou em um Wi-Fi público) conseguiria lê-las.

Premissas do laboratório:

- Duas máquinas na mesma rede: **servidor** (srvdocker01) e **cliente/observador** (kali).
- O servidor roda um container Docker com uma aplicação Flask **sem HTTPS**.
- O cliente captura o tráfego com `tcpdump` e analisa os pacotes.
- Todos os comandos devem ser executados e validados um a um.
- A atividade deve ocorrer somente dentro da subrede autorizada do laboratório.
- Sempre substitua exemplos como `172.30.234.55` e `172.30.234.56` pelos valores reais encontrados no seu ambiente.

Objetivos de aprendizagem:

1. Configurar um servidor web vulnerável em Docker com Flask.
2. Capturar tráfego de rede com `tcpdump`.
3. Identificar credenciais em texto claro em capturas HTTP.
4. Analisar pacotes com `tcpdump` (e entender o equivalente no Wireshark).
5. Compreender por que HTTPS é essencial em qualquer aplicação web.

---

## 2. Observação Importante: CLI vs Interface Gráfica

Neste workshop, todos os passos são executados **via linha de comando (CLI)** com `tcpdump` e `curl`. Essa escolha é proposital: a CLI permite documentar cada comando de forma exata e reproduzível, facilitar a criação de textos didáticos, roteiros de aula e scripts automatizados, além de funcionar em qualquer máquina Linux sem depender de interface gráfica.

No entanto, **o mesmo experimento poderia ser feito com interface gráfica**, e é importante que o aluno saiba transitar entre os dois mundos:

- **Ubuntu/Debian (Linux):** instale o Wireshark (`sudo apt install wireshark`), selecione a interface de rede, aplique o filtro `tcp.port == 5000`, faça login pelo navegador em `http://IP_SERVIDOR:5000` e clique com o botão direito no request POST para escolher **Follow > HTTP Stream**. O Wireshark mostra o pacote inteiro, com as credenciais visíveis em texto claro.
- **Windows:** o `tcpdump` não existe nativamente, então o caminho natural é usar o **Wireshark para Windows** (com o driver Npcap) + qualquer navegador (Chrome, Edge, Firefox) para acessar a página de login. O resultado é o mesmo: o POST aparece no Wireshark com `username=admin&password=123456` legível.
- **macOS:** o `tcpdump` já vem com o sistema (ou instale via `brew install tcpdump`), e o Wireshark também está disponível (`brew install --cask wireshark`). No macOS é possível tanto seguir o roteiro CLI deste workshop quanto usar a interface gráfica do Wireshark com um navegador.

Resumindo: **o conceito demonstrado é idêntico em todas as plataformas** — um navegador envia credenciais via HTTP e um capturador de pacotes as lê na rede. A CLI aqui escolhida facilita a leitura da documentação, a reprodução exata dos comandos e a validação passo a passo; a GUI (Wireshark + navegador) oferece a mesma evidência com uma visualização mais amigável, ideal para apresentações em sala ou para alunos iniciantes. Se preferir, faça o workshop duas vezes: uma com CLI (como documentado) e outra com Wireshark, e compare os dois resultados.

---

## 3. Arquitetura do Laboratório

```
┌─────────────────────────────────────────────────────────────┐
│              MÁQUINA 1 - SERVIDOR (srvdocker01)              │
│  Host: Ubuntu 26.04 LTS, IP 172.30.234.55                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Docker Container: laboratorio-http (porta 5000)      │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  Flask Server (sem HTTPS)                       │  │  │
│  │  │  - Formulário de login                          │  │  │
│  │  │  - Credenciais fixas (admin/123456, ...)        │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                             │
                             │  HTTP (sem criptografia)
                             │  porta 5000
                             ▼
┌─────────────────────────────────────────────────────────────┐
│              MÁQUINA 2 - CLIENTE (kali)                      │
│  Host: Kali Linux 2026.1, IP 172.30.234.56                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  tcpdump (captura)  +  curl (gera o tráfego)          │  │
│  │  Captura: username=admin&password=123456             │  │
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
| Container | laboratorio-http (ID a992afeafa79) |
| Porta publicada | 5000 (0.0.0.0:5000 → 5000) |
| Credenciais do app | admin/123456, usuario/senha123, aluno/senai2024 |

---

## 4. Fase 1: Setup do Servidor (srvdocker01)

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
sudo mkdir -p /docker/laboratorio-seguranca
sudo chown -R user1:user1 /docker/laboratorio-seguranca
cd /docker/laboratorio-seguranca
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

### Passo 4.2: Criar o servidor Flask (sem HTTPS)

Crie o arquivo `server.py` com um formulário de login **sem qualquer criptografia**:

```bash
nano server.py
```

Conteúdo:

```python
from flask import Flask, request, render_template_string
import os
import datetime

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'chave-demo-simples-para-laboratorio')

# Credenciais fixas para demonstração
USERS = {
    'admin': '123456',
    'usuario': 'senha123',
    'aluno': 'senai2024'
}

LOGIN_TEMPLATE = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Laboratório de Segurança - Login</title>
    <style>
        body { font-family: Arial, sans-serif; display: flex; justify-content: center;
               align-items: center; min-height: 100vh; background: #667eea; }
        .login-container { background: white; padding: 40px; border-radius: 12px; width: 350px; }
        .warning { background: #fff3cd; border: 1px solid #ffc107; padding: 15px;
                   border-radius: 6px; margin-bottom: 25px; font-size: 13px; }
        input { width: 100%; padding: 12px; border: 2px solid #e0e0e0; border-radius: 6px; }
        button { width: 100%; padding: 12px; background: #667eea; color: white;
                 border: none; border-radius: 6px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>🔐 Login do Sistema</h2>
        <div class="warning">
            <strong>⚠️ AMBIENTE SEM HTTPS</strong><br>
            Credenciais transmitidas em PLAINTEXT!<br>
            Acessando: {{ server_ip }}:{{ server_port }}
        </div>
        {% if error %}<p style="color:red">{{ error }}</p>{% endif %}
        <form method="POST" action="/">
            <p><label>👤 Usuário:</label>
               <input type="text" name="username" required autofocus></p>
            <p><label>🔑 Senha:</label>
               <input type="password" name="password" required></p>
            <p><button type="submit">Entrar</button></p>
        </form>
    </div>
</body>
</html>
'''

DASHBOARD_TEMPLATE = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head><meta charset="UTF-8"><title>Dashboard - Laboratório</title></head>
<body>
    <h1>🎉 Login Realizado</h1>
    <p>Usuário: <strong>{{ username }}</strong></p>
    <p>Data/Hora: <strong>{{ timestamp }}</strong></p>
    <div style="background:#fff3cd;border:1px solid #ffc107;padding:15px;margin:20px 0;">
        <h3>⚠️ Risco Demonstrado</h3>
        <p>Seu tráfego HTTP está sendo capturado. As credenciais foram enviadas em texto claro.</p>
        <pre>POST / HTTP/1.1
Host: {{ host }}
Content-Type: application/x-www-form-urlencoded

username={{ username }}&password=********</pre>
    </div>
    <p><a href="/">Fazer logout</a></p>
</body>
</html>
'''

@app.route('/', methods=['GET', 'POST'])
def index():
    server_ip = os.environ.get('SERVER_HOST', 'localhost')
    server_port = os.environ.get('SERVER_PORT', '5000')

    if request.method == 'POST':
        username = request.form.get('username', '')
        password = request.form.get('password', '')

        print(f"[LOGIN] {username} - IP: {request.remote_addr}")

        if username in USERS and USERS[username] == password:
            return render_template_string(
                DASHBOARD_TEMPLATE,
                username=username,
                timestamp=datetime.datetime.now().strftime('%d/%m/%Y %H:%M:%S'),
                host=f"{server_ip}:{server_port}"
            )
        return render_template_string(LOGIN_TEMPLATE, error='❌ Usuário ou senha incorretos!',
                                      server_ip=server_ip, server_port=server_port)

    return render_template_string(LOGIN_TEMPLATE, error=None,
                                  server_ip=server_ip, server_port=server_port)

@app.route('/status')
def status():
    return {'status': 'online', 'port': 5000}

if __name__ == '__main__':
    print("=" * 50)
    print("🧪 Servidor Laboratório - Sem HTTPS")
    print("Acesse: http://0.0.0.0:5000")
    print("Usuários: admin/123456, usuario/senha123, aluno/senai2024")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5000, debug=False)
```

Análise:

- O formulário envia os dados via `POST` com `Content-Type: application/x-www-form-urlencoded`.
- As credenciais vão no **corpo da requisição, em texto claro** — é exatamente isso que vamos capturar.
- O aviso visual "AMBIENTE SEM HTTPS" reforça o propósito didático.

Crie também o `requirements.txt`:

```bash
nano requirements.txt
```

```text
flask==3.0.3
```

---

### Passo 4.3: Criar o Dockerfile

```bash
nano Dockerfile
```

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Instalar tcpdump (opcional, para análise no container)
RUN apt-get update && apt-get install -y tcpdump wireshark-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Criar grupo tcpdump e usuário não-root
RUN groupadd -r tcpdump && useradd -r -g tcpdump tcpdump

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY server.py .

# Expor porta 5000
EXPOSE 5000

# Usar usuário não-root para segurança
USER tcpdump

CMD ["python", "server.py"]
```

Análise:

- Imagem base `python:3.11-slim`: leve e suficiente.
- O container roda como usuário **não-root** (`tcpdump`), boa prática mesmo em laboratório.
- `EXPOSE 5000` documenta a porta; a publicação real acontece no `docker run`.

---

### Passo 4.4: Construir a imagem e iniciar o container

#### Comando 1: construir a imagem

```bash
cd /docker/laboratorio-seguranca
docker build -t laboratorio-http:latest .
```

Flags usadas:

- `-t laboratorio-http:latest`: nome e tag da imagem.
- `.`: usa o Dockerfile do diretório atual.

Resultado esperado (últimas linhas):

```text
 => exporting to image
 => => naming to docker.io/library/laboratorio-http:latest
```

#### Comando 2: iniciar o container

```bash
docker run -d --name laboratorio-http -p 5000:5000 laboratorio-http:latest
```

Flags usadas:

- `-d`: roda em segundo plano (detached).
- `--name laboratorio-http`: nome do container.
- `-p 5000:5000`: publica a porta 5000 do container na porta 5000 do host.

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
CONTAINER ID   IMAGE                    COMMAND           STATUS         PORTS                    NAMES
a992afeafa79   laboratorio-http:latest  "python server.py" Up 2 minutes  0.0.0.0:5000->5000/tcp   laboratorio-http
```

Análise:

- `0.0.0.0:5000->5000/tcp`: o container está acessível na rede pelo IP do host na porta 5000.
- Confirme também os logs:

```bash
docker logs laboratorio-http
```

Resultado esperado:

```text
==================================================
🧪 Servidor Laboratório - Sem HTTPS
Acesse: http://0.0.0.0:5000
Usuários: admin/123456, usuario/senha123, aluno/senai2024
==================================================
 * Running on all addresses (0.0.0.0)
 * Running on http://0.0.0.0:5000
```

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

#### Comando 3: confirmar que a porta 5000 está aberta

```bash
nc -zv 172.30.234.55 5000
```

Flags usadas:

- `-z`: testa a porta sem enviar dados.
- `-v`: modo verboso.

Resultado esperado:

```text
Connection to 172.30.234.55 5000 port [tcp/*] succeeded!
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

## 6. Fase 3: Captura do Tráfego HTTP

### Passo 6.1: Iniciar a captura com tcpdump

No **kali**, dentro de `~/laboratorio-capturas`:

```bash
sudo tcpdump -i any -s 0 -w captura.pcap "host 172.30.234.55 and port 5000"
```

Flags usadas:

- `-i any`: captura em todas as interfaces de rede.
- `-s 0`: captura o pacote inteiro (snapshot completo, sem truncar).
- `-w captura.pcap`: grava no arquivo `captura.pcap` (formato libpcap).
- `"host 172.30.234.55 and port 5000"`: filtro de captura — só tráfego com o servidor na porta 5000.
- Se a interface específica for conhecida, use `-i eth0` no lugar de `-i any`.

Resultado esperado:

```text
tcpdump: listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
```

Análise:

- O `tcpdump` fica em espera até aparecer tráfego que case com o filtro.
- **Deixe esta janela de terminal aberta** — a captura está rodando.

---

### Passo 6.2: Gerar tráfego com login via curl

Abra um **segundo terminal** no kali e faça o login — aqui usamos `curl` para reproduzir exatamente o que um navegador faria ao enviar o formulário:

```bash
curl -v -X POST http://172.30.234.55:5000/ \
  -d "username=admin&password=123456"
```

Flags usadas:

- `-v`: mostra o request/response completo no terminal.
- `-X POST`: método HTTP POST.
- `-d "username=admin&password=123456"`: corpo da requisição (dados do formulário).

Repita com outro usuário para capturar mais de um login:

```bash
curl -v -X POST http://172.30.234.55:5000/ \
  -d "username=aluno&password=senai2024"
```

Resultado esperado (trecho):

```text
> POST / HTTP/1.1
> Host: 172.30.234.55:5000
> User-Agent: curl/8.5.0
> Accept: */*
> Content-Type: application/x-www-form-urlencoded
> Content-Length: 27
>
< HTTP/1.1 200 OK
...
🎉 Login Realizado
```

Análise:

- O corpo `username=admin&password=123456` foi enviado **sem nenhuma proteção**.
- O `Content-Type: application/x-www-form-urlencoded` é o mesmo usado pelo formulário HTML.

> **Alternativa com navegador:** abra `http://172.30.234.55:5000` no navegador do kali (ou de outra máquina), preencha usuário/senha e clique em Entrar. O efeito na captura é idêntico ao do `curl`.

---

### Passo 6.3: Parar a captura

Volte ao terminal do `tcpdump` e pressione `Ctrl+C`.

Resultado esperado:

```text
^C
26 packets captured
26 packets received by filter
0 packets dropped by kernel
```

Análise (ambiente real do instrutor):

- `26 packets captured`: a sessão completa dos dois logins foi registrada.
- `0 packets dropped by kernel`: nenhum pacote perdido — a evidência está completa.

---

## 7. Fase 4: Análise e Extração de Credenciais

### Passo 7.1: Resumo da captura

```bash
sudo tcpdump -r captura.pcap -n
```

Flags usadas:

- `-r captura.pcap`: lê do arquivo em vez de capturar ao vivo.
- `-n`: não resolve nomes (mostra IPs e portas numéricas).

Resultado esperado (trecho):

```text
reading from file captura.pcap, link-type LINUX_SLL2 (Linux cooked v2)
12:31:45.123456 IP 172.30.234.56.54842 > 172.30.234.55.5000: Flags [P.], seq 1:80, ack 1, win 502, length 79
12:31:45.124567 IP 172.30.234.55.5000 > 172.30.234.56.54842: Flags [.], ack 80, win 509, length 0
...
```

Análise:

- Pacotes com `length > 0` no sentido `kali → servidor` carregam os dados do POST.
- Agora vamos olhar **o conteúdo** desses pacotes.

---

### Passo 7.2: Extrair credenciais em plaintext

```bash
sudo tcpdump -r captura.pcap -A | grep -o "username=[^&]*&password=[^[:space:]]*"
```

Flags usadas:

- `-A`: imprime o conteúdo ASCII dos pacotes (payload legível).
- `grep -o`: extrai apenas o trecho que casa com o padrão.
- `username=[^&]*&password=[^[:space:]]*`: captura o par usuário/senha completo.

Resultado esperado (ambiente real do instrutor):

```text
username=admin&password=123456
username=aluno&password=senai2024
```

Análise:

- **As credenciais estão totalmente legíveis** na captura de rede.
- Qualquer pessoa na mesma rede (ou em um ponto de acesso intermediário) conseguiria extraí-las da mesma forma, sem nenhum esforço adicional.
- Esta é a prova central do risco de usar HTTP sem criptografia.

---

### Passo 7.3: Visualizar o request completo

```bash
sudo tcpdump -r captura.pcap -A | grep -E "POST|Host|Content-Type|username" 
```

Resultado esperado:

```text
POST / HTTP/1.1
Host: 172.30.234.55:5000
User-Agent: curl/8.5.0
Content-Type: application/x-www-form-urlencoded
Content-Length: 27
username=admin&password=123456
```

Análise:

- O request HTTP completo está reproduzido na íntegra.
- O mesmo conteúdo apareceria no Wireshark em **Follow > HTTP Stream**.

---

## 8. Lições Aprendidas: por que HTTPS importa

1. **HTTP não criptografa nada.** Qualquer dado enviado (credenciais, cookies, dados pessoais) trafega em texto claro e pode ser lido por quem estiver no caminho.
2. **A captura é passiva e silenciosa.** O servidor nem percebe que o tráfego foi observado — não há detecção trivial no lado da aplicação.
3. **Ameaça real em redes compartilhadas.** Wi-Fi público, hubs de rede e roteadores intermediários são pontos onde a captura acontece.
4. **HTTPS (TLS) resolve o problema na camada de transporte.** Com HTTPS, o conteúdo do request viaja criptografado e o `tcpdump` mostraria apenas bytes aparentemente aleatórios, sem credenciais legíveis.
5. **Sempre exija HTTPS em aplicações reais** (HSTS, redirecionamento de HTTP para HTTPS, certificados válidos).

> **🔜 Laboratórios Futuros:**
> A implementação completa de HTTPS (geração de certificados, configuração de TLS no Flask/Nginx, inspeção com Wireshark) será abordada em laboratórios posteriores. Neste workshop, o foco é comprovar o risco do plaintext.

---

## Checklist de Validação do Aluno

- [ ] Criei o diretório `/docker/laboratorio-seguranca` no servidor.
- [ ] Criei o `server.py` com formulário de login sem HTTPS.
- [ ] Construí a imagem com `docker build -t laboratorio-http:latest .`
- [ ] Iniciei o container com `docker run -d --name laboratorio-http -p 5000:5000 laboratorio-http:latest`
- [ ] Confirmei com `docker ps` a porta `0.0.0.0:5000->5000/tcp`.
- [ ] Testei conectividade do kali com `ping` e `nc -zv`.
- [ ] Iniciei a captura com `sudo tcpdump -i any -s 0 -w captura.pcap "host IP_SERVIDOR and port 5000"`.
- [ ] Gerei tráfego com `curl -X POST` (ou pelo navegador).
- [ ] Parei a captura com `Ctrl+C` e conferi `packets captured`.
- [ ] Extraí credenciais com `tcpdump -r captura.pcap -A | grep -o "username=..."`.
- [ ] Visualizei o request POST completo no arquivo .pcap.
- [ ] Expliquei, com minhas palavras, por que HTTPS é obrigatório.

---

## Comandos de Referência Rápida

| Ação | Comando |
|------|---------|
| Conectar no servidor | `ssh user1@172.30.234.55` |
| Conectar no cliente | `ssh kali@172.30.234.56` |
| Construir imagem | `docker build -t laboratorio-http:latest .` |
| Iniciar container | `docker run -d --name laboratorio-http -p 5000:5000 laboratorio-http:latest` |
| Ver containers | `docker ps` |
| Logs do app | `docker logs laboratorio-http` |
| Parar container | `docker stop laboratorio-http` |
| Testar porta | `nc -zv IP_SERVIDOR 5000` |
| Capturar tráfego | `sudo tcpdump -i any -s 0 -w captura.pcap "host IP_SERVIDOR and port 5000"` |
| Ler captura (ASCII) | `sudo tcpdump -r captura.pcap -A` |
| Extrair credenciais | `sudo tcpdump -r captura.pcap -A \| grep -o "username=[^&]*&password=[^[:space:]]*"` |
| Abrir no Wireshark | `wireshark captura.pcap` |

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| `docker: command not found` no servidor | Instalar Docker e adicionar usuário ao grupo `docker`. |
| Container não inicia | `docker logs laboratorio-http` e `docker ps -a` para ver o erro. |
| Porta 5000 já em uso | `docker stop laboratorio-http`; ou mudar para outra porta com `-p 5001:5000`. |
| `nc: Connection refused` | Verificar `docker ps`; conferir se o firewall libera a porta (`sudo ufw allow 5000`). |
| tcpdump sem permissão | Usar `sudo tcpdump` ou adicionar usuário ao grupo `pcap`/`wireshark`. |
| `Nenhuma credencial em plaintext` | Certifique-se de ter feito login **durante** a captura; confira o filtro `host` e `port`. |
| Captura sem pacotes | Trocar `-i any` pela interface real (`ip a` para descobrir, ex.: `-i eth0`). |
| Credenciais truncadas no grep | Conferir se o login gerou `Content-Type: application/x-www-form-urlencoded`. |

---

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/01-Captura_de_Tráfego_HTTP.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>
