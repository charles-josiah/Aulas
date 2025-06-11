# Docker no Ubuntu 24.04


## Instalação do Docker 

### Atualização e dependências:
```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
```

### Adicionando chave GPG e repositório Docker:
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
```

### Instalação:
```bash
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER   #user que estou usando para instalar o docker
```
> ℹ️ *É necessário reiniciar a sessão para que o usuário atual possa executar comandos `docker` sem `sudo`.*


### Alterar a rede padrão do Docker (caso de conflito com rede local):
Crie ou edite o arquivo:
```bash
sudo nano /etc/docker/daemon.json
```
Adicione ou altere para um rede sem overlap:
```json
{
  "bip": "192.168.101.1/24" 
}
```
Reinicie o serviço:
```bash
sudo systemctl restart docker
```


### Verificação:
```bash
docker version
docker info
```

---

## 2. Comandos Básicos

### Visualização:
- Ver containers em execução:
```bash
docker ps
```
- Ver todos os containers (inclusive parados):
```bash
docker ps -a
```
- Ver imagens baixadas localmente:
```bash
docker images
```
- Ver redes existentes:
```bash
docker network ls
```
- Ver volumes criados:
```bash
docker volume ls
``` 

### Remoção:
- Remover container parado:
```bash
docker rm <id|nome>
```
- Remover imagem local:
```bash
docker rmi <imagem>
```
- Remover rede:
```bash
docker network rm <nome>
```
- Remover volume:
```bash
docker volume rm <nome>
```

### Rodando containers:
### Testando container simples:
```bash
docker run hello-world
```

### Rodar container temporário com saída no terminal:
```bash
docker run --rm alpine echo "Olá do Alpine!"
```

### Rodar container interativo:
```bash
docker run -it alpine /bin/sh
```
> *Executa um shell interativo dentro do container.*

### Acessar container já em execução:
```bash
docker exec -it <nome ou id> /bin/sh
```
c


### Baixando imagens:
```bash
docker pull ubuntu
docker pull nginx
```

---

## Volumes no Docker – Conceitos e Prática

Volumes são usados para **armazenamento persistente** de dados em containers. Eles ficam fora do sistema de arquivos do container, permitindo que os dados sobrevivam à sua reinicialização ou exclusão.

### 🔸 Tipos principais

#### 1. Volumes nomeados
Criados e gerenciados pelo Docker. Ideal para manter dados entre reinicializações de containers.

Criados com:
```bash
docker volume create meu-volume
docker run -v meu-volume:/app alpine
```
- Persistem após remoção do container.
- Gerenciáveis com `docker volume ls`, `rm`, etc.

#### 2. Volumes anônimos
```bash
docker run -v /dados alpine
```
- Criados sem nome explícito.
- Difíceis de rastrear, usados para testes rápidos.
- Nao usar na produção

#### 3. Bind mounts
Montam diretórios locais do sistema operacional host dentro do container:
```bash
docker run -v $(pwd)/meus-dados:/dados alpine
```
- Úteis em ambiente de desenvolvimento (sincronização direta com arquivos locais).
- Permitem observar ou editar arquivos do container em tempo real.
- Premitem servidor utilizarem dados persistentes como serivços web, banco de dados, e outros. 

#### 4. Volumes efêmeros
Volumes efêmeros são aqueles não persistidos entre execuções. 
Um exemplo típico ocorre com a flag --rm e sem o uso de volumes nomeados:

Com `--rm`, dados não persistem:
```bash
docker run --rm -v /tmp:/dados alpine
```
- Quando o container termina, o volume não é reutilizável.
- Ideal para operações transitórias ou temporárias.


### Comparativo rápido

| Tipo de Volume  | Persistência | Uso Ideal                   |
|-----------------|--------------|-----------------------------|
| Nomeado         | ✅           | Dados duráveis (DBs, cache) |
| Anônimo         | ⚠️           | Testes rápidos              |
| Bind mount      | ✅ (host)    | Desenvolvimento local       |
| Efêmero (`--rm`)| ❌           | Execuções descartáveis      |

### Dicas
- Sempre prefira volumes nomeados para dados que precisam persistir.
- Evite bind mounts em produção: segurança e permissões são mais difíceis de controlar.
- Use docker volume inspect para ver detalhes de qualquer volume.

```bash
docker run --rm -v meu-volume:/volume -v $(pwd):/backup alpine \
  tar czf /backup/volume.tar.gz -C /volume .
