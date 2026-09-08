---
title: "Workshop 07: Certificados Digitais, PKI e TLS na Prática"
description: "Workshop prático: entenda o que é um certificado digital X.509, monte uma mini-Autoridade Certificadora (PKI) com OpenSSL, emita certificados para um servidor, configure HTTPS, valide cadeias de confiança e demonstre os ataques mais comuns (certificado expirado, hostname errado, cadeia quebrada e MITM)."
keywords: ["certificado digital", "X.509", "PKI", "ICP-Brasil", "TLS", "HTTPS", "OpenSSL", "Autoridade Certificadora", "cadeia de confiança", "testssl.sh", "segurança em redes", "SENAI"]
tags: ["certificado-digital", "x509", "pki", "icp-brasil", "tls", "https", "openssl", "autoridade-certificadora", "cadeia-de-confianca", "testssl", "seguranca-em-redes"]
author: "Charles Alandt"
lang: "pt-BR"
layout: default
---

# Workshop 07: Certificados Digitais, PKI e TLS na Prática

**Tags:** `certificado digital` · `X.509` · `PKI` · `ICP-Brasil` · `TLS` · `HTTPS` · `OpenSSL` · `Autoridade Certificadora` · `cadeia de confiança` · `testssl.sh`

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
> Este workshop foi testado e validado pelo instrutor em ambiente Ubuntu 26.04 LTS com OpenSSL 3.5.5 (host `srvdocker01`). No entanto, versões diferentes de OpenSSL (Kali, macOS/LibreSSL, Windows/Git Bash) podem gerar saídas ligeiramente diferentes ou exigir flags equivalentes.
>
> **Fique atento:**
> - A execução é permitida apenas em laboratório isolado (VM dedicada ou diretório de trabalho descartável).
> - As chaves privadas e certificados gerados aqui são **apenas para fins didáticos** — nunca reutilize essas chaves em sistemas reais.
> - Em produção, chaves privadas nunca devem ficar em texto puro no disco de um laptop; use HSM, keystore protegido ou, no mínimo, uma passphrase.
> - **Ajustes manuais podem ser necessários** para adequar os comandos à sua versão de OpenSSL e distribuição Linux.
> - **Este material é um guia prático.** O passo a passo foi validado no ambiente do instrutor; adaptações podem ser necessárias para seu ambiente específico.

---

## Índice

