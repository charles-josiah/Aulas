# Aula — Introdução ao Docker + Captura de Tráfego com tshark/Wireshark

**Disciplina:** Criptografia e Segurança em Redes — SENAI
**Pré-requisitos:** acesso ao srvdocker01 (servidor com Docker) e ao Kali (atacante)

> Baseado em: `2025-04-Lab-Cripto-e-SegRedes/Notas-Aulas-20250430.md` e
> `2025-04-Lab-Cripto-e-SegRedes/guia_completo_nginx_php_autenticacao.md`
>
> **Aprofundamento (comandos Docker, volumes, redes e DMZ):**
> [Introducao_Docker_para_ambientes.md](https://github.com/charles-josiah/Aulas/blob/master/2025-10-Analise_de_Vulnerabilidade_e_Testes_de_Invasao/Introducao_Docker_para_ambientes.md)
> — instalação completa do Docker no Ubuntu, comandos básicos, tipos de
> volumes (nomeado/anônimo/bind/efêmero), tipos de rede (bridge/host/none/overlay)
> e um exemplo de topologia DMZ. Vale a leitura para quem quiser se aprofundar.

---

## Objetivos da aula

1. Entender o que é Docker e por que todos os laboratórios da disciplina usam containers
2. Aprender os comandos essenciais de Docker e Docker Compose
3. Subir um serviço web com autenticação (nginx + htpasswd) em um container
4. Capturar as credenciais desse serviço com **tshark** e ver no **Wireshark**
5. Concluir por que HTTP sem TLS expõe credenciais na rede

---

## Parte 1 — Introdução ao Docker

### 1.1 O que é Docker (teoria rápida)

| Conceito | Explicação |
|---|---|
| **Container** | Ambiente isolado que roda uma aplicação com suas dependências, sem instalar nada no host |
| **Imagem** | "Fotografia" de um ambiente pronta para virar container (ex.: `nginx:alpine`) |
| **Dockerfile** | Receita que constrói uma imagem (passo a passo) |
| **docker-compose** | Orquestra vários containers juntos (ex.: web + banco + admin) |

**História:** Docker (2013) popularizou a ideia dos *jails* do FreeBSD (2000) usando recursos do kernel Linux:
- **Namespaces** → isolamento (processos, rede, sistema de arquivos)
- **Cgroups** → limites de CPU/memória
- **UnionFS/OverlayFS** → imagem em camadas (reuso e download parcial)

**Benefícios para o laboratório:**
- Serviço vulnerável sobe em segundos e é descartado sem sujar o host
- Todos os alunos usam o **mesmo ambiente** (reprodutível)
- Portas expostas só quando o laboratório precisa (menor privilégio)

### 1.2 Comandos essenciais (prática no srvdocker01)

```bash
# --- Imagens ---
docker images                       # lista imagens baixadas
docker pull nginx:alpine            # baixa uma imagem do Docker Hub

# --- Exemplo 1: o "hello world" do Docker ---
docker run hello-world              # baixa a imagem, roda um container,
                                    # imprime a mensagem de boas-vindas e para
docker ps -a                        # o container já aparece como Exited

# --- Exemplo 2: um serviço "de verdade" (broker MQTT, como no Workshop 04) ---
# Porta 1884 no host porque a 1883 pode estar ocupada pelo lab do Workshop 04
docker run -d --name mosquitto-aula -p 1884:1883 eclipse-mosquitto:2
docker ps                           # mosquitto-aula Up (rodando em background)
docker logs -f mosquitto-aula       # "mosquitto version 2.x running" (Ctrl+C sai)
docker exec -it mosquitto-aula sh   # entra no shell do container (exit sai)
docker stop mosquitto-aula          # para o container
docker rm mosquitto-aula            # remove o container (nome liberado)
docker ps -a                        # não aparece mais na lista

# --- Volumes (dados fora do container) ---
docker run -v "$PWD/conf:/etc/nginx/conf.d:ro" ...   # monta pasta local

# --- Compose (vários serviços) ---
docker compose up -d                # sobe tudo que está no docker-compose.yml
docker compose ps                   # status
docker compose logs -f              # logs de todos
docker compose down                 # derruba tudo
```

**O que o exemplo 2 demonstra (ciclo de vida de um container):**
- `docker run -d` → o container sobe em **background** e continua vivo
- `docker logs -f` → acompanhamos o log do processo sem entrar nele
- `docker exec -it` → entramos no container (é um Linux mínimo, mas é isolado do host)
- `docker stop` + `docker rm` → para e **remove** — o host fica limpo, nada instalado

> [!NOTE]
> A lista completa de comandos (incluindo remoção de imagens/redes/volumes:
> `docker rmi`, `docker network rm`, `docker volume rm`) está no
> [Introducao_Docker_para_ambientes.md](https://github.com/charles-josiah/Aulas/blob/master/2025-10-Analise_de_Vulnerabilidade_e_Testes_de_Invasao/Introducao_Docker_para_ambientes.md),
> seção **"2. Comandos Básicos"**.

> [!TIP]
> `-d` = detached (background) · `-it` = interativo (abre terminal) ·
> `--rm` = remove após parar (descartável) · `:ro` = monta só leitura

### 1.3 Volumes e redes: como containers compartilham

#### Volumes — dados que sobrevivem ao container

Um container é **descartável**: tudo que é escrito dentro dele morre quando o
container é removido. Para persistir ou compartilhar dados, usamos **volumes** —
uma pasta do host "montada" dentro do container:

```bash
# Bind mount: pasta do host <-> pasta do container
docker run -v "$PWD/conf:/etc/nginx/conf.d:ro" nginx:alpine
#           pasta do host    pasta no container    :ro = read-only
```

- **Pasta do host** (`$PWD/conf`): você edita no editor normal do servidor
- **Pasta no container** (`/etc/nginx/conf.d`): o serviço lê de dentro
- **`:ro`** (read-only): o container não consegue alterar o arquivo (boa prática de segurança)
- **Volume nomeado**: `-v mqtt_data:/mosquitto/data` — o Docker gerencia a pasta, e os dados **persistem** mesmo com `docker compose down` (é assim que o broker do Workshop 04 guarda dados entre reinícios)

Comandos úteis:

```bash
docker volume ls                   # lista os volumes nomeados
docker volume inspect mqtt_data    # mostra onde o Docker guarda os dados
```

> [!NOTE]
> O documento
> [Introducao_Docker_para_ambientes.md](https://github.com/charles-josiah/Aulas/blob/master/2025-10-Analise_de_Vulnerabilidade_e_Testes_de_Invasao/Introducao_Docker_para_ambientes.md)
> detalha os **4 tipos de volume** (nomeado, anônimo, bind mount e efêmero)
> com exemplos práticos (persistir o HTML do Nginx, compartilhar um volume
> entre containers) e um comparativo de persistência de cada tipo.

#### Redes — como containers conversam entre si

Por padrão, o Docker cria uma rede **bridge** isolada por projeto. Containers do
mesmo compose se encontram pelo **nome do serviço** — o Docker DNS resolve o IP
automaticamente (sem IP fixo, sem configurar nada):

```bash
# Exemplo real (Workshop 04): o dashboard conecta no broker assim
#   MQTT_HOST=mosquitto      (nome do serviço, não o IP!)
# o Docker resolve "mosquitto" -> IP do container do broker na rede do compose
```

- `docker network ls` → lista as redes existentes
- `-p 8080:80` → expõe a porta do container no host — é a **única porta visível de fora**
- Sem `-p`, o container é **inacessível de fora** (isolamento por padrão — segurança!)
- Containers de projetos diferentes não se enxergam (redes isoladas entre si)

> [!NOTE]
> O mesmo documento de aprofundamento explica os **4 tipos de rede** do Docker
> (bridge, host, none e overlay), como criar redes personalizadas
> (`docker network create --driver bridge frontend-net`) e um exemplo de
> **topologia DMZ** com containers públicos e privados.

Isso conecta direto com os workshops: o lab do MQTT usa **volume** (`conf/`,
`mqtt_data`) e **rede** (o `mosquitto` como hostname do broker).

### 1.4 Anatomia de um `docker-compose.yml`

```yaml
services:
  web:                      # nome do serviço
    image: nginx:alpine     # imagem usada
    ports:
      - "8080:80"           # porta do host : porta do container
    volumes:
      - ./conf:/etc/nginx/conf.d:ro   # config local montada no container
  db:
    image: mariadb:10.5.2   # segundo serviço do mesmo compose
    environment:
      MYSQL_ROOT_PASSWORD: rootpwd   # variáveis de ambiente do container
volumes:
  mqtt_data:                # volume nomeado (persiste com down)
```

---

## Parte 2 — Subindo um serviço com autenticação (nginx + htpasswd)

Vamos subir um servidor web com **autenticação básica** (a mesma do
`auth_basic` do guia NGINX, mas containerizado). É propositalmente **sem TLS**:
as credenciais vão trafegar em texto claro.

```bash
# No srvdocker01 -----------------------------------------------------
mkdir -p /docker/aula-docker/nginx
cd /docker/aula-docker/nginx

# 1. Gerar o arquivo de usuários/senhas (htpasswd) usando um container
#    descartável da imagem httpd (que já vem com o binário htpasswd)
docker run --rm httpd:alpine htpasswd -bn admin senha123 > .htpasswd
cat .htpasswd        # admin:$apr1$... (hash, não é a senha em claro!)

# 2. Config do nginx com auth_basic
cat > default.conf <<'EOF'
server {
    listen 80;
    server_name _;
    auth_basic "Area Restrita - Lab Docker";
    auth_basic_user_file /etc/nginx/.htpasswd;
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF

# 3. Subir o container nginx com as duas montagens (:ro = read-only)
docker run -d --name nginx-aula -p 8080:80 \
  -v "$PWD/default.conf:/etc/nginx/conf.d/default.conf:ro" \
  -v "$PWD/.htpasswd:/etc/nginx/.htpasswd:ro" \
  nginx:alpine

# 4. Testar
curl -o /dev/null -w "%{http_code}\n" http://172.30.234.55:8080/       # 401
curl -u admin:senha123 -o /dev/null -w "%{http_code}\n" http://172.30.234.55:8080/   # 200
```

**Explicando os comandos novos:**
- `htpasswd -bn`: gera a linha `usuario:hash` sem pedir senha interativa (`-b` batch)
- `-v pasta_local:pasta_container`: monta um volume (a config é do host, o nginx lê de dentro)
- `:ro`: o container não consegue modificar o arquivo (boa prática de segurança)

---

## Parte 3 — Captura das credenciais com tshark/Wireshark

Agora o papel do **atacante**: o Kali observa a rede enquanto alguém faz login.

### 3.1 Capturar com tshark (no Kali)

```bash
# No Kali -------------------------------------------------------------
# 1. Iniciar captura da porta 8080 (6 segundos)
tshark -i eth0 -f "tcp port 8080" -a duration:6 -w /tmp/aula-docker.pcap

# 2. Em OUTRO terminal, gerar o tráfego com o login:
curl -u admin:senha123 -o /dev/null http://172.30.234.55:8080/
```

### 3.2 Analisar a captura (no Kali)

```bash
# Listar as requisições HTTP capturadas
tshark -r /tmp/aula-docker.pcap -Y "http.request" \
  -T fields -e frame.number -e http.request.method -e http.request.uri

# Extrair o header Authorization (onde está a credencial)
tshark -r /tmp/aula-docker.pcap -Y "http.authorization" \
  -T fields -e http.authorization
# Resultado: Basic YWRtaW46c2VuaGExMjM=
```

### 3.3 Decodificar o base64 (o "momento WOW")

```bash
echo "YWRtaW46c2VuaGExMjM=" | base64 -d
# Resultado: admin:senha123
```

**Por que isso é possível:** o HTTP Basic Auth envia
`Authorization: Basic base64(usuario:senha)`. O base64 **não é criptografia** —
é só uma codificação para transporte. Qualquer um na rede decodifica em 1 comando.

### 3.4 Ver no Wireshark (interface gráfica)

1. No Kali: `wireshark /tmp/aula-docker.pcap` (ou abrir o arquivo `.pcap`)
2. Digitar `http.authorization` no filtro de exibição
3. Clicar no pacote → expandir **Hypertext Transfer Protocol** → **Authorization**
4. O campo mostra `Basic YWRtaW46c2VuaGExMjM=` — e o Wireshark ainda decodifica
   a credencial na coluna: `Credentials: admin:senha123`

---

## Parte 4 — Lições e encerramento

1. **Docker é a base dos laboratórios**: ambientes isolados, reproduzíveis e descartáveis — o serviço vulnerável não contamina o host.
2. **HTTP sem TLS expõe tudo**: credencial (Basic Auth), formulários (POST), cookies — tudo legível na rede.
3. **Base64 não é segurança**: é codificação, não criptografia.
4. **A captura é passiva e silenciosa**: servidor e cliente não percebem nada.
5. **Próximos passos**: Workshop 01 (HTTP), 02 (FTP), 03 (MySQL), 04 (MQTT) —
   todos seguem o mesmo padrão: subir serviço com Docker, capturar com tshark,
   mostrar o dado vazando em claro, e concluir "por que TLS é essencial".

---

## Anexo — Limpeza do ambiente de aula

```bash
# Derrubar e remover o container da aula
docker stop nginx-aula && docker rm nginx-aula

# Remover a pasta da aula
rm -rf /docker/aula-docker
```

---

## Troubleshooting

| Erro | Causa | Solução |
|---|---|---|
| `docker: command not found` no srvdocker01 | Docker não instalado | `apt install docker docker-compose` + `systemctl enable --now docker` |
| `401` ao acessar mesmo com `-u` | Usuário/senha errados no `.htpasswd` | Regerar: `docker run --rm httpd:alpine htpasswd -bn admin senha123 > .htpasswd` |
| `Unable to find image 'nginx:alpine'` | Imagem não baixada | O `docker run` baixa sozinho (aguardar) |
| tshark sem permissão de captura | Usuário fora do grupo `wireshark` | `sudo usermod -aG wireshark kali` + relogar, ou `sudo tshark ...` |
| Nenhum pacote capturado | Captura em interface errada ou tráfego não passou pelo Kali | Conferir `ip -br addr` (use `eth0`), e gerar o `curl` **durante** a captura |
