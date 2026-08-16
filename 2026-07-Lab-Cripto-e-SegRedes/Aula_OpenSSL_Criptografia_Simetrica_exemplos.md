# Aula — Criptografia Simétrica com OpenSSL — Exemplos e Validação

**Disciplina:** Criptografia e Segurança em Redes — SENAI
**Pré-requisitos:** OpenSSL 3.x (ex.: container `openssl:3` do Docker Hub, ou build
oficial do OpenSSL) ou máquina com Ubuntu 22.04+

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
>
> **Atenção — GCM (AEAD) e o comando `enc`:** o comando `openssl enc` **não
> suporta** modos autenticados como GCM e CCM (erro `AEAD ciphers not
> supported`). Isso é uma decisão oficial de design do OpenSSL, documentada na
> man page (`openssl-enc`). A autenticação na linha de comando é feita com o
> padrão **Encrypt-then-MAC** (CBC + HMAC), demonstrado na seção 11. O GCM
> existe e é amplamente usado — mas por **bibliotecas e protocolos** (TLS 1.3,
> LUKS, SSH), não pela ferramenta de linha de comando `enc`.

---

## 1. Objetivo

Validar todos os comandos da aula de criptografia simétrica em um ambiente real
com OpenSSL 3.x. Cada exemplo abaixo foi executado e produz a saída exata
esperada.

---

## 2. Ambiente de Execução

```bash
openssl version
OpenSSL 3.0.13 30 Jan 2024 (Library: OpenSSL 3.0.13 30 Jan 2024)
```

**Diretório de trabalho:** `/tmp/lab-simetrica`

**Para reproduzir com o container oficial (mesma versão usada aqui):**

```bash
docker run --rm -v "$PWD:/work" -w /work openssl:3 openssl version
```

> **Observação sobre distribuições Linux:** builds empacotados por distribuições
> (Debian/Ubuntu) podem exibir a mesma mensagem `AEAD ciphers not supported`
> para GCM/CCM — comportamento idêntico ao oficial. Todos os exemplos deste
> documento usam apenas o que o `enc` realmente suporta.

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
# -rw-rw-r-- 1 ubuntu ubuntu 32 Aug 16 13:54 secret.key
```

**Conteúdo em hex (exemplo real desta execução):**

```bash
xxd secret.key
# 00000000: eb0a c211 d64f 5a29 4e89 69aa 6697 da9e  .....OZ)N.i.f...
# 00000010: 5cf3 372d 640e e63b e244 0dfd 3065 f900  \.7-d..;.D..0e..
```

> **Importante:** a chave é aleatória — a sua será diferente. Nunca versione
> a chave nem a envie junto com os dados criptografados.

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
- `-pass file:./secret.key` → mesma chave usada na criptografia

### 4.4 Verificar o resultado

```bash
cat decrypted_data.txt
# Mensagem secreta: a prova esta no /tmp

diff data.txt decrypted_data.txt && echo "Arquivos idênticos" || echo "Diferentes"
# Saída esperada: Arquivos idênticos
```

---

## 5. Senha em Vez de Arquivo de Chave (PBKDF2 + Salt)

**Objetivo:** usar uma **senha** em vez de um arquivo de chave. A senha vira a
chave via PBKDF2 (seção 3.3 e historinha 6.1 do documento principal).

### 5.1 Criptografar com senha

```bash
openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt \
  -in data.txt -out data_pw.enc -pass pass:"MinhaSenhaForte!2026"
```

### 5.2 Descriptografar com a mesma senha

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -in data_pw.enc -out data_pw.dec -pass pass:"MinhaSenhaForte!2026"

diff data.txt data_pw.dec && echo "OK: senha como chave funciona"
# OK: senha como chave funciona
```

### Explicação dos componentes

- `-pass pass:"senha"` → senha informada na linha de comando (aparece em `ps`;
  para testes/scripts automatizados)
