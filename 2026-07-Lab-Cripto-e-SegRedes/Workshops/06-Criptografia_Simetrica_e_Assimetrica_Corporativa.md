---
title: "Workshop 05: Criptografia Híbrida Corporativa (Simétrica + Assimétrica)"
description: "Workshop prático: combine AES-256 e RSA-2048 para proteger um relatório corporativo, provar autoria com assinatura digital, distribuir a chave simétrica com segurança e demonstrar ataques às três chaves envolvidas."
keywords: ["criptografia simétrica", "criptografia assimétrica", "criptografia híbrida", "AES-256", "RSA-2048", "OpenSSL", "assinatura digital", "hash SHA-256", "integridade", "autenticidade", "confidencialidade", "SENAI"]
tags: ["criptografia", "aes-256", "rsa-2048", "openssl", "assinatura-digital", "hash", "criptografia-hibrida", "seguranca-corporativa", "ataques"]
author: "Charles Alandt"
lang: "pt-BR"
layout: default
---

# Workshop 05: Criptografia Híbrida Corporativa (Simétrica + Assimétrica)

**Tags:** `criptografia simétrica` · `criptografia assimétrica` · `criptografia híbrida` · `AES-256` · `RSA-2048` · `OpenSSL` · `hash SHA-256` · `assinatura digital`

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
> Este workshop foi testado e validado pelo instrutor em ambiente Ubuntu 26.04 LTS com OpenSSL 3.x. No entanto, versões diferentes de OpenSSL (Kali, macOS/LibreSSL, Windows/Git Bash) podem gerar saídas ligeiramente diferentes ou exigir flags equivalentes.
>
> **Fique atento:**
> - A execução é permitida apenas em laboratório isolado (VM dedicada ou diretório de trabalho descartável).
> - As chaves privadas geradas aqui são **apenas para fins didáticos** — nunca reutilize essas chaves em sistemas reais.
> - Em produção, chaves privadas nunca devem ficar em texto puro no disco de um laptop; use HSM, keystore protegido ou, no mínimo, uma passphrase.
> - **Ajustes manuais podem ser necessários** para adequar os comandos à sua versão de OpenSSL e distribuição Linux.
> - **Este material é um guia prático.** O passo a passo foi validado no ambiente do instrutor; adaptações podem ser necessárias para seu ambiente específico.

---

## Índice

