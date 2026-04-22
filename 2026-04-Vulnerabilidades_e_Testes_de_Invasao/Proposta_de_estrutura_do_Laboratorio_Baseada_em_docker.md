# 🐳 Proposta de Estrutura do Laboratório Baseada em Docker

---

# 📌 Visão Geral

O laboratório deixa de ser baseado em múltiplas VMs e passa a utilizar:

👉 **uma única VM de gerenciamento (Host Docker)**  
👉 **containers como alvos vulneráveis**

O Kali Linux atuará como máquina atacante, explorando uma rede virtual interna criada pelo Docker.

---

# 🧠 1. Topologia Recomendada (Lógica e de Rede)

Para garantir isolamento e simulação realista, será utilizada:

👉 **rede Docker do tipo bridge**

Sugestão:
<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/452d876f-cbb4-430e-b92d-605a2466b896" />

---

## 📌 Estrutura lógica

- Host Docker (VM principal)
- Switch virtual Docker (rede interna)
- Containers vulneráveis conectados à rede
- Kali Linux acessando via rede do host

---

## 📌 Componentes da Topologia

### 🔵 Host Docker (Servidor de Alvos)

- VM Linux leve (Ubuntu Server / Debian)
- Executa o Docker Engine
- Possui IP na rede do laboratório

---

### 🌐 Rede Docker: `lab_vulneravel`

- Tipo: bridge
- Subnet: `172.18.0.0/16`
- Rede isolada para os alvos

---

# ⚙️ 2. Detalhamento dos Componentes

---

## 🔴 Máquina Atacante (fora da rede Docker)

| Componente | Função | Acesso à Rede |
| :--- | :--- | :--- |
| **Kali Linux / Parrot** | Scans, exploração e ataques web | Deve pingar o IP do Host Docker |

### 📌 Observação

- O Kali deve conseguir **pingar o Host Docker**
- Para acessar containers:
  - usar portas mapeadas  
  - ou configurar rota estática  

---

## 🟡 Alvos Vulneráveis (Containers Docker)

Cada serviço roda isoladamente em container.

👉 Característica importante:  
**estado não persistente (reset automático ao reiniciar)**

---

### 📌 Tabela de Alvos

| Alvo | Imagem Docker | Portas (Host:Container) | Função Principal |
| :--- | :--- | :--- | :--- |
| **Metasploitable2** | `tleemcjr/metasploitable2` | `2121:21`, `2222:22`, `8181:80` | Serviços de rede legados |
| **DVWA** | `vulnerables/web-dvwa` | `8080:80` | Vulnerabilidades Web (PHP/MySQL) |
| **Juice Shop** | `bkimminich/juice-shop` | `3000:3000` | Aplicação Moderna (API/JS) |
| **Vulnerable API** | `roottusk/vulnerable-api` | `8888:8080` | OWASP API Security Top 10 |
| **ImageMagick** | `vulhub/imagemagick:7.0.1-10` | N/A | Exploração de CVEs de sistema |
---

# 🧩 3. Implementação com Docker Compose

Para padronizar e facilitar o uso, utilize:

👉 `docker-compose.yml`

---

## 📄 lab-seguranca/docker-compose.yml:

```yaml
version: '3.8'

networks:
  lab_vulneravel:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16

services:

  # Alvo 1: Metasploitable2 (Ambiente Legado)
  metasploitable2:
    image: tleemcjr/metasploitable2
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.10
    ports:
      - "2121:21"    # Mapeia FTP para porta 2121 do Host
      - "2222:22"    # Mapeia SSH para porta 2222 do Host
      - "8181:80"    # Mapeia HTTP para porta 8181 do Host
    restart: always

  # Alvo 2: DVWA (Aplicação Web clássica)
  dvwa:
    image: vulnerables/web-dvwa
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.20
    ports:
      - "8080:80"    # Mapeia DVWA para porta 8080 do Host
    environment:
      - DBMS_TYPE=MySQL
    restart: always

  # Alvo 3: OWASP Juice Shop (Aplicação Moderna)
  juice-shop:
    image: bkimminich/juice-shop
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.30
    ports:
      - "3000:3000"  # Mapeia Juice Shop para porta 3000 do Host
    restart: always

  # Alvo 4: Vulnerable API
  vulnerable-api:
    image: roottusk/vulnerable-api
    networks:
      lab_vulneravel:
        ipv4_address: 172.18.0.40
    ports:
      - "8888:8080"  # Mapeia API para porta 8888 do Host
    restart: always
```
# 🚀 4. GUIA OPERACIONAL

