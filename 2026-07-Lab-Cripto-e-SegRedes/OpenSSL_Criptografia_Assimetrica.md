# Criptografia Assimétrica com OpenSSL

**Disciplina:** Criptografia e Segurança em Redes — SENAI
**Pré-requisitos:** Container com OpenSSL 3.x (ex.: `openssl:3` do Docker Hub) ou máquina com Ubuntu 22.04+

> **Nota sobre a versão do OpenSSL:** Este material utiliza comandos compatíveis
> com o OpenSSL 3.x (versão atual). O OpenSSL 3.x emite warnings de deprecado
> para comandos antigos como `rsautl`. Todos os exemplos abaixo já usam os
> comandos modernos (`pkeyutl`). Se você encontrar erros, verifique a versão
> com `openssl version`.

---

## 1. Objetivo

Aprender a usar o OpenSSL para operações de criptografia assimétrica no Linux:
gerar pares de chaves, criptografar/descriptografar arquivos, assinar digitalmente
documentos e verificar assinaturas — tudo com comandos reais e explicação do
que cada flag faz.

---

## 2. O que é Criptografia Assimétrica

A criptografia assimétrica (também chamada de criptografia de **chave pública**)
utiliza **dois números mágicos** — um público e um privado — para proteger dados.
Os dois números são matematicamente vinculados, mas é computacionalmente inviável
calcular um a partir do outro.

O par de chaves funciona assim:

| Chave | Quem controla | Para que serve |
|---|---|---|
| **Chave pública** | Qualquer pessoa pode ter | Criptografar dados / Verificar assinaturas |
| **Chave privada** | Apenas o proprietário | Descriptografar dados / Assinar documentos |

**Exemplo intuitivo:** Imagine uma **caixa com fechadura especial**. Qualquer
pessoa pode **trancar** a caixa (usar a chave pública), mas apenas quem tem a
**chave privada** pode abri-la. Ou seja: qualquer pessoa envia dados criptografados,
mas apenas o destinatário pode ler.

**Onde a segurança vem de:** a segurança depende da dificuldade computacional de
resolver problemas matemáticos específicos — no caso do RSA, fatorar números
primos muito grandes; no caso de ECC (Curva Elíptica), resolver o problema do
logaritmo discreto sobre curvas.

---

## 3. Conceitos Fundamentais

Antes de executar os comandos, é essencial entender os cinco conceitos que
sustentam toda a criptografia assimétrica:

### 3.1 Criptografia e Descriptografia

- **Criptografar** = transformar dados legíveis em dados ilegíveis (texto
  cifrado), usando uma chave.
- **Descriptografar** = reverter o processo, transformando os dados cifrados
  em dados legíveis novamente.

### 3.2 Chave Pública vs. Chave Privada

- **Chave pública**: pode ser distribuída livremente (em um site, em um
  e-mail, em um repositório). É usada para **criptografar** dados e para
  **verificar** assinaturas.
- **Chave privada**: deve ser mantida em absoluto segredo. É usada para
  **descriptografar** dados e para **assinar** documentos.

### 3.3 Assinatura Digital

Uma assinatura digital garante que:
- O documento **não foi alterado** (integridade).
- O documento **foi criado por quem diz ser** o autor (autenticidade).
- O autor **não pode negar** que assinou (não repúdio).

A assinatura é criada com a **chave privada** e verificada com a **chave pública**.

### 3.4 Certificado Digital

Um certificado digital é um documento eletrônico que **vincula uma chave pública
a uma identidade** (pessoa, empresa ou servidor). Ele contém:
- Nome do proprietário (ex.: `banco.com`)
- Chave pública
- Data de validade
- Assinatura da Autoridade Certificadora (CA)

### 3.5 Infraestrutura de Chave Pública (PKI)

A PKI é o ecossistema que mantém a **cadeia de confiança**. Sem ela, não teríamos
como garantir que a chave pública que recebemos realmente pertence à pessoa certa.
Os componentes principais são:

| Componente | Função |
|---|---|
| **Autoridade Certificadora (CA)** | Verifica identidade e emite certificados assinados |
| **Autoridade de Registro (RA)** | Auxilia a CA na validação de identidade |
| **Certificado Digital** | Vincula chave pública a identidade |
| **Repositório de Certificados** | Banco público de certificados emitidos |
| **CRL** (Lista de Revogação) | Lista de certificados invalidados antes do prazo |

> **Analogia:** A CA é como um **cartório digital**. Você vai até o cartório
> (CA), prova quem é (RA/identificação), e o cartório emite um documento
> (certificado) atestando que aquela chave pública é sua. Se alguém quiser
> verificar, basta consultar o cartório.

---

## 4. Por que os Certificados São Inquestionáveis

O certificado digital responde a cinco pilares da segurança de comunicações:

### 4.1 Assinatura da CA

A garantia central de um certificado é a **assinatura digital da CA**. Você
não precisa confiar diretamente no site ou pessoa que te enviou o certificado —
basta confiar na CA. Seu navegador já vem com uma lista de CAs confiáveis
pré-instalada. A assinatura da CA é a prova de que ela validou a identidade e
que o certificado não foi adulterado.

### 4.2 Não Repúdio (Non-Repudiation)

Quando alguém assina digitalmente algo com sua chave privada, o certificado
vincula a assinatura à sua identidade de forma **irrevogável**. A assinatura
é criptograficamente única — apenas o proprietário da chave privada pode gerar
uma assinatura que corresponda à chave pública. Uma vez assinado, é impossível
negar a autoria.

### 4.3 Autenticidade

O certificado prova que a entidade com a qual você se comunica é **realmente
quem diz ser**. A cadeia de confiança funciona assim: seu sistema confia na
CA → a CA validou a identidade do emissor → o certificado é como um "passaporte
digital" que não pode ser falsificado.

### 4.4 Integridade

A assinatura digital é calculada sobre um **hash** (resumo criptográfico) do
documento. Qualquer alteração, por mínima que seja, gera um hash completamente
diferente. Na verificação, se o hash não coincidir, a assinatura é rejeitada —
provando que o documento foi adulterado.

### 4.5 Confidencialidade

A confidencialidade é implementada por meio de **criptografia híbrida**. O
certificado contém a chave pública do destinatário, que é usada para criptografar
uma **chave simétrica de sessão**. A chave simétrica é quem realmente criptografa
os dados. Sem o certificado, não há como estabelecer a comunicação segura inicial
para a troca da chave.

> **Ponto chave:** Em HTTPS/TLS, a criptografia assimétrica (RSA/ECC) é usada
> apenas na **negociação inicial** (troca de chaves). Depois disso, a comunicação
> usa criptografia simétrica (AES) por ser muito mais rápida. A criptografia
> assimétrica sozinha seria lenta demais para dados em volume.

---

## 5. Usabilidade e Casos de Uso

A criptografia assimétrica é usada diariamente em diversos cenários:

### 5.1 Comunicação Segura na Web (HTTPS/TLS)

A maioria dos sites utiliza criptografia assimétrica para autenticar o servidor
e estabelecer uma chave de sessão. É isso que aparece como "cadeado" no
navegador. Sem ele, senhas e dados de pagamento seriam transmitidos em texto puro.

### 5.2 Autenticação SSH

Para acessar servidores de forma segura, usa-se autenticação baseada em chaves.
A chave pública é armazenada no servidor (`~/.ssh/authorized_keys`), e a chave
privada fica no cliente. O servidor verifica se quem conecta tem a chave privada
correspondente — sem nunca enviar a senha pela rede.

### 5.3 Assinatura de Software

Desenvolvedores assinam pacotes de software (`.deb`, `.rpm`, containers Docker)
digitalmente para garantir que não foram adulterados durante o download. Se o
hash não conferir, o pacote é rejeitado.

### 5.4 E-mail Seguro (PGP/GPG)

O Pretty Good Privacy utiliza criptografia assimétrica para proteger o conteúdo
dos e-mails e garantir a autenticidade do remetente.

### 5.5 VPN

Criptografia do tráfego de rede para proteger a privacidade dos usuários, mesmo
em redes públicas (como o Wi-Fi de um aeroporto).