- `-pbkdf2 -iter 100000` → deriva a chave de 256 bits a partir da senha
  (PBKDF2 com 100000 iterações de SHA-256)
- `-salt` → salt aleatório de 8 bytes (sem salt, senha igual ⇒ chave igual)

### 5.3 O salt garante ciphertexts diferentes

A mesma senha e o mesmo arquivo produzem **resultados diferentes** a cada
execução (o salt muda):

```bash
openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt \
  -in data.txt -out data_pw2.enc -pass pass:"MinhaSenhaForte!2026"

sha256sum data_pw.enc data_pw2.enc
# 015f6be05da4b4ec250e452575a180f70313315ae0dfeff9fe9d501f36f01e71  data_pw.enc
# d0edab33fac4f09c09f225df03068be65e7ca8205c103fbc63c14435caafe003  data_pw2.enc
```

### 5.4 Ver os parâmetros derivados com `-P`

O `-P` imprime o salt, a chave e o IV derivados (sem gerar arquivo):

```bash
openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt \
  -in data.txt -P -pass pass:"MinhaSenhaForte!2026"
# salt=88C35B4836997E82
# key=6D6FBEAACDD190B732B9D40C0AB392CF3C1BD45108FE72C427B1EFD1270C8FE7
# iv =EABE22E60D22CBD3A62AF8D6A8D30145
```

> **Conclusão prática:** senha + PBKDF2 + salt = mesma segurança de chave para
> a CLI. Mas **nunca use senha fraca** (ver seção 6) e lembre: se a senha for
> perdida, o arquivo é irrecuperável (historinha 6.1).

---

## 6. Ataque de Dicionário — Por que Senha Fraca é Quebrada

**Objetivo:** demonstrar na prática o ataque da seção 7.3 (limitações) e da
tabela de ataques da seção 9 do documento principal.

### 6.1 Alice criptografa com senha fraca

```bash
openssl enc -aes-256-cbc -pbkdf2 -iter 1000 -salt \
  -pass pass:senha123 -in data.txt -out alvo.enc
```

> Nota: usamos `-iter 1000` para a demonstração ficar rápida — o atacante usa
> a mesma iteração que a vítima. Com `-iter 100000` o ataque é ~17× mais lento
> por tentativa (medido na seção 6.3).

### 6.2 Força bruta com wordlist

O atacante tenta cada senha da lista: se o PBKDF2 + descriptografia resultam
no arquivo original (`cmp -s`), a senha foi encontrada:

```bash
cat > wordlist.txt <<'EOF'
admin
123456
password
senha123
qwerty
EOF

while IFS= read -r pwd; do
  if openssl enc -d -aes-256-cbc -pbkdf2 -iter 1000 -salt \
       -pass "pass:$pwd" -in alvo.enc -out test.dec 2>/dev/null \
     && cmp -s data.txt test.dec; then
    echo "SENHA ENCONTRADA: $pwd"
    break
  fi
done < wordlist.txt
# SENHA ENCONTRADA: senha123
```

### 6.3 Custo por tentativa: `-iter 1000` vs `-iter 100000`

Medindo 5 tentativas com senha errada (mesma máquina):

```bash
# iter 1000   -> 5 tentativas: 23 ms
# iter 100000 -> 5 tentativas: 397 ms
```

Com `-iter 100000` cada tentativa fica ~17× mais cara. Em um ataque real com
milhões de senhas (wordlists de bilhões de entradas + GPUs), a diferença é
decisiva.

> **Mitigação (documento principal, seção 9):** use senha **longa e aleatória**
> + `-pbkdf2 -iter 100000`. Senhas curtas/dicionário (`123456`, `senha123`)
> são quebradas em segundos.

---

## 7. ECB vs CBC — Por que o ECB é Proibido

**Objetivo:** reproduzir o fenômeno da historinha 6.2 (vazamento por padrões):
blocos iguais de texto plano geram blocos iguais de ciphertext no ECB.

### 7.1 Criar um arquivo com blocos repetidos