Após a configuração do Host Docker e disponibilização do arquivo `docker-compose.yml`, o aluno deverá executar apenas os comandos abaixo, garantindo padronização e reprodutibilidade do ambiente.

## ▶️ Inicialização do laboratório
```bash 
# docker-compose up -d
```

## 📊 Verificação do estado dos serviços
```bash 
# docker-compose ps
```

## 🔄 Reinicialização de um serviço específico
Exemplo (DVWA):
```bash 
# docker-compose restart dvwa
```

## 🌐 Acesso às aplicações
A partir da máquina atacante (Kali Linux), acessar via navegador:

http://<IP_DO_HOST_DOCKER>:8080

⚠️ Observações importantes:

- O acesso ocorre via portas mapeadas no Host Docker
- Os containers não são acessados diretamente por IP externo
- O ambiente pode ser resetado a qualquer momento sem perda de consistência didática

---

# 🧪 5. EXERCÍCIOS PRÁTICOS PROPOSTOS (NÍVEL 2026)

A estrutura baseada em containers permite simular cenários modernos de ataque e movimentação lateral, não triviais em ambientes tradicionais de máquinas virtuais.

## 💣 5.1 Ataque do Host para Containers (Host-to-Container)

Objetivo:
- Avaliar impacto de comprometimento do Host Docker

Atividades:
- Acessar o Host Docker
- Utilizar comandos como `docker ps` e `docker exec`
- Interagir diretamente com containers vulneráveis

---

## 🔄 5.2 Ataque entre Containers (Container-to-Container)

Objetivo:
- Simular movimentação lateral dentro da rede interna

Atividades:
- Explorar uma aplicação (ex: DVWA)
- Obter acesso ao container
- Executar varredura na rede interna (172.18.0.0/16)
- Identificar outros alvos (ex: Metasploitable2)

---

## ⚠️ 5.3 Abuso de Docker Socket (Escalada de Privilégio)

### 🎯 Objetivo

Demonstrar como a exposição indevida do Docker Socket (`/var/run/docker.sock`) pode permitir:

- controle total do ambiente Docker
- criação de containers privilegiados
- potencial comprometimento do Host

---

### 🧠 Conceito Fundamental

O arquivo:

/var/run/docker.sock

é o canal de comunicação entre o cliente Docker e o daemon.

👉 Quem tem acesso a esse socket:
- pode listar containers
- iniciar/parar containers
- montar volumes do Host
- executar comandos com privilégios elevados

⚠️ Em termos práticos:  
acesso ao socket = acesso root indireto ao Host

---

### 🧪 Cenário de Laboratório

Para simulação controlada, será necessário:

- um container vulnerável com o socket montado
- acesso ao shell dentro do container

Exemplo conceitual de configuração insegura:

- volume:
  - /var/run/docker.sock:/var/run/docker.sock

---

### 🔍 Etapa 1 — Identificação da Vulnerabilidade

Dentro do container comprometido, verificar:

- existência do socket Docker
- permissões de acesso

Indicadores:

- presença do arquivo `/var/run/docker.sock`
- acesso de leitura/escrita

---

### 🧪 Etapa 2 — Interação com o Docker

Uma vez identificado o socket:

- verificar containers existentes
- validar acesso ao daemon Docker

Objetivo didático:
👉 demonstrar que o container tem controle sobre o ambiente

---

### 💣 Etapa 3 — Escalada de Privilégio (Conceito)

O risco ocorre quando é possível:

- criar um novo container com privilégios elevados
- montar o sistema de arquivos do Host
- acessar arquivos críticos do sistema

👉 Exemplo conceitual:
- container com acesso ao `/` do Host
- execução de comandos com contexto privilegiado

---

### ⚠️ Resultado Esperado

O aluno deve compreender que:

- containers não são seguros por padrão
- isolamento pode ser quebrado por má configuração
- Docker mal configurado equivale a exposição do Host

---

### 📊 Evidência Esperada

O aluno deverá apresentar:

- prova de acesso ao socket
- demonstração de controle sobre containers
- evidência de potencial impacto no Host

---

### 🛡️ Mitigação (Ponto MAIS IMPORTANTE)

Nunca:

- expor `/var/run/docker.sock` para containers desnecessariamente

Boas práticas:

- utilizar usuários não privilegiados
- aplicar políticas de segurança (AppArmor / SELinux)
- evitar containers privilegiados
- usar Docker rootless quando possível
- controlar acesso via RBAC (em ambientes orquestrados)

---

### ⚖️ Conclusão

Docker não é vulnerável por si só.

👉 A vulnerabilidade está na configuração.

---