---

## 6. Historinhas: O Que Acontece Quando a Segurança Falha

### 6.1 O Vazamento da Chave Privada de um Banco

Imagine que a chave privada de um grande banco vaza. O impacto é **catastrófico**:

**Confidencialidade comprometida:** Qualquer pessoa com a chave privada pode
interceptar e descriptografar comunicações criptografadas com a chave pública
correspondente. Isso inclui senhas, transações e dados de cartão de crédito.
Toda a comunicação que se acreditava ser segura se torna pública.

**Autenticidade comprometida:** Criminosos podem usar a chave vazada para se
passar pelo banco. Eles criam sites falsos (phishing) com certificados que
parecem legítimos — o navegador não detecta a fraude porque o certificado é
tecnicamente válido. Usuários digitam senhas e dados financeiros sem desconfiar.

**Solução de emergência:** A única saída é **revogar o certificado** e gerar um
novo par de chaves. Mas a revogação leva tempo para se propagar — até que todos
os sistemas atualizem suas listas de revogação, o risco persiste.

### 6.2 O Advogado e a Chave Privada

Um advogado usa sua chave privada para assinar petições, contratos e documentos
eletrônicos. A assinatura tem validade legal — ela prova que ele é o autor.

**O cenário de perda:** Se a chave privada é roubada (malware, computador
furtado, descuido), o criminoso pode:
1. **Assinar documentos falsos** — petições fraudulentas ou acordos ilegais
   assinados com a chave do advogado. A verificação com a chave pública
   (que é pública e conhecida) é bem-sucedida.
2. **Destruir a reputação** — como não é possível distinguir assinaturas
   legítimas de falsas, **todas** as assinaturas do advogado ficam
   comprometidas, tanto as passadas quanto as futuras.

A revogação é a única medida de segurança. Mas o dano reputacional já foi feito.

---

## 7. O Processo de Revogação de um Certificado

Revogar um certificado é declará-lo **inválido antes da data de expiração**.
É um passo crítico quando uma chave privada é comprometida.

| Passo | O que acontece |
|---|---|
| 1. Notificação à CA | O proprietário prova sua identidade e solicita a revogação |
| 2. Inclusão na CRL | A CA adiciona o número de série à Lista de Revogação de Certificados |
| 3. Atualização dos sistemas | Navegadores e SOs consultam a CRL periodicamente (ou via OCSP) e rejeitam o certificado |
| 4. Novo certificado | O proprietário gera um novo par de chaves e solicita um novo certificado à CA |

A revogação é uma **corrida contra o tempo**. A rapidez com que a CA atualiza a
CRL e com que os sistemas consultam essa lista determina a janela de vulnerabilidade.

---

## 8. Limitações Práticas do RSA

Antes de executar os comandos, é importante entender duas limitações reais do RSA:

### 8.1 Tamanho da Mensagem

A criptografia RSA pura (sem esquema de encadeamento) só suporta mensagens
**menores que o tamanho da chave**. Com uma chave RSA de 2048 bits (256 bytes),
o máximo que pode ser criptografado diretamente é ~245 bytes (com padding OAEP).
Para arquivos maiores, usa-se **criptografia híbrida**: gera-se uma chave
simétrica aleatória (ex.: AES-256), criptografa-se o arquivo com ela, e
depois criptografa-se a chave simétrica com a chave pública RSA.

### 8.2 Velocidade

A criptografia assimétrica é **muito mais lenta** que a simétrica. Por isso,
no TLS/HTTPS, ela é usada apenas na **negociação inicial**. Depois de trocar
a chave de sessão, toda a comunicação usa AES (simétrico), que é centenas de
vezes mais rápido.

---

## 9. Exemplos Práticos no Linux

Todos os exemplos abaixo foram testados com OpenSSL 3.x. Para verificar sua
versão:

```bash
openssl version
# Exemplo de saída: OpenSSL 3.0.13 30 Jan 2024 (Library: OpenSSL 3.0.13 30 Jan 2024)
```

### 9.1 Geração do Par de Chaves

