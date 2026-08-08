---
title: "Workshop 03: Captura de Tráfego MySQL (Senha, Queries e Permissionamento em Texto Claro)"
description: "Workshop prático de segurança: demonstra a captura de senhas, queries SQL e grants MySQL em texto claro via tcpdump e tshark. Aprenda por que TLS é essencial em conexões de banco de dados."
keywords: ["segurança da informação", "captura de tráfego", "tcpdump", "tshark", "MySQL", "SGBD", "Kali Linux", "Docker", "permissionamento", "GRANT", "credenciais em texto claro", "Wireshark", "segurança em redes", "SENAI"]
tags: ["seguranca-da-informacao", "captura-de-trafego", "tcpdump", "tshark", "mysql", "sgbd", "kali-linux", "docker", "permissionamento", "seguranca-em-redes"]
author: "Charles Alandt"
lang: "pt-BR"
layout: default
---

# Workshop 03: Captura de Tráfego MySQL (Senha, Queries e Permissionamento em Texto Claro)

**Tags:** `segurança da informação` · `captura de tráfego` · `tcpdump` · `tshark` · `MySQL` · `SGBD` · `Kali Linux` · `Docker` · `permissionamento` · `Wireshark`

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

- [1. Ambiente e Preparação](#1-ambiente-e-preparação)
- [2. Como Subir o MySQL via Docker](#2-como-subir-o-mysql-via-docker)
- [3. Captura do Tráfego MySQL e Criação de Banco/Tabelas](#3-captura-do-tráfego-mysql-e-criação-de-bancotabelas)
  - [Passo 3.1: Iniciar a captura com tcpdump](#passo-31-iniciar-a-captura-com-tcpdump)
  - [Passo 3.2: Executar comandos SQL no MySQL](#passo-32-executar-comandos-sql-no-mysql)
  - [Passo 3.3: Parar a captura](#passo-33-parar-a-captura)
- [4. Recuperação dos Comandos SQL do Dump](#4-recuperação-dos-comandos-sql-do-dump)
  - [Passo 4.1: Extrair queries com tshark](#passo-41-extrair-queries-com-tshark)
  - [Passo 4.2: Extrair queries com tcpdump (modo bruto)](#passo-42-extrair-queries-com-tcpdump-modo-brilho)
  - [Passo 4.3: Reconstruir o banco num MySQL limpo](#passo-43-reconstruir-o-banco-num-mysql-limpo)
- [5. Desafio: Sniffer Attack](#5-desafio-sniffer-attack)
- [6. Mini-howto de Permissionamento MySQL](#6-mini-howto-de-permissionamento-mysql)
- [7. Lições Aprendidas](#7-lições-aprendidas)
- [8. Atividade Extra: Análise no Wireshark](#8-atividade-extra-análise-no-wireshark)
- [Checklist de Validação do Aluno](#checklist-de-validação-do-aluno)
- [Troubleshooting](#troubleshooting)
- [Anexo A: O que é o tshark?](#anexo-a-o-que-é-o-tshark)

---

## 1. Ambiente e Preparação

Neste workshop, um servidor MySQL 8.0 roda em um container Docker no **srvdocker01**. Um segundo host (**kali**) atua como observador de rede: ele captura todo o tráfego da porta 3306 com `tcpdump` e, depois, analisa o arquivo `.pcap` com `tshark` — a versão de linha de comando do Wireshark, que entende o protocolo MySQL e extrai as queries SQL de forma limpa. O cenário simula um DBA que faz backup remoto do banco via rede **sem TLS**, permitindo que qualquer pessoa na mesma rede leia senhas, comandos e dados sensíveis.

Premissas do laboratório:

- Duas máquinas na mesma rede: **servidor** (srvdocker01) e **cliente/observador** (kali).
- O servidor roda um container Docker com MySQL 8.0 **sem TLS/SSL**.
- O cliente captura o tráfego com `tcpdump` e analisa com `tshark`.
- O DBA executa comandos SQL que criam usuários, databases, tabelas e inserem dados sensíveis.
- Todos os comandos devem ser executados e validados um a um.
- A atividade deve ocorrer somente dentro da subrede autorizada do laboratório.
- Sempre substitua exemplos como `172.30.234.55` e `172.30.234.56` pelos valores reais encontrados no seu ambiente.

Objetivos de aprendizagem:

1. Configurar um servidor MySQL vulnerável em Docker (sem TLS).
2. Capturar tráfego de banco de dados com `tcpdump`.
3. Extrair queries SQL, senhas em plaintext e grants com `tshark`.
4. Reconstruir um banco de dados inteiro a partir de um `.pcap`.
5. Compreender por que TLS é essencial em conexões de banco de dados.

> [!NOTE]
> **Ajuste os endereços IP conforme o seu ambiente!**
> Os IPs abaixo são do laboratório onde o instrutor validou o workshop. No seu ambiente os endereços serão diferentes.
>
> **Como descobrir o IP de cada máquina:**
> - No servidor: `ip -brief address`
> - No cliente: `ip -brief address`
>
> **Regra prática:** substitua `172.30.234.55` pelo IP real do servidor e `172.30.234.56` pelo IP real do cliente/kali.

---

## 2. Como Subir o MySQL via Docker

### 2.1 Dockerfile e docker‑compose (sem TLS)

```bash
# Dockerfile já está na raiz do workshop (Dockerfile)
# Ele usa a imagem oficial mysql:8.0 e expõe a porta 3306 sem TLS.
# As variáveis de ambiente definem a senha do usuário root:
#   MYSQL_ROOT_PASSWORD=root_secret_2024
#   MYSQL_ROOT_HOST=%   # permite login de qualquer host (necessário para o laboratório)
# O script `init/init.sql` será copiado para `/docker-entrypoint‑initdb.d/`
# e executado na primeira inicialização do container, criando o banco
# `app_db`, a tabela `clientes` e usuários `dba_user`, `app_user` e `rel_user`.
```

```yaml
# docker‑compose.yml (já incluído no workshop)
version: "3.8"
services:
  mysql:
    build: .
    container_name: laboratorio-mysql
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=root_secret_2024
      - MYSQL_ROOT_HOST=%
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped
volumes:
  mysql_data:
```

### 2.2 Iniciar o container

```bash
# No servidor (srvdocker01)
cd /docker/laboratorio-seguranca-mysql
./scripts/iniciar_servidor.sh   # script que constrói a imagem e levanta o container
```

Esse script:
- Remove containers antigos (`docker compose down`).
- Constrói a nova imagem (`docker compose build`).
- Levanta o container em background (`docker compose up -d`).
- Aguarda alguns segundos e verifica se o MySQL está aceitando conexões.

> **Importante:** o MySQL leva ~10‑20 s para iniciar; o script já inclui um loop de espera (`docker exec ... SELECT 1`).

### 2.3 Verificar a instância

```bash
docker ps            # deve listar `laboratorio-mysql` com a porta 0.0.0.0:3306->3306/tcp
mysql -h 172.30.234.55 -u root -proot_secret_2024 -e "SHOW DATABASES;"
```

Se aparecer `app_db` e `information_schema` a instalação está concluída.

---

## 3. Captura do Tráfego MySQL e Criação de Banco/Tabelas

### Passo 3.1: Iniciar a captura com tcpdump

No **kali**, dentro de `~/laboratorio-capturas`:

```bash
sudo tcpdump -i any -s 0 -w mysql.pcap "host 172.30.234.55 and port 3306"
```

Flags usadas:

- `-i any`: captura em todas as interfaces de rede.
- `-s 0`: captura o pacote inteiro (snapshot completo).
- `-w mysql.pcap`: grava no arquivo `mysql.pcap` (formato libpcap).
- `"host 172.30.234.55 and port 3306"`: filtro — só tráfego MySQL com o servidor.

Resultado esperado:

```text
tcpdump: listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
```

**Deixe esta janela de terminal aberta** — a captura está rodando.

---

### Passo 3.2: Executar comandos SQL no MySQL

Abra um **segundo terminal** no kali e conecte no servidor MySQL como DBA:

```bash
mysql -h 172.30.234.55 -u dba_user -p
```

Senha: `dba_secret_2024`

Resultado esperado:

```text
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 8.0.36 MySQL Community Server - GPL

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

Agora execute os comandos SQL a seguir. Cada um deles gera tráfego que será capturado:

#### 3.2.1 Criar banco e tabela

```sql
CREATE DATABASE IF NOT EXISTS app_db;
USE app_db;

CREATE TABLE IF NOT EXISTS clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cpf VARCHAR(14) NOT NULL,
  email VARCHAR(120) NOT NULL,
  senha_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 3.2.2 Inserir dados sensíveis

```sql
INSERT INTO clientes (nome, cpf, email, senha_hash) VALUES
  ('Maria Silva',      '123.456.789-00', 'maria.silva@exemplo.com',   SHA2('senha_maria_2024', 256)),
  ('João Santos',      '987.654.321-00', 'joao.santos@exemplo.com',   SHA2('senha_joao_2024', 256)),
  ('Ana Oliveira',     '456.789.123-00', 'ana.oliveira@exemplo.com',  SHA2('senha_ana_2024', 256));
```

#### 3.2.3 Criar novo usuário com senha em plaintext

```sql
CREATE USER IF NOT EXISTS 'app_user'@'%'
  IDENTIFIED WITH mysql_native_password BY 'app_secret_2024';
```

#### 3.2.4 Conceder permissões granulares

```sql
GRANT SELECT, INSERT, UPDATE ON app_db.clientes TO 'app_user'@'%';
```

#### 3.2.5 Criar usuário com acesso excessivo (intencionalmente mal configurado)

```sql
CREATE USER IF NOT EXISTS 'reports_user'@'%'
  IDENTIFIED WITH mysql_native_password BY 'reports_2024_secret';
GRANT ALL PRIVILEGES ON app_db.* TO 'reports_user'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

#### 3.2.6 Consultar dados (SELECT)

```sql
SELECT id, nome, cpf, email FROM clientes;
```

Resultado esperado:

```text
+----+--------------+-------------+---------------------------+
| id | nome         | cpf         | email                     |
+----+--------------+-------------+---------------------------+
|  1 | Maria Silva  | 123.456.789-00 | maria.silva@exemplo.com |
|  2 | João Santos  | 987.654.321-00 | joao.santos@exemplo.com |
|  3 | Ana Oliveira | 456.789.123-00 | ana.oliveira@exemplo.com|
+----+--------------+-------------+---------------------------+
```

#### 3.2.7 Ver permissões do reports_user

```sql
SHOW GRANTS FOR 'reports_user'@'%';
```

Resultado esperado:

```text
+--------------------------------------------------------------------------------------------------+
| Grants for reports_user@%                                                                        |
+--------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `reports_user`@`%`                                                         |
| GRANT ALL PRIVILEGES ON `app_db`.* TO `reports_user`@`%` WITH GRANT OPTION                      |
+--------------------------------------------------------------------------------------------------+
```

#### 3.2.8 Logout

```sql
EXIT;
```

Análise:

- Cada `COM_QUERY` (tipo `0x03` no protocolo MySQL) carrega o SQL **em texto claro** no payload.
- A senha de `app_user` (`app_secret_2024`) aparece literalmente no comando `CREATE USER ... IDENTIFIED BY`.
- A senha de `reports_user` (`reports_2024_secret`) também aparece.
- Os `INSERT` carregam os dados pessoais (nomes, CPFs, e-mails).
- Os `GRANT` revelam exatamente quais permissões cada usuário tem.
- O `SHOW GRANTS` retorna a estrutura completa de permissões — visível na captura.

> **Alternativa automatizada:** em vez de digitar tudo manualmente, salve os comandos num arquivo e execute:
> ```bash
> mysql -h 172.30.234.55 -u dba_user -pdba_secret_2024 < /caminho/comandos-dba.sql
> ```
> O efeito na captura é idêntico — cada comando gera um pacote `COM_QUERY` legível.

---

### Passo 3.3: Parar a captura

Volte ao terminal do `tcpdump` e pressione `Ctrl+C`.

Resultado esperado:

```text
^C
42 packets captured
42 packets received by filter
0 packets dropped by kernel
```

Análise (exemplo de saída real do laboratório do instrutor):

- `42 packets captured`: a sessão completa (CREATE DATABASE, CREATE TABLE, INSERTs, CREATE USER, GRANTs, SELECT, SHOW GRANTS) foi registrada.
- `0 packets dropped by kernel`: nenhum pacote perdido.

---

## 4. Recuperação dos Comandos SQL do Dump

Agora que você tem o `mysql.pcap`, o desafio é **extrair tudo o que foi transmitido**.

### Passo 4.1: Extrair queries com tshark (recomendado)

O `tshark` (versão CLI do Wireshark) tem um **dissector nativo para MySQL** que entende o protocolo e extrai as queries diretamente:

```bash
tshark -r mysql.pcap -Y "mysql.query" -T fields -e mysql.query
```

Flags usadas:

- `-r mysql.pcap`: lê do arquivo pcap.
- `-Y "mysql.query"`: filtro de exibição — mostra só pacotes com queries MySQL.
- `-T fields`: formato de saída por campos.
- `-e mysql.query`: extrai apenas o texto da query.

Resultado esperado:

```text
CREATE DATABASE IF NOT EXISTS app_db
USE app_db
CREATE TABLE clientes (id INT AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(100) NOT NULL, cpf VARCHAR(14) NOT NULL, email VARCHAR(120) NOT NULL, senha_hash VARCHAR(255) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)
INSERT INTO clientes (nome, cpf, email, senha_hash) VALUES ('Maria Silva', '123.456.789-00', 'maria.silva@exemplo.com', SHA2('senha_maria_2024', 256))
INSERT INTO clientes (nome, cpf, email, senha_hash) VALUES ('João Santos', '987.654.321-00', 'joao.santos@exemplo.com', SHA2('senha_joao_2024', 256))
INSERT INTO clientes (nome, cpf, email, senha_hash) VALUES ('Ana Oliveira', '456.789.123-00', 'ana.oliveira@exemplo.com', SHA2('senha_ana_2024', 256))
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED WITH mysql_native_password BY 'app_secret_2024'
GRANT SELECT, INSERT, UPDATE ON app_db.clientes TO 'app_user'@'%'
CREATE USER IF NOT EXISTS 'reports_user'@'%' IDENTIFIED WITH mysql_native_password BY 'reports_2024_secret'
GRANT ALL PRIVILEGES ON app_db.* TO 'reports_user'@'%' WITH GRANT OPTION
FLUSH PRIVILEGES
SELECT id, nome, cpf, email FROM clientes
SHOW GRANTS FOR 'reports_user'@'%'
```

Análise:

- **Todas as queries aparecem limpas**, incluindo senhas em plaintext (`app_secret_2024`, `reports_2024_secret`).
- Os `INSERT` revelam CPFs, e-mails e hashes de senha dos clientes.
- Os `GRANT` mostram exatamente as permissões de cada usuário.
- O `SHOW GRANTS` expõe o `WITH GRANT OPTION` do `reports_user` (poder de criar outros usuários!).

### Passo 4.2: Extrair queries com tcpdump (modo bruto)

Se não tiver `tshark` instalado, use `tcpdump -A` + `grep`:

```bash
sudo tcpdump -r mysql.pcap -A | grep -E "CREATE|GRANT|INSERT|SELECT|SHOW|FLUSH|USE "
```

Resultado esperado (trecho):

```text
... CREATE DATABASE IF NOT EXISTS app_db ...
... USE app_db ...
... CREATE TABLE clientes (id INT AUTO_INCREMENT ...
... INSERT INTO clientes (nome, cpf, email ...
... CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED WITH mysql_native_password BY 'app_secret_2024' ...
... GRANT SELECT, INSERT, UPDATE ON app_db.clientes TO 'app_user'@'%' ...
... CREATE USER IF NOT EXISTS 'reports_user'@'%' IDENTIFIED WITH mysql_native_password BY 'reports_2024_secret' ...
... GRANT ALL PRIVILEGES ON app_db.* TO 'reports_user'@'%' WITH GRANT OPTION ...
... SELECT id, nome, cpf, email FROM clientes ...
... SHOW GRANTS FOR 'reports_user'@'%' ...
```

Análise:

- Funciona, mas a saída é mais "suja" (pacotes fragmentados, headers TCP misturados).
- O `tshark` é mais limpo e confiável para protocolos binários como MySQL.

### Passo 4.3: Reconstruir o banco num MySQL limpo

Com os comandos extraídos, você pode reconstruir o banco inteiro num MySQL limpo:

```bash
# Num MySQL limpo (pode ser outro container ou o mesmo após DROP DATABASE app_db):
mysql -h IP_MYSQL_LIMPO -u root -p

# Cole os comandos extraídos na ordem:
CREATE DATABASE IF NOT EXISTS app_db;
USE app_db;
CREATE TABLE clientes (...);
INSERT INTO clientes (...) VALUES (...), (...), (...);
CREATE USER 'app_user'@'%' IDENTIFIED BY 'app_secret_2024';
GRANT SELECT, INSERT, UPDATE ON app_db.clientes TO 'app_user'@'%';
CREATE USER 'reports_user'@'%' IDENTIFIED BY 'reports_2024_secret';
GRANT ALL PRIVILEGES ON app_db.* TO 'reports_user'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

> [!IMPORTANT]
> **Preencha os `(...)` com os dados reais extraídos da captura!**
> Os `(...)` acima são apenas marcadores de posição. Você deve substituí-los pelos valores que apareceram na saída do `tshark` (Passo 4.1) — por exemplo, a definição completa da tabela `clientes` e os `INSERT` com os nomes, CPFs e e-mails reais capturados.

Resultado: o banco reconstruído é **idêntico** ao original — mesma estrutura, mesmos dados, mesmos usuários e permissões.

---

## 5. Desafio: Sniffer Attack

**Objetivo geral:**
- **Como atacante**, você já tem o arquivo `mysql.pcap` capturado na rede da corporação.
- Seu trabalho é **extrair** tudo que for útil (senhas, grants, dados sensíveis) e **reconstruir** o banco completo num ambiente controlado.

**Cenário narrativo:**
- Você é parte da equipe de Red Team de uma empresa de saúde que faz backup de bancos críticos durante a madrugada via `mysqldump` sem TLS.
- O backup atravessa a rede corporativa onde há um ponto de escuta (Raspberry Pi + `tcpdump`).
- O dump contém **comandos DDL/DCL/DML** (criação de bases, usuários, permissões e inserções de dados reais). Como o canal está em plaintext, tudo pode ser extraído.

**Como o dump é gerado e capturado (contexto para o atacante):**

O DBA da corporação executa o backup remoto assim (no servidor MySQL):

```bash
# No servidor MySQL (srvdocker01), o DBA gera o dump:
mysqldump -h 127.0.0.1 -u dba_user -pdba_secret_2024 --all-databases > backup.sql
```

Enquanto isso, o atacante (você) já está capturando o tráfego na rede:

```bash
# No kali — captura iniciada ANTES do dump começar:
sudo tcpdump -i any -s 0 -w mysql.pcap "host 172.30.234.55 and port 3306"
```

> [!NOTE]
> O `mysqldump` conecta no MySQL pela porta 3306 e executa uma sequência de `SELECT`, `SHOW CREATE TABLE`, `LOCK TABLES`, etc. — **tudo em texto claro**. O arquivo `backup.sql` gerado no servidor é a "versão final", mas o atacante não precisa dele: o `.pcap` contém os mesmos comandos, capturados no meio do caminho.

**Passo‑a‑passo detalhado para o atacante:**

1. **Extrair queries SQL** (tshark ou tcpdump). Exemplo recomendado:
   ```bash
   tshark -r mysql.pcap -Y "mysql.query" -T fields -e mysql.query > queries.sql
   ```
   - O arquivo `queries.sql` contém literalmente **todos** os `CREATE`, `INSERT`, `GRANT`, `SELECT` que foram enviados.
2. **Identificar senhas em plaintext** – procure linhas com `IDENTIFIED BY`:
   ```bash
   grep "IDENTIFIED BY" queries.sql
   ```
   - Você obterá algo como:
     ```text
     CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED WITH mysql_native_password BY 'app_secret_2024';
     CREATE USER IF NOT EXISTS 'reports_user'@'%' IDENTIFIED WITH mysql_native_password BY 'reports_2024_secret';
     ```
3. **Listar grants críticos** – procure `GRANT` e `WITH GRANT OPTION`:
   ```bash
   grep "GRANT" queries.sql
   ```
   - Exemplo de saída perigosa:
     ```text
     GRANT ALL PRIVILEGES ON app_db.* TO 'reports_user'@'%' WITH GRANT OPTION;
     ```
   - Esse usuário pode **criar novos usuários** e conceder privilégios – ponto de partida para escalonamento.
4. **Extrair dados sensíveis** – procure `INSERT` nas tabelas alvo (`clientes`):
   ```bash
   grep "INSERT INTO clientes" queries.sql
   ```
   - Você verá CPFs, e‑mails e os hashes de senha (`SHA2('senha_x',256)`).
5. **Reconstruir o ambiente** num MySQL limpo (pode ser um novo container):
   ```bash
   # Crie um novo container (ou use o existente, mas limpe antes)
   docker run -d --name mysql-recon -e MYSQL_ROOT_PASSWORD=root_secret_2024 -p 3307:3306 mysql:8.0
   # Conecte e execute as queries na ordem correta
   mysql -h 127.0.0.1 -P 3307 -u root -proot_secret_2024 < queries.sql
   ```
   - O banco `app_db` aparecerá com a mesma estrutura, usuários e dados.
6. **Validar a reconstrução** – rode algumas queries de verificação:
   ```bash
   mysql -h 127.0.0.1 -P 3307 -u root -proot_secret_2024 -e "SELECT COUNT(*) FROM app_db.clientes;"
   ```
   - O número de linhas deve coincidir com o que foi capturado.
7. **Escalonamento (opcional):**
   - Logue como `reports_user` (poder total no `app_db` e `WITH GRANT OPTION`).
   - Crie um novo usuário com privilégios administrativos:
     ```sql
     CREATE USER 'evil_admin'@'%' IDENTIFIED BY 'senha_evil_2024';
     GRANT ALL PRIVILEGES ON *.* TO 'evil_admin'@'%' WITH GRANT OPTION;
     FLUSH PRIVILEGES;
     ```
   - Agora você tem **acesso total** a todos os bancos da corporação.

**Por que este ataque funciona?**
- **Ausência de TLS**: todo o tráfego MySQL (incluindo `CREATE USER … IDENTIFIED BY …`) viaja em plaintext.
- **Grants excessivos**: o DBA (exemplo `reports_user`) delega `WITH GRANT OPTION`, permitindo que um atacante crie novos usuários privilegiados.
- **Dados sensíveis**: `INSERT` revela informações pessoais (CPFs, e‑mails).

**Mitigações recomendadas (para o time de defesa):**
1. **Habilitar TLS** no MySQL (`REQUIRE SSL` no `GRANT`).
2. **Restringir hosts** (`'user'@'10.0.0.%'` em vez de `%`).
3. **Aplicar o princípio do menor privilégio** – nunca usar `GRANT ALL … WITH GRANT OPTION` em usuários de aplicação.
4. **Auditar logs** – monitorar `CREATE USER`, `GRANT` e `INSERT` em tempo real.
5. **Segmentar rede** – colocar o banco atrás de firewall interno, impedir sniffer externo.

Esse desafio coloca o aluno na pele do atacante, exigindo que ele descubra as informações **por si mesmo**, ao invés de receber tudo pronto. O sucesso depende da capacidade de usar `tshark`, `grep` e `mysql` para reconstruir um ambiente realista, identificando também os pontos críticos de segurança que precisam ser corrigidos.

---

## 6. Mini-howto de Permissionamento MySQL

> Este é um resumo dos comandos de permissionamento mais usados. Para referência completa, consulte a [documentação oficial do MySQL](https://dev.mysql.com/doc/refman/8.0/en/grant.html).

### 6.1 Criar usuários

```sql
-- Criar usuário com senha
CREATE USER 'app_user'@'%' IDENTIFIED WITH mysql_native_password BY 'senha_aqui';

-- Criar usuário restrito a um host específico (mais seguro)
CREATE USER 'app_user'@'172.30.234.56' IDENTIFIED WITH mysql_native_password BY 'senha_aqui';

-- Criar usuário com autenticação por socket (apenas localhost)
CREATE USER 'app_user'@'localhost' IDENTIFIED WITH auth_socket;
```

### 6.2 Conceder permissões (GRANT)

| Nível | Exemplo | O que permite |
|-------|---------|---------------|
| **Global** | `GRANT ALL ON *.* TO 'user'@'%'` | Tudo em todos os bancos |
| **Banco** | `GRANT ALL ON app_db.* TO 'user'@'%'` | Tudo no banco `app_db` |
| **Tabela** | `GRANT SELECT, INSERT ON app_db.clientes TO 'user'@'%'` | SELECT e INSERT só na tabela `clientes` |
| **Coluna** | `GRANT SELECT (nome, email) ON app_db.clientes TO 'user'@'%'` | SELECT só em colunas específicas |

### 6.3 Verificar permissões

```sql
SHOW GRANTS FOR 'app_user'@'%';
```

Resultado esperado:

```text
+--------------------------------------------------------------------------------------------------+
| Grants for app_user@%                                                                           |
+--------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `app_user`@`%`                                                            |
| GRANT SELECT, INSERT, UPDATE ON `app_db`.`clientes` TO `app_user`@`%`                           |
+--------------------------------------------------------------------------------------------------+
```

### 6.4 Revogar permissões

```sql
REVOKE INSERT, UPDATE ON app_db.clientes FROM 'app_user'@'%';
```

### 6.5 Remover usuário

```sql
DROP USER 'app_user'@'%';
```

### 6.6 Aplicar mudanças

```sql
FLUSH PRIVILEGES;
```

### 6.7 Exemplo completo: criar usuário com permissão mínima

```sql
-- Criar usuário restrito ao host da aplicação
CREATE USER 'app_user'@'172.30.234.56' IDENTIFIED WITH mysql_native_password BY 'senha_forte_2024';

-- Conceder apenas o estritamente necessário
GRANT SELECT, INSERT ON app_db.clientes TO 'app_user'@'172.30.234.56';

-- Aplicar
FLUSH PRIVILEGES;

-- Verificar
SHOW GRANTS FOR 'app_user'@'172.30.234.56';
```

### 6.8 Princípio do Menor Privilégio

| Prática | Recomendação |
|---------|--------------|
| Host do usuário | Restrito ao IP da aplicação (`'app_user'@'10.0.0.5'`), não `'%'` |
| Permissões | Mínimas necessárias (`SELECT, INSERT`), não `ALL` |
| Senha | Forte, armazenada com `mysql_native_password` ou `caching_sha2_password` |
| `WITH GRANT OPTION` | Nunca conceder a usuários de aplicação |
| TLS | Sempre habilitar em produção (`REQUIRE SSL`) |

---

## 7. Lições Aprendidas

1. **MySQL sem TLS é plaintext.** Todas as queries — `CREATE USER`, `GRANT`, `INSERT`, `SELECT` — trafegam em texto claro e são legíveis por quem capturar o tráfego na rede.
2. **O handshake de login usa challenge-response** (hash + salt), então a senha do login não aparece diretamente. Mas o `CREATE USER ... IDENTIFIED BY 'senha'` **sim** — aparece em texto claro no comando SQL.
3. **GRANTs são tão sensíveis quanto senhas.** Um `GRANT ALL PRIVILEGES ON *.* WITH GRANT OPTION` capturado na rede dá ao atacante poder total de replicação.
4. **Dados sensíveis em SELECTs são visíveis.** CPFs, e-mails, hashes de senhas — tudo legível no dump.
5. **A captura é passiva e silenciosa.** O servidor MySQL nem percebe que o tráfego foi observado.
6. **TLS resolve o problema na camada de transporte.** Com TLS habilitado (`REQUIRE SSL` no GRANT), o tcpdump mostra apenas bytes criptografados — nada legível.
7. **Princípio do menor privilégio é essencial.** O usuário `reports_user` com `GRANT ALL ... WITH GRANT OPTION` é o exemplo clássico de permissão excessiva que um atacante exploraria.

> **🔜 Laboratórios Futuros:**
> - Configuração de TLS no MySQL (`REQUIRE SSL` no GRANT) e comparação de capturas.
> - Autenticação por certificado client-side (`REQUIRE X509`).
> - Detecção de intrusão com audit plugins do MySQL.

---

## 8. Atividade Extra: Análise no Wireshark

Agora que você tem o `mysql.pcap`, leve essa captura para uma máquina com **Wireshark** instalado e estude os pacotes em detalhes.

1. **Abra o arquivo** no Wireshark: `Arquivo > Abrir` (ou `wireshark mysql.pcap` no terminal).
2. **Filtre o tráfego MySQL:** aplique o filtro `mysql` na barra de filtros — fica só o tráfego da porta 3306.
3. **Estude a anatomia de um pacote.** Clique em um pacote `COM_QUERY` e observe as camadas: **Ethernet II** → **IPv4** → **TCP** (porta 3306) → **MySQL** (comando `COM_QUERY`, payload com a query SQL em texto claro).
4. **Encontre os pontos principais:**
   - O pacote com `COM_QUERY` e o payload `CREATE USER 'reports_user'@'%' IDENTIFIED BY 'reports_2024_secret'` — a senha em texto claro!
   - O pacote com `COM_QUERY` e o payload `GRANT ALL PRIVILEGES ON app_db.* TO 'reports_user'@'%' WITH GRANT OPTION` — o grant mais perigoso.
   - O pacote com `COM_QUERY` e o payload `INSERT INTO clientes ...` — os dados pessoais (CPFs, e-mails).
5. **Siga o fluxo completo:** clique com o botão direito no primeiro pacote da sessão → **Follow > TCP Stream** — o Wireshark remonta a conversa inteira (todos os comandos SQL em ordem).
6. **Extraia objetos:** no Wireshark, use **Export Objects > HTTP** **não funciona para MySQL** (HTTP é protocolo de camada 7 diferente). Para reconstruir, use `tshark` ou `tcpdump -A` como mostrado na seção 4.
7. **Reflita:** o dump permitiu recuperar senhas, grants e dados pessoais porque o MySQL sem TLS trafega tudo em texto claro. Se o servidor usasse TLS (MySQL com SSL), o payload seria criptografado e o Wireshark mostraria apenas bytes aparentemente aleatórios — a estrutura visível para de "fazer sentido".

### Como fazer na prática

| Ferramenta | Comando / Ação | Resultado |
|------------|----------------|-----------|
| **tshark** (Kali) | `tshark -r mysql.pcap -Y "mysql.query" -T fields -e mysql.query` | Extrai todas as queries SQL em ordem |
| **tcpdump + grep** (Kali) | `sudo tcpdump -r mysql.pcap -A \| grep -E "CREATE\|GRANT\|INSERT\|SELECT"` | Extração bruta, funcional |
| **Wireshark** | Filtro `mysql` + Follow > TCP Stream | Sessão remontada com todas as queries |
| **mysqlreplay** | `mysqlreplay -r mysql.pcap --server=IP_LIMPO` | Replay automático das queries num MySQL limpo |
| **Manual** | `tcpdump -r mysql.pcap -X \| less` | Hex + ASCII do pacote (para análise profunda) |

> **Dica de estudo:** compare uma conexão MySQL deste laboratório com uma conexão **MySQL com TLS** (configure `REQUIRE SSL` no GRANT e conecte com `mysql --ssl-mode=REQUIRED`) — no MySQL sem TLS os dados aparecem legíveis; no MySQL com TLS, o payload vira bytes criptografados. Essa comparação é o resumo visual do porquê este workshop existe.

---

## Checklist de Validação do Aluno

- [ ] Criei o diretório `/docker/laboratorio-seguranca-mysql` no servidor.
- [ ] Construí a imagem Docker com `docker build -t laboratorio-mysql:latest .`
- [ ] Iniciei o container com `docker run -d --name laboratorio-mysql -p 3306:3306 laboratorio-mysql:latest`
- [ ] Confirmei com `docker ps` a porta `0.0.0.0:3306->3306/tcp`.
- [ ] Testei conectividade do kali com `nc -zv IP_SERVIDOR 3306`.
- [ ] Iniciei a captura com `sudo tcpdump -i any -s 0 -w mysql.pcap "host IP_SERVIDOR and port 3306"`.
- [ ] Executei os comandos SQL (CREATE DATABASE, CREATE TABLE, INSERT, CREATE USER, GRANT, SELECT).
- [ ] Parei a captura com `Ctrl+C` e conferi `packets captured`.
- [ ] Extraí as queries com `tshark -r mysql.pcap -Y "mysql.query" -T fields -e mysql.query`.
- [ ] Identifiquei as senhas em plaintext (`app_secret_2024`, `reports_2024_secret`).
- [ ] Identifiquei os grants excessivos (`GRANT ALL ... WITH GRANT OPTION`).
- [ ] Reconstruí o banco num MySQL limpo usando os comandos extraídos.
- [ ] Expliquei, com minhas palavras, por que TLS é obrigatório em conexões de banco de dados.

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| `docker: command not found` no servidor | Instalar Docker e adicionar usuário ao grupo `docker`. |
| Container não inicia | `docker logs laboratorio-mysql` e `docker ps -a` para ver o erro. |
| Porta 3306 já em uso | `docker stop laboratorio-mysql`; ou mudar para outra porta com `-p 3307:3306`. |
| `nc: Connection refused` na porta 3306 | Verificar `docker ps`; conferir se o firewall libera a porta (`sudo ufw allow 3306`). |
| `mysql: command not found` no cliente | Instalar: `sudo apt install default-mysql-client`. |
| `tshark: command not found` | Instalar: `sudo apt install tshark`. |
| tcpdump sem permissão | Usar `sudo tcpdump` ou adicionar usuário ao grupo `pcap`/`wireshark`. |
| Nenhuma query na captura | Certifique-se de ter executado os comandos SQL **durante** a captura; confira o filtro `host` e `port 3306`. |
| Captura sem pacotes | Trocar `-i any` pela interface real (`ip a` para descobrir, ex.: `-i eth0`). |
| `tshark` não extrai queries | Verifique se o pacote `mysql.pcap` tem tráfego na porta 3306: `tcpdump -r mysql.pcap -n`. |
| MySQL demora para iniciar | Aguarde ~20 segundos; o container precisa inicializar o banco antes de aceitar conexões. |
| `Access denied for user 'dba_user'@'%'` | Confirme a senha (`dba_secret_2024`) e se o usuário foi criado no `init.sql`. |

---

## Anexo A: O que é o tshark?

O `tshark` é a **versão de linha de comando do Wireshark** — a mesma ferramenta gráfica de análise de pacotes, mas sem interface. Ele roda em qualquer terminal Linux/macOS e é ideal para:

- **Filtrar** pacotes de um `.pcap` com a mesma sintaxe de filtros do Wireshark (ex.: `-Y "mysql.query"`).
- **Extrair campos específicos** do protocolo com `-T fields -e <campo>` (ex.: só o texto da query SQL).
- **Automatizar** análise em scripts — perfeito para o desafio deste workshop, onde você extrai centenas de comandos de uma vez.

Neste workshop, o comando-chave do tshark é:

```bash
tshark -r mysql.pcap -Y "mysql.query" -T fields -e mysql.query
```

Ele lê o arquivo `mysql.pcap`, filtra só os pacotes com queries MySQL e imprime apenas o texto SQL — **limpo, sem os headers binários do protocolo**.

> **Comparação:** o `tcpdump` é o "canivete suíço" bruto (captura + mostra payload ASCII); o `tshark` é o "bisturi" (entende o protocolo e extrai exatamente o campo que você quer). Para protocolos binários como MySQL, o tshark é muito mais prático.
>
> **Instalação (no Kali/Debian/Ubuntu):** `sudo apt install tshark`
>
> **Documentação:** `man tshark` ou https://www.wireshark.org/docs/man-pages/tshark.html

---

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/03-Captura_de_Tráfego_MySQL.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>