```bash
head -c 1024 /dev/zero | tr '\0' 'A' > pattern.txt
# 1024 bytes = 64 blocos idênticos de 16 bytes ("AAAAAAAAAAAAAAAA")
```

### 7.2 Criptografar com ECB e com CBC

```bash
openssl enc -aes-256-ecb -pbkdf2 -iter 100000 \
  -in pattern.txt -out pattern.ecb -pass file:./secret.key

openssl enc -aes-256-cbc -pbkdf2 -iter 100000 \
  -in pattern.txt -out pattern.cbc -pass file:./secret.key
```

### 7.3 Comparar os primeiros bytes

```bash
xxd -l 64 pattern.ecb
# 00000000: 5361 6c74 6564 5f5f 6cfb 7b5c 7fec 7554  Salted__l.{\..uT
# 00000010: 834c 098f bf8e 864f 92c2 d22a 879c 0cee  .L.....O...*....
# 00000020: 834c 098f bf8e 864f 92c2 d22a 879c 0cee  .L.....O...*....
# 00000030: 834c 098f bf8e 864f 92c2 d22a 879c 0cee  .L.....O...*....

xxd -l 64 pattern.cbc
# 00000000: 5361 6c74 6564 5f5f adf2 c7a5 9029 70e7  Salted__.....)p.
# 00000010: 51e8 7ae5 6895 a09b a37f 3664 411e 21fe  Q.z.h.....6dA.!.
# 00000020: eeea 51a6 7fab 3d6a 6d03 312d 7e9d 20bb  ..Q...=jm.1-~. .
# 00000030: 4f1f 90fe ee04 7134 46d0 73fc 381e aa54  O.....q4F.s.8..T
```

**ECB:** o bloco `834c098fbf8e864f92c2d22a879c0cee` se repete em todo o
arquivo. **CBC:** nenhum bloco se repete.

### 7.4 Contar blocos únicos de 16 bytes

```bash
# ECB (contagem de cada bloco):
xxd -p -c 4096 pattern.ecb | fold -w 32 | sort | uniq -c | sort -rn
#      64 834c098fbf8e864f92c2d22a879c0cee   <- 64 blocos de dados IDÊNTICOS
#       1 b4ec38c9a750bec137b8a26b2fc2f549   <- bloco de padding (PKCS#7)
#       1 53616c7465645f5f6cfb7b5c7fec7554   <- cabeçalho Salted__ + salt

# CBC (total de blocos únicos):
xxd -p -c 4096 pattern.cbc | fold -w 32 | sort | uniq | wc -l
# 66   <- todos os 66 blocos diferentes
```

> **Conclusão:** com ECB, um atacante que vê o ciphertext aprende os padrões do
> conteúdo (imagens com área de cor sólida, headers de arquivos, etc. — ver
> historinha 6.2). **Nunca use ECB.** Use CBC (com HMAC — seção 11) ou GCM a
> nível de biblioteca.

---

## 8. AES-256-CTR — Bit-Flip Silencioso

**Objetivo:** mostrar que modos **stream** (CTR) sem autenticação permitem
adulteração **silenciosa**: 1 bit alterado no ciphertext = 1 bit alterado no
texto plano, sem nenhum erro.

### 8.1 Criptografar com CTR

```bash
openssl enc -aes-256-ctr -pbkdf2 -iter 100000 \
  -in data.txt -out data.ctr -pass file:./secret.key
```

### 8.2 Ver o primeiro byte do ciphertext

O arquivo começa com o cabeçalho `Salted__` + 8 bytes de salt (16 bytes). O
primeiro byte do ciphertext está no offset 16:

```bash
xxd -s 16 -l 8 data.ctr
# 00000010: 32ca 306c 542a 0074                      2.0lT*.t
```

### 8.3 Adulterar 1 bit e descriptografar