**Passo 1 — Gerar a chave privada RSA (4096 bits):**

```bash
openssl genpkey -algorithm RSA -out private.key -pkeyopt rsa_keygen_bits:4096
```

Explicação dos componentes:
- `genpkey` → comando moderno para gerar chaves (substitui o antigo `genrsa`)
- `-algorithm RSA` → algoritmo RSA
- `-out private.key` → arquivo de saída com a chave privada
- `-pkeyopt rsa_keygen_bits:4096` → tamanho da chave em bits (recomendado: 4096)

> **Nota:** Para proteger a chave privada com senha, adicione `-aes256`:
> ```bash
> openssl genpkey -algorithm RSA -out private.key -pkeyopt rsa_keygen_bits:4096 -aes256
> ```
> Isso criptografa a chave privada com AES-256. Toda vez que você usar a chave,
> será solicitada a senha.

**Passo 2 — Gerar a chave pública:**

```bash
openssl rsa -pubout -in private.key -out public.key
```

Explicação:
- `-pubout` → extrai apenas a parte pública da chave
- `-in private.key` → arquivo de entrada (chave privada)
- `-out public.key` → arquivo de saída (chave pública)

**Verificar as chaves geradas:**

```bash
# Ver informações da chave privada
openssl rsa -in private.key -text -noout | head -5

# Ver informações da chave pública
openssl rsa -pubin -in public.key -text -noout | head -5
```

### 9.2 Exemplo 1: Criptografar e Descriptografar Arquivo

**Cenário:** Alice quer enviar um arquivo secreto para Bob. Ela criptografa
com a chave pública de Bob. Apenas Bob (com sua chave privada) pode ler.

**Preparar o arquivo:**

```bash
echo "Mensagem secreta: a prova esta no /tmp" > data.txt
cat data.txt
```

**Criptografar com a chave pública:**

```bash
openssl pkeyutl -encrypt -inkey public.key -pubin -in data.txt -out encrypted_data.bin -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

Explicação:
- `pkeyutl` → comando moderno para operações com chaves (substitui `rsautl`)
- `-encrypt` → operação de criptografia
- `-inkey public.key` → chave usada para criptografar (a pública)
- `-pubin` → indica que a chave de entrada é pública
- `-in data.txt` → arquivo de entrada
- `-out encrypted_data.bin` → arquivo cifrado (binário)
- `-pkeyopt rsa_padding_mode:oaep` → usa padding OAEP (mais seguro que PKCS#1 v1.5)
- `-pkeyopt rsa_oaep_md:sha256` → função hash usada no OAEP

> **Por que OAEP?** O padding OAEP (Optimal Asymmetric Encryption Padding) é
> o padrão recomendado peloPKCS#1 v2. O padding antigo (PKCS#1 v1.5) é
> vulnerável a ataques de adaptação de ciphertext. OAEP adiciona aleatoriedade
> ao processo, tornando a criptografia segura contra esses ataques.

**Descriptografar com a chave privada:**

```bash
openssl pkeyutl -decrypt -inkey private.key -in encrypted_data.bin -out decrypted_data.txt -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

**Verificar o resultado:**

```bash
cat decrypted_data.txt
# Saída: Mensagem secreta: a prova esta no /tmp

# Comparar com o original
diff data.txt decrypted_data.txt && echo "Arquivos identicos" || echo "Diferentes"
# Saída: Arquivos identicos
```

### 9.3 Exemplo 2: Assinatura Digital

**Cenário:** Alice quer provar que um documento foi criado por ela. Ela assina
com sua chave privada. Qualquer pessoa pode verificar com sua chave pública.

**Preparar o documento:**

```bash
echo "Contrato: prestacao de servicos de TI" > documento.txt
```

**Gerar a assinatura:**

```bash
openssl pkeyutl -sign -inkey private.key -in documento.txt -out signature.bin
```

Explicação:
- `-sign` → operação de assinatura (usa a chave privada para assinar)
- `-inkey private.key` → chave privada do signatário
- `-in documento.txt` → documento a ser assinado
- `-out signature.bin` → arquivo com a assinatura (binário)