```
### Exemplos de Uso 

### 1. Persistência de conteúdo web com volume nomeado (Nginx)

```bash
docker volume create conteudo-nginx

docker run -d \
  --name nginx-web \
  -v conteudo-nginx:/usr/share/nginx/html \
  -p 8080:80 \
  nginx
```

📁 **Resultado**: os arquivos HTML que o Nginx serve ficam armazenados no volume `conteudo-nginx`. Mesmo que o container seja removido, o conteúdo persiste.


### 2. Conectar um container a diferentes volumes

#### 1. Conectando ao primeiro volume:

```bash
docker volume create dados-v1

docker run -dit --name app1 -v dados-v1:/app alpine /bin/sh
docker exec -it app1 sh -c "echo 'Versão 1' > /app/versao.txt"
```

#### 2. Conectando ao segundo volume:

```bash
docker volume create dados-v2

docker container rm -f app1

docker run -dit --name app2 -v dados-v2:/app alpine /bin/sh
docker exec -it app2 sh -c "echo 'Versão 2' > /app/versao.txt"
```

#### 3. Conferindo os conteúdos:

```bash
docker run --rm -v dados-v1:/check alpine cat /check/versao.txt
# Saída: Versão 1

docker run --rm -v dados-v2:/check alpine cat /check/versao.txt
# Saída: Versão 2
```

📁 **Resultado**: demonstramos como um container pode usar volumes diferentes para armazenar dados distintos em momentos diferentes.


### 3. Exemplo: Servindo arquivos HTML locais com Nginx

#### Crie um diretório com um arquivo HTML:

```bash
mkdir html-site
echo "<h1>Olá, Docker com Bind Mount!</h1>" > html-site/index.html
```

#### Execute o container com bind mount:

```bash
docker run -d \
  --name nginx-bind \
  -v $(pwd)/html-site:/usr/share/nginx/html:ro \
  -p 8081:80 \
  nginx
```

- `$(pwd)/html-site`: caminho do diretório local.
- `/usr/share/nginx/html`: diretório onde o Nginx busca os arquivos.
- `:ro`: monta como *somente leitura* (opcional, para segurança).

#### 3️⃣ Acesse no navegador:

```
http://localhost:8081
```

📁 **Resultado**: o Nginx vai servir diretamente o arquivo `index.html` do diretório local `html-site`.


## Redes no Docker – Tipos, Operações e Exemplo de DMZ

---

### 🔸 Tipos de Rede no Docker

1. **bridge** (padrão)
   - Rede NAT privada gerenciada pelo Docker.
   - Containers podem se comunicar entre si usando nomes.
   - Ideal para redes isoladas no host.

2. **host**
   - Container compartilha a pilha de rede do host.
   - Sem isolamento: acesso direto à rede externa.
   - Mais rápido, mas menos seguro.

3. **none**
   - Sem rede conectada.
   - Container sem acesso à internet ou a outros containers.
   - Útil para tarefas totalmente isoladas.

4. **overlay**
   - Usado com Docker Swarm para redes entre hosts.
   - Requer orquestração, ex. Swarm, ativa.

---

### Criar e Conectar Redes

#### Criar rede personalizada:
```bash
docker network create --driver bridge frontend-net
docker network create --driver bridge backend-net
```

#### Executar containers conectados às redes:
```bash
# Exposto ao público
docker run -dit --name nginx-front --network frontend-net nginx

# Backend 1 e 2
docker run -dit --name api1 --network backend-net alpine sh
docker run -dit --name api2 --network backend-net alpine sh
```

#### Conectar container a múltiplas redes:
```bash
docker network connect backend-net nginx-front
```

Agora `nginx-front` está tanto em `frontend-net` (exposição) quanto em `backend-net` (comunicação interna).

---

### Exemplo de Topologia "DMZ" com Docker

#### Objetivo:
Simular uma arquitetura com:
- 1 container público (DMZ)
- 2 containers privados (backend)

#### Topologia:

```
[internet] → [nginx-front] → [api1, api2]
        frontend-net       backend-net