```bash
# Inverter o bit menos significativo do 1º byte (0x32 -> 0x33)
cp data.ctr data.ctr.flip
printf '\x33' | dd of=data.ctr.flip bs=1 seek=16 count=1 conv=notrunc 2>/dev/null

openssl enc -d -aes-256-ctr -pbkdf2 -iter 100000 \
  -in data.ctr.flip -out data.ctr.dec -pass file:./secret.key

cat data.ctr.dec
# Lensagem secreta: a prova esta no /tmp
```

**Sem nenhum erro!** O `M` virou `L` (1 bit) e o arquivo foi descriptografado
normalmente. Comparação byte a byte:

```bash
cmp -l data.txt data.ctr.dec
# 1 115 114     <- posição 1: 0x4D ('M') virou 0x4C ('L')
```

> **Por que:** no CTR, o ciphertext é o texto plano XOR com um keystream.
> Inverter 1 bit do ciphertext inverte exatamente 1 bit do texto plano. Sem
> autenticação, **ninguém percebe**. Com CBC, o mesmo 1 bit corrompe o bloco
> inteiro + 1 bit do bloco seguinte (seção 11) — mas também sem erro.
>
> **Lição:** confidencialidade (CTR/CBC) ≠ integridade. Para detectar
> adulteração é obrigatório um MAC/HMAC (seção 11) ou um modo autenticado
> (GCM, em bibliotecas).

---

## 9. Verificação de Integridade com Hash

**Objetivo:** garantir que o arquivo não foi alterado após a criptografia.

### 9.1 Alice gera o hash do arquivo original

```bash
openssl dgst -sha256 data.txt > data_hash.txt
cat data_hash.txt
# SHA2-256(data.txt)= 761fdf13cfd172b7a84422e4b5d23f1eec0de269a390dc91fb92e604657e6e1c
```

### 9.2 Alice criptografa e envia

```bash
# (envia: data_hash.txt + encrypted_data.bin + secret.key)
```

### 9.3 Bob descriptografa e verifica

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

### 9.4 Testar adulteração

```bash
echo "ALTERADO" >> received_data.txt
openssl dgst -sha256 received_data.txt > received_hash.txt
diff data_hash.txt received_hash.txt && echo "Integridade confirmada" || echo "ARQUIVO ADULTERADO"
# Saída esperada: ARQUIVO ADULTERADO
```

> **Limitação:** o hash (sem chave) garante integridade, mas **qualquer pessoa**
> pode recalcular o hash após adulterar. Para impedir isso, o HMAC (seção 10)
> usa uma chave secreta.

---

## 10. HMAC (Autenticação + Integridade)

**Objetivo:** além da criptografia, Alice quer garantir que apenas quem tem a
chave pode ter gerado o arquivo.

### 10.1 Alice gera o HMAC

```bash
openssl dgst -sha256 -mac HMAC -macopt key:./secret.key data.txt > data_hmac.txt
cat data_hmac.txt
# HMAC-SHA2-256(data.txt)= 0ee40dc02d286cb0675ccd4444e192dfb0f402332ed09fd705b2ccc8ec1b5e79
```

### 10.2 Alice criptografa e envia

```bash
# (envia: data.txt + encrypted_data.bin + data_hmac.txt)
```

### 10.3 Bob descriptografa e verifica o HMAC

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

> **Diferença para o hash:** o HMAC é calculado **com a chave secreta** — o
> atacante não consegue gerar um HMAC válido para o arquivo adulterado.

---

## 11. Detecção de Adulteração na Prática — Encrypt-then-MAC

**Objetivo:** implementar na CLI o que o GCM faz em bibliotecas: **autenticar o
ciphertext**. Padrão: **Encrypt-then-MAC** (criptografar e depois calcular o
HMAC do ciphertext).

### 11.1 Por que não usar `-aes-256-gcm`?

O OpenSSL recusa (decisão oficial — ver man page `openssl-enc`):

```bash
openssl enc -aes-256-gcm -pbkdf2 -iter 100000 \
  -in data.txt -out gcm.bin -pass file:./secret.key
# enc: AEAD ciphers not supported
# enc: Use -help for summary.
```

