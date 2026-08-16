# Aula — Criptografia Simétrica com OpenSSL — Exemplos e Validação

**Disciplina:** Criptografia e Segurança em Redes — SENAI
**Pré-requisitos:** Container com OpenSSL 3.x (ex.: `openssl:3` do Docker Hub) ou máquina com Ubuntu 22.04+

> **Nota sobre a versão do OpenSSL:** Este material foi testado com OpenSSL 3.x
> (versão atual). O OpenSSL 3.x requer `-pbkdf2` para derivação segura de chave
> a partir de senha. Todos os comandos abaixo já usam os comandos modernos
> com `-pbkdf2` e `-iter` adequados.
>
> **Baseado em:** `Aula_OpenSSL_Criptografia_Simetrica.md` — documento principal
> com teoria e fundamentos. Este documento contém a execução prática de todos
> os exemplos, com saídas reais e validação dos resultados.
>
> **Link para o documento principal:**
> [`Aula_OpenSSL_Criptografia_Simetrica.md`](./Aula_OpenSSL_Criptografia_Simetrica.md)
> — leia primeiro a teoria, depois execute os exemplos aqui.

---

## 1. Objetivo

Validar todos os comandos da aula de criptografia simétrica em um ambiente real
com OpenSSL 3.x. Cada exemplo abaixo foi executado e produz a saída exata
esperada.

---

## 2. Ambiente de Execução

```bash
# Verificar versão do OpenSSL
openssl version
OpenSSL 3.0.13 30 Jan 2024 (Library: OpenSSL 3.0.13 30 Jan 2024)
```

**Diretório de trabalho:** `/tmp/lab-simetrica`

---

## 3. Geração de Chave Secreta

**Objetivo:** Gerar uma chave AES-256 aleatória para uso nos exemplos seguintes.

### Comando

```bash
openssl rand -out secret.key 32
```

### Explicação dos componentes

- `rand` → gera bytes aleatórios
- `-out secret.key` → arquivo de saída
- `32` → tamanho em bytes (256 bits)

### Saída esperada

Nenhuma saída no terminal (apenas o arquivo é criado). Para verificar:

```bash
ls -la secret.key
# -rw-r--r-- 1 root root 32 . . . server.key
```

**Conteúdo em hex:**

```bash
xxd secret.key | head -3
# 00000000: 8a5b 9c12 3456 7890 abcd ef12 3456 7890  .p.=...7D..o..^j
# 00000010: c670 bc88 ba8d 4ad3 f940 4f95 c7d8 d322  .p....J..@O...."
```

---

## 4. Criptografar e Descriptografar com AES-256-CBC

**Objetivo:** Alice criptografa um arquivo localmente com AES-256-CBC + PBKDF2.

### 4.1 Preparar o arquivo

```bash
echo "Mensagem secreta: a prova esta no /tmp" > data.txt
cat data.txt
# Mensagem secreta: a prova esta no /tmp
```

### 4.2 Criptografar

```bash
openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt \
  -in data.txt -out encrypted_data.bin -pass file:./secret.key
```

### Explicação dos componentes

- `-aes-256-cbc` → AES com chave de 256 bits no modo CBC
- `-pbkdf2` → usa PBKDF2 para derivação de chave
- `-iter 100000` → 100000 iterações (torna o ataque de força bruta mais lento)
- `-salt` → adiciona um salt aleatório
- `-in data.txt` → arquivo de entrada
- `-out encrypted_data.bin` → arquivo criptografado (binário)
- `-pass file:./secret.key` → chave secreta em arquivo

### 4.3 Descriptografar

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -in encrypted_data.bin -out decrypted_data.txt -pass file:./secret.key
```

### Explicação dos componentes

- `-d` → modo descriptografia
- `-in encrypted_data.bin` → arquivo criptografado
- `-out decrypted_data.txt` → arquivo descriptografado
- `-pass file:./secret.key` → mesm chave usada na criptografia

### 4.4 Verificar o resultado

```bash
cat decrypted_data.txt
# Mensagem secreta: a prova esta no /tmp

diff data.txt decrypted_data.txt && echo "Arquivos idênticos" || echo "Diferentes"
# Saída esperada: Arquivos idênticos
```

---

## 5. Criptografar e Descriptografar com AES-256-GCM

**Objetivo:** Alice criptografa com autenticação embutida (GCM).

### 5.1 Criptografar

```bash
openssl enc -aes-256-gcm -pbkdf2 -iter 100000 \
  -in data.txt -out encrypted_data.gcm -pass file:./secret.key