- [1. Abertura e Objetivos](#1-abertura-e-objetivos)
- [2. Fundamentos Conceituais](#2-fundamentos-conceituais)
  - [2.1 O problema: por que não usar só uma das duas?](#21-o-problema-por-que-não-usar-só-uma-das-duas)
  - [2.2 Chave 1 — Chave Privada](#22-chave-1--chave-privada)
  - [2.3 Chave 2 — Chave Pública](#23-chave-2--chave-pública)
  - [2.4 Chave 3 — Chave Simétrica](#24-chave-3--chave-simétrica)
  - [2.5 O fluxo híbrido completo](#25-o-fluxo-híbrido-completo)
- [3. Preparação do Laboratório (Etapa 1)](#3-preparação-do-laboratório-etapa-1)
- [4. Laboratório Guiado](#4-laboratório-guiado)
  - [Etapa 2: Criação do relatório](#etapa-2-criação-do-relatório)
  - [Etapa 3: Integridade (hash SHA-256)](#etapa-3-integridade-hash-sha-256)
  - [Etapa 4: Criptografia simétrica (AES-256)](#etapa-4-criptografia-simétrica-aes-256)
  - [Etapa 5: Compactação e cifragem](#etapa-5-compactação-e-cifragem)
  - [Etapa 6: Par de chaves assimétricas](#etapa-6-par-de-chaves-assimétricas)
  - [Etapa 7: Provar que "eu sou eu" (assinatura digital)](#etapa-7-provar-que-eu-sou-eu-assinatura-digital)
  - [Etapa 8: Distribuição segura da chave simétrica](#etapa-8-distribuição-segura-da-chave-simétrica)
  - [Etapa 9: Mensagem secreta de retorno](#etapa-9-mensagem-secreta-de-retorno)
  - [Etapa 10: Validação final de integridade e autenticidade](#etapa-10-validação-final-de-integridade-e-autenticidade)
- [5. Ataques e Falhas](#5-ataques-e-falhas)
  - [Ataque 1: Vazamento da chave simétrica](#ataque-1-vazamento-da-chave-simétrica)
  - [Ataque 2: Chave privada incorreta](#ataque-2-chave-privada-incorreta)
  - [Ataque 3: Substituição da chave pública (MITM)](#ataque-3-substituição-da-chave-pública-mitm)
  - [Ataque 4: Alteração do arquivo (integridade quebrada)](#ataque-4-alteração-do-arquivo-integridade-quebrada)
  - [Ataque 5: Chave/senha fraca (dicionário e força bruta)](#ataque-5-chavesenha-fraca-dicionário-e-força-bruta)
- [6. Desafio Final](#6-desafio-final)
- [Solução Comentada do Desafio](#solução-comentada-do-desafio)
- [7. Fechamento](#7-fechamento)
- [8. Atividade Extra: Transporte Seguro com TLS (Curiosidade)](#8-atividade-extra-transporte-seguro-com-tls-curiosidade)
- [Troubleshooting](#troubleshooting)

---

## 1. Abertura e Objetivos

### Contextualização

Você é **Alex**, analista de segurança de uma empresa. Precisa enviar um **relatório corporativo confidencial** para **Sam**, o gerente responsável. Simplesmente anexar o arquivo em um e-mail ou enviar por chat **não é suficiente**, porque isso não resolve nenhum destes problemas:

- Qualquer pessoa com acesso ao canal (e-mail, chat, servidor de arquivos) consegue **ler** o conteúdo.
- Sam não tem como comprovar que o arquivo **realmente veio de Alex** — poderia ser qualquer um se passando por ela.
- Se alguém alterar uma vírgula, um número ou uma frase no meio do caminho, **ninguém percebe**.
- Se Alex usar uma senha simples para proteger o arquivo, ela pode ser adivinhada ou quebrada.
- Depois, **Jamie**, colega de equipe de Alex, também precisa mandar uma mensagem que **só Sam** consiga ler — e nem Alex, nem ninguém mais.

Este workshop resolve esse problema construindo, passo a passo, um fluxo de **criptografia híbrida**: simétrica (AES-256) para os dados grandes, assimétrica (RSA-2048) para proteger a chave simétrica e provar autoria, e hash (SHA-256) para garantir integridade.

### Problema corporativo (resumo em uma frase)

> "Como enviar um relatório para que **só o destinatário certo** consiga ler, **prove quem enviou**, **detecte qualquer alteração**, e faça tudo isso **sem nunca transmitir a chave secreta em texto puro**?"

> [!NOTE]
> **Contexto dos Workshops 01–04:** nos laboratórios anteriores, você viu como relatórios e dados em **texto claro** (HTTP, FTP, MySQL, MQTT sem criptografia) podem ser capturados, lidos, remontados e até alterados durante o transporte, sem ninguém perceber. Este workshop resolve esse problema combinando **criptografia simétrica** (confidencialidade), **criptografia assimétrica** (autenticidade + distribuição segura de chave), **hash** (integridade) e **assinatura digital** — exatamente o que falta nos cenários anteriores.

### Objetivos de aprendizagem

Ao final deste workshop, você será capaz de:

1. Diferenciar claramente **chave privada**, **chave pública** e **chave simétrica**.
2. Gerar e usar uma chave simétrica (AES-256) para proteger um arquivo.
3. Compactar e cifrar um conjunto de arquivos corporativos.
4. Calcular e verificar hash SHA-256 para checar integridade.
5. Gerar um par de chaves assimétricas (RSA-2048).
6. Assinar digitalmente um documento e validar a assinatura.
7. Proteger (envelopar) uma chave simétrica usando a chave pública do destinatário.
8. Executar o fluxo completo de **criptografia híbrida**, nos dois sentidos (ida e volta).
9. Reconhecer e demonstrar 5 ataques/erros relacionados às três chaves.
10. Resolver, sozinho, um desafio corporativo aplicando tudo o que foi aprendido.

### Pré-requisitos

- Linux (Ubuntu/Debian/Kali) com `openssl`, `tar`, `sha256sum`, `zip` instalados.
- Conhecimento básico de terminal (criar diretórios, editar arquivos, redirecionar saída).
- Ter participado (ou revisado) os Workshops 01–04 (captura de tráfego HTTP/FTP/MySQL/MQTT) ajuda a entender **por que** confidencialidade em trânsito importa.

### Resultado esperado

Ao final, você terá em mãos um diretório `empresa/` completo, reproduzindo o fluxo real de uma troca de documento corporativo protegido, mais um relatório de ataques testados no seu próprio ambiente.

---

## 2. Fundamentos Conceituais

### 2.1 O problema: por que não usar só uma das duas?

```
SÓ CRIPTOGRAFIA SIMÉTRICA (AES)                SÓ CRIPTOGRAFIA ASSIMÉTRICA (RSA)
────────────────────────────────               ──────────────────────────────────
✓ Rápida (~1 GB/s)                              ✓ Não precisa compartilhar segredo
✓ Ideal para arquivos grandes                   ✓ Permite assinatura digital
✗ Como enviar a CHAVE com segurança?            ✗ MUITO lenta para arquivos grandes
✗ Se a chave vazar, tudo vaza                   ✗ RSA só cifra poucos bytes por vez
                                                    (limite ~245 bytes em RSA-2048)

            SOLUÇÃO: CRIPTOGRAFIA HÍBRIDA = AES (dados) + RSA (chave + assinatura)
```

### 2.2 Chave 1 — Chave Privada

| Pergunta | Resposta |
|----------|----------|
| Onde fica armazenada? | Somente com o dono, nunca sai da sua máquina (idealmente em HSM/keystore) |
| Pode ser compartilhada? | **Nunca.** Se vazar, qualquer pessoa pode se passar pelo dono ou ler tudo que foi cifrado para ele |
| Para que serve na assinatura? | **Assina** o hash do documento — só quem tem a privada consegue gerar aquela assinatura |
| Para que serve na cifra? | **Descriptografa** o que foi cifrado com a chave pública correspondente |
| Impacto se vazar? | Perda total de confidencialidade (dados cifrados para o dono) **e** de autenticidade (qualquer um assina como se fosse o dono) |

### 2.3 Chave 2 — Chave Pública

| Pergunta | Resposta |
|----------|----------|
| Pode ser distribuída? | Sim, livremente — é feita para circular |
| O que terceiros fazem com ela? | Cifram dados **destinados exclusivamente** ao dono da privada correspondente, ou **verificam** assinaturas feitas pelo dono |
| Como verifica assinatura? | Se a assinatura "abre" corretamente com a pública, prova que foi gerada pela privada correspondente |
| Como protege dados exclusivos? | Qualquer um cifra com a pública, mas **só** a privada correspondente decifra |
| Risco principal? | Alguém pode te entregar uma chave pública **falsa**, dizendo ser de outra pessoa (ataque de substituição / MITM) |

### 2.4 Chave 3 — Chave Simétrica

| Pergunta | Resposta |
|----------|----------|
| Por que é eficiente? | Algoritmos como AES operam em blocos, ~1000x mais rápidos que RSA para grandes volumes |
| Como deve ser gerada? | Com gerador criptográfico aleatório (`openssl rand`), nunca "inventada" ou derivada de uma frase óbvia |
| Pode ser enviada em texto puro? | **Nunca.** Quem interceptar o canal lê tudo cifrado com ela |
| Como é protegida? | Cifrando-a com a chave **pública** do destinatário (é pequena, cabe no limite do RSA) |
| Consequência se vazar? | Confidencialidade perdida imediatamente para **tudo** que foi cifrado com aquela chave |

### 2.5 O fluxo híbrido completo

```
                 CRIPTOGRAFIA HÍBRIDA

               RELATÓRIO CORPORATIVO
                        │
                        ▼
                 SHA-256 / HASH
                        │
                        ▼
                 ASSINATURA DIGITAL
                        │
                        │
           ┌────────────┴────────────┐
           │                         │
           ▼                         ▼
   CHAVE SIMÉTRICA AES        CHAVE PRIVADA (Alex)
           │                         │
           ▼                         ▼
    CIFRA O RELATÓRIO          ASSINA O HASH
           │
           ▼
   RELATÓRIO CIFRADO
           │
           │
           ▼
CHAVE SIMÉTRICA PROTEGIDA
COM A CHAVE PÚBLICA
DO DESTINATÁRIO (Sam)
           │
           ▼
       TRANSPORTE
           │
           ▼
     DESTINATÁRIO (Sam)
           │
           ├── chave privada (Sam)     → recupera chave simétrica
           │
           ├── chave simétrica           → recupera relatório
           │
           ├── chave pública (Alex)       → valida assinatura
           │
           └── SHA-256                   → valida integridade
```

### Lendo o diagrama em palavras

O diagrama acima parece complexo à primeira vista, mas é só uma história em duas metades. Acompanhe:

**Lado do remetente (Alex, a analista que escreveu o relatório):**

1. Alex termina de escrever o **relatório corporativo**. Ele existe em texto puro na máquina dela.
2. Alex passa o relatório por uma função **hash SHA-256**, obtendo uma impressão digital curta do conteúdo.
3. Alex **assina** essa impressão digital com a **chave privada dela** — é isso que prova, depois, que o documento saiu das mãos de Alex e de mais ninguém.
4. Em paralelo, Alex gera uma **chave simétrica AES** nova e usa essa chave para **cifrar o relatório**, que vira um arquivo ilegível.
5. Sobra um problema: Sam precisa dessa chave AES para abrir o arquivo, mas ela não pode viajar em texto puro. Então Alex **cifra a própria chave AES** usando a **chave pública de Sam**.
6. Alex envia três coisas pelo transporte (e-mail, chat, servidor de arquivos — não importa): o relatório cifrado, a chave AES protegida e a assinatura.

**Lado do destinatário (Sam, o gerente que vai receber):**

7. Sam usa a **chave privada dele** para abrir o envelope e recuperar a **chave AES** — ninguém mais no mundo consegue esse passo.
8. Com a chave AES em mãos, Sam **decifra o relatório** e finalmente lê o conteúdo.
9. Sam usa a **chave pública de Alex** para **conferir a assinatura**: se bater, o documento veio mesmo de Alex.
10. E o **SHA-256** confirma que nem um byte foi alterado no caminho.

Repare que ninguém precisou combinar uma senha secreta antes, e a chave simétrica nunca trafegou legível. É exatamente isso que torna o modelo híbrido viável em uma empresa real.

> **Pergunta ao aluno:** no fluxo que você acabou de ler, o relatório foi **escrito por Alex** e será **lido por Sam**. Sabendo disso, responda:
>
> 1. Qual das três chaves aparece **duas vezes** no diagrama, com papéis diferentes — uma vez cifrando o relatório e outra vez sendo ela mesma protegida?
> 2. A assinatura foi feita com a chave privada **de quem**, e será verificada com a chave pública **de quem**?
> 3. Se Alex tivesse usado a **própria** chave pública (em vez da de Sam) para proteger a chave AES, quem conseguiria abrir o relatório no final?
>
> Guarde suas respostas — vamos confirmar todas na Etapa 8.

---

## 3. Preparação do Laboratório (Etapa 1)

**Objetivo:** montar a estrutura de diretórios que simula os quatro papéis do cenário corporativo e os arquivos que serão protegidos.

**Conceito:** cada papel representa uma máquina/pessoa diferente com acesso a chaves diferentes — assim como em uma empresa real, ninguém tem acesso à chave privada de outra pessoa.

**Comandos:**

```bash
mkdir -p empresa/{remetente,equipe,destinatario,interceptador}
cd empresa
ls -la
```

**Explicação dos comandos:**

- `mkdir -p empresa/{remetente,equipe,destinatario,interceptador}`: cria de uma vez os quatro diretórios que representam os participantes.
- `remetente/` → **Alex**, analista que envia o relatório.
- `equipe/` → **Jamie**, colega de Alex, que mais tarde envia uma mensagem confidencial só para Sam.
- `destinatario/` → **Sam**, gerente que recebe o relatório e a mensagem.
- `interceptador/` → **Morgan**, atacante simulado, usado somente na seção de ataques.

**Resultado esperado:**

```text
drwxr-xr-x  6 aluno aluno 4096 ago 25 09:00 .
drwxr-xr-x  2 aluno aluno 4096 ago 25 09:00 remetente
drwxr-xr-x  2 aluno aluno 4096 ago 25 09:00 equipe
drwxr-xr-x  2 aluno aluno 4096 ago 25 09:00 destinatario
drwxr-xr-x  2 aluno aluno 4096 ago 25 09:00 interceptador
```

**Validação:** `ls empresa/` deve listar exatamente os 4 diretórios.

Agora crie os arquivos corporativos fictícios de Alex:

```bash
cd remetente

cat > clientes.csv << 'EOF'
id,nome,valor_contrato
1,Empresa Alfa Ltda,150000.00
2,Beta Comercio SA,89000.00
3,Gamma Industria,320000.00
EOF

cat > resultado_trimestral.txt << 'EOF'
RESULTADO TRIMESTRAL - Q3 2026
Receita: R$ 4.200.000,00
Despesas: R$ 2.850.000,00
Lucro liquido: R$ 1.350.000,00
EOF

ls -la
```

**Resultado esperado:**

```text
-rw-r--r-- 1 aluno aluno  98 ago 25 09:01 clientes.csv
-rw-r--r-- 1 aluno aluno 110 ago 25 09:01 resultado_trimestral.txt
```

**Pergunta ao aluno:** por que criamos esses arquivos **antes** de falar em criptografia? (Resposta: porque a proteção sempre vem *depois* de existir algo a proteger — o dado é o ativo, a chave é a ferramenta.)

---

## 4. Laboratório Guiado

### Etapa 2: Criação do relatório

**Objetivo:** criar o relatório principal e visualizar o problema de enviá-lo sem proteção.

**Conceito:** confidencialidade — dados sensíveis em texto puro podem ser lidos por qualquer um com acesso ao canal de transporte (lembre dos Workshops 01–04: HTTP, FTP, MySQL e MQTT sem criptografia expunham tudo em texto claro do mesmo jeito).

**Comandos:**

```bash
cd ~/empresa/remetente

cat > relatorio_financeiro.txt << 'EOF'
RELATORIO FINANCEIRO CONFIDENCIAL - Q3 2026
============================================
Classificacao: CONFIDENCIAL - USO INTERNO

Resumo Executivo:
- Vulnerabilidade critica identificada em servidor de pagamentos
- Exposicao potencial de dados de 12.000 clientes
- Valor de impacto estimado: R$ 5.000.000,00
- Recomendacao: acionar plano de resposta a incidentes imediatamente

Proximos passos:
1. Notificar diretoria executiva
2. Acionar equipe juridica
3. Preparar comunicado as autoridades reguladoras (LGPD)

Assinado eletronicamente por: Alex - Analista de Seguranca
EOF

cat relatorio_financeiro.txt
```

**Explicação dos comandos:**

- `cat > arquivo << 'EOF' ... EOF`: heredoc, grava múltiplas linhas em um arquivo de uma vez.
- `cat relatorio_financeiro.txt`: exibe o conteúdo para confirmarmos que está em **texto puro** neste momento.

**Resultado esperado:**

```text
RELATORIO FINANCEIRO CONFIDENCIAL - Q3 2026
============================================
[... conteúdo completo, 100% legível ...]
```

**Validação:** o conteúdo deve aparecer legível no terminal — é exatamente esse o problema que vamos resolver.

**Pergunta ao aluno:** se você anexasse este arquivo, do jeito que está, num e-mail comum, quais das quatro garantias (confidencialidade, integridade, autenticidade, chave protegida) você teria? *(Resposta: nenhuma das quatro.)*

---

### Etapa 3: Integridade (hash SHA-256)

**Objetivo:** gerar uma "impressão digital" do arquivo para detectar qualquer alteração futura.

**Conceito:**

```text
Arquivo → função hash (SHA-256) → digest (256 bits, fixo)
```

Uma função hash criptográfica sempre produz a mesma saída para a mesma entrada, mas **qualquer** mudança na entrada — mesmo de 1 bit — muda completamente a saída (efeito avalanche). Hash **não** é cifra: não existe "descriptografar" um hash.

**Comandos:**

```bash
sha256sum relatorio_financeiro.txt | tee relatorio_financeiro.txt.sha256
```

**Explicação dos comandos:**

- `sha256sum`: calcula o digest SHA-256 (256 bits / 64 caracteres hexadecimais) do arquivo.
- `tee arquivo.sha256`: mostra na tela **e** grava o resultado em arquivo, para comparação futura.

**Resultado esperado:**

```text
5f3a8c2e91b4d7f60a1c8e3b9d2f4a6c7e8b1d3f5a7c9e0b2d4f6a8c0e2b4d6  relatorio_financeiro.txt
```

*(o hash real do seu arquivo será diferente — cada byte de conteúdo muda o resultado completamente)*

**Demonstração do efeito avalanche:**

```bash
cp relatorio_financeiro.txt relatorio_adulterado_teste.txt
sed -i 's/5.000.000,00/50.000,00/' relatorio_adulterado_teste.txt
sha256sum relatorio_adulterado_teste.txt
```

**Resultado esperado:**

```text
9d1e4b7c2a5f8e3d6b0c9a2f5e8d1b4c7a0f3e6d9c2b5a8e1d4f7c0a3e6b9d2  relatorio_adulterado_teste.txt
```

**Validação:** compare os dois hashes — devem ser **completamente diferentes**, mesmo tendo mudado apenas alguns caracteres.

```bash
diff <(sha256sum relatorio_financeiro.txt | cut -d' ' -f1) \
     <(sha256sum relatorio_adulterado_teste.txt | cut -d' ' -f1) && echo "IGUAIS (erro!)" || echo "DIFERENTES (esperado)"
rm relatorio_adulterado_teste.txt
```

**Pergunta ao aluno:** o hash sozinho garante que o arquivo **veio de Alex**? *(Não — qualquer pessoa pode calcular o SHA-256 de qualquer arquivo. Hash prova só integridade; autenticidade vem da assinatura digital, na Etapa 7.)*

---

### Etapa 4: Criptografia simétrica (AES-256)

**Objetivo:** gerar uma chave simétrica segura e cifrar o relatório com ela.

**Conceito:** AES-256-CBC é rápido e adequado para arquivos de qualquer tamanho. A chave deve ter **256 bits de aleatoriedade real** — nunca uma senha "pensada" por humano (isso volta no Ataque 5).

**Comandos:**

```bash
openssl rand -out chave_aes.bin 32
ls -lh chave_aes.bin
```

**Explicação dos comandos:**

- `openssl rand`: gerador de bytes pseudoaleatórios criptograficamente seguro.
- `-out chave_aes.bin`: salva a chave em binário.
- `32`: 32 bytes = 256 bits — o tamanho exato exigido pelo AES-256.

**Resultado esperado:**

```text
-rw-r--r-- 1 aluno aluno 32 ago 25 09:05 chave_aes.bin
```

Agora cifre o relatório:

```bash
openssl enc -aes-256-cbc -in relatorio_financeiro.txt -out relatorio_financeiro.enc -pass file:chave_aes.bin -S 0 -p
```

**Explicação dos comandos:**

- `enc -aes-256-cbc`: algoritmo AES, chave de 256 bits, modo CBC (encadeamento de blocos).
- `-in / -out`: arquivo original e arquivo cifrado.
- `-pass file:chave_aes.bin`: usa o conteúdo do arquivo como material de chave (**chave**, não senha digitada — diferença importante).
- `-S 0`: fixa o salt em zero, só para o laboratório ser reprodutível em aula; **em produção, use salt aleatório** (comportamento padrão do OpenSSL sem `-S`).
- `-p` (minúsculo): imprime a chave derivada e o IV usados **e executa a cifragem**, para fins didáticos (nunca faça isso em produção). **Atenção:** `-P` (maiúsculo) apenas imprime os parâmetros e **sai sem cifrar**, gerando um arquivo de saída vazio.

**Resultado esperado:**

```text
salt=0000000000000000
key=A3F2187CB53E2A1D9F44C72B3A8D5F6E7B1C9E4A2D8F3B5C0A7E1F9D2B6C8A4F
iv=1A2B3C4D5E6F7A8B9C0D1E2F3A4B5C6D
```

**Validação:**

```bash
file relatorio_financeiro.enc
cat relatorio_financeiro.enc
```

O `file` deve indicar `data` (binário) e o `cat` deve exibir apenas bytes ilegíveis — prova de que a confidencialidade está ativa.

**Pergunta ao aluno:** qual das três chaves (privada / pública / simétrica) você acabou de usar aqui, e ela poderia ser divulgada publicamente? *(Chave simétrica; não, nunca pode ser divulgada.)*

---

### Etapa 5: Compactação e cifragem

**Objetivo:** proteger, em um único pacote, todos os documentos corporativos (relatório + planilha + resultado trimestral).

**Conceito:** compactar ≠ proteger ≠ criptografar. Compactação só reduz tamanho; senha de ZIP comum costuma ser fraca; criptografia com chave AES robusta é o que garante confidencialidade real.

```text
relatorio_financeiro.txt
clientes.csv
resultado_trimestral.txt
        ↓
     compactação (tar/gzip)
        ↓
relatorio_corporativo.tar.gz   ← ainda legível por qualquer um que abrir!
        ↓
     criptografia (AES-256)
        ↓
relatorio_corporativo.tar.gz.enc   ← agora protegido
```

**Comandos:**

```bash
tar -czf relatorio_corporativo.tar.gz relatorio_financeiro.txt clientes.csv resultado_trimestral.txt
tar -tzf relatorio_corporativo.tar.gz
```

**Explicação dos comandos:**

- `tar -czf`: `c` cria, `z` comprime com gzip, `f` define o arquivo de saída.
- `tar -tzf`: lista o conteúdo sem extrair — só para conferir o pacote.

**Resultado esperado:**

```text
relatorio_financeiro.txt
clientes.csv
resultado_trimestral.txt
```

**Demonstração de que compactar não é proteger:**

```bash
mkdir -p /tmp/teste_extracao && tar -xzf relatorio_corporativo.tar.gz -C /tmp/teste_extracao
cat /tmp/teste_extracao/clientes.csv
rm -rf /tmp/teste_extracao
```

Qualquer um consegue abrir — nada está protegido ainda.

Agora cifre o pacote inteiro com uma chave simétrica dedicada:

```bash
openssl rand -out chave_pacote.bin 32
openssl enc -aes-256-cbc -in relatorio_corporativo.tar.gz -out relatorio_corporativo.tar.gz.enc -pass file:chave_pacote.bin -S 0
ls -lh relatorio_corporativo.*
```

**Resultado esperado:**

```text
-rw-r--r-- 1 aluno aluno  612 ago 25 09:08 relatorio_corporativo.tar.gz
-rw-r--r-- 1 aluno aluno  624 ago 25 09:08 relatorio_corporativo.tar.gz.enc
```

**Validação:** tente descompactar o `.enc` direto — deve falhar, provando que a proteção está ativa:

```bash
tar -tzf relatorio_corporativo.tar.gz.enc
```

**Resultado esperado:**

```text
tar: This does not look like a tar archive
```

**Pergunta ao aluno:** por que geramos uma chave **nova** (`chave_pacote.bin`) em vez de reaproveitar `chave_aes.bin` da Etapa 4? *(Boa prática: cada objeto protegido idealmente tem sua própria chave, limitando o impacto se uma delas vazar.)*

---

### Etapa 6: Par de chaves assimétricas

**Objetivo:** gerar os pares de chave privada/pública de Alex (remetente) e de Sam (destinatário).

**Conceito:** cada pessoa tem **seu próprio** par RSA-2048. A privada nunca sai do dono; a pública é livremente distribuída.

**Comandos — Alex (remetente):**

```bash
cd ~/empresa/remetente
openssl genrsa -out alex_privada.pem 2048
openssl rsa -in alex_privada.pem -pubout -out alex_publica.pem
chmod 600 alex_privada.pem
chmod 644 alex_publica.pem
ls -l alex_*.pem
```

**Comandos — Sam (destinatario):**

```bash
cd ~/empresa/destinatario
openssl genrsa -out sam_privada.pem 2048
openssl rsa -in sam_privada.pem -pubout -out sam_publica.pem
chmod 600 sam_privada.pem
chmod 644 sam_publica.pem
ls -l sam_*.pem
```

**Explicação dos comandos:**

- `genrsa ... 2048`: gera a chave privada RSA de 2048 bits.
- `rsa -in ... -pubout -out ...`: extrai a chave pública correspondente.
- `chmod 600`: só o dono pode ler/escrever a privada — ninguém mais no sistema tem acesso.
- `chmod 644`: a pública pode ser lida por qualquer um (é para isso que ela existe).

**Resultado esperado:**

```text
-rw------- 1 aluno aluno 1704 ago 25 09:10 alex_privada.pem
-rw-r--r-- 1 aluno aluno  451 ago 25 09:10 alex_publica.pem
```

**Validação:**

```bash
openssl rsa -in alex_privada.pem -check -noout
```

Deve responder `RSA key ok`.

Agora troquem as chaves públicas (simulação de distribuição):

```bash
cp ~/empresa/remetente/alex_publica.pem ~/empresa/destinatario/
cp ~/empresa/destinatario/sam_publica.pem ~/empresa/remetente/
```

**Pergunta ao aluno:** se o arquivo `alex_privada.pem` estivesse com permissão `644` (qualquer usuário do sistema podendo ler), o que um outro usuário da mesma máquina conseguiria fazer? *(Assinar documentos se passando por Alex e descriptografar tudo que foi cifrado para ela.)*

---

### Etapa 7: Provar que "eu sou eu" (assinatura digital)

**Objetivo:** Alex assina o relatório para que Sam consiga comprovar a autoria.

**Conceito — diferença fundamental:**

```text
CRIPTOGRAFAR                          ASSINAR DIGITALMENTE
──────────────                        ─────────────────────
Usa a CHAVE PÚBLICA do destinatário   Usa a CHAVE PRIVADA do autor
Garante CONFIDENCIALIDADE             Garante AUTENTICIDADE + INTEGRIDADE
Só o dono da privada correspondente   Qualquer um com a pública do autor
  consegue ler                          consegue verificar
```

**Comandos:**

```bash
cd ~/empresa/remetente
openssl dgst -sha256 -sign alex_privada.pem -out relatorio_corporativo.sig relatorio_corporativo.tar.gz
ls -lh relatorio_corporativo.sig
```

**Explicação dos comandos:**

- `dgst -sha256`: calcula o hash SHA-256 do pacote.
- `-sign alex_privada.pem`: cifra esse hash com a chave privada de Alex — isso **é** a assinatura digital.
- `-out relatorio_corporativo.sig`: arquivo de assinatura, separado do pacote.

**Resultado esperado:**

```text
-rw-r--r-- 1 aluno aluno 256 ago 25 09:12 relatorio_corporativo.sig
```

Envie a assinatura para Sam (junto com o pacote, que vamos preparar na Etapa 8):

```bash
cp relatorio_corporativo.sig ~/empresa/destinatario/
```

**Validação — Sam verifica com a chave pública de Alex:**

```bash
cd ~/empresa/destinatario
openssl dgst -sha256 -verify alex_publica.pem -signature relatorio_corporativo.sig relatorio_corporativo.tar.gz
```

> **Atenção:** neste ponto Sam ainda não tem `relatorio_corporativo.tar.gz` (só chega na Etapa 8). Para validar isoladamente agora, copie o pacote cifrado de teste:

```bash
cp ~/empresa/remetente/relatorio_corporativo.tar.gz .
openssl dgst -sha256 -verify alex_publica.pem -signature relatorio_corporativo.sig relatorio_corporativo.tar.gz
```

**Resultado esperado:**

```text
Verified OK
```

**Pergunta ao aluno:** se Morgan (interceptador) tivesse gerado seu próprio par de chaves e assinado um relatório falso com a **privada dele**, o que aconteceria quando Sam tentasse verificar com a **pública de Alex**? *(Falharia — `Verification Failure` — porque a assinatura só "casa" com a chave pública do par que a gerou.)*

---

### Etapa 8: Distribuição segura da chave simétrica

**Objetivo:** resolver o problema central do workshop — enviar `chave_pacote.bin` para Sam sem transmiti-la em texto puro.

**Conceito:**

```text
RELATÓRIO                              CHAVE AES (chave_pacote.bin)
   ↓                                          ↓
AES-256 (chave_pacote.bin)          chave pública de Sam (RSA)
   ↓                                          ↓
RELATÓRIO CIFRADO                    CHAVE AES PROTEGIDA (.enc)
```

Isso é a **essência da criptografia híbrida**: a chave simétrica, pequena, cabe dentro do limite do RSA (RSA-2048 cifra no máximo ~245 bytes; nossa chave tem só 32 bytes).

**Comandos:**

```bash
cd ~/empresa/remetente
openssl rsautl -encrypt -inkey sam_publica.pem -pubin -in chave_pacote.bin -out chave_pacote.bin.enc
ls -lh chave_pacote.bin.enc
```

**Explicação dos comandos:**

- `rsautl -encrypt`: modo de cifra com RSA.
- `-inkey sam_publica.pem -pubin`: usa a chave **pública** de Sam — só a privada dele vai conseguir reverter.
- `-in chave_pacote.bin`: a chave AES que protege o pacote.
- `-out chave_pacote.bin.enc`: chave AES agora protegida (envelopada).

**Resultado esperado:**

```text
-rw-r--r-- 1 aluno aluno 256 ago 25 09:14 chave_pacote.bin.enc
```

**Validação — o envelope não revela a chave:**

```bash
hexdump -C chave_pacote.bin.enc | head -3
```

Deve mostrar bytes aparentemente aleatórios — impossível recuperar `chave_pacote.bin` sem a privada de Sam.

Agora monte e envie o pacote final para Sam:

```bash
cp relatorio_corporativo.tar.gz.enc chave_pacote.bin.enc relatorio_corporativo.sig ~/empresa/destinatario/
```

**No destinatário (Sam) — recuperar a chave:**

```bash
cd ~/empresa/destinatario
openssl rsautl -decrypt -inkey sam_privada.pem -in chave_pacote.bin.enc -out chave_pacote_recuperada.bin
diff chave_pacote_recuperada.bin ~/empresa/remetente/chave_pacote.bin && echo "Chave recuperada com sucesso!"
```

**Resultado esperado:**

```text
Chave recuperada com sucesso!
```

**No destinatário — recuperar o relatório:**

```bash
openssl enc -aes-256-cbc -d -in relatorio_corporativo.tar.gz.enc -out relatorio_corporativo.tar.gz -pass file:chave_pacote_recuperada.bin -S 0
tar -tzf relatorio_corporativo.tar.gz
tar -xzf relatorio_corporativo.tar.gz
cat relatorio_financeiro.txt
```

**Resultado esperado:**

```text
relatorio_financeiro.txt
clientes.csv
resultado_trimestral.txt

RELATORIO FINANCEIRO CONFIDENCIAL - Q3 2026
[... conteúdo original, agora legível só por Sam ...]
```

**Validação:** a assinatura ainda é válida para o pacote recém-descriptografado:

```bash
openssl dgst -sha256 -verify alex_publica.pem -signature relatorio_corporativo.sig relatorio_corporativo.tar.gz
```

Deve retornar `Verified OK`.

**Pergunta ao aluno:** neste fluxo, a chave simétrica foi cifrada com a **pública de quem**? E foi decifrada com a **privada de quem**? *(Cifrada com a pública de Sam; decifrada com a privada de Sam — só ele consegue.)*

---

### Etapa 9: Mensagem secreta de retorno

**Objetivo:** Jamie (equipe) envia uma mensagem que **somente Sam** consiga ler — nem Alex, nem ninguém mais.

**Conceito:** mesmo fluxo híbrido, mas agora é Jamie quem usa a chave **pública de Sam** (não a de Alex) para proteger a chave simétrica da mensagem. Só a privada de Sam reverte.

**Comandos — Jamie prepara a mensagem:**

```bash
cd ~/empresa/equipe
cp ~/empresa/destinatario/sam_publica.pem .

cat > mensagem_confidencial.txt << 'EOF'
Sam,

Confirmo que o servidor de pagamentos foi isolado da rede as 08h45.
Nao compartilhe este numero de incidente por canais nao criptografados: INC-2026-0847.

Jamie
EOF

openssl rand -out chave_msg.bin 32
openssl enc -aes-256-cbc -in mensagem_confidencial.txt -out mensagem_confidencial.enc -pass file:chave_msg.bin -S 0
openssl rsautl -encrypt -inkey sam_publica.pem -pubin -in chave_msg.bin -out chave_msg.bin.enc
```

**Explicação dos comandos:** exatamente o mesmo padrão da Etapa 8 (gerar chave AES → cifrar dados → cifrar a chave com RSA pública do destinatário), mas agora a chave pública usada é a de **Sam**, porque é para ele que a mensagem se destina.

**Resultado esperado:**

```text
-rw-r--r-- 1 aluno aluno  ~96 mensagem_confidencial.enc
-rw-r--r-- 1 aluno aluno  256 chave_msg.bin.enc
```

Envie para Sam:

```bash
cp mensagem_confidencial.enc chave_msg.bin.enc ~/empresa/destinatario/
```

**No destinatário (Sam) — só ele consegue abrir:**

```bash
cd ~/empresa/destinatario
openssl rsautl -decrypt -inkey sam_privada.pem -in chave_msg.bin.enc -out chave_msg_recuperada.bin
openssl enc -aes-256-cbc -d -in mensagem_confidencial.enc -out mensagem_confidencial.txt -pass file:chave_msg_recuperada.bin -S 0
cat mensagem_confidencial.txt
```

**Resultado esperado:**

```text
Sam,

Confirmo que o servidor de pagamentos foi isolado da rede as 08h45.
Nao compartilhe este numero de incidente por canais nao criptografados: INC-2026-0847.

Jamie
```

**Validação — prova de que só Sam conseguiria:** tente decifrar com a chave privada de Alex (deve falhar):

```bash
openssl rsautl -decrypt -inkey ~/empresa/remetente/alex_privada.pem -in chave_msg.bin.enc -out /tmp/tentativa_alex.bin 2>&1 | head -3
```

**Resultado esperado:**

```text
RSA operation error
... (falha — a chave foi cifrada para a pública de Sam, não a de Alex)
```

**Pergunta ao aluno:** por que nem Alex, dona do relatório original, consegue ler a mensagem de Jamie para Sam? *(Porque a chave simétrica da mensagem foi protegida com a chave pública de Sam — só a privada dele reverte, independente de quem mais tenha outras chaves privadas.)*

---

### Etapa 10: Validação final de integridade e autenticidade

**Objetivo:** consolidar as verificações e deixar explícita a diferença entre as três propriedades de segurança.

**Conceito:**

```text
Confidencialidade ≠ Integridade ≠ Autenticidade

Confidencialidade → AES-256 (só quem tem a chave lê)
Integridade       → SHA-256 (detecta qualquer alteração)
Autenticidade     → Assinatura digital com RSA (prova quem enviou)
```

**Comandos — checagem completa no lado de Sam:**

```bash
cd ~/empresa/destinatario

# 1. Integridade: hash do arquivo recebido bate com o original?
sha256sum relatorio_corporativo.tar.gz
sha256sum ~/empresa/remetente/relatorio_corporativo.tar.gz

# 2. Autenticidade: assinatura de Alex confere?
openssl dgst -sha256 -verify alex_publica.pem -signature relatorio_corporativo.sig relatorio_corporativo.tar.gz

# 3. Confidencialidade: o conteúdo só existia em claro após a chave privada de Sam reverter o envelope
ls -la relatorio_financeiro.txt
```

**Resultado esperado:**

```text
<hash>  relatorio_corporativo.tar.gz
<mesmo hash>  ../remetente/relatorio_corporativo.tar.gz
Verified OK
-rw-r--r-- 1 aluno aluno 612 ago 25 09:20 relatorio_financeiro.txt
```

**Validação:** os dois hashes devem ser **idênticos** e a verificação deve dizer `Verified OK`.

**Pergunta ao aluno:** se apenas o hash batesse mas a assinatura falhasse, o que isso significaria? *(O arquivo não foi alterado — integridade OK — mas não veio de quem alega ter enviado, ou a chave pública usada está errada — autenticidade comprometida.)*

---

## 5. Ataques e Falhas

> [!CAUTION]
> Todas as demonstrações abaixo ocorrem **exclusivamente** dentro de `empresa/interceptador/` e nos artefatos já gerados neste laboratório. Nunca aplique essas técnicas fora de um ambiente controlado e autorizado.

### Ataque 1: Vazamento da chave simétrica

**Cenário:** Morgan (interceptador) obtém, de alguma forma (backup mal protegido, USB perdido), o arquivo cifrado **e** a chave simétrica usada.

```bash
cd ~/empresa/interceptador
cp ~/empresa/remetente/relatorio_corporativo.tar.gz.enc .
cp ~/empresa/remetente/chave_pacote.bin .   # simulando o vazamento

openssl enc -aes-256-cbc -d -in relatorio_corporativo.tar.gz.enc -out relatorio_roubado.tar.gz -pass file:chave_pacote.bin -S 0
tar -tzf relatorio_roubado.tar.gz
```

**Resultado esperado:**

```text
relatorio_financeiro.txt
clientes.csv
resultado_trimestral.txt
```

**Propriedade comprometida:** confidencialidade. Com o par (arquivo cifrado + chave), **qualquer pessoa** descriptografa — RSA e assinatura não entram nessa conta. É por isso que a chave simétrica precisa estar sempre protegida (Etapa 8) e nunca em backups em texto puro.

---

### Ataque 2: Chave privada incorreta

**Cenário:** Morgan intercepta o envelope de chave (`chave_pacote.bin.enc`) mas tenta usar sua **própria** chave privada, não a de Sam.

```bash
cd ~/empresa/interceptador
openssl genrsa -out morgan_privada.pem 2048 2>/dev/null
cp ~/empresa/remetente/chave_pacote.bin.enc .

openssl rsautl -decrypt -inkey morgan_privada.pem -in chave_pacote.bin.enc -out tentativa_morgan.bin
```

**Resultado esperado:**

```text
RSA operation error
40447A08F87B0000:error:...:padding check failed...
```

**Análise:** a operação falha porque `chave_pacote.bin.enc` só foi cifrada para a chave **pública de Sam** — nenhuma outra chave privada, nem mesmo uma tecnicamente válida, consegue reverter.

**Propriedade demonstrada:** o envelopamento assimétrico é seletivo — só o par correto funciona.

---

### Ataque 3: Substituição da chave pública (MITM)

**Cenário:** Morgan se posiciona entre Alex e Sam e entrega a **própria** chave pública para Alex, fingindo ser a de Sam.

```
Alex ──── "me manda sua chave pública" ────→ Morgan intercepta
Alex ←──── chave pública de Morgan (fingindo ser de Sam) ──── Morgan
Alex cifra a chave simétrica com a chave "de Sam" (na verdade, de Morgan)
Morgan descriptografa com a própria privada e lê tudo
```

```bash
cd ~/empresa/interceptador
openssl rsa -in morgan_privada.pem -pubout -out morgan_publica.pem

# Simule Alex recebendo a chave errada, pensando ser a de Sam:
cd ~/empresa/remetente
cp ~/empresa/interceptador/morgan_publica.pem chave_publica_recebida.pem

# Alex cifra a chave simétrica com a chave que ACHA ser de Sam:
openssl rsautl -encrypt -inkey chave_publica_recebida.pem -pubin -in chave_pacote.bin -out chave_para_suposto_sam.enc

# Morgan intercepta e descriptografa com a própria privada:
cd ~/empresa/interceptador
openssl rsautl -decrypt -inkey morgan_privada.pem -in ../remetente/chave_para_suposto_sam.enc -out chave_interceptada.bin
diff chave_interceptada.bin ~/empresa/remetente/chave_pacote.bin && echo "Morgan leu a chave simétrica!"
```

**Resultado esperado:**

```text
Morgan leu a chave simétrica!
```

**Relação com conceitos maiores:**

- Este é um **Man-in-the-Middle (MITM)** clássico contra troca de chaves públicas.
- A causa raiz: Alex nunca verificou se a chave pública recebida **realmente pertencia** a Sam.
- Mitigação real: **certificados digitais** (X.509) assinados por uma **Autoridade Certificadora (PKI)**, ou verificação manual de **fingerprint** (`openssl rsa -pubin -in chave.pem -outform DER | sha256sum`) por um canal alternativo confiável (telefone, presencialmente).
- Não é necessário implementar PKI completa neste workshop — o importante é entender que **receber uma chave pública não prova, por si só, de quem ela é**.

**Pergunta ao aluno:** o que Alex poderia ter feito, de forma simples, para confirmar que a chave pública recebida era realmente de Sam? *(Comparar o fingerprint da chave por um canal diferente — telefone, chat já validado — ou exigir um certificado assinado por CA confiável.)*

---

### Ataque 4: Alteração do arquivo (integridade quebrada)

**Cenário:** o pacote é modificado no meio do transporte (ou por erro de sincronização, ou por adulteração maliciosa).

```bash
cd ~/empresa/destinatario
cp relatorio_corporativo.tar.gz relatorio_corporativo_adulterado.tar.gz
printf '\x00\x00\x00\x00' | dd of=relatorio_corporativo_adulterado.tar.gz bs=1 seek=10 conv=notrunc 2>/dev/null

sha256sum relatorio_corporativo.tar.gz relatorio_corporativo_adulterado.tar.gz
```

**Resultado esperado:**

```text
<hash_A>  relatorio_corporativo.tar.gz
<hash_B (diferente!)>  relatorio_corporativo_adulterado.tar.gz
```

Agora tente validar a assinatura contra o arquivo adulterado:

```bash
openssl dgst -sha256 -verify alex_publica.pem -signature relatorio_corporativo.sig relatorio_corporativo_adulterado.tar.gz
```

**Resultado esperado:**

```text
Verification Failure
```

**Análise:** `hash original ≠ hash arquivo adulterado`, e por consequência a assinatura (que foi calculada sobre o hash original) também não confere mais. Isso prova, em conjunto, **integridade** (via hash) e reforça a **autenticidade** (a assinatura amarra o conteúdo exato ao autor).

```bash
rm relatorio_corporativo_adulterado.tar.gz
```

---

### Ataque 5: Chave/senha fraca (dicionário e força bruta)

**Cenário:** em vez de gerar uma chave aleatória de 256 bits, alguém decide "proteger" o pacote com uma senha previsível — o mesmo erro de senhas fracas já discutido em workshops anteriores do curso sobre resistência de senhas.

```bash
cd ~/empresa/interceptador
echo "conteudo super confidencial da empresa" > teste_senha_fraca.txt
openssl enc -aes-256-cbc -pbkdf2 -in teste_senha_fraca.txt -out teste_senha_fraca.enc -pass pass:senai2024
```

**Demonstração de dicionário simples:**

```bash
cat > wordlist.txt << 'EOF'
123456
senha123
empresa2024
senai2024
admin123
EOF

for senha in $(cat wordlist.txt); do
  if openssl enc -aes-256-cbc -pbkdf2 -d -in teste_senha_fraca.enc -pass pass:"$senha" 2>/dev/null > /dev/null; then
    echo "SENHA ENCONTRADA: $senha"
    break
  fi
done
```

**Resultado esperado:**

```text
SENHA ENCONTRADA: senai2024
```

**Análise:**

- A senha `senai2024` estava em uma wordlist pequena de apenas 5 tentativas — em segundos, foi encontrada.
- Compare com `chave_pacote.bin`: 256 bits de aleatoriedade real, impossível de estar em qualquer wordlist ou de ser adivinhada por força bruta com tecnologia atual.
- O mesmo princípio de resistência de senha (comprimento, aleatoriedade, ausência de padrões previsíveis) já trabalhado em workshops anteriores do curso se aplica **diretamente** a chaves de criptografia: senha fraca vira o elo mais fraco da corrente, mesmo com AES-256 "por baixo".

**Mitigação:**

- Nunca proteger dados sensíveis com senha "de cabeça"; usar chave gerada por `openssl rand` (ou gerenciador de senhas para segredos memorizáveis).
- Se uma senha humana for inevitável, usar KDF lenta (PBKDF2 com iteração alta, Argon2) e frase longa e não previsível.

```bash
rm teste_senha_fraca.txt teste_senha_fraca.enc wordlist.txt
```

---

## 6. Desafio Final

> **Cenário:** o **Diretor Financeiro** precisa enviar um arquivo confidencial ao **Diretor Jurídico**. O arquivo deve permanecer confidencial, sua autoria precisa ser comprovada, e qualquer modificação deve ser detectável. A chave utilizada para cifrar o arquivo também não pode ser enviada em texto puro.

Usando apenas os comandos e conceitos deste workshop, monte a solução sozinho, antes de olhar a próxima seção. Determine:

1. Quantos pares de chaves RSA são necessários, e de quem?
2. Qual chave cifra o **arquivo**?
3. Qual chave protege a **chave simétrica**?
4. Qual chave **assina** o documento, e qual chave o Jurídico usa para **verificar**?
5. Como o Jurídico, ao final, comprova simultaneamente confidencialidade, integridade e autenticidade?

Monte a estrutura de diretórios, gere as chaves e execute o fluxo completo antes de conferir a solução abaixo.

---

## Solução Comentada do Desafio

**1. Pares de chave necessários:** dois — um para o Diretor Financeiro (assinatura) e um para o Diretor Jurídico (recebimento). Cada papel tem sua própria privada/pública, exatamente como Alex e Sam.

```bash
mkdir -p desafio/{financeiro,juridico}
cd desafio/financeiro
openssl genrsa -out financeiro_privada.pem 2048
openssl rsa -in financeiro_privada.pem -pubout -out financeiro_publica.pem
cd ../juridico
openssl genrsa -out juridico_privada.pem 2048
openssl rsa -in juridico_privada.pem -pubout -out juridico_publica.pem
cd ..
cp financeiro/financeiro_publica.pem juridico/
cp juridico/juridico_publica.pem financeiro/
```

**2. Chave que cifra o arquivo:** uma chave **simétrica** nova, gerada aleatoriamente — igual à Etapa 4/5, nunca RSA direto no arquivo (seria lento demais e ultrapassaria o limite de bytes do RSA).

```bash
cd financeiro
echo "Contrato confidencial - valor R$ 2.400.000,00" > contrato.txt
openssl rand -out chave_contrato.bin 32
openssl enc -aes-256-cbc -in contrato.txt -out contrato.enc -pass file:chave_contrato.bin -S 0
```

**3. Chave que protege a chave simétrica:** a chave **pública do Jurídico** — só a privada dele reverte (mesma lógica da Etapa 8).

```bash
openssl rsautl -encrypt -inkey juridico_publica.pem -pubin -in chave_contrato.bin -out chave_contrato.bin.enc
```

**4. Assinatura:** o Financeiro assina com sua **própria privada**; o Jurídico valida com a **pública do Financeiro** (mesma lógica da Etapa 7 — nunca confundir com a chave usada para cifrar).

```bash
openssl dgst -sha256 -sign financeiro_privada.pem -out contrato.sig contrato.txt
cp contrato.enc chave_contrato.bin.enc contrato.sig ../juridico/
```

**5. Verificação final pelo Jurídico — as três propriedades:**

```bash
cd ../juridico
# Confidencialidade: recuperar a chave e o conteúdo
openssl rsautl -decrypt -inkey juridico_privada.pem -in chave_contrato.bin.enc -out chave_recuperada.bin
openssl enc -aes-256-cbc -d -in contrato.enc -out contrato.txt -pass file:chave_recuperada.bin -S 0
cat contrato.txt

# Autenticidade: valida a assinatura do Financeiro
openssl dgst -sha256 -verify financeiro_publica.pem -signature contrato.sig contrato.txt
```

**Resultado esperado:**

```text
Contrato confidencial - valor R$ 2.400.000,00
Verified OK
```

Se `Verified OK` aparecer e o conteúdo estiver correto, as quatro garantias do enunciado foram cumpridas: confidencialidade (só o Jurídico leu), autenticidade (assinatura do Financeiro confere), integridade (hash embutido na assinatura bate) e a chave simétrica nunca trafegou em texto puro (sempre envelopada em RSA).

---

## 7. Fechamento

```text
Chave privada       → segredo do proprietário; nunca compartilhada
Chave pública        → pode ser distribuída livremente
Chave simétrica       → protege eficientemente os dados (rápida, grande volume)
Hash (SHA-256)         → verifica integridade (detecta qualquer alteração)
Assinatura digital       → comprova autenticidade + integridade juntas
Criptografia híbrida       → combina eficiência do AES + distribuição segura de chave via RSA
```

Recapitulando o fio condutor do workshop: nenhuma dessas ferramentas resolve o problema sozinha. AES sem RSA não resolve "como enviar a chave". RSA sem AES é lento demais para relatórios reais. Hash sem assinatura não prova autoria. Assinatura sem hash não escala para arquivos grandes. A resposta corporativa real é sempre a **combinação** das três chaves, cada uma cumprindo o papel para o qual foi desenhada.

---

## 8. Atividade Extra: Transporte Seguro com TLS (Curiosidade)

> [!NOTE]
> Esta seção é **opcional** e demonstra um conceito extra: proteger a **conversa** entre duas máquinas, não apenas o **arquivo**. Se o tempo de aula esgotar, pule para o Checklist.

### O que já fizemos e o que falta

Até aqui, o fluxo completo foi executado — mas tudo aconteceu **em uma única máquina** (diretórios `empresa/remetente/`, `empresa/destinatario/`, etc.) usando `cp` para simular o "transporte".

Na **realidade corporativa**, os arquivos atravessam a rede (e-mail, SFTP, HTTP, chat, etc.) e é aí que surgem dois problemas que parecem contraditórios:

1. **Já ciframos o arquivo com AES-256.** Por que precisar de mais criptografia no canal?
2. **Mas e os metadados?** O nome do arquivo, tamanho, hora de envio — mesmo que o arquivo esteja cifrado, esses dados viajam legíveis.

### A resposta: camada do objeto vs camada do canal

```text
CAMADA DO OBJETO (arquivo)          CAMADA DO CANAL (transporte)
──────────────────────────          ─────────────────────────────
AES-256-CBC                         TLS 1.2/1.3
├─ Cifra o conteúdo                 ├─ Cifra toda a conversa
├─ Sobrevive ao armazenamento       ├─ Protege metadados
│  (arquivo fica cifrado em disco)  │  (nome, tamanho, IP origem/destino)
└─ Válido mesmo depois de anos      └─ Válido durante a transmissão

CENÁRIO 1 — Arquivo com AES, mas SEM TLS:
┌─────────────────────────────────────────┐
│ tcpdump mostra:                         │
│ ├─ Destinatário: 192.168.1.10           │  ← qual endereço está recebendo?
│ ├─ Nome: relatorio_corporativo.tar.gz   │  ← qual é o assunto?
│ └─ [bytes cifrados aqui]                │  ← conteúdo OK, protegido
│                                         │
│ Problema: metadata leak — atacante      │
│ sabe QUEM fala com QUEM e SOBRE O QUÊ  │
└─────────────────────────────────────────┘

CENÁRIO 2 — Arquivo com AES E com TLS:
┌─────────────────────────────────────────┐
│ tcpdump mostra:                         │
│ ├─ TLS Handshake...                     │  ← só o certificado fica visível
│ ├─ [bytes de dados cifrado]             │  ← conteúdo cifrado
│ └─ [bytes de mais dados cifrado]        │  ← metadados também cifrados
│                                         │
│ Resultado: nem conteúdo, nem metadata  │
│ — atacante vê só que HOUVE transferência
└─────────────────────────────────────────┘
```

**Regra de ouro:** 
- **AES protege o objeto** — o arquivo, mesmo que interceptado e armazenado, permanece ilegível.
- **TLS protege a conversa** — ninguém (nem seu ISP, nem um atacante na rede local) vê o que está sendo transferido.

Em um ambiente corporativo real, você usa **ambas**: AES no arquivo (proteção permanente) + TLS no canal (proteção da transmissão).

### Fluxo prático: enviar o pacote via nc + TLS

Vamos simular duas máquinas diferentes (na prática, você rodaria em dois terminais ou dois computadores). O objetivo é capturar o tráfego e comparar.

#### Passo 1: Preparar certificado TLS (openssl)

O TLS exige um certificado. Vamos gerar um autoassinado (válido só para demo, não em produção):

```bash
cd ~/empresa/destinatario
openssl req -x509 -newkey rsa:2048 -keyout srv.key -out srv.crt -days 1 -nodes \
  -subj "/CN=sam.local/O=Empresa/C=BR"
```

**Explicação dos flags:**
- `-x509`: gera certificado autoassinado (X.509).
- `-newkey rsa:2048`: gera chave privada RSA-2048 junto.
- `-keyout srv.key`: salva a chave privada.
- `-out srv.crt`: salva o certificado.
- `-days 1`: válido por 1 dia (é um lab).
- `-nodes`: não cifra a chave privada com senha (simplifica demo).
- `-subj ...`: dados do certificado (CN = Common Name = nome do servidor).

**Resultado esperado:**
```text
-rw------- 1 aluno aluno 1704 ago 25 20:30 srv.key
-rw-r--r-- 1 aluno aluno 1223 ago 25 20:30 srv.crt
```

#### Passo 2: Servidor (Sam/destinatário) aguarda conexão cifrada

```bash
cd ~/empresa/destinatario
openssl s_server -cert srv.crt -key srv.key -port 4444 -quiet < /dev/null > relatorio_recebido.tar.gz.enc
```

**Explicação:**
- `-cert srv.crt -key srv.key`: usa o certificado e chave gerados acima.
- `-port 4444`: escuta na porta 4444.
- `-quiet`: não mostra logs do handshake (apenas passa dados).
- `< /dev/null > relatorio_recebido.tar.gz.enc`: redireciona para salvar o que receber.

**Resultado esperado:** o comando **fica em espera**, esperando conexão. (Não retorna prompt — é normal; deixe esse terminal aberto.)

#### Passo 3: Cliente (Alex/remetente) conecta e envia

Em outro terminal:

```bash
cd ~/empresa/remetente
cat relatorio_corporativo.tar.gz.enc | \
  openssl s_client -connect localhost:4444 -quiet 2>/dev/null
```

**Explicação:**
- `cat relatorio_corporativo.tar.gz.enc`: lê o arquivo cifrado (já gerado na Etapa 5).
- `openssl s_client`: cliente TLS.
- `-connect localhost:4444`: conecta ao servidor na porta 4444 (use IP real se em máquinas diferentes).
- `-quiet`: sem logs.
- `2>/dev/null`: silencia avisos de certificado autoassinado.
- A saída (`|`) vai direto para o `s_client`, que a transmite cifrada.

**Resultado esperado:** conexão estabelecida, arquivo enviado em segundos, comando retorna. No outro terminal, o servidor recebe o arquivo e fecha.

#### Passo 4: Validar que o arquivo chegou íntegro

```bash
cd ~/empresa/destinatario
diff <(sha256sum relatorio_corporativo.tar.gz | cut -d' ' -f1) \
     <(sha256sum relatorio_recebido.tar.gz.enc | cut -d' ' -f1) && \
  echo "✓ Arquivo recebido e integro!"
```

**Resultado esperado:**
```text
✓ Arquivo recebido e integro!
```

### Captura com tcpdump: vendo a diferença

Este é o **ponto de conexão visual** com os Workshops 01-04.

#### Sem TLS (apenas para referência — não rodamos aqui)

Nos Workshops 01-04, você viu:
```bash
sudo tcpdump -i any -s 0 -A "host 192.168.1.10 and port 21" | grep -A 5 "PASS\|USER\|SELECT"
# Resultado: credenciais e queries em TEXTO CLARO
```

#### Com TLS (agora, no Workshop 05)

Abra um terceiro terminal e rode **enquanto** os dois anteriores estão trocando dados:

```bash
sudo tcpdump -i lo -s 0 'tcp port 4444' -A | head -50
```

**Explicação:**
- `-i lo`: interface loopback (localhost → localhost).
- `-s 0`: captura pacotes completos.
- `'tcp port 4444'`: filtra só a porta 4444 (onde TLS está rodando).
- `-A`: mostra payload em ASCII.
- `| head -50`: limita a 50 linhas (TLS handshake é verboso).

**Resultado esperado:**

```text
....... .......
14:22:15.234567 IP localhost.45678 > localhost.4444: Flags [P.], seq 1:243, ack 1
...X.....<.....A.M.6.w.2..y...U.3.e......[.7..E.....&..m!..Aq.~..S..
14:22:15.235678 IP localhost.4444 > localhost.45678: Flags [P.], seq 1:1234, ack 243
.c...C.@.......z.H.....^...x%.!7Q...)......#7."b...+.E....V...
[mais bytes aparentemente aleatórios — é o conteúdo cifrado]
```

**Análise:** compare com o `tcpdump` dos Workshops 01-04:
- **Lá:** você viu `USER admin`, `PASS 123456`, comandos SQL `SELECT *` em texto puro.
- **Aqui:** você vê apenas bytes aparentemente aleatórios — **a mesma informação, mas cifrada**.

Seu arquivo `relatorio_corporativo.tar.gz.enc` contém um relatório sensível. Mesmo capturado pela rede, ele permanece ilegível. Os metadados (quem fala com quem) também estão protegidos pelo TLS Handshake.

### Alternativa mais simples: ncat com --ssl

Se `openssl s_server` parecer complicado, existe um atalho usando `ncat` (pacote `nmap`):

```bash
# Servidor (Sam)
sudo apt install nmap  # se não tiver
ncat --ssl -l 4444 > relatorio_recebido.tar.gz.enc

# Cliente (Alex), em outro terminal
ncat --ssl localhost 4444 < relatorio_corporativo.tar.gz.enc
```

**Vantagem:** ncat gera certificado autoassinado automaticamente, sem `openssl req`.

**Desvantagem:** menos educacional — você não vê o certificado sendo construído.

### Resumindo a curiosidade

| Aspecto | Workshops 01-04 | Workshop 05 base | Workshop 05 Extra (TLS) |
|--------|-----------------|-----------------|------------------------|
| **Conteúdo** | HTTP, FTP, MySQL, MQTT | Arquivo cifrado com AES | Conversa cifrada com TLS |
| **tcpdump mostra** | Credenciais, queries | Bytes aleatórios (AES) | Bytes aleatórios (TLS) |
| **Quem vê** | Atacante em rede local | Ninguém (arquivo protegido) | Ninguém (canal + arquivo) |
| **Proteção** | Nenhuma | Permanente (objeto) | Permanente (objeto) + Transmissão (canal) |

**A lição:** um arquivo cifrado com AES-256 é seguro **para sempre** — mesmo capturado, mesmo copiado, mesmo anos depois. Mas a **transmissão** também importa. TLS resolve metadados que AES não cobre. Juntos = defesa em profundidade.

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| `openssl: command not found` | Instalar: `sudo apt install openssl` |
| `unable to load Private Key` | Verificar caminho e permissões (`chmod 600`) do arquivo `.pem` |
| `bad decrypt` no AES | Chave errada ou `-S` diferente do usado na cifragem; confira `chave_*.bin` correta |
| `RSA operation error` no `rsautl` | Chave privada não corresponde à pública usada para cifrar (ver Ataque 2) |
| `Verification Failure` na assinatura | Arquivo foi alterado, ou a chave pública usada não é a do autor real |
| `rsautl: command not found` (OpenSSL 3.x recentes) | Comando legado ainda funciona na maioria das builds; alternativa moderna: `openssl pkeyutl -encrypt/-decrypt` com os mesmos parâmetros `-inkey`/`-pubin` |
| `tar: This does not look like a tar archive` ao abrir `.enc` direto | Esperado — o arquivo está cifrado; descriptografe primeiro com `openssl enc -d` |
| Hashes não batem entre remetente e destinatário | Confirme que copiou o arquivo `.tar.gz` (ou `.enc`) exato, sem re-gerar em outro momento |
| `s_server`/`s_client` não conecta | Confirme que o servidor está rodando **antes** do cliente conectar; confira a porta (`4444`) livre com `ss -tulpn \| grep 4444` |
| Certificado autoassinado gera aviso | Normal em ambiente de laboratório; use `2>/dev/null` no `s_client` para silenciar, ou aceite manualmente se solicitado |
| `tcpdump` não captura nada na interface `lo` | Em algumas distros, use `-i any` em vez de `-i lo`, ou confirme que o tráfego é mesmo loopback (`localhost`) |

---

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/06-Criptografia_Simetrica_e_Assimetrica_Corporativa.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>
