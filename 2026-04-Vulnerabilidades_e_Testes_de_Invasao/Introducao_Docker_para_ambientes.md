# Uma introdução ao Docker no Ubuntu 24.04, com foco em sua aplicação em ambientes de Pentest e análise de segurança.

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
> Este laboratório foi testado e validado pelo instrutor. No entanto, o ecossistema de TI (versões de kernel, distribuições Linux, imagens Docker, ferramentas de rede e provedores de virtualização) evolui rapidamente.
>
> **Fique atento:**
> - A execução é permitida apenas em laboratório isolado (VM dedicada, Docker Lab, NAT/Host-Only ou rede segregada).
> - As técnicas demonstradas envolvem reconhecimento de host, descoberta de rede e enumeração de serviços, devendo permanecer restritas ao escopo autorizado do laboratório.
> - Ambientes de laboratório são sensíveis e dependentes de hardware, configuração de rede e versões de pacotes.
> - Falhas podem ocorrer devido a drivers, virtualização desativada (BIOS/VT-x/AMD-V), firewall local, ausência de pacotes ou conflitos de rede.
> - **Ajustes manuais podem ser necessários** durante o processo para adequar o lab à sua máquina específica.

---

## Índice

- [1. Instalação do Docker](#toc-1-instalacao-do-docker)
  - [1.1 O que é Docker](#toc-1-1-o-que-e-docker)
  - [1.2 Histórico: de dotCloud ao Docker](#toc-1-2-historico-de-dotcloud-ao-docker)
  - [1.3 Padronização: OCI, runc e containerd](#toc-1-3-padronizacao-oci-runc-e-containerd)
  - [1.4 Para onde vai: tendências técnicas](#toc-1-4-para-onde-vai-tendencias-tecnicas)
  - [1.5 Docker e Kubernetes: relação real](#toc-1-5-docker-e-kubernetes-relacao-real)
  - [1.6 Atualização e dependências](#toc-1-6-atualizacao-e-dependencias)
  - [1.7 Adicionando chave GPG e repositório Docker](#toc-1-7-adicionando-chave-gpg-e-repositorio-docker)
  - [1.8 Instalação e habilitação do serviço](#toc-1-8-instalacao-e-habilitacao-do-servico)
  - [1.9 Alterar a rede padrão do Docker (opcional)](#toc-1-9-alterar-a-rede-padrao-do-docker-opcional)
  - [1.10 Verificação](#toc-1-10-verificacao)
- [2. Comandos Básicos](#toc-2-comandos-basicos)
  - [2.1 Visualização](#toc-2-1-visualizacao)
  - [2.2 Remoção](#toc-2-2-remocao)
  - [2.3 Rodando containers](#toc-2-3-rodando-containers)
  - [2.4 Baixando imagens](#toc-2-4-baixando-imagens)
- [3. Volumes no Docker](#toc-3-volumes-no-docker)
  - [3.1 Tipos principais](#toc-3-1-tipos-principais)
  - [3.2 Comparativo rápido](#toc-3-2-comparativo-rapido)
  - [3.3 Dicas](#toc-3-3-dicas)
  - [3.4 Exemplos de uso](#toc-3-4-exemplos-de-uso)
- [4. Redes no Docker](#toc-4-redes-no-docker)
  - [4.1 Tipos de rede no Docker](#toc-4-1-tipos-de-rede-no-docker)
  - [4.2 Criar e conectar redes](#toc-4-2-criar-e-conectar-redes)
  - [4.3 Exemplo de topologia DMZ com Docker](#toc-4-3-exemplo-de-topologia-dmz-com-docker)
  - [4.4 Dicas](#toc-4-4-dicas)
- [5. Docker Compose](#toc-5-docker-compose)
  - [5.1 O que é](#toc-5-1-o-que-e)
  - [5.2 Instalação](#toc-5-2-instalacao)
  - [5.3 Exemplo de `docker-compose.yml`](#toc-5-3-exemplo-de-docker-composeyml)
  - [5.4 Comandos](#toc-5-4-comandos)
  - [5.5 Exemplos práticos com volumes](#toc-5-5-exemplos-praticos-com-volumes)
  - [5.6 Dica final](#toc-5-6-dica-final)

---

<a name="toc-1-instalacao-do-docker"></a>
## 1. Instalação do Docker

<a name="toc-1-1-o-que-e-docker"></a>
### 1.1 O que é Docker

Docker é um conjunto de ferramentas para **construir**, **distribuir** e **executar** aplicações empacotadas como **containers**. Em Linux, um container **não** é uma VM: containers compartilham o **mesmo kernel** do host e são isolados principalmente por mecanismos do kernel, como **namespaces** (visibilidade e isolamento) e **cgroups** (limites e contabilização de recursos).

Uma forma objetiva de enxergar o Docker em camadas:

- **Imagem:** pacote imutável em camadas (layers) que descreve filesystem e metadados de execução.
- **Container:** instância em execução de uma imagem, com uma camada gravável (copy-on-write).
- **Engine:** daemon `dockerd` + API + CLI, que prepara rede, storage, namespaces, limites e ciclo de vida.

Em segurança e pentest, isso importa porque "rodar em container" não elimina risco. Ele muda a fronteira de isolamento, a superfície de ataque (capabilities, mounts, namespaces, sockets) e a forma de auditar.

<a name="toc-1-2-historico-de-dotcloud-ao-docker"></a>
### 1.2 Histórico: de dotCloud ao Docker

O Docker surgiu como uma tecnologia interna na **dotCloud** (PaaS) e foi demonstrado publicamente em 2013, sendo aberto como projeto open source em março de 2013. As primeiras versões usavam **LXC** como base de execução; em 2014 (Docker 0.9), o projeto passou a manipular diretamente APIs do kernel via **libcontainer**, reduzindo dependências externas e consolidando um modelo mais previsível de execução.

Resultado prático dessa trajetória: o Docker popularizou o modelo de "build once, run anywhere" para aplicações, junto com um ecossistema de imagens, registries e pipelines.

<a name="toc-1-3-padronizacao-oci-runc-e-containerd"></a>
### 1.3 Padronização: OCI, runc e containerd

Com a popularização dos containers, emergiu a necessidade de padronização. Em 2015 foi criada a **Open Container Initiative (OCI)** para definir especificações abertas de **formato de imagem** e **runtime**. A partir desse movimento, consolidou-se uma separação mais clara entre:

- **Runtimes de alto nível** (ex.: `containerd`): gerenciam lifecycle, pull de imagens e integração com sistemas.
- **Runtimes de baixo nível** (ex.: `runc`): executam o container no kernel (namespaces, cgroups, mounts).

Essa padronização é o que torna viável trocar runtime sem "quebrar" imagens e fluxos de deploy.

<a name="toc-1-4-para-onde-vai-tendencias-tecnicas"></a>
### 1.4 Para onde vai: tendências técnicas

No ecossistema moderno, o Docker tende a aparecer como **ferramenta de desenvolvimento e empacotamento** (build, imagens, registries) e como **Engine** em ambientes mais simples. Ao mesmo tempo, há tendências fortes em:

- **Supply chain security:** assinatura de imagens, SBOM e evidências de build (proveniência).
- **Menos privilégio:** `rootless` e isolamento adicional (ex.: runtimes sandboxed em cenários sensíveis).
- **Formato como contrato:** OCI como base para distribuição de artefatos além de imagens tradicionais (incluindo workloads emergentes).

<a name="toc-1-5-docker-e-kubernetes-relacao-real"></a>
### 1.5 Docker e Kubernetes: relação real

Kubernetes é um **orquestrador** de containers. Ele não "depende" do Docker, mas depende de um runtime compatível com a **CRI** (Container Runtime Interface), como `containerd` ou `CRI-O`. Historicamente, Kubernetes conversava com o Docker Engine via `dockershim`; isso mudou e o `dockershim` foi removido do Kubernetes a partir da versão 1.24.

O ponto importante para o laboratório: **imagens construídas com Docker continuam válidas** (padrões OCI), mas o runtime no node pode não ser o Docker Engine. Na prática, o Docker segue central na "esteira" de build e testes locais, enquanto Kubernetes domina a orquestração em clusters.

<a name="toc-1-6-atualizacao-e-dependencias"></a>
### 1.6 Atualização e dependências
```bash
sudo apt update
sudo apt install ca-certificates curl -y
```

<a name="toc-1-7-adicionando-chave-gpg-e-repositorio-docker"></a>
### 1.7 Adicionando chave GPG e repositório Docker
```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
```

<a name="toc-1-8-instalacao-e-habilitacao-do-servico"></a>
### 1.8 Instalação e habilitação do serviço
```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER   # usuario que estou usando para instalar o Docker
```
> ℹ️ *É necessário reiniciar a sessão para que o usuário atual possa executar comandos `docker` sem `sudo`.*

> [!WARNING]
> **Nota de segurança (grupo `docker`):** adicionar um usuário ao grupo `docker` normalmente equivale a conceder capacidade administrativa no host, pois o Docker Engine pode criar containers, montar volumes e interagir com recursos do sistema via daemon. Em ambientes corporativos, trate essa permissão como privilegiada e conceda apenas quando houver necessidade real e rastreabilidade.

<a name="toc-1-9-alterar-a-rede-padrao-do-docker-opcional"></a>
### 1.9 Alterar a rede padrão do Docker (opcional)
Crie ou edite o arquivo:
```bash
sudo nano /etc/docker/daemon.json
```
Adicione ou altere para uma rede sem overlap:
```json
{
  "bip": "192.168.101.1/24" 
}
```
Reinicie o serviço:
```bash
sudo systemctl restart docker
```

<a name="toc-1-10-verificacao"></a>
### 1.10 Verificação
```bash
docker version
docker info
```

---

<a name="toc-2-comandos-basicos"></a>
## 2. Comandos Básicos

<a name="toc-2-1-visualizacao"></a>
### 2.1 Visualização
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

<a name="toc-2-2-remocao"></a>
### 2.2 Remoção
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

<a name="toc-2-3-rodando-containers"></a>
### 2.3 Rodando containers
#### 2.3.1 Testando container simples
```bash
docker run hello-world
```

#### 2.3.2 Rodar container temporário com saída no terminal
```bash
docker run --rm alpine echo "Olá do Alpine!"
```

#### 2.3.3 Rodar container interativo
```bash
docker run -it alpine /bin/sh
```
> *Executa um shell interativo dentro do container.*

#### 2.3.4 Acessar container já em execução
```bash
docker exec -it <nome ou id> /bin/sh
```

<a name="toc-2-4-baixando-imagens"></a>
### 2.4 Baixando imagens
```bash
docker pull ubuntu
docker pull nginx
```

---

<a name="toc-3-volumes-no-docker"></a>
## 3. Volumes no Docker

Volumes são usados para **armazenamento persistente** de dados em containers. Eles ficam fora do sistema de arquivos do container, permitindo que os dados sobrevivam à sua reinicialização ou exclusão.

<a name="toc-3-1-tipos-principais"></a>
### 3.1 Tipos principais

#### 3.1.1 Volumes nomeados
Criados e gerenciados pelo Docker. Ideal para manter dados entre reinicializações de containers.

Criados com:
```bash
docker volume create meu-volume
docker run -v meu-volume:/app alpine
```
- Persistem após remoção do container.
- Gerenciáveis com `docker volume ls`, `rm`, etc.

#### 3.1.2 Volumes anônimos
```bash
docker run -v /dados alpine
```
- Criados sem nome explícito.
- Difíceis de rastrear, usados para testes rápidos.
- Não usar na produção.

#### 3.1.3 Bind mounts
Montam diretórios locais do sistema operacional host dentro do container:
```bash
docker run -v $(pwd)/meus-dados:/dados alpine
```
- Úteis em ambiente de desenvolvimento (sincronização direta com arquivos locais).
- Permitem observar ou editar arquivos do container em tempo real.
- Permitem que serviços utilizem dados persistentes no host (ex.: web, banco de dados, cache).

#### 3.1.4 Armazenamento efêmero (tmpfs)
Para dados realmente efêmeros (não persistidos no host), use `tmpfs`:
```bash
docker run --rm --tmpfs /dados alpine sh -c "echo 'temporario' > /dados/t.txt && ls -l /dados"
```
- O conteúdo existe apenas enquanto o container está em execução.
- Ao finalizar o container, os dados são descartados.


<a name="toc-3-2-comparativo-rapido"></a>
### 3.2 Comparativo rápido

| Tipo de Volume  | Persistência | Uso Ideal                   |
|-----------------|--------------|-----------------------------|
| Nomeado         | ✅           | Dados duráveis (DBs, cache) |
| Anônimo         | ⚠️           | Testes rápidos              |
| Bind mount      | ✅ (host)    | Desenvolvimento local       |
| Efêmero (`tmpfs`)| ❌          | Execuções descartáveis      |

<a name="toc-3-3-dicas"></a>
### 3.3 Dicas
- Sempre prefira volumes nomeados para dados que precisam persistir.
- Evite bind mounts em produção: segurança e permissões são mais difíceis de controlar.
- Use docker volume inspect para ver detalhes de qualquer volume.

```bash
docker run --rm -v meu-volume:/volume -v $(pwd):/backup alpine \
  tar czf /backup/volume.tar.gz -C /volume .
```
<a name="toc-3-4-exemplos-de-uso"></a>
### 3.4 Exemplos de uso

#### 3.4.1 Persistência de conteúdo web com volume nomeado (Nginx)

```bash
docker volume create conteudo-nginx

docker run -d \
  --name nginx-web \
  -v conteudo-nginx:/usr/share/nginx/html \
  -p 8080:80 \
  nginx
```

> **Resultado**: os arquivos HTML que o Nginx serve ficam armazenados no volume `conteudo-nginx`. Mesmo que o container seja removido, o conteúdo persiste.


#### 3.4.2 Conectar um container a diferentes volumes

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

> **Resultado**: demonstramos como um container pode usar volumes diferentes para armazenar dados distintos em momentos diferentes.


#### 3.4.3 Servindo arquivos HTML locais com Nginx

#### 3.4.3.1 Crie um diretório com um arquivo HTML

```bash
mkdir html-site
echo "<h1>Olá, Docker com Bind Mount!</h1>" > html-site/index.html
```

#### 3.4.3.2 Execute o container com bind mount

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

#### 3.4.3.3 Acesse no navegador

```
http://localhost:8081
```

> **Resultado**: o Nginx vai servir diretamente o arquivo `index.html` do diretório local `html-site`.


<a name="toc-4-redes-no-docker"></a>
## 4. Redes no Docker

---

<a name="toc-4-1-tipos-de-rede-no-docker"></a>
### 4.1 Tipos de rede no Docker

Em Linux, o Docker implementa networking combinando **network namespaces** (cada container com sua pilha de rede), pares **veth** (interfaces virtuais conectando namespace do container ao host), bridges Linux e regras de firewall/NAT (iptables/nftables). A escolha do driver de rede define **o nível de isolamento**, **o caminho de tráfego** e **a forma de exposição** de portas.

Abaixo estão os drivers mais comuns em ambientes de laboratório e produção:

1. **bridge** (padrão em hosts standalone)
   - Cria uma rede L2/L3 privada no host (bridge Linux como `docker0` ou `br-...`).
   - Containers recebem IP privado e se comunicam dentro da mesma bridge via veth.
   - Em redes *user-defined bridge*, há **resolução automática por nome/alias** (DNS embutido), o que simplifica stacks e composes.
   - Publicação de portas (`-p HOST:CONTAINER`) costuma envolver regras de NAT e filtragem no host.

2. **host**
   - O container compartilha a pilha de rede do host (sem namespace de rede dedicado).
   - Reduz isolamento e aumenta o risco de colisão de portas e de exposição acidental.
   - Útil para casos específicos de performance ou integração, mas geralmente deve ser tratado como exceção controlada.

3. **none**
   - O container inicia sem interface de rede (além do loopback), ficando isolado.
   - Útil para tarefas offline, processamento local ou cenários onde rede é uma superfície a ser eliminada.

4. **overlay** (multi-host)
   - Cria uma rede distribuída entre múltiplos hosts Docker, tipicamente encapsulando tráfego (ex.: VXLAN).
   - É o modelo usado quando se precisa de comunicação transparente entre containers em hosts diferentes (ex.: Swarm).
   - Em Kubernetes, a conectividade multi-host costuma ser provida por plugins CNI, não pelo driver overlay do Docker diretamente.

**Observação acadêmica:** "rede de container" não é um detalhe operacional; ela define o perímetro. Em auditoria, o que importa é: onde a aplicação escuta, quais portas estão publicadas no host, como o tráfego cruza namespaces e quais regras de filtragem estão ativas.

---

<a name="toc-4-2-criar-e-conectar-redes"></a>
### 4.2 Criar e conectar redes

#### 4.2.1 Criar rede personalizada
```bash
docker network create --driver bridge frontend-net
docker network create --driver bridge backend-net
```

#### 4.2.2 Executar containers conectados às redes
```bash
# Exposto ao público
docker run -dit --name nginx-front --network frontend-net nginx

# Backend 1 e 2
docker run -dit --name api1 --network backend-net alpine sh
docker run -dit --name api2 --network backend-net alpine sh
```

#### 4.2.3 Conectar container a múltiplas redes
```bash
docker network connect backend-net nginx-front
```

Agora `nginx-front` está tanto em `frontend-net` (exposição) quanto em `backend-net` (comunicação interna).

---

<a name="toc-4-3-exemplo-de-topologia-dmz-com-docker"></a>
### 4.3 Exemplo de topologia DMZ com Docker

#### 4.3.1 Objetivo
Simular uma arquitetura com:
- 1 container público (DMZ)
- 2 containers privados (backend)

#### 4.3.2 Topologia

```
[internet] → [nginx-front] → [api1, api2]
        frontend-net       backend-net
```

#### 4.3.3 Passos

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
# A imagem oficial do nginx pode não incluir ferramentas como `ping`.
# Para validar DNS e conectividade sem depender do que existe dentro do nginx,
# use um container de diagnóstico temporário na mesma rede.
docker run --rm --network backend-net busybox ping -c 1 api1
docker run --rm --network backend-net busybox ping -c 1 api2
docker run --rm --network backend-net busybox ping -c 1 nginx-front
```

---

<a name="toc-4-4-dicas"></a>
### 4.4 Dicas

- Use `--subnet` e `--gateway` no `docker network create` para segmentar IPs:
```bash
docker network create --subnet=192.168.100.0/24 --gateway=192.168.100.1 dmz-net
```

- `docker network disconnect` remove uma rede de um container.
- `docker network rm <nome-da-rede>` remove completamente a rede no docker, necessário desconectar as rede do cluster.
- Use `docker network inspect` para examinar topologias e IPs atribuídos.

---


<a name="toc-5-docker-compose"></a>
## 5. Docker Compose

<a name="toc-5-1-o-que-e"></a>
### 5.1 O que é
O **Docker Compose** é uma ferramenta oficial do Docker que permite definir e executar **aplicações multicontainer** de forma simples e organizada, usando um único arquivo de configuração chamado `docker-compose.yml`.

Com ele, você descreve:
- Serviços (containers a serem executados)
- Imagens ou Dockerfiles
- Volumes (bind ou named)
- Redes personalizadas
- Dependências entre containers

É amplamente utilizado para **ambientes de desenvolvimento, testes e até produção**, por automatizar a criação, configuração e interconexão de múltiplos containers.



<a name="toc-5-2-instalacao"></a>
### 5.2 Instalação
```bash
sudo apt install docker-compose-plugin -y
```

<a name="toc-5-3-exemplo-de-docker-composeyml"></a>
### 5.3 Exemplo de `docker-compose.yml`
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

<a name="toc-5-4-comandos"></a>
### 5.4 Comandos

- Subir os containers:
  ```bash
  docker compose up -d
  ```

- Ver status:
  ```bash
  docker compose ps
  ```

- Parar e remover tudo:
  ```bash
  docker compose down
  ```

- Ver logs dos serviços:
  ```bash
  docker compose logs -f
  ```

<a name="toc-5-5-exemplos-praticos-com-volumes"></a>
### 5.5 Exemplos práticos com volumes

#### 5.5.1 Bind mount para desenvolvimento web

#### 5.5.1.1 Estrutura de diretórios
```
projeto/
├── docker-compose.yml
└── site/
    └── index.html
```

#### 5.5.1.2 Conteúdo `docker-compose.yml`
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

#### 5.5.2 Volume nomeado para banco de dados PostgreSQL

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

#### 5.5.3 Compartilhamento de volume entre serviços

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

<a name="toc-5-6-dica-final"></a>
### 5.6 Dica final

- O Docker Compose simplifica a orquestração local e pode ser estendido com **perfis**, **overrides**, e integração com **Docker Swarm**.
- Combine volumes e redes para simular topologias complexas de forma prática.
- Mais exemplos: https://github.com/charles-josiah/docker

---

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/Introducao_Docker_para_ambientes.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>