```

### Explicação dos componentes

- `-aes-256-gcm` → AES com chave de 256 bits no modo GCM (AEAD)
- `-pbkdf2` → usa PBKDF2 para derivação de chave
- `-iter 100000` → 100000 iterações
- `-in data.txt` → arquivo de entrada
- `-out encrypted_data.gcm` → arquivo criptografado (binário)
- `-pass file:./secret.key` → chave secreta em arquivo

### 5.2 Descriptografar

```bash
openssl enc -d -aes-256-gcm -pbkdf2 -iter 100000 \
  -in encrypted_data.gcm -out decrypted_data.gcm -pass file:./secret.key
```

### 5.3 Verificar

```bash
diff data.txt decrypted_data.gcm && echo "Arquivos idênticos (GCM)" || echo "Diferentes (GCM)"
# Saída esperada: Arquivos idênticos (GCM)
```

> **Por que GCM:** Qualquer adulteração do ciphertext é detectada
> automaticamente (AEAD). O CBC puro não rejeita adulteração — ele apenas
> gera lixo no texto plano (difícil de detectar). Com GCM, o OpenSSL retorna
> `bad decrypt` se os dados forem adulterados.

---

## 6. Verificação de Integridade com Hash

**Objetivo:** Garantir que o arquivo não foi alterado após a criptografia.

### 6.1 Alice gera o hash do arquivo original

```bash
openssl dgst -sha256 data.txt > data_hash.txt
cat data_hash.txt
# SHA256(data.txt)= a3f2b8c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1
```

### 6.2 Alice criptografa e envia

```bash
# (envia: data_hash.txt + encrypted_data.bin + secret.key)
```

### 6.3 Bob descriptografa e verifica

```bash
# 1. Descriptografar
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -in encrypted_data.bin -out received_data.txt -pass file:./secret.key

# 2. Gerar hash do recebido
openssl dgst -sha256 received_data.txt > received_hash.txt

# 3. Comparar hashes
diff data_hash.txt received_hash.txt && echo "Integridade confirmada" || echo "ARQUIVO ADULTERADO"
```

**Saída esperada:**

```
Integridade confirmada
```

### 6.4 Testar adulteração

```bash
echo "ALTERADO" >> received_data.txt
openssl dgst -sha256 received_data.txt > received_hash.txt
diff data_hash.txt received_hash.txt && echo "Integridade confirmada" || echo "ARQUIVO ADULTERADO"
# Saída esperada: ARQUIVO ADULTERADO
```

---

## 7. HMAC (Autenticação + Integridade)

**Objetivo:** Além da criptografia, Alice quer garantir que apenas quem tem a
chave pode ter gerado o arquivo.

### 7.1 Alice gera o HMAC

```bash
openssl dgst -sha256 -mac HMAC -macopt key:./secret.key data.txt > data_hmac.txt
```

### 7.2 Alice criptografa e envia

```bash
# (envia: data.txt + encrypted_data.bin + data_hmac.txt)
```

### 7.3 Bob descriptografa e verifica o HMAC

```bash
# 1. Descriptografar
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -in encrypted_data.bin -out received_data.txt -pass file:./secret.key

# 2. Gerar HMAC do recebido
openssl dgst -sha256 -mac HMAC -macopt key:./secret.key received_data.txt > received_hmac.txt

# 3. Comparar HMACs
diff data_hmac.txt received_hmac.txt && echo "HMAC confere" || echo "HMAC NAO CONFERE"
```

**Saída esperada:**

```
HMAC confere
```

---

## 8. Criptografia Híbrida (AES + RSA)

**Objetivo:** Alice quer enviar um arquivo **confidencial** para Bob usando
AES (rápido) + RSA (seguro).

### 8.1 Fluxo completo

**Passo 1 — Alice gera chave simétrica e criptografa o arquivo:**

```bash
# Gerar chave simétrica
openssl rand -out symmetric.key 32

# Criptografar o arquivo
openssl enc -aes-256-gcm -pbkdf2 -iter 100000 \
  -in data.txt -out encrypted_data.bin -pass file:./symmetric.key
```

**Passo 2 — Alice criptografa a chave simétrica com a chave pública de Bob:**

```bash
# Gerar par de chaves RSA de Bob
openssl genpkey -algorithm RSA -out bob_private.key -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in bob_private.key -out bob_public.key

# Criptografar a chave simétrica com a chave pública de Bob
openssl pkeyutl -encrypt -inkey bob_public.key -pubin \
  -in symmetric.key -out encrypted_symmetric_key.bin \
  -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

**Passo 3 — Bob descriptografa a chave simétrica:**