> O motivo documentado: no `enc` o fluxo de saída começa antes de a tag de
> autenticação poder ser validada, e a reutilização de IV/nonce causaria
> falhas catastróficas de segurança. Para bulk encryption autenticada, a
> própria documentação recomenda `openssl cms` (híbrido com certificados) —
> e para a CLI pura, o padrão abaixo.

### 11.2 Alice criptografa e calcula o HMAC do ciphertext

```bash
# 1. Criptografar com CBC
openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt \
  -in data.txt -out msg.cbc -pass file:./secret.key

# 2. HMAC SOBRE O CIPHERTEXT (Encrypt-then-MAC)
openssl dgst -sha256 -mac HMAC -macopt key:./secret.key msg.cbc > msg.cbc.hmac
cat msg.cbc.hmac
# HMAC-SHA2-256(msg.cbc)= e8eeab8c88a4bd97a3f56f68e6cf25a25dde2b60647824142eb44f6b5bba501f

# (envia: msg.cbc + msg.cbc.hmac)
```

### 11.3 O atacante adultera o ciphertext

```bash
cp msg.cbc msg.cbc.flip
printf '\x85' | dd of=msg.cbc.flip bs=1 seek=20 count=1 conv=notrunc 2>/dev/null
```

### 11.4 Bob descriptografa o arquivo adulterado (silenciosamente!)

O CBC **não reclama** — ele apenas devolve texto corrompido:

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -in msg.cbc.flip -out msg.dec -pass file:./secret.key
# (nenhum erro de descriptografia!)

diff data.txt msg.dec
# 1c1
# < Mensagem secreta: a prova esta no /tmp
# ---
# > ..OH..k...#PR4:: a qrova esta no /tmp
```

O que aconteceu (comportamento clássico do CBC):
- **Bloco 0** ("Mensagem secreta") virou lixo — o AES tem efeito avalanche: 1
  bit alterado no ciphertext altera ~metade do bloco no plaintext
- **Bloco 1** sofreu exatamente o bit-flip: "p**r**ova" → "p**q**rova"
- **Padding intacto** → nenhum erro de padding → descriptografia "bem-sucedida"

### 11.5 Bob verifica o HMAC e detecta

```bash
openssl dgst -sha256 -mac HMAC -macopt key:./secret.key msg.cbc.flip > msg.cbc.flip.hmac

diff msg.cbc.hmac msg.cbc.flip.hmac
# 1c1
# < HMAC-SHA2-256(msg.cbc)= e8eeab8c88a4bd97a3f56f68e6cf25a25dde2b60647824142eb44f6b5bba501f
# ---
# > HMAC-SHA2-256(msg.cbc.flip)= ecb0507ff684b3bdcc04fcbaf8bc444dcabc7c6459af9d555fea6668522c4fb0

# (HMAC diferente => arquivo adulterado => descartar)
```

### 11.6 Resumo do comportamento dos modos

| Modo | Adulteração detectada? | Comportamento ao adulterar |
|---|---|---|
| ECB | Não | Bloco corrompido (garbage) |
| CBC | Não (sem HMAC) | Bloco vira lixo + 1 bit no seguinte — sem erro |
| CTR | Não (sem HMAC) | 1 bit flips no plaintext — sem erro |
| CBC + HMAC (EtM) | **Sim** | HMAC não confere → descartar |
| GCM (bibliotecas/TLS) | **Sim** | Tag inválida → rejeita automaticamente |

---

## 12. Criptografia Híbrida (AES + RSA)

**Objetivo:** Alice quer enviar um arquivo **confidencial** para Bob usando
AES (rápido) + RSA (seguro). O AES protege os dados; o RSA protege a chave
AES. (Seções 5 e 8.6 do documento principal.)

### 12.1 Fluxo completo

**Passo 1 — Alice gera chave simétrica e criptografa o arquivo:**

```bash
openssl rand -out symmetric.key 32

openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt \
  -in data.txt -out encrypted_data.bin -pass file:./symmetric.key
```

**Passo 2 — Alice criptografa a chave simétrica com a chave pública de Bob:**

```bash
# Gerar par de chaves RSA de Bob
openssl genpkey -algorithm RSA -out bob_private.key -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in bob_private.key -out bob_public.key

# Criptografar a chave simétrica com a chave pública de Bob (RSA-OAEP)
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
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -in encrypted_data.bin -out decrypted_data.txt -pass file:./symmetric.key
```

### 12.2 Verificar

```bash
diff data.txt decrypted_data.txt && echo "Criptografia híbrida funcionou" || echo "Falhou"
# Saída esperada: Criptografia híbrida funcionou
```

> **Nota de autenticação:** para o envio completo (confidencialidade +
> integridade + autenticidade), combine com HMAC (seção 11) ou assine com a
> chave privada de Alice (`openssl pkeyutl -sign`).

---

## 13. Backup Criptografado (tar + CBC + HMAC)

**Objetivo:** criptografar um diretório inteiro em um único arquivo (caso de
uso "Backup criptografado" da seção 5 e historinha 6.1 do documento principal).

### 13.1 Preparar o diretório

```bash
mkdir -p backup_src/docs
echo "Relatorio financeiro Q3 2026" > backup_src/docs/relatorio.txt
echo "Backup de configuracao v2" > backup_src/docs/config.txt
```

### 13.2 Criptografar com tar + openssl em pipe

```bash
tar -czf - -C backup_src docs | openssl enc -aes-256-cbc -pbkdf2 -iter 100000 \
  -salt -pass pass:"BackupSeguro!2026" -out backup.tgz.enc

ls -la backup.tgz.enc
# -rw-rw-r-- 1 ubuntu ubuntu 240 Aug 16 13:54 backup.tgz.enc
```

**Explicação dos componentes:**

- `tar -czf -` → empacota e compacta para a **saída padrão** (`-` = stdout)
- `|` → pipe direto para o OpenSSL (nada sensível é gravado em disco)
- `openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt` → criptografa o fluxo
- `-pass pass:"BackupSeguro!2026"` → senha forte do backup

### 13.3 Calcular o HMAC do backup (integridade)

```bash
openssl dgst -sha256 -mac HMAC -macopt key:./secret.key backup.tgz.enc > backup.tgz.hmac
# (guarde backup.tgz.hmac junto com a senha, separado do arquivo criptografado)
```

### 13.4 Restaurar

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -pass pass:"BackupSeguro!2026" -in backup.tgz.enc -out backup.tgz

tar -xzf backup.tgz

diff -r backup_src/docs docs && echo "Backup restaurado: diretórios idênticos"
# Backup restaurado: diretórios idênticos
```