```

#### Passos:

1. Criar redes:
```bash
docker network create frontend-net
docker network create backend-net
```

2. Subir containers:
```bash
docker run -dit --name api1 --network backend-net alpine sh
docker run -dit --name api2 --network backend-net alpine sh

docker run -dit --name nginx-front --network frontend-net nginx
docker network connect backend-net nginx-front
```

3. Verificar redes:
```bash
docker inspect nginx-front | grep -i network
```

4. (Opcional) Testar comunicação:
```bash
docker exec -it nginx-front ping api1
docker exec -it nginx-front ping api2
```

---

### Dicas

- Use `--subnet` e `--gateway` no `docker network create` para segmentar IPs:
```bash
docker network create --subnet=192.168.100.0/24 --gateway=192.168.100.1 dmz-net
```

- `docker network disconnect` remove uma rede de um container.
- `docker network rm <nome-da-rede>` remove completamente a rede no docker, necessário desconectar as rede do cluster.
- Use `docker network inspect` para examinar topologias e IPs atribuídos.

---


## 📄 4. Introdução ao Docker Compose (20 min)

### O que é:
O **Docker Compose** é uma ferramenta oficial do Docker que permite definir e executar **aplicações multicontainer** de forma simples e organizada, usando um único arquivo de configuração chamado `docker-compose.yml`.

Com ele, você descreve:
- Serviços (containers a serem executados)
- Imagens ou Dockerfiles
- Volumes (bind ou named)
- Redes personalizadas
- Dependências entre containers

É amplamente utilizado para **ambientes de desenvolvimento, testes e até produção**, por automatizar a criação, configuração e interconexão de múltiplos containers.



### Instalação:
```bash
sudo apt install docker-compose -y
```

### Exemplo de `docker-compose.yml`:
```yaml
version: '3'
services:
  web:
    image: nginx
    ports:
      - "8080:80"
  alpine:
    image: alpine
    command: tail -f /dev/null
```

### Comandos:

- Subir os containers:
  ```bash
  docker-compose up -d
  ```

- Ver status:
  ```bash
  docker-compose ps
  ```

- Parar e remover tudo:
  ```bash
  docker-compose down
  ```

- Ver logs dos serviços:
  ```bash
  docker-compose logs -f
  ```

### Exemplos práticos com volumes

### Exemplo 1: Bind mount para desenvolvimento web

#### Estrutura de diretórios:
```
projeto/
├── docker-compose.yml
└── site/
    └── index.html
```

#### Conteúdo `docker-compose.yml`:
```yaml
version: '3'
services:
  web:
    image: nginx
    ports:
      - "8080:80"
    volumes:
      - ./site:/usr/share/nginx/html:ro
```
> O Nginx serve os arquivos do diretório local `site/` com atualização instantânea.

### Exemplo 2: Volume nomeado para banco de dados PostgreSQL

```yaml
version: '3'
services:
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: exemplo123
    volumes:
      - dados-pg:/var/lib/postgresql/data

volumes:
  dados-pg:
```
> Os dados do banco são armazenados em um volume persistente chamado `dados-pg`.

### Exemplo 3: Compartilhamento de volume entre serviços

```yaml
version: '3'
services:
  writer:
    image: alpine
    command: sh -c "echo 'gerado no volume' > /compartilhado/info.txt && tail -f /dev/null"
    volumes:
      - volume-comp:/compartilhado

  reader:
    image: alpine
    depends_on:
      - writer
    command: sh -c "sleep 2 && cat /compartilhado/info.txt"
    volumes:
      - volume-comp:/compartilhado

volumes:
  volume-comp:
