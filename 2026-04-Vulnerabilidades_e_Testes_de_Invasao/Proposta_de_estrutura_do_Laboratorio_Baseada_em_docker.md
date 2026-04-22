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

Sugestao visual:
![Topologia sugerida](https://github.com/user-attachments/assets/452d876f-cbb4-430e-b92d-605a2466b896)

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

| Componente | Funcao | Acesso a rede |
| :--- | :--- | :--- |
| **Kali Linux / Parrot** | Varredura, exploracao e ataques web | Deve pingar o IP do Host Docker |

Observacoes:

- o Kali deve conseguir pingar o Host Docker;
- para acessar containers, usar portas mapeadas ou configurar rota estatica.

### 2.2 Alvos vulneraveis (containers Docker)

Cada servico roda isoladamente em container.

Caracteristica importante: estado nao persistente (reset automatico ao reiniciar).

| Alvo | Imagem Docker | Portas (Host:Container) | Foco principal | Nivel didatico |
| :--- | :--- | :--- | :--- | :--- |
| **Metasploitable2** | `tleemcjr/metasploitable2` | `2121:21`, `2222:22`, `8181:80` | Servicos de rede legados | Iniciante |
| **DVWA** | `vulnerables/web-dvwa` | `8080:80` | Vulnerabilidades web classicas (PHP/MySQL) | Iniciante |
| **Juice Shop** | `bkimminich/juice-shop` | `3000:3000` | Falhas web modernas (API/JS) | Intermediario |
| **Vulnerable API** | `roottusk/vulnerable-api` | `8888:8080` | OWASP API Security Top 10 | Intermediario |
| **ImageMagick** | `vulhub/imagemagick:7.0.1-10` | N/A | Exploracao de CVEs de sistema | Intermediario |

---

## 🧩 3. Implementacao com Docker Compose

Para padronizar e facilitar o uso, utilize o arquivo `docker-compose.yml`.

### 3.1 Pre-requisitos minimos

- Host Linux com Docker Engine instalado e em execucao;
- Docker Compose plugin habilitado (`docker compose version`);
- minimo recomendado: 4 vCPU, 8 GB RAM e 30 GB livres;
- conectividade com Docker Hub para pull das imagens;
- usuario com permissao para executar comandos Docker.

### 3.2 Exemplo de `lab-seguranca/docker-compose.yml`

```yaml
version: '3.8'

networks:
  lab_vulneravel:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16

services:
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
    restart: always

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
    restart: always

  # Alvo 3: OWASP Juice Shop (aplicacao moderna)
  juice-shop:
    image: bkimminich/juice-shop
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.30
    ports:
      - "3000:3000"
    restart: always

  # Alvo 4: Vulnerable API
  vulnerable-api:
    image: roottusk/vulnerable-api
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.40
    ports:
      - "8888:8080"
    restart: always
```

---

## 🚀 4. Guia operacional

Apos configurar o Host Docker e disponibilizar o arquivo `docker-compose.yml`, execute os comandos abaixo.

### 4.1 Inicializacao do laboratorio

```bash
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

- [ ] `docker compose ps` mostra os servicos como `running`;
- [ ] `http://<IP_DO_HOST_DOCKER>:8080` abre a DVWA;
- [ ] `http://<IP_DO_HOST_DOCKER>:3000` abre a Juice Shop;
- [ ] `http://<IP_DO_HOST_DOCKER>:8888` responde a API vulneravel.

### 4.5 Acesso as aplicacoes

A partir da maquina atacante (Kali Linux), acessar via navegador:

- `http://<IP_DO_HOST_DOCKER>:8080`
- `http://<IP_DO_HOST_DOCKER>:3000`
- `http://<IP_DO_HOST_DOCKER>:8888`

Observacoes importantes:

- o acesso ocorre via portas mapeadas no Host Docker;
- os containers nao sao acessados diretamente por IP externo;
- o ambiente pode ser resetado a qualquer momento sem perda de consistencia didatica.

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
