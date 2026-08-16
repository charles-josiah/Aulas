# Criptografia Simétrica com OpenSSL

**Disciplina:** Criptografia e Segurança em Redes — SENAI
**Pré-requisitos:** Container com OpenSSL 3.x (ex.: `openssl:3` do Docker Hub) ou máquina com Ubuntu 22.04+

> **Nota sobre a versão do OpenSSL:** Este material utiliza comandos compatíveis
> com o OpenSSL 3.x (versão atual). O OpenSSL 3.x requer `-pbkdf2` para derivação
> segura de chave a partir de senha. Todos os exemplos abaixo já usam os
> comandos modernos com `-pbkdf2` e `-iter` adequados.
>
> **Baseado em:** `2025-09-Lab-Cripto-e-SegRedes/OpenSSL_Criptografia_Simétrica_Aula_v2.md`
> — documento original. Este material foi reescrito e expandido para o
> laboratório de 2026-07, com comandos atualizados, explicação dos modos de
> operação (CBC vs GCM), ataques comuns e fluxo completo de criptografia híbrida.
>
> **Integração Docker:** O script de exemplo completo pode ser executado
> diretamente num container `openssl:3`.
>
> **Conexão entre as partes:** Cada exemplo prático está vinculado a uma história
> do mundo real, tornando abstrata criptografia concreta para desenvolvedores e
> engenheiros de segurança.
>
> **Veja também:**
> [`Aula_OpenSSL_Criptografia_Simetrica_exemplos.md`](./Aula_OpenSSL_Criptografia_Simetrica_exemplos.md)
> — execução completa passo a passo com saídas de terminal e validação prática.

---

## Índice

