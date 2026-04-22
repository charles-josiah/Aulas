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

# 🧪 5. EXERCÍCIOS PRÁTICOS PROPOSTOS

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

Objetivo:
- Demonstrar riscos de má configuração do Docker

Atividades:
- Identificar container com acesso ao socket Docker (`/var/run/docker.sock`)
- Criar container privilegiado
- Escalar acesso para o Host

---

## ⚖️ Diretriz Metodológica

Todos os exercícios devem observar:

- execução em ambiente controlado
- registro de evidências
- análise do impacto da vulnerabilidade
- proposta de mitigação

---

## 🔥 Resultado Esperado

Ao final, o aluno deverá ser capaz de:

- compreender fluxos reais de ataque
- correlacionar vulnerabilidades com impacto prático
- executar testes de forma estruturada
- documentar tecnicamente os achados