### 13.5 Senha errada = dados inacessíveis

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -pass pass:"senhaErrada" -in backup.tgz.enc -out backup_errado.tgz
# bad decrypt
```

> **Historinha 6.1:** se a senha for perdida, o backup vira lixo. Armazene a
> senha em cofre (ex.: gerenciador de senhas) e considere usar ferramentas
> dedicadas (age, gpg, `openssl cms`) que implementam autenticação (AEAD)
> corretamente e evitam os erros de configuração possíveis com a CLI pura.

---

## 14. Resumo dos Comandos Executados

| Exemplo | Comando | Saída |
|---|---|---|
| 3 | `openssl rand -out secret.key 32` | Chave AES-256 aleatória |
| 4.2 | `openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -in data.txt -out encrypted_data.bin -pass file:./secret.key` | Criptografa com CBC |
| 4.3 | `openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in encrypted_data.bin -out decrypted_data.txt -pass file:./secret.key` | Descriptografa |
| 5.1 | `openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -in data.txt -out data_pw.enc -pass pass:"MinhaSenhaForte!2026"` | Criptografa com senha (PBKDF2) |
| 5.4 | `openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -in data.txt -P -pass pass:"..."` | Mostra salt, chave e IV derivados |
| 6.2 | Loop `openssl enc -d ... -pass "pass:$pwd"` + `cmp -s` | Força bruta com wordlist → `senha123` |
| 7.2 | `openssl enc -aes-256-ecb/-cbc ...` em `pattern.txt` | ECB repete blocos; CBC não |
| 8.1 | `openssl enc -aes-256-ctr -pbkdf2 -iter 100000 -in data.txt -out data.ctr -pass file:./secret.key` | Criptografa em modo stream |
| 8.3 | `printf '\x33' \| dd of=data.ctr.flip bs=1 seek=16 count=1 conv=notrunc` + decrypt | Bit-flip silencioso (M→L) |
| 9.1 | `openssl dgst -sha256 data.txt > data_hash.txt` | Gera hash SHA-256 |
| 10.1 | `openssl dgst -sha256 -mac HMAC -macopt key:./secret.key data.txt` | Gera HMAC |
| 11.2 | `openssl dgst -sha256 -mac HMAC -macopt key:./secret.key msg.cbc` | HMAC do ciphertext (EtM) |
| 11.4 | `diff data.txt msg.dec` | CBC adulterado decodifica sem erro (texto corrompido) |
| 11.5 | `diff msg.cbc.hmac msg.cbc.flip.hmac` | HMAC não confere → adulteração detectada |
| 12 | `openssl pkeyutl -encrypt/-decrypt ... rsa_padding_mode:oaep` + AES-CBC | Criptografia híbrida |
| 13.2 | `tar -czf - -C backup_src docs \| openssl enc -aes-256-cbc ... -out backup.tgz.enc` | Backup criptografado |
| 13.3 | `openssl dgst -sha256 -mac HMAC -macopt key:./secret.key backup.tgz.enc` | HMAC do backup |
| 13.5 | `openssl enc -d ... -pass pass:"senhaErrada"` | `bad decrypt` |

---

## 15. Boas Práticas — Verificação

- [ ] **Chave AES-256 gerada com `openssl rand -out secret.key 32`** ✅
- [ ] **Criptografia com AES-256-CBC + PBKDF2 + salt** ✅
- [ ] **Senha forte + `-pbkdf2 -iter 100000`** (senha fraca quebrada em segundos) ✅
- [ ] **ECB nunca usado** (blocos idênticos vazam padrões) ✅
- [ ] **CTR/stream sem autenticação = bit-flip silencioso** ✅
- [ ] **HMAC gerado com `-mac HMAC` sobre o ciphertext (Encrypt-then-MAC)** ✅
- [ ] **Adulteração detectada pelo HMAC** ✅
- [ ] **Criptografia híbrida (RSA + AES) validada** ✅
- [ ] **Backup com tar + AES + HMAC restaurado e verificado** ✅
- [ ] **GCM/CCM via `enc` rejeitados pela própria ferramenta** (usar EtM ou `openssl cms`) ✅

---

## 16. Referências

- [Documento Principal — Aula_OpenSSL_Criptografia_Simetrica.md](./Aula_OpenSSL_Criptografia_Simetrica.md)
- [OpenSSL Documentation — enc (inclui nota oficial sobre AEAD/GCM)](https://docs.openssl.org/3.0/man1/openssl-enc/)
- [OpenSSL Documentation — cms (recomendado para criptografia autenticada)](https://docs.openssl.org/3.0/man1/openssl-cms/)
- [OpenSSL GitHub Issue #12220 — Why AEAD is not supported in command enc](https://github.com/openssl/openssl/issues/12220)
- [NIST FIPS 197 — AES](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf)
- [NIST SP 800-38A — Block Cipher Modes of Operation (ECB, CBC, CTR...)](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38a.pdf)
- [NIST SP 800-38D — GCM](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38d.pdf)
- [RFC 5288 — AES-GCM for TLS](https://datatracker.ietf.org/doc/html/rfc5288)
- [OWASP — Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