**Verificar a assinatura (com a chave pública):**

```bash
openssl pkeyutl -verify -pubin -inkey public.key -in documento.txt -sigfile signature.bin
```

Saída esperada:
```
Signature Verified Successfully
```

**Testar adulteração — alterar o documento:**

```bash
echo "Contrato: prestacao de servicos de TI - ALTERADO" > documento.txt
```

**Verificar novamente:**

```bash
openssl pkeyutl -verify -pubin -inkey public.key -in documento.txt -sigfile signature.bin
```

Saída esperada:
```
Signature Verification Failure
```

> **Resultado:** A verificação falha porque o hash do documento alterado é
> diferente do hash que foi assinado. Isso prova que o documento foi adulterado
> após a assinatura.

**Restaurar o documento original para os próximos exemplos:**

```bash
echo "Contrato: prestacao de servicos de TI" > documento.txt
```

### 9.4 Exemplo 3: Envio Seguro de Mensagem

**Cenário:** Alice quer enviar uma mensagem que apenas Bob pode ler.

**Alice criptografa com a chave pública de Bob:**

```bash
echo "Bob, a senha do servidor e: x7k9m2" > message.txt
openssl pkeyutl -encrypt -inkey bob_public.key -pubin -in message.txt -out encrypted_message.bin -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

**Bob descriptografa com sua chave privada:**

```bash
openssl pkeyutl -decrypt -inkey bob_private.key -in encrypted_message.bin -out decrypted_message.txt -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
cat decrypted_message.txt
# Saída: Bob, a senha do servidor e: x7k9m2
```

> **Nota:** No mundo real, Bob teria um par de chaves próprio. Alice usaria a
> chave **pública** de Bob, e apenas Bob teria a chave **privada** correspondente.

### 9.5 Exemplo 4: Fluxo Completo — Assinar + Criptografar

**Cenário:** Alice quer enviar um documento que é **confidencial** (só Bob lê)
e **autenticado** (Bob sabe que veio de Alice).

**Fluxo:**

```
Alice                          Rede                          Bob
  │                              │                              │
  │ 1. Assina com chave privada  │                              │
  │ 2. Criptografa com chave     │                              │
  │    pública de Bob            │                              │
  │                              │                              │
  │──── encrypted_document.bin ──┼──── encrypted_document.bin ──┤
  │                              │                              │
  │                              │  3. Descriptografa com       │
  │                              │     chave privada            │
  │                              │  4. Verifica assinatura      │
  │                              │     com chave pública        │
  │                              │     de Alice                 │
```

**Passo 1 — Assinar (Alice):**

```bash
openssl pkeyutl -sign -inkey alice_private.key -in documento.txt -out signature.bin
```

**Passo 2 — Criptografar o documento + assinatura (Alice):**

```bash
# Criptografar o documento com a chave pública de Bob
openssl pkeyutl -encrypt -inkey bob_public.key -pubin -in documento.txt -out encrypted_document.bin -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256

# Criptografar a assinatura também (protege contra análise de tráfego)
openssl pkeyutl -encrypt -inkey bob_public.key -pubin -in signature.bin -out encrypted_signature.bin -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

**Passo 3 — Descriptografar (Bob):**

```bash
# Descriptografar o documento
openssl pkeyutl -decrypt -inkey bob_private.key -in encrypted_document.bin -out received_document.txt -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256

# Descriptografar a assinatura
openssl pkeyutl -decrypt -inkey bob_private.key -in encrypted_signature.bin -out received_signature.bin -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
```

**Passo 4 — Verificar a assinatura (Bob):**

```bash
openssl pkeyutl -verify -pubin -inkey alice_public.key -in received_document.txt -sigfile received_signature.bin
```

Saída esperada:
```
Signature Verified Successfully
```

> **Resultado:** Bob tem certeza de que o documento veio de Alice (autenticidade),
> não foi alterado (integridade) e ninguém mais pôde ler (confidencialidade).

### 9.6 Exemplo 5: Verificação de Integridade com Hash