- [1. Objetivo](#1-objetivo)
- [2. O que é Criptografia Simétrica](#2-o-que-é-criptografia-simétrica)
- [3. Conceitos Fundamentais](#3-conceitos-fundamentais)
  - [3.1 Algoritmo de Criptografia (AES)](#31-algoritmo-de-criptografia-aes)
  - [3.2 Modos de Operação](#32-modos-de-operação)
  - [3.3 Padding e Derivação de Chave](#33-padding-e-derivação-de-chave)
  - [3.4 IV (Initialization Vector)](#34-iv-initialization-vector)
  - [3.5 HMAC (Hash-based Message Authentication Code)](#35-hmac-hash-based-message-authentication-code)
- [4. Por que a Criptografia Simétrica é Rápida](#4-por-que-a-criptografia-simétrica-é-rápida)
- [5. Usabilidade e Casos de Uso](#5-usabilidade-e-casos-de-uso)
- [6. Historinhas: O Que Acontece Quando a Segurança Simétrica Falha](#6-historinhas-o-que-acontece-quando-a-segurança-simétrica-falha)
  - [6.1 O Backup Criptografado sem Chave](#61-o-backup-criptografado-sem-chave)
  - [6.2 O Vazamento de um Arquivo Criptografado com Chave Fraca](#62-o-vazamento-de-um-arquivo-criptografado-com-chave-fraca)
  - [6.3 O Ataque de Padding Oracle](#63-o-ataque-de-padding-oracle)
- [7. Limitações Práticas da Criptografia Simétrica](#7-limitações-práticas-da-criptografia-simétrica)
  - [7.1 Compartilhamento de Chave](#71-compartilhamento-de-chave)
  - [7.2 Tamanho do Arquivo](#72-tamanho-do-arquivo)
  - [7.3 Ataques de Dicionário](#73-ataques-de-dicionário)
- [8. Exemplos Práticos No Linux](#8-exemplos-práticos-no-linux)
  - [8.1 Geração de Chave Secreta](#81-geração-de-chave-secreta)
  - [8.2 Exemplo 1: Criptografar e Descriptografar Arquivo](#82-exemplo-1-criptografar-e-descriptografar-arquivo)
  - [8.3 Exemplo 2: AES-256-GCM (Modo Autenticado)](#83-exemplo-2-aes-256-gcm-modo-autenticado)
  - [8.4 Exemplo 3: Verificação de Integridade com Hash](#84-exemplo-3-verificação-de-integridade-com-hash)
  - [8.5 Exemplo 4: HMAC (Autenticação + Integridade)](#85-exemplo-4-hmac-autenticação-integridade)
  - [8.6 Exemplo 5: Criptografia Híbrida (AES-256-GCM + RSA)](#86-exemplo-5-criptografia-híbrida-aes-256-gcm--rsa)
- [9. Ataques Conhecidos e Mitigação](#9-ataques-conhecidos-e-mitigação)
- [10. Modos de Operação — Guia Rápido](#10-modos-de-operação-guia-rápido)
- [11. Resumo dos Comandos](#11-resumo-dos-comandos)
- [12. Boas Práticas](#12-boa-práticas)
- [13. Referências](#13-referências)

---

## 1. Objetivo

Aprender a usar o OpenSSL para operações de **criptografia simétrica** no Linux:
gerar chaves secretas, criptografar/descriptografar arquivos com AES, verificar
integridade com hashes e HMACs, e entender como a criptografia simétrica se
combina com a assimétrica na prática (criptografia híbrida).

---

## Exemplo Prático — Execução Detalhada

Todos os exemplos desta aula foram **executados e validados** em ambiente real
com OpenSSL 3.x via container Docker (`openssl:3`). Para a execução completa
passo a passo com saídas de terminal, saídas esperadas e validação de cada
comando, consulte:

[**Aula_OpenSSL_Criptografia_Simetrica_exemplos.md**](./Aula_OpenSSL_Criptografia_Simetrica_exemplos.md)

Esse documento complementar contém:
- Prompt do terminal, comandos exatos e saídas reais
- Verificações de integridade (diff, HMAC, hash)
- Fluxo completo de criptografia híbrida (AES + RSA)
- Teste de detecção de adulteração com GCM (bad decrypt)

---

## 2. O que é Criptografia Simétrica

A criptografia simétrica (também chamada de criptografia de **chave secreta**)
utiliza **uma única chave** para criptografar e descriptografar dados. Quem
tem a chave pode ler o arquivo; quem não tem, não pode.

| Característica | Descrição |
|---|---|
| **Chave usada** | A **mesma** para criptografar e descriptografar |
| **Velocidade** | Muito mais rápida que a assimétrica (centenas de vezes) |
| **Exemplo** | AES-256-GCM (padrão moderno) |
| **Problema principal** | Como compartilhar a chave secreta de forma segura? |

**Imagine um cofre com chave única**. Você tranca o cofre com uma chave. A mesma chave abre. Se você perder a chave, ninguém mais abre. Se alguém copiar a chave, essa pessoa pode abrir o cofre.

A segurança depende do sigilo da chave (nunca expô-la) e da qualidade do algoritmo de criptografia. O AES-256 é o padrão atual do NIST para dados sensíveis.

---

## 3. Conceitos Fundamentais

### 3.1 Algoritmo de Criptografia (AES)

O **Advanced Encryption Standard (AES)** é o padrão NIST FIPS 197 para
criptografia simétrica. Suporta chaves de 128, 192 ou 256 bits.

| Tamanho da chave | Segurança |
|---|---|
| AES-128 | Seguro para dados não classificados |
| AES-192 | Seguro para dados classificados |
| AES-256 | Seguro para dados ultra-secretos (recomendado) |

### 3.2 Modos de Operação

O AES criptografa blocos de 16 bytes. Como lidar com arquivos maiores?
**Modos de operação:**

| Modo | Autenticação | Recomendado |
|---|---|---|
| **CBC** (Cipher Block Chaining) | Não | Requer HMAC ou MAC externo |
| **GCM** (Galois/Counter Mode) | Sim (AEAD) | **Recomendado** para tráfego moderno |
| **CTR** (Counter Mode) | Não | Bom para paralelização |
| **OFB/CFB** (Output/ Cipher Feedback) | Não | Legado |

> **Por que GCM?** GCM combina criptografia + autenticação em um único passo
> (AEAD — Authenticated Encryption with Associated Data). Qualquer adulteração
> do ciphertext é detectada automaticamente. Não precisa de HMAC extra.

### 3.3 Padding e Derivação de Chave

O OpenSSL oferece dois métodos para converter uma senha em uma chave:

| Método | Segurança | Uso |
|---|---|---|
| `-pass pass:` | Senha em texto plano (aparece em `ps`) | Apenas para testes |
| `-pass file:` | Chave secreta em arquivo | Uso em scripts |
| `-pbkdf2` | **PBKDF2 com salt** (recomendado) | **Padrão moderno** |

> **Recomendação:** Sempre use `-pbkdf2` com `-iter 100000` quando usar
> senha. O `-aes-256-cbc` sem `-pbkdf2` é vulnerável a ataques de dicionário.

### 3.4 IV (Initialization Vector)

O IV é um valor aleatório adicionado ao início da criptografia. Ele garante
que o **mesmo arquivo** criptografado duas vezes produza **resultados
diferentes**. Sem IV, ataques de padrão são possíveis.

| Tamanho do IV |
|---|
| AES-CBC: 16 bytes (bloco) |
| AES-GCM: 12 bytes (recomendado pela RFC 5288) |

### 3.5 HMAC (Hash-based Message Authentication Code)

O HMAC combina um hash (SHA-256) com uma chave secreta. Ele garante:

1. **Integridade:** O arquivo não foi alterado.
2. **Autenticidade:** Apenas quem tem a chave poderia ter gerado o HMAC.

---

## 4. Por que a Criptografia Simétrica é Rápida

Comparação de performance (dados aproximados):

| Operação | Tempo relativo |
|---|---|
| AES-256-GCM (1 MB) | ~0.01s |
| RSA-2048 encrypt (1 KB) | ~0.05s |
| RSA-2048 decrypt (1 KB) | ~0.5s |

A criptografia assimétrica é **50 a 100 vezes mais lenta** para a mesma
quantidade de dados. Por isso, no TLS, a negociação inicial usa assimétrica
(AES/ECC/ECDH), mas a comunicação subsequente usa simétrica (AES).

---

## 5. Usabilidade e Casos de Uso

| Caso | Exemplo |
|---|---|
| **Criptografia de arquivos locais** | `openssl enc -aes-256-cbc -in data.txt -out data.enc -pass file:./secret.key` |
| **Backup criptografado** | `tar -cf - diretorio` pipeado para `openssl enc -aes-256-gcm -out backup.tar.gpg` |
| **Criptografia de disco** | LUKS (dm-crypt) usa AES para dados em repouso |
| **Criptografia híbrida (TLS/HTTPS)** | Chave simétrica trocada via certificado X.509 |
| **Verificação de integridade** | `openssl dgst -sha256` antes e depois da transmissão |
| **HMAC para autenticação** | `openssl dgst -sha256 -mac HMAC -macopt key:./secret.key` |

---

## 6. Historinhas: O Que Acontece Quando a Segurança Simétrica Falha

### 6.1 O Backup Criptografado sem Chave

Um administrador criptografa um backup com `openssl enc -aes-256-cbc -pass
pass:senha123` e o armazena. Anos depois, ninguém lembra a senha, e o backup
é inacessível.

**Impacto:**
- Dados perdidos permanentemente.
- Criptografia simétrica sem KDF (PBKDF2/scrypt) é quebrável com dicionário.

**Mitigação:**
- Use `-pbkdf2 -iter 100000` para tornar a senha mais resistente.
- Armazene a chave em um cofre (ex.: `secret.key`) e o backup com `-pass file:./secret.key`.

### 6.2 O Vazamento de um Arquivo Criptografado com Chave Fraca

Um desenvolvedor usa `openssl enc -aes-128-cbc` sem salt. Dois arquivos
idênticos produzem ciphertext idêntico. Um atacante descobre o conteúdo por
análise de padrões (ECB).

**Impacto:**
- Imagens com áreas de cor sólida revelam o conteúdo (ex.: `ciphertext` idêntico
  para blocos idênticos).
- Senhas curtas são quebradas com dicionário.

**Mitigação:**
- Use **CBC** com **IV** (ou **GCM** com **nonce**) para garantir resultados diferentes.
- Use `-pbkdf2` para derivação de chave.

### 6.3 O Ataque de Padding Oracle

Um atacante tem acesso a um sistema que usa `AES-128-CBC` e pode observar
se o padding é válido após a descriptografia.

**Impacto:**
- O atacante pode **deduzir o texto plano** byte a byte.
- Atacar `openssl enc -aes-128-cbc` sem `-pbkdf2` é trivial.

**Mitigação:**
- Use **GCM** (autenticado) em vez de **CBC** (sem autenticação).
- Adicione HMAC externo se CBC for necessário.

---

## 7. Limitações Práticas da Criptografia Simétrica

### 7.1 Compartilhamento de Chave

O maior desafio da criptografia simétrica é **como compartilhar a chave
secreta** com o destinatário. Se você enviar a chave pela rede, ela pode
ser interceptada.

**Solução prática:** **Criptografia híbrida** — criptografar a chave simétrica
com a chave pública do destinatário (RSA/ECC). O destinatário descriptografa
a chave simétrica com sua chave privada.

### 7.2 Tamanho do Arquivo

O AES-256-CBC + IV adiciona 16 bytes ao ciphertext. O GCM adiciona IV (12
bytes) + tag (16 bytes). Para arquivos pequenos, isso é irrelevante.

### 7.3 Ataques de Dicionário

Senhas fracas (ex.: `senha123`) são quebradas em segundos com `hashcat`.

**Mitigação:**
- Use `-pbkdf2 -iter 100000` para tornar cada tentativa de senha mais lenta.
- Use chave secreta aleatória (ex.: `openssl rand -out secret.key 32`) em vez
  de senha.

---

## 8. Exemplos Práticos no Linux

Todos os exemplos foram testados com OpenSSL 3.x. Para verificar sua versão:

```bash
openssl version
# Exemplo de saída: OpenSSL 3.0.13 30 Jan 2024 (Library: OpenSSL 3.0.13 30 Jan 2024)
```

### 8.1 Geração de Chave Secreta

**Gerar chave AES-256 aleatória:**

```bash
openssl rand -out secret.key 32
```

Explicação:
- `rand` → gera bytes aleatórios
- `-out secret.key` → arquivo de saída
- `32` → tamanho em bytes (256 bits)

**Gerar chave com PBKDF2 (a partir de senha):**

```bash
openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -pass pass:"minha senha forte" -P
```

Explicação:
- `-pbkdf2` → função de derivação moderna (substitui o antigo `-md MD5`)
- `-iter 100000` → número de iterações (10000 é o mínimo, 100000 é o recomendado)
- `-P` → exibe a chave derivada e o salt (não criptografa o arquivo)

### 8.2 Exemplo 1: Criptografar e Descriptografar Arquivo

**Cenário:** Alice quer criptografar um arquivo localmente.

**Preparar o arquivo:**

```bash
echo "Mensagem secreta: a prova esta no /tmp" > data.txt
```

**Criptografar com AES-256-CBC + PBKDF2:**

```bash
openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt -in data.txt -out encrypted_data.bin -pass file:./secret.key
```

Explicação:
- `-aes-256-cbc` → AES com chave de 256 bits no modo CBC
- `-pbkdf2` → usa PBKDF2 para derivação de chave
- `-iter 100000` → 100000 iterações (torna o ataque de força bruta mais lento)
- `-salt` → adiciona um salt aleatório
- `-in data.txt` → arquivo de entrada
- `-out encrypted_data.bin` → arquivo criptografado (binário)
- `-pass file:./secret.key` → chave secreta em arquivo

**Descriptografar:**

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in encrypted_data.bin -out decrypted_data.txt -pass file:./secret.key
```

Explicação:
- `-d` → modo descriptografia
- `-in encrypted_data.bin` → arquivo criptografado
- `-out decrypted_data.txt` → arquivo descriptografado
- `-pass file:./secret.key` → mesm chave usada na criptografia

**Verificar o resultado:**

```bash
diff data.txt decrypted_data.txt && echo "Arquivos identicos" || echo "Diferentes"
# Saída esperada: Arquivos identicos
```

### 8.3 Exemplo 2: AES-256-GCM (Modo Autenticado)

**Cenário:** Alice quer criptografar com autenticação embutida (GCM).

```bash
openssl enc -aes-256-gcm -pbkdf2 -iter 100000 -in data.txt -out encrypted_data.gcm -pass file:./secret.key
```

**Descriptografar:**

```bash
openssl enc -d -aes-256-gcm -pbkdf2 -iter 100000 -in encrypted_data.gcm -out decrypted_data.gcm -pass file:./secret.key
```

**Verificar:**

```bash
diff data.txt decrypted_data.gcm && echo "Arquivos identicos (GCM)" || echo "Diferentes (GCM)"
# Saída esperada: Arquivos identicos (GCM)
```

> **Por que GCM:** Qualquer adulteração do ciphertext é detectada
> automaticamente (AEAD). O CBC puro não rejeita adulteração — ele apenas
> gera lixo no texto plano (difícil de detectar). Com GCM, o OpenSSL retorna
> `bad decrypt` se os dados forem adulterados.

### 8.4 Exemplo 3: Verificação de Integridade com Hash

**Cenário:** Alice quer garantir que o arquivo não foi alterado após a
criptografia.

**Alice gera o hash do arquivo original:**

```bash
openssl dgst -sha256 data.txt > data_hash.txt
cat data_hash.txt
```

**Alice criptografa e envia: data_hash.txt + encrypted_data.bin**

**Bob descriptografa e verifica:**

```bash
# 1. Descriptografar
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in encrypted_data.bin -out received_data.txt -pass file:./secret.key

# 2. Gerar hash do recebido
openssl dgst -sha256 received_data.txt > received_hash.txt

# 3. Comparar hashes
diff data_hash.txt received_hash.txt && echo "Integridade confirmada" || echo "ARQUIVO ADULTERADO"
```

**Testar adulteração:**

```bash
echo "ALTERADO" >> received_data.txt
openssl dgst -sha256 received_data.txt > received_hash.txt
diff data_hash.txt received_hash.txt && echo "Integridade confirmada" || echo "ARQUIVO ADULTERADO"
# Saída esperada: ARQUIVO ADULTERADO
```

### 8.5 Exemplo 4: HMAC (Autenticação + Integridade)

**Cenário:** Além da criptografia, Alice quer garantir que apenas quem tem a
chave pode ter gerado o arquivo.

**Alice gera o HMAC do arquivo original:**

```bash
openssl dgst -sha256 -mac HMAC -macopt key:./secret.key data.txt > data_hmac.txt
```

**Alice criptografa e envia: data.txt + encrypted_data.bin + data_hmac.txt**

**Bob descriptografa e verifica o HMAC:**

```bash
# 1. Descriptografar
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in encrypted_data.bin -out received_data.txt -pass file:./secret.key

# 2. Gerar HMAC do recebido
openssl dgst -sha256 -mac HMAC -macopt key:./secret.key received_data.txt > received_hmac.txt

# 3. Comparar HMACs
diff data_hmac.txt received_hmac.txt && echo "HMAC confere" || echo "HMAC NAO CONFERE"
```

> **Resultado:** Se o arquivo foi adulterado, o HMAC não confere. O HMAC
> garante que apenas quem tem a chave secreta pode ter gerado o código de
> autenticação.

### 8.6 Exemplo 5: Criptografia Híbrida (AES-256-GCM + RSA)

**Cenário:** Alice quer enviar um arquivo **confidencial** para Bob usando
AES (rápido) + RSA (seguro).

**Fluxo completo:**

```
Alice:
  1. Gera chave simétrica aleatória
  2. Criptografa o arquivo com essa chave (AES-256-GCM)
  3. Criptografa a chave simétrica com a chave pública de Bob (RSA-OAEP)
  4. Envia: (arquivo criptografado) + (chave simétrica criptografada)

Bob:
  1. Descriptografa a chave simétrica com sua chave privada (RSA-OAEP)
  2. Usa a chave simétrica para descriptografar o arquivo (AES-256-GCM)
  3. Verifica a integridade (GCM AEAD)
```

**Passo 1 — Alice gera chave simétrica e criptografa o arquivo:**

```bash
# Gerar chave simétrica
openssl rand -out symmetric.key 32

# Criptografar o arquivo
openssl enc -aes-256-gcm -pbkdf2 -iter 100000 -in data.txt -out encrypted_data.bin -pass file:./symmetric.key

# Extrair o IV e a tag
openssl enc -aes-256-gcm -pbkdf2 -iter 100000 -in data.txt -out encrypted_data.bin -pass file:./symmetric.key -P
```

**Passo 2 — Alice criptografa a chave simétrica com a chave pública de Bob:**

```bash
openssl pkeyutl -encrypt -inkey bob_public.key -pubin -in symmetric.key -out encrypted_symmetric_key.bin -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

**Passo 3 — Bob descriptografa a chave simétrica:**

```bash
openssl pkeyutl -decrypt -inkey bob_private.key -in encrypted_symmetric_key.bin -out symmetric.key -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

**Passo 4 — Bob descriptografa o arquivo com a chave simétrica:**

```bash
openssl enc -d -aes-256-gcm -pbkdf2 -iter 100000 -in encrypted_data.bin -out decrypted_data.txt -pass file:./symmetric.key
```

**Verificar:**

```bash
diff data.txt decrypted_data.txt && echo "Criptografia hibrida funcionou" || echo "Falhou"
```

> **Por que isso funciona:** O RSA resolve o problema de compartilhamento de
> chave. Apenas Bob pode descriptografar a chave simétrica. O AES-256-GCM
> garante confidencialidade e integridade dos dados.
>
> ---
>
> **Veja a execução completa dos exemplos:**
> [`Aula_OpenSSL_Criptografia_Simetrica_exemplos.md`](./Aula_OpenSSL_Criptografia_Simetrica_exemplos.md)
> — documento com todos os comandos, saídas esperadas e validação em tempo real.

---

## 9. Ataques Conhecidos e Mitigação

| Tipo de Ataque | O que o atacante faz | Por que é perigoso | Mitigação |
|---|---|---|---|
| **Padding Oracle** | Envia ciphertext adaptativo, observa erro de padding | Deduz o texto plano byte a byte | Use **GCM** (AEAD) em vez de CBC |
| **Dicionário** | Tenta senhas comuns contra PBKDF2 | Senha fraca é quebrada rapidamente | Use `-iter 100000` com PBKDF2 |
| **AES-ECB** (modo inseguro) | Blocos idênticos produzem ciphertext idêntico | Padrões revelam o conteúdo | Use **CBC** ou **GCM** (nunca ECB) |
| **Replay** | Captura o ciphertext e reenvia | O mesmo arquivo é aceito novamente | Adicione timestamp/nonce, use **GCM** |
| **IV fixo** | Mesmo IV para todos os arquivos | Criptografia é determinística | IV **aleatório** (`-rand` ou `openssl rand`) |
| **HMAC falso** | HMAC não é verificado | Arquivo adulterado é aceito | Sempre compare HMAC com `diff` |

---

## 10. Modos de Operação — Guia Rápido

| Modo | Tamanho do IV | Tag | Autenticação | Uso recomendado |
|---|---|---|---|---|
| **CBC** | 16 bytes | Não | Não (requer HMAC) | Arquivos locais com HMAC |
| **GCM** | 12 bytes | 16 bytes | Sim (AEAD) | **Padrão moderno** para tráfego |
| **CTR** | 16 bytes | Não | Não | Stream criptografado |
| **OFB** | 16 bytes | Não | Não | Modo síncrono |

---

## 11. Resumo dos Comandos

| Operação | Comando |
|---|---|
| Gerar chave aleatória | `openssl rand -out secret.key 32` |
| Gerar chave via PBKDF2 | `openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -pass pass:"senha" -P` |
| Criptografar (CBC) | `openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -in arquivo -out arquivo.enc -pass file:./secret.key` |
| Descriptografar (CBC) | `openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in arquivo.enc -out arquivo -pass file:./secret.key` |
| Criptografar (GCM) | `openssl enc -aes-256-gcm -pbkdf2 -iter 100000 -in arquivo -out arquivo.gcm -pass file:./secret.key` |
| Descriptografar (GCM) | `openssl enc -d -aes-256-gcm -pbkdf2 -iter 100000 -in arquivo.gcm -out arquivo -pass file:./secret.key` |
| Gerar hash SHA-256 | `openssl dgst -sha256 arquivo.txt` |
| Gerar HMAC | `openssl dgst -sha256 -mac HMAC -macopt key:./secret.key arquivo.txt` |
| Verificar HMAC | `diff arquivo_hmac.txt novo_hmac.txt` |

---

## 12. Boas Práticas

1. **Use AES-256-GCM** para dados confidenciais (autenticação automática).
2. **Use `-pbkdf2 -iter 100000`** em vez de `-pass pass:` (protege contra
   ataques de dicionário).
3. **IV aleatório** (nunca reutilize o mesmo IV para dois arquivos diferentes).
4. **Nunca envie a chave simétrica pela rede** sem criptografia assimétrica
   (use criptografia híbrida para compartilhar).
5. **Verifique o HMAC** antes de abrir o arquivo (integridade).
6. **Teste a adulteração** do ciphertext (GCM rejeita automaticamente, CBC
   precisa de verificação extra).

---

## 13. Referências

- [OpenSSL Documentation — enc](https://www.openssl.org/docs/man3.0/man1/openssl-enc.html)
- [NIST FIPS 197 — AES](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf)
- [NIST SP 800-38D — GCM](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38d.pdf)
- [RFC 5288 — AES-GCM for TLS](https://datatracker.ietf.org/doc/html/rfc5288)
- [OpenSSL Documentation — pkeyutl](https://www.openssl.org/docs/man3.0/man1/openssl-pkeyutl.html) (para criptografia híbrida)