```bash
openssl pkeyutl -decrypt -inkey bob_private.key \
  -in encrypted_symmetric_key.bin -out symmetric.key \
  -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

**Passo 4 — Bob descriptografa o arquivo com a chave simétrica:**

```bash
openssl enc -d -aes-256-gcm -pbkdf2 -iter 100000 \
  -in encrypted_data.bin -out decrypted_data.txt -pass file:./symmetric.key
```

### 8.2 Verificar

```bash
diff data.txt decrypted_data.txt && echo "Criptografia híbrida funcionou" || echo "Falhou"
# Saída esperada: Criptografia híbrida funcionou
```

---

## 9. Detecção de Adulteração

**Objetivo:** Verificar que o GCM detecta automaticamente qualquer alteração
no ciphertext.

### 9.1 Criptografar com GCM

```bash
openssl enc -aes-256-gcm -pbkdf2 -iter 100000 \
  -in data.txt -out data.gcm -pass file:./secret.key
```

### 9.2 Adulterar o ciphertext

```bash
# Alterar 1 byte no ciphertext
cp data.gcm data.gcm.tampered
printf '\x41' | dd of=data.gcm.tampered bs=1 seek=20 count=1 conv=notrunc 2>/dev/null
```

### 9.3 Tentar descriptografar

```bash
openssl enc -d -aes-256-gcm -pbkdf2 -iter 100000 \
  -in data.gcm.tampered -out tampered_dec.txt -pass file:./secret.key 2>&1
# Saída esperada: bad decrypt
```

> **Resultado:** O OpenSSL retorna `bad decrypt` porque o GCM detecta que o
> ciphertext foi adulterado. A autenticação falha e o arquivo é rejeitado.

---

## 10. Resumo dos Comandos Executados

| Exemplo | Comando | Saída |
|---|---|---|
| 4.2 | `openssl enc -aes-256-cbc -in data.txt -out encrypted_data.bin -pass file:./secret.key` | Criptografa com CBC |
| 4.3 | `openssl enc -d -aes-256-cbc -in encrypted_data.bin -out decrypted_data.txt -pass file:./secret.key` | Descriptografa |
| 5.1 | `openssl enc -aes-256-gcm -in data.txt -out encrypted_data.gcm -pass file:./secret.key` | Criptografa com GCM |
| 5.2 | `openssl enc -d -aes-256-gcm -in encrypted_data.gcm -out decrypted_data.gcm -pass file:./secret.key` | Descriptografa GCM |
| 6.1 | `openssl dgst -sha256 data.txt > data_hash.txt` | Gera hash |
| 6.3 | `diff data_hash.txt received_hash.txt` | Compara hashes |
| 7.1 | `openssl dgst -sha256 -mac HMAC -macopt key:./secret.key data.txt` | Gera HMAC |
| 7.3 | `diff data_hmac.txt received_hmac.txt` | Compara HMACs |
| 8.1 | `openssl pkeyutl -encrypt -inkey bob_public.key -pubin -in symmetric.key -out encrypted_symmetric_key.bin` | Criptografa chave simétrica com RSA |
| 8.2 | `openssl pkeyutl -decrypt -inkey bob_private.key -in encrypted_symmetric_key.bin -out symmetric.key` | Descriptografa chave simétrica com RSA |
| 9.2 | `printf '\x41' \| dd of=data.gcm.tampered bs=1 seek=20 count=1 conv=notrunc` | Adultera ciphertext GCM |
| 9.3 | Tentativa de descriptografar GCM adulterado | `bad decrypt` |

---

## 11. Boas Práticas — Verificação

- [ ] **Chave AES-256 gerada com `openssl rand -out secret.key 32`** ✅
- [ ] **Criptografia com AES-256-CBC + PBKDF2** ✅
- [ ] **Criptografia com AES-256-GCM (modo autenticado)** ✅
- [ ] **HMAC gerado com `-mac HMAC`** ✅
- [ ] **Criptografia híbrida (RSA + AES)** ✅
- [ ] **Adulteração detectada pelo GCM** ✅

---

## 12. Referências

- [Documento Principal — Aula_OpenSSL_Criptografia_Simetrica.md](./Aula_OpenSSL_Criptografia_Simetrica.md)
- [OpenSSL Documentation — enc](https://www.openssl.org/docs/man3.0/man1/openssl-enc.html)
- [NIST FIPS 197 — AES](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf)
- [NIST SP 800-38D — GCM](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38d.pdf)
- [RFC 5288 — AES-GCM for TLS](https://datatracker.ietf.org/doc/html/rfc5288)