```

> Dois containers compartilham o mesmo volume: um escreve, o outro lê.

### Dica final

- O Docker Compose simplifica a orquestração local e pode ser estendido com **perfis**, **overrides**, e integração com **Docker Swarm**.
- Combine volumes e redes para simular topologias complexas de forma prática.
- Mais exemplos: https://github.com/charles-josiah/docker


---
## Monitoramento de Vulnerabilidades com Docker

### Por que monitorar vulnerabilidades em containers?

Mesmo usando imagens oficiais, containers podem conter pacotes desatualizados ou vulneráveis. Monitorar vulnerabilidades garante que sua infraestrutura não esteja exposta a riscos conhecidos — especialmente em ambientes de produção, onde falhas de segurança podem ser exploradas rapidamente.

O uso de ferramentas de varredura automatizada permite identificar **CVE (Common Vulnerabilities and Exposures)** em imagens e aplicações rodando em containers.

---

###  Exemplo 1: Usando OpenVAS (Greenbone Vulnerability Manager)

O OpenVAS é uma plataforma completa de **varredura de vulnerabilidades de rede**, podendo detectar milhares de falhas conhecidas em serviços, sistemas operacionais, servidores web, etc.

#### Executar o OpenVAS via Docker:

```bash
docker run -d -p 8080:9392 --name openvas mikesplain/openvas
```

#### Acessar via navegador:

```
http://localhost:8080
Usuário: admin
Senha: admin (ou consultar via `docker logs openvas`)
```

> Ideal para varreduras externas em máquinas da rede ou em containers com serviços expostos.


### Exemplo 2: Usando Trivy (scanner de imagem leve)

Trivy é um scanner de vulnerabilidades moderno e rápido, usado para inspecionar imagens antes de enviá-las para produção.

#### Instalar Trivy:
```bash
sudo apt install trivy  # ou usar via Docker
```

#### Rodar varredura em uma imagem:
```bash
trivy image nginx
```
> Retorna lista de vulnerabilidades por severidade, pacote e CVE.


### Exemplo 3: Clair – Scanner de Imagens Docker

Clair é um scanner popular para **pipelines CI/CD** que inspeciona imagens e armazena relatórios de vulnerabilidade.

#### Exemplo básico com Docker Compose:

```bash
git clone https://github.com/quay/clair
cd clair
docker-compose up
```
> Integra-se facilmente com registries como Harbor ou Quay.io.


### Exemplo 4: Exemplo: Scanner com Nmap contra um container vulnerável (CVE)

 Exemplo: Scanner com Nmap contra um Container Vulnerável (DVWA)

### Objetivo

Simular um ambiente de teste onde:
- Um container roda uma aplicação **vulnerável (DVWA)**.
- Outro container executa **Nmap** para inspecionar serviços e versões expostas.


#### 1. Criar rede isolada para o laboratório

```bash
docker network create lab-net
```

#### 2. Subir o container DVWA (Damn Vulnerable Web Application)

```bash
docker run -d \
  --name dvwa \
  --network lab-net \
  -e MYSQL_ROOT_PASSWORD=dvwa \
  -e MYSQL_PASSWORD=dvwa \
  -e MYSQL_USER=dvwa \
  -e MYSQL_DATABASE=dvwa \
  vulnerables/web-dvwa
```

> Aguarde 20–30 segundos até o serviço inicializar.

#### 3. Executar Nmap contra o DVWA

```bash
docker run --rm -it \
  --name scanner \
  --network lab-net \
  instrumentisto/nmap \
  nmap -sV dvwa
```
> Esse comando realiza um **scan de versão (-sV)** contra o hostname `dvwa`, resolvido pela rede interna Docker.

> Resultado: Nmap detectará os serviços ativos da DVWA (geralmente Apache, MySQL) e suas versões — você pode usar isso como base para validar a presença de vulnerabilidades conhecidas (CVE).

#### 4. Opcional: Rodar Trivy para inspeção de CVEs diretamente na imagem
```bash 
trivy image vulnerables/web-dvwa
```
> Esse comando realiza um **scan** contra a imagem do dvwa

---

#### Outras ferramentas úteis

- **Anchore Engine** – escaneia imagens e aplica políticas de segurança.
- **Grype** – scanner rápido da Anchore, com suporte nativo a várias distros.
- **Dockle** – verifica práticas de segurança em configurações Dockerfiles.

---

## Dicas Finais

- Use volumes para persistência de dados.
- Evite `:latest`; use tags específicas.
- Segurança: use usuário não root nos containers.
- Use `.dockerignore` como o `.gitignore`.
- Separe ambientes de dev/prod nos `docker-compose.yml`.

---
