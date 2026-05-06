# 🐳 Proposta de Estrutura do Laboratorio Baseada em Docker

---

> [!CAUTION]
> **AVISO DE ETICA E RESPONSABILIDADE**
> Este ambiente foi projetado exclusivamente para fins educacionais, laboratoriais e de pesquisa em ambiente controlado.
>
> **Nao utilizar em ambiente produtivo.**
>
> Uso vedado em:
>
> - ambientes de producao;
> - sistemas de terceiros sem autorizacao formal;
> - qualquer contexto que viole normas legais.
>
> Execucao permitida apenas em laboratorio isolado (VM dedicada, Docker Lab ou rede segregada).

---

## 📌 Visao geral

O laboratorio deixa de ser baseado em multiplas VMs e passa a utilizar:

- uma unica VM de gerenciamento (Host Docker);
- containers como alvos vulneraveis.

O Kali Linux atuara como maquina atacante, explorando uma rede virtual interna criada pelo Docker.

---

## 🧠 1. Topologia recomendada (logica e rede)

Para garantir isolamento e simulacao realista, sera utilizada uma rede Docker do tipo `bridge`.

Sugestao:

Topologia do laboratorio Docker recomendada

### 1.1 Estrutura logica

- Host Docker (VM principal);
- switch virtual Docker (rede interna);
- containers vulneraveis conectados a rede;
- Kali Linux acessando via rede do host.

### 1.2 Componentes da topologia

#### Host Docker (servidor de alvos)

- VM Linux leve (Ubuntu Server ou Debian);
- executa o Docker Engine;
- possui IP na rede do laboratorio.

#### Rede Docker `lab_vulneravel`

- tipo: bridge;
- subnet: `172.18.0.0/16`;
- rede isolada para os alvos.

---

## ⚙️ 2. Detalhamento dos componentes

### 2.1 Maquina atacante (fora da rede Docker)


| Componente              | Funcao                              | Acesso a rede                   |
| ----------------------- | ----------------------------------- | ------------------------------- |
| **Kali Linux / Parrot** | Varredura, exploracao e ataques web | Deve pingar o IP do Host Docker |


Observacoes:

- o Kali deve conseguir pingar o Host Docker;
- para acessar containers, usar portas mapeadas ou configurar rota estatica.

### 2.2 Alvos vulneraveis (containers Docker)

Cada servico roda isoladamente em container.

Caracteristica importante: estado nao persistente (reset automatico ao reiniciar).


| Alvo                | Imagem Docker                 | Portas (Host:Container)         | Foco principal                             | Nivel didatico |
| ------------------- | ----------------------------- | ------------------------------- | ------------------------------------------ | -------------- |
| **Metasploitable2** | `tleemcjr/metasploitable2`    | `2121:21`, `2222:22`, `8181:80` | Servicos de rede legados                   | Iniciante      |
| **DVWA**            | `vulnerables/web-dvwa`        | `8080:80`                       | Vulnerabilidades web classicas (PHP/MySQL) | Iniciante      |
| **Juice Shop**      | `bkimminich/juice-shop`       | `3000:3000`                     | Falhas web modernas (API/JS)               | Intermediario  |
| **Vulnerable API**  | `roottusk/vulnerable-api`     | `8888:8080`                     | OWASP API Security Top 10                  | Intermediario  |
| **ImageMagick**     | `vulhub/imagemagick:7.0.1-10` | N/A                             | Exploracao de CVEs de sistema              | Intermediario  |


---

## 🧩 3. Implementacao com Docker Compose

Para padronizar e facilitar o uso, utilize o ficheiro `[lab-seguranca/docker-compose.yml](https://github.com/charles-josiah/Aulas/blob/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/lab-seguranca/docker-compose.yml)` (inclui **Portainer** para gestao visual dos containers).

### 3.1 Pre-requisitos minimos

- Host Linux com Docker Engine instalado e em execucao;
- Docker Compose plugin habilitado (`docker compose version`);
- minimo recomendado: 4 vCPU, 8 GB RAM e 30 GB livres;
- conectividade com Docker Hub para pull das imagens;
- usuario com permissao para executar comandos Docker.

### 3.2 Ficheiro `lab-seguranca/docker-compose.yml`

O compose completo (rede `lab_vulneravel`, alvos didaticos e **Portainer** para gestao por interface) esta versionado no repositorio:


| Acao                      | Link                                                                                                                                                                                                     |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Ver no GitHub             | [Proposta em `lab-seguranca/docker-compose.yml` no repositorio Aulas](https://github.com/charles-josiah/Aulas/blob/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/lab-seguranca/docker-compose.yml) |
| **Download direto (raw)** | [docker-compose.yml (raw)](https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/lab-seguranca/docker-compose.yml)                                  |


**Descarregar pela linha de comandos** (grava `docker-compose.yml` na pasta atual):

```bash
curl -fsSL -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/lab-seguranca/docker-compose.yml
```

**Conteudo completo para copiar/colar** — grave como `docker-compose.yml` ou `docker-compose.yaml` na pasta onde vai executar `docker compose up -d` (e o mesmo conteudo do [ficheiro no repo](https://github.com/charles-josiah/Aulas/blob/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/lab-seguranca/docker-compose.yml)):

```yaml
# Laboratorio didatico — rede isolada + alvos vulneraveis + Portainer (gestao via UI)
# Uso: na pasta deste ficheiro, executar: docker compose up -d
# Requisito: Docker Engine com plugin Compose; utilizador com permissao ao socket Docker.

networks:
  lab_vulneravel:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16

volumes:
  portainer_data:

services:
  # Interface web para gerir containers, imagens e volumes (facilita o uso do laboratorio)
  portainer:
    image: portainer/portainer-ce:latest
    container_name: lab_portainer
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.2
    ports:
      - "9443:9443"

  # Alvo 1: Metasploitable2 (ambiente legado)
  metasploitable2:
    image: tleemcjr/metasploitable2
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.10
    ports:
      - "2121:21"
      - "2222:22"
      - "8181:80"
    restart: unless-stopped

  # Alvo 2: DVWA (aplicacao web classica)
  dvwa:
    image: vulnerables/web-dvwa
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.20
    ports:
      - "8080:80"
    environment:
      - DBMS_TYPE=MySQL
    restart: unless-stopped

  # Alvo 3: OWASP Juice Shop (aplicacao moderna)
  juice-shop:
    image: bkimminich/juice-shop
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.30
    ports:
      - "3000:3000"
    restart: unless-stopped

  # Alvo 4: Vulnerable API
  vulnerable-api:
    image: roottusk/vulnerable-api
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.40
    ports:
      - "8888:8080"
    restart: unless-stopped
```

> **Nota:** Em clone local do repo, o mesmo texto esta em `2026-04-Vulnerabilidades_e_Testes_de_Invasao/lab-seguranca/docker-compose.yml`.

---

## 🚀 4. Guia operacional

Apos configurar o Host Docker e obter o ficheiro `docker-compose.yml` (pasta de trabalho = diretorio onde o ficheiro esta), execute os comandos abaixo.

### 4.1 Inicializacao do laboratorio

```bash
cd /caminho/para/pasta/com/docker-compose.yml
docker compose up -d
```

### 4.2 Verificacao do estado dos servicos

```bash
docker compose ps
```

### 4.3 Reinicializacao de um servico especifico

Exemplo (DVWA):

```bash
docker compose restart dvwa
```

### 4.4 Validacao pos-subida (checklist rapido)

- `docker compose ps` mostra os servicos como `running`;
- `https://<IP_DO_HOST_DOCKER>:9443` abre o Portainer (avisar excecao de certificado se necessario);
- `http://<IP_DO_HOST_DOCKER>:8080` abre a DVWA;
- `http://<IP_DO_HOST_DOCKER>:3000` abre a Juice Shop;
- `http://<IP_DO_HOST_DOCKER>:8888` responde a API vulneravel.

### 4.5 Acesso as aplicacoes

Substitua `<IP_DO_HOST_DOCKER>` pelo endereco IP da VM ou maquina onde o Docker expoe as portas (visto a partir do Kali ou da rede do laboratorio).

#### Portas publicadas no host (mapeamento Host:Container)


| Porta no host | Porta dentro do container | Servico / uso                       |
| ------------- | ------------------------- | ----------------------------------- |
| **9443**      | 9443                      | Portainer (HTTPS) — gestao visual   |
| **8181**      | 80                        | Metasploitable2 — HTTP (web legada) |
| **2121**      | 21                        | Metasploitable2 — FTP               |
| **2222**      | 22                        | Metasploitable2 — SSH               |
| **8080**      | 80                        | DVWA                                |
| **3000**      | 3000                      | Juice Shop                          |
| **8888**      | 8080                      | Vulnerable API                      |


**Exemplos de URL / cliente** (troque `<IP_DO_HOST_DOCKER>`):

- Gestao: `https://<IP_DO_HOST_DOCKER>:9443` (HTTPS; certificado autoassinado — aceitar excecao em laboratorio; criar admin na primeira vez).
- Metasploitable2 web: `http://<IP_DO_HOST_DOCKER>:8181` (equivale ao HTTP na porta 80 **dentro** do container).
- Metasploitable2 FTP: `ftp://<IP_DO_HOST_DOCKER>:2121` ou `ftp <IP_DO_HOST_DOCKER> 2121` (servico na porta 21 **dentro** do container).
- Metasploitable2 SSH: `ssh <usuario>@<IP_DO_HOST_DOCKER> -p 2222` (SSH na porta 22 **dentro** do container).
- DVWA: `http://<IP_DO_HOST_DOCKER>:8080`
- Juice Shop: `http://<IP_DO_HOST_DOCKER>:3000`
- Vulnerable API: `http://<IP_DO_HOST_DOCKER>:8888`

#### Como obter o IP de cada container (rede interna Docker)

O acesso **a partir de outra maquina na mesma rede** costuma ser pelo **IP do host + tabela acima**. Para saber o **IP interno** de um container na rede `lab_vulneravel` (ex.: varredura `172.18.0.0/16`, movimentacao lateral entre containers):

**1. Com o nome do container** (ex.: `lab_portainer` do Portainer, ou o nome listado por `docker compose ps`):

```bash
docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' lab_portainer
```

**2. Listar todos os containers do projeto com IP** (executar na pasta do `docker-compose.yml`):

```bash
docker compose ps -q | xargs -I {} docker inspect --format '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' {}
```

**3. Inspecionar a rede do laboratorio** (substitua `<nome_da_rede>` se necessario — com Compose v2 costuma ser `<pasta_do_projeto>_lab_vulneravel`, por exemplo `lab-seguranca_lab_vulneravel`):

```bash
docker network ls | grep lab
docker network inspect <nome_da_rede>
```

Na secao `Containers` da saida aparecem os IPs atribuidos.

**4. Valores fixos no compose atual** (se nao alterou o `docker-compose.yml`): Portainer `172.18.0.2`; Metasploitable2 `172.18.0.10`; DVWA `172.18.0.20`; Juice Shop `172.18.0.30`; Vulnerable API `172.18.0.40`.

Observacoes importantes:

- a partir do Kali, o acesso “externo” aos servicos e em geral `IP_do_host:porta_publicada`;
- entre **containers** na mesma rede, pode usar diretamente o **IP interno** (ex.: ping/curl para `172.18.0.20` da DVWA a partir de outro container na `lab_vulneravel`);
- o ambiente pode ser reiniciado sem perda didatica planeada.

---

## 🧪 5. Exercicios praticos propostos

A estrutura baseada em containers permite simular cenarios modernos de ataque e movimentacao lateral.

### 5.1 Ataque do host para containers (host-to-container)

Objetivo:

- avaliar impacto de comprometimento do Host Docker.

Atividades:

- acessar o Host Docker;
- utilizar comandos como `docker ps` e `docker exec`;
- interagir diretamente com containers vulneraveis.

### 5.2 Ataque entre containers (container-to-container)

Objetivo:

- simular movimentacao lateral dentro da rede interna.

Atividades:

- explorar uma aplicacao (ex: DVWA);
- obter acesso ao container;
- executar varredura na rede interna (`172.18.0.0/16`);
- identificar outros alvos (ex: Metasploitable2).

### 5.3 Abuso de Docker Socket (escalada de privilegio)

Objetivo:

- demonstrar riscos de ma configuracao do Docker.

Atividades:

- identificar container com acesso ao socket Docker (`/var/run/docker.sock`);
- criar container privilegiado;
- escalar acesso para o Host.

### 5.4 Fluxo pedagogico recomendado

Sequencia sugerida para a aula:

1. executar `5.1` (fundamentos de superficie de ataque);
2. avancar para `5.2` (movimentacao lateral);
3. concluir com `5.3` (escalada de privilegio e impacto sistemico).

---

## ⚠️ 6. Limitacoes conhecidas do laboratorio

- algumas imagens podem ficar desatualizadas ou indisponiveis temporariamente no Docker Hub;
- diferencas de hardware podem impactar tempo de subida de servicos;
- portas locais em uso podem impedir publicacao dos containers;
- comportamento de alvos vulneraveis pode variar por versao da imagem.

---

## ⚖️ 7. Diretriz metodologica

Todos os exercicios devem observar:

- execucao em ambiente controlado;
- registro de evidencias;
- analise do impacto da vulnerabilidade;
- proposta de mitigacao.

---

## 🔥 8. Resultado esperado

Ao final, o aluno devera ser capaz de:

- compreender fluxos reais de ataque;
- correlacionar vulnerabilidades com impacto pratico;
- executar testes de forma estruturada;
- documentar tecnicamente os achados.





> [!CAUTION]  
> **AVISO DE ETICA E RESPONSABILIDADE**  
> Este ambiente foi projetado exclusivamente para fins educacionais, laboratoriais e de pesquisa em ambiente controlado.
>
> **Nao utilizar em ambiente produtivo.**
>
> Uso vedado em:
>
> - ambientes de producao;
> - sistemas de terceiros sem autorizacao formal;
> - qualquer contexto que viole normas legais.
>
> Execucao permitida apenas em laboratorio isolado (VM dedicada, Docker Lab ou rede segregada).