- [1. Abertura e Objetivos](#1-abertura-e-objetivos)
- [2. Fundamentos Conceituais](#2-fundamentos-conceituais)
  - [2.1 O problema: como confiar em uma chave pública?](#21-o-problema-como-confiar-em-uma-chave-pública)
  - [2.2 O que é um certificado digital X.509](#22-o-que-é-um-certificado-digital-x509)
  - [2.3 PKI, Autoridade Certificadora e ICP-Brasil](#23-pki-autoridade-certificadora-e-icp-brasil)
  - [2.4 Cadeia de confiança](#24-cadeia-de-confiança)
  - [2.5 Certificado autoassinado × certificado emitido por CA](#25-certificado-autoassinado--certificado-emitido-por-ca)
  - [2.6 TLS e HTTPS: protegendo o canal](#26-tls-e-https-protegendo-o-canal)
- [3. Preparação do Laboratório (Etapa 1)](#3-preparação-do-laboratório-etapa-1)
- [4. Laboratório](#4-laboratório)
  - [Etapa 2: Certificado autoassinado](#etapa-2-certificado-autoassinado)
  - [Etapa 3: Inspecionando um certificado](#etapa-3-inspecionando-um-certificado)
  - [Etapa 4: Montando uma mini-CA (AC raiz)](#etapa-4-montando-uma-mini-ca-ac-raiz)
  - [Etapa 5: Emitindo um certificado para o servidor](#etapa-5-emitindo-um-certificado-para-o-servidor)
  - [Etapa 6: Verificando a cadeia de confiança](#etapa-6-verificando-a-cadeia-de-confiança)
  - [Etapa 7: HTTPS na prática com s_server e s_client](#etapa-7-https-na-prática-com-s_server-e-s_client)
  - [Etapa 8: HTTP × HTTPS com tcpdump](#etapa-8-http--https-com-tcpdump)
  - [Etapa 9: Auditoria com testssl.sh (opcional)](#etapa-9-auditoria-com-testsslsh-opcional)
- [5. Ataques e Falhas](#5-ataques-e-falhas)
  - [Ataque 1: Certificado expirado](#ataque-1-certificado-expirado)
  - [Ataque 2: Hostname errado (mismatch)](#ataque-2-hostname-errado-mismatch)
  - [Ataque 3: Cadeia quebrada (CA não confiável)](#ataque-3-cadeia-quebrada-ca-não-confiável)
  - [Ataque 4: Certificado autoassinado não confiável](#ataque-4-certificado-autoassinado-não-confiável)
  - [Ataque 5: MITM com certificado falso](#ataque-5-mitm-com-certificado-falso)
- [6. Desafio Final](#6-desafio-final)
- [Solução Comentada do Desafio](#solução-comentada-do-desafio)
- [7. Fechamento](#7-fechamento)
- [8. Atividade Extra: Certificados no mundo real](#8-atividade-extra-certificados-no-mundo-real)
- [Troubleshooting](#troubleshooting)

---

## 1. Abertura e Objetivos

### Contextualização

Nos Workshops 01–04, você viu como tráfego **sem criptografia** (HTTP, FTP, MySQL, MQTT) expõe credenciais e dados em texto claro. No Workshop 06, você aprendeu a proteger um **arquivo** com criptografia híbrida (AES-256 + RSA-2048) e viu, no Ataque 3, o problema central: **como saber se uma chave pública realmente pertence a quem diz ser o dono?**

A resposta do mundo real é o **certificado digital** — um documento eletrônico que amarra uma chave pública a uma identidade, assinado por uma autoridade em que todos confiam. E quem "todos" são, na prática? **O próprio navegador.** Ele já vem de fábrica com uma lista embutida de Autoridades Certificadoras confiáveis (o *trust store* — o "cofre de confiança" do navegador). Essa lista é construída em parceria com as entidades certificadoras: para uma CA entrar nela, ela precisa passar por auditorias rigorosas e cumprir requisitos internacionais (como o WebTrust). Quando você acessa um site HTTPS, o navegador **valida o certificado usando essa lista**: ele confere se a CA que assinou o certificado está no cofre — se estiver, mostra o cadeado 🔒; se não estiver, mostra o aviso "sua conexão não é privada". É esse mesmo mecanismo que faz o e-mail ser assinado digitalmente e que permite assinar notas fiscais eletrônicas no Brasil.

Este workshop resolve esse problema construindo, passo a passo, uma **mini-PKI** (Infraestrutura de Chaves Públicas) com OpenSSL: você vai criar sua própria Autoridade Certificadora, emitir certificados para um servidor, configurar uma conexão TLS de verdade e demonstrar os ataques mais comuns.

> [!WARNING]
> **Aviso importante — O "cadeado quebrado" deste laboratório:**
> 
> Nossa mini-CA (AC-Raiz-Empresa) **não está no cofre de confiança do navegador** — porque é uma CA de laboratório que criamos agora. Portanto, quando você acessar o servidor HTTPS deste laboratório em um navegador real, ele mostrará o aviso "sua conexão não é privada" com um cadeado ❌ quebrado, mesmo que o certificado seja válido e a cadeia esteja correta.
> 
> **Por quê?** Porque o navegador segue a lógica documentada na seção anterior: procura a CA-Raiz-Empresa no seu cofre de confiança embutido — e não encontra, porque ela é nossa CA privada de teste.
> 
> **Como resolver (em cenários reais):**
> 
> 1. **Em uma corporação com CA própria (ex.: ADCS do Windows, ou uma CA corporativa):**
>    - O departamento de TI **importa o certificado da CA corporativa no cofre do navegador** de todos os computadores da empresa (via política de domínio, MDM, ou instalação manual).
>    - Depois disso, os navegadores de todos os funcionários reconhecem a CA — e qualquer certificado emitido por ela mostra o cadeado ✅ verde, sem avisos.
> 
> 2. **Neste laboratório (para testar no navegador):**
>    - Você pode **importar manualmente o certificado da CA-Raiz-Empresa no navegador** (File → Settings → Security → Certificates → Import ca.crt), marcando como "confiável para autenticar sites".
>    - Depois disso, o navegador confiará em certificados emitidos por essa CA — e mostrará o cadeado verde quando acessar o servidor de laboratório.
> 
> **Lição:** o "cadeado quebrado" aqui é **educacional** — mostra que a segurança depende não só da criptografia, mas também de **confiança estabelecida**. Sem a CA no cofre, nem OpenSSL nem navegador confiam. Com ela, ambos confiam. Essa é a diferença entre um certificado matematicamente válido e um certificado **confiável**.

### Problema corporativo (resumo em uma frase)

> "Quando você digita um endereço no navegador, **como ter certeza de que quem respondeu é mesmo o site certo — e não um impostor no meio do caminho?**"

Pense assim: você pede a chave pública do servidor pela rede e recebe uma. Mas **quem garante que essa chave veio do servidor verdadeiro?** Um atacante no meio do caminho pode interceptar o pedido e devolver a **chave dele**, e você não teria como perceber — a chave é só um monte de números, ela não tem "rosto" nem "documento de identidade".

É exatamente esse o buraco que o certificado digital fecha: ele funciona como um **documento com foto** da chave pública, emitido e assinado por um "cartório" (a Autoridade Certificadora) em que o navegador já confia.

### Contexto dos Workshops anteriores

> [!NOTE]
> **Workshop 06:** você viu o Ataque 3 (substituição de chave pública / MITM), em que Morgan entrega a própria chave pública fingindo ser de Sam. A mitigação citada foi: *"certificados digitais (X.509) assinados por uma Autoridade Certificadora (PKI), ou verificação manual de fingerprint"*. Este workshop é exatamente onde isso se resolve na prática.

### Objetivos deste workshop

Ao final deste workshop, você será capaz de:

1. Explicar o que é um certificado digital X.509 e o que ele contém.
2. Diferenciar certificado **autoassinado** de certificado **emitido por uma CA**.
3. Criar uma **mini-CA** (AC raiz) com OpenSSL.
4. Gerar uma **CSR** (Certificate Signing Request) e emitir um certificado para um servidor.
5. Verificar uma **cadeia de confiança** com `openssl verify`.
6. Estabelecer uma conexão **TLS** real entre `s_server` e `s_client`, validando o certificado.
7. Comparar **HTTP × HTTPS** com tcpdump, fechando o ciclo dos Workshops 01–04.
8. Reconhecer e demonstrar 5 falhas/ataques: certificado expirado, hostname errado, cadeia quebrada, autoassinado não confiável e MITM.
9. Auditar um servidor TLS com `testssl.sh` (opcional).
10. Resolver, sozinho, um desafio corporativo aplicando tudo o que foi aprendido.

### Pré-requisitos

- Linux (Ubuntu/Debian/Kali) com `openssl`, `tar`, `tcpdump` instalados.
- Conhecimento básico de terminal (criar diretórios, editar arquivos, redirecionar saída).
- Ter feito (ou revisado) os Workshops 01–04 (por que criptografia em trânsito importa) e o Workshop 06 (criptografia híbrida e o problema do MITM).

### Resultado esperado

Ao final, você terá em mãos um diretório `pki/` completo com uma AC raiz funcional, um certificado de servidor emitido por ela, uma conexão TLS validada de ponta a ponta e um relatório dos ataques testados no seu próprio ambiente.

---

## 2. Fundamentos Conceituais

### 2.1 O problema: como confiar em uma chave pública?

No Workshop 06, Alex recebeu uma chave pública que **achava** ser de Sam — mas era de Morgan. O problema fundamental é:

```
Como provar que uma chave pública pertence a uma identidade?
        │
        ▼
┌─────────────────────────────────────────────────────┐
│ SOLUÇÃO: um CERTIFICADO DIGITAL                     │
│                                                     │
│  "Eu, Autoridade Certificadora, ATESTO que esta     │
│   chave pública pertence a 'servidor.local'."       │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │ Certificado X.509                          │    │
│  │ ├─ Identidade (CN, O, C)                   │    │
│  │ ├─ Chave pública do dono                   │    │
│  │ ├─ Validade (não antes / não depois)       │    │
│  │ ├─ Número de série                         │    │
│  │ └─ Assinatura da CA (o que dá confiança)   │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

A chave pública **sozinha** não prova nada. O certificado é o que amarra a chave à identidade, com a assinatura de uma autoridade confiável.

### 2.2 O que é um certificado digital X.509

O **X.509** é o padrão internacional (ITU-T) que define o formato dos certificados digitais. É o formato usado por TLS/HTTPS, e-mail (S/MIME), assinatura de documentos e ICP-Brasil.

Um certificado X.509 contém, essencialmente:

| Campo | O que é | Exemplo |
|-------|---------|---------|
| **Subject (DN)** | A identidade do dono do certificado | `CN=servidor.local, O=Empresa, C=BR` |
| **Issuer (DN)** | Quem emitiu (assinou) o certificado | `CN=AC-Raiz-Empresa, O=Empresa, C=BR` |
| **Chave pública** | A chave pública do dono | RSA 2048 bits |
| **Validade** | Período em que é válido | `notBefore` / `notAfter` |
| **Número de série** | Identificador único emitido pela CA | `12:B9:5D:87:...` |
| **Assinatura da CA** | A assinatura digital da autoridade sobre tudo acima | SHA-256 com RSA |
| **SAN (Subject Alternative Name)** | Nomes de host/IP que o certificado cobre | `DNS:servidor.local, IP:127.0.0.1` |

> [!IMPORTANT]
> **SAN é obrigatório nos navegadores modernos.** Desde 2017 (Chrome 58+), o campo `commonName` (CN) **não é mais usado** para validar o nome do site — apenas o **SAN** é considerado. Um certificado sem SAN correto gera erro de hostname mesmo com CN correto.

### 2.3 PKI, Autoridade Certificadora e ICP-Brasil

**PKI (Public Key Infrastructure)** é o conjunto de hardware, software, pessoas, políticas e procedimentos necessários para criar, gerenciar, distribuir, usar, armazenar e revogar certificados digitais.

Os papéis principais:

| Papel | Função |
|-------|--------|
| **AC (Autoridade Certificadora)** | Emite e assina certificados; é o "cartório digital" |
| **AR (Autoridade de Registro)** | Valida a identidade de quem pede o certificado (faz o "cadastro") |
| **Titular** | Quem recebe o certificado (pessoa, servidor, dispositivo) |
| **Repositório** | Onde os certificados e listas de revogação (CRL) ficam publicados |

**ICP-Brasil** é a Infraestrutura de Chaves Públicas Brasileira, criada pela MP 2.200-2/2001 e regulada pelo **ITI** (Instituto Nacional de Tecnologia da Informação). É uma cadeia hierárquica:

```
AC Raiz (ITI)
 └── ACs de 1º nível (autoridades credenciadas)
      └── ACs de 2º nível
           └── Certificados de usuários finais
```

Os certificados ICP-Brasil têm tipos:

| Tipo | Onde fica a chave | Uso típico |
|------|-------------------|------------|
| **A1** | No computador (arquivo) | Assinatura de NF-e, documentos |
| **A3** | Em cartão ou token criptográfico | Assinatura com maior segurança |
| **A4** | Em cartão ou token | Assinatura com validação biométrica |
| **S** | No computador | Sigilo (criptografia de e-mail) |
| **T** | No computador | Carimbo de tempo |

### 2.4 Cadeia de confiança

Um certificado emitido por uma CA não é verificado isoladamente — o cliente monta a **cadeia** até chegar em uma CA em que ele confia:

```
┌─────────────────────────────┐
│ Certificado do servidor     │  ← emitido pela AC-Raiz
│ issuer = AC-Raiz-Empresa    │
└─────────────┬───────────────┘
              │ "quem te assinou?"
              ▼
┌─────────────────────────────┐
│ Certificado da AC-Raiz      │  ← autoassinado (raiz de confiança)
│ issuer = AC-Raiz-Empresa    │
│ (está no "cofre" do cliente)│
└─────────────────────────────┘
```

O cliente (navegador, `s_client`, sistema operacional) mantém um **cofre de CAs confiáveis** (trust store). Se a cadeia terminar em uma CA que está nesse cofre, a confiança é estabelecida. Se não, o cliente avisa: "certificado não confiável".

### 2.5 Certificado autoassinado × certificado emitido por CA

| Aspecto | Autoassinado | Emitido por CA |
|---------|--------------|----------------|
| **Quem assina** | O próprio dono | Uma CA (raiz ou intermediária) |
| **Subject = Issuer?** | Sim | Não |
| **Confiança** | Só quem já conhece o certificado | Qualquer um que confie na CA |
| **Uso típico** | Laboratório, testes, intranet pequena | Produção, internet, ICP-Brasil |
| **Navegador** | Avisa "não confiável" | Mostra cadeado 🔒 (se a CA for confiável) |

### 2.6 TLS e HTTPS: protegendo o canal

No Workshop 06, você protegeu o **objeto** (o arquivo). O **TLS** (Transport Layer Security) protege o **canal** — a conversa inteira entre duas máquinas:

```
CAMADA DO OBJETO (arquivo)          CAMADA DO CANAL (transporte)
──────────────────────────          ─────────────────────────────
AES-256-CBC                         TLS 1.2/1.3
├─ Cifra o conteúdo                 ├─ Cifra toda a conversa
├─ Sobrevive ao armazenamento       ├─ Protege metadados
│  (arquivo fica cifrado em disco)  │  (nome, tamanho, IP)
└─ Válido mesmo depois de anos      └─ Válido durante a transmissão
```

O **HTTPS** é simplesmente HTTP sobre TLS. E o TLS, na prática, é **criptografia híbrida** (como no Workshop 06): o cliente e o servidor negociam uma chave simétrica de sessão, e o certificado do servidor é usado para autenticar o servidor e proteger essa negociação.

**O handshake TLS em resumo:**

```
Cliente ── "olá, quero falar com servidor.local" ──→ Servidor
Cliente ←── "aqui está meu certificado" ──────────── Servidor
Cliente verifica: cadeia de confiança + hostname + validade
Cliente ── "combinamos uma chave de sessão (cifrada)" ──→ Servidor
Cliente ←── "tudo certo, vamos conversar cifrado" ──── Servidor
```

> 🤔 **Pense um pouco:** no handshake acima, o certificado do servidor é usado para provar **o quê** ao cliente? *(Que o servidor é realmente quem diz ser — autenticidade — e para proteger a negociação da chave de sessão.)*

---

## 3. Preparação do Laboratório (Etapa 1)

**Objetivo:** montar a estrutura de diretórios que simula os três papéis de uma PKI: a Autoridade Certificadora, o servidor que recebe o certificado e o cliente que vai validar.

**Conceito:** em uma PKI real, a CA fica em uma máquina isolada e protegida (idealmente offline), o servidor fica na rede e o cliente é qualquer navegador ou aplicação. Aqui, simulamos tudo em um único diretório.

**Comandos:**

```bash
mkdir -p pki/{ca,servidor,cliente}
cd pki
ls -la
```

**Explicação dos comandos:**

- `mkdir -p pki/{ca,servidor,cliente}`: cria de uma vez os três diretórios que representam os papéis.
- `ca/` → a **Autoridade Certificadora** (emissora dos certificados).
- `servidor/` → o **servidor** que vai receber o certificado e rodar HTTPS.
- `cliente/` → o **cliente** que vai validar a cadeia de confiança.

**Resultado esperado:**

```text
drwxr-xr-x  3 aluno aluno 4096 set  8 09:00 ca
drwxr-xr-x  3 aluno aluno 4096 set  8 09:00 cliente
drwxr-xr-x  3 aluno aluno 4096 set  8 09:00 servidor
```

**Validação:** `ls pki/` deve listar exatamente os 3 diretórios.

🤔 **Pense um pouco:** por que a CA e o servidor ficam em diretórios separados? *(Porque em uma PKI real são máquinas diferentes — a CA é o "cartório" e o servidor é o "cliente do cartório". Ninguém além da CA deve ter acesso à chave privada da CA.)*

---

## 4. Laboratório

### Etapa 2: Certificado autoassinado

**Objetivo:** gerar o primeiro certificado — um autoassinado — e entender a diferença entre "eu me assino" e "uma CA me assina".

**Conceito:** um certificado autoassinado é aquele em que `subject` (dono) e `issuer` (emissor) são a **mesma** pessoa. É como um documento em que a própria pessoa assina atestando a própria identidade — útil para testes, mas não confiável para terceiros.

**Comandos:**

```bash
cd ~/pki/servidor

openssl req -x509 -newkey rsa:2048 -keyout srv.key -out srv.crt -days 365 -nodes \
  -subj "/CN=servidor.local/O=Empresa/C=BR"
ls -l srv.key srv.crt
```

**Explicação dos comandos:**

- `req`: comando de requisição de certificado (e geração de autoassinado).
- `-x509`: gera um certificado autoassinado diretamente (em vez de uma CSR).
- `-newkey rsa:2048`: gera uma chave privada RSA de 2048 bits junto.
- `-keyout srv.key`: salva a chave privada do servidor.
- `-out srv.crt`: salva o certificado.
- `-days 365`: válido por 1 ano.
- `-nodes`: não cifra a chave privada com senha (simplifica o laboratório; em produção, use passphrase).
- `-subj "/CN=servidor.local/O=Empresa/C=BR"`: dados da identidade — CN (Common Name) = nome do servidor, O (Organization) = Empresa, C (Country) = BR.

**Resultado esperado:**

```text
-rw------- 1 aluno aluno 1704 set  8 09:02 srv.key
-rw-r--r-- 1 aluno aluno 1212 set  8 09:02 srv.crt
```

**Validação — confirme que é autoassinado (subject = issuer):**

```bash
openssl x509 -in srv.crt -noout -subject -issuer
```

**Resultado esperado:**

```text
subject=CN=servidor.local, O=Empresa, C=BR
issuer=CN=servidor.local, O=Empresa, C=BR
```

🤔 **Pense um pouco:** o que o fato de `subject` e `issuer` serem iguais indica? *(Que o certificado foi assinado pelo próprio dono — autoassinado. Nenhuma autoridade externa atestou essa identidade.)*

---

### Etapa 3: Inspecionando um certificado

**Objetivo:** aprender a "ler" um certificado — a habilidade mais útil para diagnosticar problemas de TLS.

**Conceito:** o `openssl x509 -text` mostra todos os campos do certificado. Saber ler esses campos é o que permite identificar por que um certificado está sendo rejeitado.

**Comandos:**

```bash
openssl x509 -in srv.crt -text -noout
```

**Explicação dos comandos:**

- `x509`: comando para manipular certificados X.509.
- `-in srv.crt`: certificado de entrada.
- `-text`: exibe o conteúdo completo em formato legível.
- `-noout`: não imprime o certificado em base64 (só o texto).

**Resultado esperado (trechos principais):**

```text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            2a:79:8e:21:d0:c9:08:9b:de:33:c3:98:c5:73:9e:33:ba:3f:4d:84
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=servidor.local, O=Empresa, C=BR
        Validity
            Not Before: Sep  8 01:25:43 2026 GMT
            Not After : Sep  8 01:25:43 2027 GMT
        Subject: CN=servidor.local, O=Empresa, C=BR
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
```

**Comandos rápidos de inspeção (muito úteis no dia a dia):**

```bash
# Só o subject (dono)
openssl x509 -in srv.crt -noout -subject

# Só o issuer (emissor)
openssl x509 -in srv.crt -noout -issuer

# Datas de validade
openssl x509 -in srv.crt -noout -dates

# Número de série
openssl x509 -in srv.crt -noout -serial

# Fingerprint SHA-256 (impressão digital única)
openssl x509 -in srv.crt -noout -fingerprint -sha256

# Chave pública embutida no certificado
openssl x509 -in srv.crt -pubkey -noout
```

**Validação — a chave pública do certificado casa com a chave privada?**

```bash
diff <(openssl x509 -in srv.crt -pubkey -noout) \
     <(openssl pkey -in srv.key -pubout) && echo "Chaves casam!"
```

**Resultado esperado:**

```text
Chaves casam!
```

🤔 **Pense um pouco:** por que é importante que a chave pública do certificado seja exatamente a correspondente à chave privada? *(Porque o certificado atesta "esta chave pública pertence a servidor.local" — se a chave privada não for a correspondente, o servidor não consegue provar que é o dono, e o handshake falha.)*

---

### Etapa 4: Montando uma mini-CA (AC raiz)

**Objetivo:** criar a Autoridade Certificadora da nossa mini-PKI — o "cartório digital" que vai assinar os certificados dos servidores.

**Conceito:** a AC raiz é o topo da cadeia de confiança. Ela tem sua própria chave privada (guardada com máximo cuidado) e seu próprio certificado autoassinado — mas, ao contrário do certificado do servidor, o da AC **é** a raiz de confiança: quem confia na AC, confia em tudo que ela assinar.

**Comandos:**

```bash
cd ~/pki/ca

# 1. Chave privada da CA (protegida com chmod 600)
openssl genrsa -out ca.key 2048
chmod 600 ca.key

# 2. Certificado autoassinado da CA (raiz de confiança)
openssl req -x509 -new -key ca.key -out ca.crt -days 3650 -nodes \
  -subj "/CN=AC-Raiz-Empresa/O=Empresa/C=BR"

# 3. Conferir
openssl x509 -in ca.crt -noout -subject -issuer -dates
```

**Explicação dos comandos:**

- `genrsa -out ca.key 2048`: gera a chave privada da CA (2048 bits).
- `chmod 600 ca.key`: só o dono pode ler — a chave da CA é o item mais sensível da PKI.
- `req -x509 -new -key ca.key`: gera o certificado autoassinado da CA usando a chave já existente (note: `-new` em vez de `-newkey`, pois a chave já existe).
- `-days 3650`: a CA raiz costuma ter validade longa (10 anos).
- `-subj "/CN=AC-Raiz-Empresa/O=Empresa/C=BR"`: identidade da CA.

**Resultado esperado:**

```text
subject=CN=AC-Raiz-Empresa, O=Empresa, C=BR
issuer=CN=AC-Raiz-Empresa, O=Empresa, C=BR
notBefore=Sep  8 01:25:44 2026 GMT
notAfter=Sep  8 01:25:44 2036 GMT
```

🤔 **Pense um pouco:** por que a chave privada da CA é mais sensível que a do servidor? *(Porque quem tem a chave da CA pode emitir certificados falsos para qualquer identidade — e todos que confiam na CA aceitariam. É o "carimbo" do cartório.)*

---

### Etapa 5: Emitindo um certificado para o servidor

**Objetivo:** fazer a CA emitir um certificado **para o servidor** — agora sim, um certificado com `issuer` diferente de `subject`, atestado por uma autoridade.

**Conceito:** o fluxo real de emissão tem 3 passos: (1) o servidor gera uma **CSR** (Certificate Signing Request) com sua chave e seus dados; (2) a CA valida os dados e **assina** a CSR, gerando o certificado; (3) o servidor instala o certificado. A chave privada **nunca** sai do servidor — só a CSR viaja.

**Comandos — Passo 1: o servidor gera a CSR (com SAN):**

```bash
cd ~/pki/servidor

openssl req -new -newkey rsa:2048 -keyout servidor.key -out servidor.csr -nodes \
  -subj "/CN=servidor.local/O=Empresa/C=BR" \
  -addext "subjectAltName=DNS:servidor.local,DNS:localhost,IP:127.0.0.1"
```

**Explicação dos comandos:**

- `req -new`: gera uma **CSR** (não um certificado — repare que não tem `-x509`).
- `-newkey rsa:2048`: gera uma chave nova para o servidor.
- `-keyout servidor.key`: salva a chave privada do servidor (fica com ele).
- `-out servidor.csr`: salva a requisição (é isso que vai para a CA).
- `-addext "subjectAltName=..."`: adiciona os nomes alternativos (SAN) — **essencial** para navegadores modernos.

**Comandos — Passo 2: a CA assina a CSR e emite o certificado:**

```bash
cd ~/pki/ca

openssl x509 -req -in ../servidor/servidor.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out ../servidor/servidor.crt -days 365 \
  -copy_extensions copy
```

**Explicação dos comandos:**

- `x509 -req`: modo de assinatura de uma CSR.
- `-in ../servidor/servidor.csr`: a requisição do servidor.
- `-CA ca.crt -CAkey ca.key`: o certificado e a chave da CA (quem assina).
- `-CAcreateserial`: cria o arquivo de número de série da CA (primeira emissão).
- `-out ../servidor/servidor.crt`: o certificado emitido.
- `-days 365`: validade de 1 ano.
- `-copy_extensions copy`: copia as extensões (SAN) da CSR para o certificado final.

**Resultado esperado — confira que agora issuer ≠ subject:**

```bash
openssl x509 -in ../servidor/servidor.crt -noout -subject -issuer -ext subjectAltName
```

```text
subject=CN=servidor.local, O=Empresa, C=BR
issuer=CN=AC-Raiz-Empresa, O=Empresa, C=BR
X509v3 Subject Alternative Name:
    DNS:servidor.local, DNS:localhost, IP Address:127.0.0.1
```

**Validação — o certificado do servidor foi emitido pela nossa CA:**

```bash
openssl verify -CAfile ca.crt ../servidor/servidor.crt
```

**Resultado esperado:**

```text
../servidor/servidor.crt: OK
```

🤔 **Pense um pouco:** por que a chave privada do servidor (`servidor.key`) não precisou ser enviada para a CA? *(Porque a CA só precisa da CSR — que contém a chave pública e os dados. A chave privada nunca sai do servidor; é isso que garante que só o servidor consiga usar o certificado.)*

---

### Etapa 6: Verificando a cadeia de confiança

**Objetivo:** entender como o cliente valida o certificado — montando a cadeia até a raiz de confiança.

**Conceito:** o cliente recebe o certificado do servidor, vê que o `issuer` é `AC-Raiz-Empresa`, procura essa CA no seu cofre de confiança e verifica a assinatura. Se a cadeia fechar, confia.

**Comandos — o cliente "instala" a CA no cofre:**

```bash
cd ~/pki/cliente
cp ~/pki/ca/ca.crt .

# Verificar a cadeia a partir do cofre do cliente
openssl verify -CAfile ca.crt ../servidor/servidor.crt
```

**Explicação dos comandos:**

- `cp ~/pki/ca/ca.crt .`: simula o cliente recebendo a CA raiz (em uma empresa real, isso vem pré-instalado no sistema ou via política de TI).
- `openssl verify -CAfile ca.crt ...`: verifica se o certificado do servidor é assinado por uma CA no cofre.

**Resultado esperado:**

```text
../servidor/servidor.crt: OK
```

**Verificações adicionais úteis:**

```bash
# Verificar com propósito específico (servidor web)
openssl verify -CAfile ca.crt -purpose sslserver ../servidor/servidor.crt

# Verificar hostname (deve casar com o SAN)
openssl x509 -in ../servidor/servidor.crt -noout -checkhost servidor.local
openssl x509 -in ../servidor/servidor.crt -noout -checkhost www.empresa.com
```

**Resultado esperado:**

```text
../servidor/servidor.crt: OK
Hostname servidor.local does match certificate
Hostname www.empresa.com does NOT match certificate
```

🤔 **Pense um pouco:** o que acontece se o cliente **não** tiver a CA no cofre? *(A verificação falha com "unable to get local issuer certificate" — o cliente não consegue montar a cadeia até uma raiz confiável. É exatamente o aviso que o navegador mostra para certificados de CAs desconhecidas.)*

---

### Etapa 7: HTTPS na prática com s_server e s_client

**Objetivo:** estabelecer uma conexão TLS real entre um "servidor" e um "cliente", validando o certificado de ponta a ponta.

**Conceito:** o `openssl s_server` simula um servidor HTTPS; o `openssl s_client` simula um navegador. Juntos, eles executam o handshake TLS completo — e o `s_client` mostra o resultado da validação do certificado.

**Comandos — Passo 1: iniciar o servidor TLS (em um terminal):**

```bash
cd ~/pki/servidor
openssl s_server -accept 4443 -cert servidor.crt -key servidor.key -quiet
```

**Explicação dos comandos:**

- `s_server`: modo servidor TLS do OpenSSL.
- `-accept 4443`: escuta na porta 4443.
- `-cert servidor.crt -key servidor.key`: o certificado e a chave do servidor.
- `-quiet`: não exibe logs do handshake (apenas passa dados).

**Resultado esperado:** o comando **fica em espera**, aguardando conexão. (Não retorna o prompt — é normal; deixe esse terminal aberto.)

**Comandos — Passo 2: o cliente conecta e valida (em outro terminal):**

```bash
cd ~/pki/cliente
echo "dados confidenciais via TLS" | openssl s_client -connect localhost:4443 \
  -CAfile ca.crt -verify_return_error
```

**Explicação dos comandos:**

- `s_client`: modo cliente TLS.
- `-connect localhost:4443`: conecta ao servidor.
- `-CAfile ca.crt`: o cofre de CAs confiáveis do cliente (nossa AC raiz).
- `-verify_return_error`: **aborta** a conexão se a validação falhar (comportamento de navegador).
- O texto enviado via pipe é transmitido cifrado para o servidor.

**Resultado esperado (trechos principais):**

```text
New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
Protocol: TLSv1.3
Verify return code: 0 (ok)
```

**Validação — o que cada linha significa:**

- `TLSv1.3`: a versão do protocolo negociada (a mais moderna).
- `Cipher is TLS_AES_256_GCM_SHA384`: a cifra de sessão negociada (AES-256-GCM — criptografia autenticada, a mesma família que você viu na teoria do Workshop 06).
- **`Verify return code: 0 (ok)`**: a validação do certificado passou — cadeia OK, hostname OK, validade OK. **Este é o "cadeado verde" do navegador.**

**Comandos — Passo 3: ver a cadeia que o servidor enviou:**

```bash
echo | openssl s_client -connect localhost:4443 -CAfile ca.crt -showcerts 2>/dev/null | \
  grep -E "subject=|issuer=|Verify return code"
```

**Resultado esperado:**

```text
subject=CN=servidor.local, O=Empresa, C=BR
issuer=CN=AC-Raiz-Empresa, O=Empresa, C=BR
Verify return code: 0 (ok)
```

🤔 **Pense um pouco:** no handshake, o servidor enviou o certificado **dele** — mas quem garante que esse certificado é legítimo? *(A assinatura da AC-Raiz-Empresa, que está no cofre do cliente. O cliente verificou a assinatura, a validade e o hostname — por isso o `Verify return code: 0 (ok)`.)*

---

### Etapa 8: HTTP × HTTPS com tcpdump

**Objetivo:** fechar o ciclo dos Workshops 01–04 — ver com os próprios olhos a diferença entre tráfego claro e tráfego cifrado.

**Conceito:** nos Workshops 01–04, o tcpdump mostrava `USER admin`, `PASS 123456`, queries SQL em **texto puro**. Agora, com TLS, o mesmo tcpdump mostra apenas bytes aparentemente aleatórios.

**Comandos — Passo 1: capture o tráfego TLS (em um terceiro terminal):**

```bash
sudo tcpdump -i lo -s 0 'tcp port 4443' -A | head -50
```

**Explicação dos comandos:**

- `-i lo`: interface loopback (localhost → localhost).
- `-s 0`: captura pacotes completos.
- `'tcp port 4443'`: filtra só a porta onde o TLS está rodando.
- `-A`: mostra o payload em ASCII.
- `| head -50`: limita a 50 linhas (o handshake é verboso).

**Comandos — Passo 2: enquanto captura, repita a conexão do Passo 2 da Etapa 7:**

```bash
echo "RELATORIO CONFIDENCIAL: vulnerabilidade em servidor de pagamentos" | \
  openssl s_client -connect localhost:4443 -CAfile ~/pki/cliente/ca.crt -quiet 2>/dev/null
```

**Resultado esperado no tcpdump:**

```text
14:22:15.234567 IP localhost.45678 > localhost.4443: Flags [P.], seq 1:243, ack 1
...X.....<.....A.M.6.w.2..y...U.3.e......[.7..E.....&..m!..Aq.~..S..
14:22:15.235678 IP localhost.4443 > localhost.45678: Flags [P.], seq 1:1234, ack 243
.c...C.@.......z.H.....^...x%.!7Q...)......#7."b...+.E....V...
[mais bytes aparentemente aleatórios — é o conteúdo cifrado]
```

**Análise — compare com os Workshops 01–04:**

- **Lá:** você viu `USER admin`, `PASS 123456`, `SELECT *` em texto puro.
- **Aqui:** você vê apenas bytes aparentemente aleatórios — **a mesma informação, mas cifrada**. Nem o conteúdo, nem o nome do arquivo, nem o "assunto" da conversa aparecem.

🤔 **Pense um pouco:** se um atacante capturasse esse tráfego, o que ele conseguiria ler? *(Nada do conteúdo — apenas que houve uma conexão na porta 4443 entre dois endereços. Confidencialidade do canal garantida pelo TLS.)*

---

### Etapa 9: Auditoria com testssl.sh (opcional)

**Objetivo:** usar a mesma ferramenta que profissionais de segurança usam para auditar servidores TLS — o `testssl.sh`.

**Conceito:** o `testssl.sh` é um script que testa um servidor TLS contra uma bateria de verificações: versões de protocolo suportadas, cifras, vulnerabilidades conhecidas (Heartbleed, POODLE, BEAST, etc.), validade do certificado e muito mais. É a ferramenta citada no plano da disciplina para o Lab 5.

**Comandos — Passo 1: instalar (uma vez):**

```bash
sudo apt install git -y
git clone --depth 1 https://github.com/drwetter/testssl.sh.git ~/testssl.sh
```

**Explicação dos comandos:**

- `git clone`: baixa o script do repositório oficial.
- `--depth 1`: clona só o último commit (mais rápido).

**Comandos — Passo 2: auditar nosso servidor TLS (com o s_server ainda rodando):**

```bash
cd ~/testssl.sh
./testssl.sh --quiet --color 0 localhost:4443
```

**Explicação dos comandos:**

- `--quiet`: menos ruído na saída.
- `--color 0`: desativa cores (saída limpa para copiar).
- `localhost:4443`: o alvo (nosso servidor TLS do laboratório).

**Resultado esperado (trechos):**

```text
 Testing protocols via sockets except NPN+ALPN

 SSLv2      not offered (OK)
 SSLv3      not offered (OK)
 TLS 1      not offered (OK)
 TLS 1.1    not offered (OK)
 TLS 1.2    offered (OK)
 TLS 1.3    offered (OK)

 Testing cipher categories

 Null ciphers      not offered (OK)
 Anonymous NULL Ciphers   not offered (OK)
 ...
```

**Análise:** o `testssl.sh` confirma que nosso servidor está com configuração segura: sem protocolos antigos (SSLv2/SSLv3), sem cifras nulas, TLS 1.2/1.3 habilitados. Em um servidor real, é essa auditoria que detecta configurações fracas antes de um atacante explorá-las.

> [!NOTE]
> **Se o `s_server` não estiver mais rodando**, reinicie-o (Etapa 7, Passo 1) antes de rodar o `testssl.sh`. O `testssl.sh` também funciona contra servidores remotos: `./testssl.sh https://www.exemplo.com.br`.

🤔 **Pense um pouco:** por que um auditor rodaria o `testssl.sh` contra um servidor de produção? *(Para detectar protocolos antigos, cifras fracas e vulnerabilidades conhecidas antes que um atacante as explore — é uma checagem preventiva de hardening.)*

---

## 5. Ataques e Falhas

> [!CAUTION]
> Todas as demonstrações abaixo ocorrem **exclusivamente** dentro do diretório `pki/` deste laboratório. Nunca aplique essas técnicas fora de um ambiente controlado e autorizado.

### Ataque 1: Certificado expirado

**Cenário:** o certificado do servidor passou da data de validade. Navegadores e clientes TLS **rejeitam** conexões com certificados expirados.

**Comandos — criar um certificado já expirado (datas de 2020–2021):**

```bash
cd ~/pki/ca

# CSR para o certificado "expirado"
openssl req -new -newkey rsa:2048 -keyout expirado.key -out expirado.csr -nodes \
  -subj "/CN=expirado.local/O=Empresa/C=BR" 2>/dev/null

# Configuração mínima da CA para assinar com datas no passado
cat > ca_expirado.cnf << 'EOF'
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = /tmp/pki-ca
database = $dir/index.txt
new_certs_dir = $dir/newcerts
certificate = $dir/ca.crt
private_key = $dir/ca.key
serial = $dir/serial
default_md = sha256
policy = policy_any

[ policy_any ]
commonName = supplied
organizationName = optional
countryName = optional
EOF

mkdir -p /tmp/pki-ca/newcerts
cp ca.crt ca.key /tmp/pki-ca/
touch /tmp/pki-ca/index.txt && echo 1000 > /tmp/pki-ca/serial

openssl ca -config ca_expirado.cnf -in expirado.csr -out expirado.crt -batch \
  -startdate 20200101000000Z -enddate 20210101000000Z 2>/dev/null
```

**Explicação dos comandos:**

- `openssl ca`: o comando completo de Autoridade Certificadora (mais poderoso que `x509 -req`).
- `-startdate 20200101000000Z -enddate 20210101000000Z`: define a validade **no passado** (2020–2021) — o certificado nasce já expirado.
- O arquivo `ca_expirado.cnf` define a estrutura mínima que o `openssl ca` exige (banco de dados, serial, políticas).

**Validação — confira as datas e a falha:**

```bash
openssl x509 -in expirado.crt -noout -dates
openssl verify -CAfile ca.crt expirado.crt
```

**Resultado esperado:**

```text
notBefore=Jan  1 00:00:00 2020 GMT
notAfter=Jan  1 00:00:00 2021 GMT
CN=expirado.local, O=Empresa, C=BR
error 10 at 0 depth lookup: certificate has expired
error expirado.crt: verification failed
```

**Análise:** o `openssl verify` retorna **`error 10: certificate has expired`**. Em um navegador, o usuário veria "certificado expirado" e a conexão seria bloqueada. Na prática corporativa, certificados expirados são uma das causas mais comuns de indisponibilidade — por isso existem sistemas de monitoramento de validade.

**Propriedade comprometida:** disponibilidade (o serviço para de funcionar) e confiança (o cliente não pode mais verificar a identidade).

---

### Ataque 2: Hostname errado (mismatch)

**Cenário:** o certificado é válido e a cadeia confere, mas o nome no certificado **não corresponde** ao endereço que o cliente está acessando. É o erro clássico de "certificado para outro domínio".

**Comandos — verificar o hostname do nosso certificado:**

```bash
cd ~/pki/servidor

# Hostname que o certificado cobre (SAN)
openssl x509 -in servidor.crt -noout -checkhost servidor.local

# Hostname que o certificado NÃO cobre
openssl x509 -in servidor.crt -noout -checkhost www.empresa.com
```

**Resultado esperado:**

```text
Hostname servidor.local does match certificate
Hostname www.empresa.com does NOT match certificate
```

**Demonstração prática — cliente acessa com o nome errado:**

```bash
# Servidor rodando (Etapa 7) — cliente tenta acessar como "www.empresa.com"
echo | openssl s_client -connect localhost:4443 -CAfile ~/pki/cliente/ca.crt \
  -verify_return_error -verify_hostname www.empresa.com 2>/dev/null | grep -E "Verify return code|verify error"
```

**Explicação dos comandos:**

- `-verify_hostname www.empresa.com`: faz o cliente verificar se o nome acessado está no SAN do certificado. **Sem essa flag, o `s_client` valida apenas a cadeia de confiança** (como um navegador com a verificação de nome desligada) — por isso o `-verify_hostname` é essencial para reproduzir o comportamento real de um navegador.

**Resultado esperado:**

```text
verify error:num=62:hostname mismatch
Verify return code: 62 (hostname mismatch)
```

**Análise:** o código **62 (hostname mismatch)** é exatamente o que o navegador mostra como "o certificado não é válido para este site" — mesmo que a cadeia de confiança esteja OK. Isso impede o ataque em que um certificado válido de um domínio é usado em outro.

**Propriedade comprometida:** autenticidade (o cliente não pode confirmar que está falando com o servidor certo).

---

### Ataque 3: Cadeia quebrada (CA não confiável)

**Cenário:** o servidor apresenta um certificado emitido por uma CA que o cliente **não conhece**. O cliente não consegue montar a cadeia até uma raiz confiável.

**Comandos — simular um cliente que confia em outra CA:**

```bash
cd ~/pki/cliente

# Uma CA "desconhecida" (como se fosse de um atacante)
openssl req -x509 -newkey rsa:2048 -keyout outra_ca.key -out outra_ca.crt -days 365 -nodes \
  -subj "/CN=AC-Desconhecida/O=Atacante/C=BR" 2>/dev/null

# Cliente confia em AC-Desconhecida, mas o servidor tem cert da AC-Raiz-Empresa
echo | openssl s_client -connect localhost:4443 -CAfile outra_ca.crt \
  -verify_return_error 2>/dev/null | grep -E "Verify return code|verify error"
```

**Resultado esperado:**

```text
Verify return code: 20 (unable to get local issuer certificate)
```

**Análise:** o código **20 (unable to get local issuer certificate)** significa que o cliente não encontrou, no seu cofre, a CA que assinou o certificado do servidor. É o aviso "certificado não confiável" dos navegadores. A cadeia está **quebrada** — não há como chegar a uma raiz em que o cliente confie.

**Propriedade comprometida:** confiança (o cliente não consegue validar a identidade do servidor).

---

### Ataque 4: Certificado autoassinado não confiável

**Cenário:** o servidor usa um certificado autoassinado (como o da Etapa 2). Para o cliente, isso é o mesmo que "ninguém atestou essa identidade" — a menos que o cliente já conheça e confie naquele certificado específico.

**Comandos — cliente tenta validar o autoassinado com o cofre da CA:**

```bash
cd ~/pki/cliente

# O certificado autoassinado da Etapa 2 (srv.crt) — issuer = subject
openssl verify -CAfile ca.crt ../servidor/srv.crt
```

**Resultado esperado:**

```text
CN=servidor.local, O=Empresa, C=BR
error 18 at 0 depth lookup: self-signed certificate
error ../servidor/srv.crt: verification failed
```

**Análise:** o certificado autoassinado **não foi emitido pela nossa CA** — ele foi assinado por ele mesmo. O OpenSSL 3.5.5 reporta o código **18 (self-signed certificate)** quando o certificado é autoassinado e não está no cofre do cliente (em versões mais antigas, o mesmo caso aparece como `error 20: unable to get local issuer certificate` — o significado é o mesmo: **ninguém confiável atestou essa identidade**). O cliente, que só confia na `AC-Raiz-Empresa`, rejeita. É por isso que navegadores mostram "sua conexão não é privada" para sites com certificado autoassinado.

**Quando o autoassinado é aceitável?** Em laboratórios, redes internas pequenas ou quando o cliente **já conhece** o certificado (por exemplo, instalando-o manualmente no cofre). Em produção na internet, não.

**Propriedade comprometida:** autenticidade (qualquer um pode gerar um autoassinado com qualquer nome — sem uma CA, não há como distinguir o legítimo do falso).

---

### Ataque 5: MITM com certificado falso

**Cenário:** Morgan se posiciona entre o cliente e o servidor e apresenta o **próprio** certificado (autoassinado ou emitido por uma CA que ele controla), fingindo ser `servidor.local`. Este é o ataque que o Workshop 06 apresentou como "substituição de chave pública" — agora com certificados.

**Comandos — Morgan gera um certificado falso para servidor.local:**

```bash
cd ~/pki/cliente

# Morgan cria um certificado autoassinado com o MESMO nome do servidor legítimo
openssl req -x509 -newkey rsa:2048 -keyout morgan.key -out morgan.crt -days 365 -nodes \
  -subj "/CN=servidor.local/O=Atacante/C=BR" 2>/dev/null

# O certificado de Morgan "diz" ser servidor.local...
openssl x509 -in morgan.crt -noout -subject -issuer
```

**Resultado esperado:**

```text
subject=CN=servidor.local, O=Empresa, C=BR
issuer=CN=servidor.local, O=Empresa, C=BR
```

**Análise — o truque e a defesa:**

- **O truque:** o certificado de Morgan tem o mesmo `CN` (servidor.local). Se o cliente validasse **só o nome**, Morgan passaria.
- **A defesa:** o cliente valida a **cadeia de confiança**. O certificado de Morgan é autoassinado (issuer = subject) e **não está no cofre do cliente** — a validação falha:

```bash
openssl verify -CAfile ca.crt morgan.crt
```

**Resultado esperado:**

```text
CN=servidor.local, O=Empresa, C=BR
error 18 at 0 depth lookup: self-signed certificate
error morgan.crt: verification failed
```

**Relação com conceitos maiores:**

- Este é o **Man-in-the-Middle (MITM)** clássico que o Workshop 06 apresentou no Ataque 3.
- A diferença: no Workshop 06, Alex não tinha como verificar a chave pública de Sam. **Aqui, o certificado resolve o problema** — desde que o cliente valide a cadeia até uma CA confiável.
- **A causa raiz de MITMs bem-sucedidos** é sempre a mesma: o cliente **não validou** a cadeia (aceitou um aviso de certificado, instalou uma CA desconhecida, ou usou `-verify_return_error` de menos).
- **Mitigação real:** nunca ignorar avisos de certificado; usar CAs confiáveis (ICP-Brasil, Let's Encrypt, CAs corporativas); validar fingerprints por canal alternativo.

🤔 **Pense um pouco:** por que o ataque de Morgan falha mesmo com um certificado que "diz" ser servidor.local? *(Porque o certificado é autoassinado — nenhuma CA confiável o emitiu. O cliente valida a cadeia, não apenas o nome.)*

---

## 6. Desafio Final

> **Cenário:** a empresa precisa disponibilizar um **portal interno** (https://intranet.empresa.local) para os funcionários consultarem documentos. O gerente de TI exige que:
> 1. O servidor tenha um certificado **emitido por uma CA da própria empresa** (não autoassinado).
> 2. O certificado cubra os nomes `intranet.empresa.local` e `localhost`.
> 3. Um cliente consiga validar a cadeia de confiança e conectar com `Verify return code: 0 (ok)`.
> 4. A equipe de segurança consiga **provar** que um certificado autoassinado com o mesmo nome seria rejeitado.

Usando apenas os comandos e conceitos deste workshop, monte a solução sozinho, antes de olhar a próxima seção. Determine:

1. Quantas CAs são necessárias, e qual o nome dela?
2. Qual o fluxo completo para emitir o certificado do portal (CSR → assinatura)?
3. Como o cliente valida a cadeia e o hostname?
4. Como provar que um autoassinado falso seria rejeitado?

Monte a estrutura de diretórios, gere as chaves e execute o fluxo completo antes de conferir a solução abaixo.

---

## Solução Comentada do Desafio

**1. CA necessária:** uma — a `AC-Intranet-Empresa`, que será a raiz de confiança da intranet.

```bash
mkdir -p desafio/{ca,servidor,cliente}
cd desafio/ca

openssl genrsa -out ca.key 2048
chmod 600 ca.key
openssl req -x509 -new -key ca.key -out ca.crt -days 3650 -nodes \
  -subj "/CN=AC-Intranet-Empresa/O=Empresa/C=BR"
```

**2. Fluxo de emissão do certificado do portal (CSR → assinatura):**

```bash
cd ../servidor

# Servidor gera chave + CSR com SAN cobrindo os dois nomes exigidos
openssl req -new -newkey rsa:2048 -keyout portal.key -out portal.csr -nodes \
  -subj "/CN=intranet.empresa.local/O=Empresa/C=BR" \
  -addext "subjectAltName=DNS:intranet.empresa.local,DNS:localhost,IP:127.0.0.1"

# CA assina a CSR e emite o certificado
cd ../ca
openssl x509 -req -in ../servidor/portal.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out ../servidor/portal.crt -days 365 \
  -copy_extensions copy
```

**3. Validação pelo cliente — cadeia e hostname:**

```bash
cd ../cliente
cp ../ca/ca.crt .

# Cadeia de confiança
openssl verify -CAfile ca.crt ../servidor/portal.crt

# Hostname (os dois exigidos)
openssl x509 -in ../servidor/portal.crt -noout -checkhost intranet.empresa.local
openssl x509 -in ../servidor/portal.crt -noout -checkhost localhost
```

**Resultado esperado:**

```text
../servidor/portal.crt: OK
Hostname intranet.empresa.local does match certificate
Hostname localhost does match certificate
```

**4. Prova de que um autoassinado falso seria rejeitado:**

```bash
# Atacante gera autoassinado com o MESMO nome
openssl req -x509 -newkey rsa:2048 -keyout falso.key -out falso.crt -days 365 -nodes \
  -subj "/CN=intranet.empresa.local/O=Atacante/C=BR" 2>/dev/null

# Cliente valida contra a CA da empresa → deve falhar
openssl verify -CAfile ca.crt falso.crt
```

**Resultado esperado:**

```text
CN=intranet.empresa.local, O=Atacante, C=BR
error 18 at 0 depth lookup: self-signed certificate
error falso.crt: verification failed
```

**Verificação final — conexão TLS validada de ponta a ponta:**

```bash
cd ../servidor
openssl s_server -accept 4443 -cert portal.crt -key portal.key -quiet &
sleep 1

echo "documento confidencial da intranet" | \
  openssl s_client -connect localhost:4443 -CAfile ../cliente/ca.crt \
  -verify_return_error 2>/dev/null | grep -E "Verify return code|Protocol"
```

**Resultado esperado:**

```text
Protocol: TLSv1.3
Verify return code: 0 (ok)
```

Se `Verify return code: 0 (ok)` aparecer, as quatro exigências do enunciado foram cumpridas: certificado emitido por CA da empresa (não autoassinado), SAN cobrindo os dois nomes, cadeia validada pelo cliente e prova de que o autoassinado falso é rejeitado.

---

## 7. Fechamento

```text
Certificado digital  → amarra chave pública a uma identidade (X.509)
PKI                  → infraestrutura de emissão, gestão e revogação
CA (AC)              → o "cartório digital" que assina certificados
Cadeia de confiança  → do certificado até uma raiz que o cliente confia
TLS/HTTPS            → protege o canal (a conversa), não só o objeto
testssl.sh           → auditoria de configuração TLS de servidores
```

Recapitulando o fio condutor: os Workshops 01–04 mostraram o **problema** (tráfego em claro). O Workshop 06 mostrou como proteger o **objeto** (arquivo) e deixou em aberto o problema do MITM. Este workshop fechou o ciclo: o **certificado digital** resolve a pergunta "como confiar em uma chave pública?", e o **TLS** protege o canal inteiro. Nenhuma dessas camadas é opcional — juntas, formam a defesa em profundidade que uma empresa real exige.

A lição mais importante: **um certificado só vale o quanto vale a cadeia de confiança que o sustenta.** Um certificado autoassinado com o nome certo não prova nada; um certificado emitido por uma CA confiável prova tudo — desde que o cliente valide a cadeia, o hostname e a validade. E é exatamente essa validação que o navegador faz quando mostra o cadeado 🔒.

---

## 8. Atividade Extra: Certificados no mundo real

> [!NOTE]
> Esta seção é **opcional** e conecta o laboratório com o que você usa todos os dias.

### Onde você já usa certificados sem perceber

| Situação | Certificado envolvido |
|----------|----------------------|
| Acessar um site com 🔒 (HTTPS) | Certificado TLS do servidor (emitido por CA pública) |
| Assinar NF-e (nota fiscal eletrônica) | Certificado A1/A3 ICP-Brasil |
| Assinar documentos no cartório digital | Certificado ICP-Brasil com validação biométrica |
| Protocolizar petições em tribunais (PJe) | Certificado ICP-Brasil A3 |
| E-mail assinado (S/MIME) | Certificado de e-mail |
| Atualizações do sistema operacional | Cadeia de certificados das CAs do sistema |

### Como ver o certificado de um site no navegador

1. Acesse `https://www.exemplo.com.br`.
2. Clique no cadeado 🔒 na barra de endereço.
3. Clique em "Conexão segura" → "O certificado é válido" (ou similar).
4. Explore os campos: emissor, validade, nomes (SAN).

**Compare com o que você viu no laboratório:** o `subject`, `issuer`, `dates` e `SAN` que você inspecionou com `openssl x509 -text` são exatamente os mesmos campos que o navegador mostra.

### Let's Encrypt: certificados gratuitos e automatizados

O **Let's Encrypt** é uma CA gratuita que emite certificados TLS válidos para a internet, com renovação automática (90 dias) via o cliente `certbot`. É o que a maioria dos sites modernos usa — e o certificado que ele emite é exatamente o mesmo tipo X.509 que você criou neste workshop, só que assinado por uma CA pública que todos os navegadores confiam.

```bash
# Exemplo (em um servidor web real, com domínio público):
sudo apt install certbot
sudo certbot --nginx -d www.exemplo.com.br
```

**A lição:** o que você montou no laboratório (CA → CSR → certificado → validação) é o mesmo fluxo que o Let's Encrypt automatiza em escala global — a diferença é só a CA que assina e a confiança que ela já tem nos navegadores.

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| `openssl: command not found` | Instalar: `sudo apt install openssl` |
| `unable to load Private Key` | Verificar caminho e permissões (`chmod 600`) do arquivo `.key` |
| `Verify return code: 20 (unable to get local issuer certificate)` | O cliente não confia na CA que emitiu o certificado — adicionar a CA ao cofre (`-CAfile ca.crt`) ou verificar se usou a CA certa |
| `error 18 at 0 depth lookup: self-signed certificate` | O certificado é autoassinado e não está no cofre do cliente — comportamento normal do OpenSSL 3.5.5 (versões antigas mostram `error 20`); usar certificado emitido pela CA (Etapa 5) |
| `Verify return code: 10 (certificate has expired)` | Certificado fora da validade — verificar com `openssl x509 -in cert.crt -noout -dates` e reemitir |
| `Verify return code: 62 (hostname mismatch)` | O nome acessado não está no SAN do certificado — verificar com `openssl x509 -in cert.crt -noout -checkhost <nome>` e reemitir com o SAN correto |
| `s_server`/`s_client` não conecta | Confirmar que o servidor está rodando **antes** do cliente conectar; conferir a porta livre com `ss -tulpn \| grep 4443` |
| `s_client` fica "travado" | O `s_server` pode ter fechado; reiniciar o servidor e usar `timeout 5` no cliente |
| Certificado autoassinado gera aviso no navegador | Esperado — autoassinado não é confiável para terceiros; usar certificado emitido por CA (Etapa 5) |
| `-copy_extensions copy` não copia o SAN | Em versões antigas do OpenSSL, usar `-extfile` com um arquivo de configuração contendo o SAN |
| `openssl ca` reclama de arquivos faltando | O comando `ca` exige `index.txt`, `serial` e `newcerts/` — criar antes (ver Ataque 1) |
| `testssl.sh` não roda | Confirmar que o servidor TLS está ativo; o script precisa de `openssl` e `bash` |
| `tcpdump` não captura nada na interface `lo` | Em algumas distros, usar `-i any` em vez de `-i lo`, ou confirmar que o tráfego é mesmo loopback (`localhost`) |

---

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/07-Certificados_Digitais_PKI_e_TLS.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>