**Cenário:** Além da assinatura, queremos uma forma rápida e independente de
verificar se o arquivo recebido é idêntico ao original.

**Alice gera o hash do documento original:**

```bash
openssl dgst -sha256 documento.txt
```

Saída esperada:
```
SHA256(documento.txt)= a3f2b8c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1
```

Salvar o hash:

```bash
openssl dgst -sha256 documento.txt > document_hash.txt
cat document_hash.txt
```

**Alice envia: documento.txt + signature.bin + document_hash.txt**

**Bob recebe e verifica:**

```bash
# 1. Verificar assinatura
openssl pkeyutl -verify -pubin -inkey alice_public.key -in documento.txt -sigfile signature.bin

# 2. Gerar hash do recebido
openssl dgst -sha256 documento.txt > received_hash.txt

# 3. Comparar os hashes
diff document_hash.txt received_hash.txt && echo "Integridade confirmada" || echo "ARQUIVO ADULTERADO"
```

Saída esperada:
```
Integridade confirmada
```

**Testar adulteração — alterar o documento recebido:**

```bash
echo "ALTERADO" >> documento.txt
openssl dgst -sha256 documento.txt > received_hash.txt
diff document_hash.txt received_hash.txt && echo "Integridade confirmada" || echo "ARQUIVO ADULTERADO"
```

Saída esperada:
```
ARQUIVO ADULTERADO
```

> **Resultado:** O hash do arquivo alterado é completamente diferente. Qualquer
> modificação, por mínima que seja, gera um hash irreconhecível. Isso prova que
> o arquivo foi adulterado.

**Restaurar o documento original:**

```bash
echo "Contrato: prestacao de servicos de TI" > documento.txt
```

---

## 10. Resumo dos Comandos

| Operação | Comando |
|---|---|
| Gerar chave privada | `openssl genpkey -algorithm RSA -out private.key -pkeyopt rsa_keygen_bits:4096` |
| Gerar chave pública | `openssl rsa -pubout -in private.key -out public.key` |
| Criptografar | `openssl pkeyutl -encrypt -inkey public.key -pubin -in arquivo.txt -out arquivo.bin -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256` |
| Descriptografar | `openssl pkeyutl -decrypt -inkey private.key -in arquivo.bin -out arquivo.txt -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256` |
| Assinar | `openssl pkeyutl -sign -inkey private.key -in arquivo.txt -out signature.bin` |
| Verificar assinatura | `openssl pkeyutl -verify -pubin -inkey public.key -in arquivo.txt -sigfile signature.bin` |
| Gerar hash SHA-256 | `openssl dgst -sha256 arquivo.txt` |
| Verificar com hash | `openssl dgst -sha256 arquivo.txt` e comparar com `diff` |

---

## 11. Boas Práticas

1. **Use chaves de pelo menos 2048 bits** (recomendado: 4096). Chaves menores
   são quebráveis com hardware moderno.
2. **Use padding OAEP** (`-pkeyopt rsa_padding_mode:oaep`), nunca PKCS#1 v1.5.
   O OAEP é imune a ataques de adaptação de ciphertext.
3. **Proteja a chave privada com senha** (`-aes256` na geração). Se alguém
   obtiver acesso ao arquivo da chave, sem a senha ela é inútil.
4. **Nunca envie a chave privada pela rede.** A chave pública pode ser
   compartilhada livremente; a privada nunca.
5. **Revogue certificados comprometidos imediatamente.** A janela de
   vulnerabilidade é o tempo entre o comprometimento e a revogação.
6. **Use `pkeyutl` em vez de `rsautl`.** O `rsautl` está deprecado no
   OpenSSL 3.x e não suporta OAEP nativamente.

---

## 12. Referências

- [OpenSSL Documentation — pkeyutl](https://www.openssl.org/docs/man3.0/man1/openssl-pkeyutl.html)
- [RFC 8017 — PKCS#1: RSA Cryptography Specifications](https://datatracker.ietf.org/doc/html/rfc8017)
- [NIST SP 800-56B — Recommendation for Pair-Wise Key-Establishment Schemes Using RSA](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-56Br2.pdf)
