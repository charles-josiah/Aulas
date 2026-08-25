# Workshop Prático: Criptografia e Assinatura Digital com GPG

## Disciplina: Criptografia e Segurança em Redes — 2026/02

**Curso:** Superior de Tecnologia em Segurança Cibernética  
**Docente:** Charles Alandt  
**Chave GPG:** `1299 BD01 7A0E 77B2 3585  0DEE C880 FC22 2955 FFA3`

---

## Índice

1. [Usabilidade da chave GPG](#1-usabilidade-da-chave-gpg)
2. [O que é uma assinatura digital GPG?](#2-o-que-é-uma-assinatura-digital-gpg)
3. [O que foi feito?](#3-o-que-foi-feito)
4. [Pré-requisitos](#4-pré-requisitos)
5. [Passo a passo: validar a assinatura](#5-passo-a-passo-validar-a-assinatura)
6. [Comandos rápidos (copia e cola)](#6-comandos-rápidos-copia-e-cola)
7. [Entendendo o resultado](#7-entendendo-o-resultado)
8. [Exercício prático: descriptografar e validar a mensagem de boas-vindas](#8-exercício-prático-descriptografar-e-validar-a-mensagem-de-boas-vindas)
9. [Para saber mais](#9-para-saber-mais)

---

## 1. Usabilidade da chave GPG

A criptografia de chave pública (GPG/PGP) tem diversas aplicações práticas no mundo real. Abaixo, 5 usabilidades essenciais:

### 🔏 1.1 — Assinatura de documentos e contratos

Substitui a assinatura de próprio punho em ambientes digitais. Um contrato assinado com GPG tem **validade jurídica** (MP 2.200-2 / ICP-Brasil) e pode ser verificado por qualquer parte envolvida.

**Exemplo:** Empresa A assina um PDF de contrato e envia para Empresa B, que valida a assinatura com a chave pública da Empresa A.

### 🔐 1.2 — Criptografia de e-mails e comunicações

O GPG permite criptografar e-mails de ponta a ponta usando o padrão **OpenPGP**, integrado a clientes como Thunderbird (Enigmail), Outlook (Gpg4win) e Mutt.

**Exemplo:** Jornalistas e ativistas usam GPG para proteger comunicações sensíveis contra interceptação.

### 🛡️ 1.3 — Autenticação em commits Git (GitHub/GitLab)

Desenvolvedores usam chaves GPG para **assinar commits e tags** no Git. O GitHub exibe um selo ✅ "Verified" quando o commit é assinado por uma chave GPG válida.

**Exemplo:** Projetos open source como Linux Kernel e Debian exigem commits assinados para garantir que o código veio de fontes confiáveis.

### 📦 1.4 — Verificação de integridade de pacotes e softwares

Distribuições Linux e repositórios de software distribuem **checksums assinados** com GPG para que usuários verifiquem se um pacote não foi adulterado durante o download.

**Exemplo:** Ao baixar uma ISO do Ubuntu, o arquivo `SHA256SUMS` é assinado com a chave GPG oficial da Canonical — o usuário valida antes de instalar.

### 🏛️ 1.5 — Autenticação de documentos oficiais e cartórios

O **ITI (Instituto Nacional de Tecnologia da Informação)** — ICP-Brasil regula a infraestrutura de chaves públicas no Brasil. Certificados A1/A3 são usados para:

- Assinar notas fiscais eletrônicas (NF-e)
- Autenticar documentos em cartórios digitais (e-Notariado)
- Protocolizar petições em tribunais (e-SAJ, PJe)

**Exemplo:** Um advogado assina digitalmente uma petição com certificado A3 e protocola no sistema PJe do tribunal — sem precisar ir ao fórum.

> **Resumo:** a chave GPG/PGP é a base da **infraestrutura de chave pública (PKI)** e está presente em contratos, e-mails, código-fonte, software livre e sistemas governamentais.

---

## 2. O que é uma assinatura digital GPG?

Uma assinatura digital comprova **autenticidade** e **integridade** de um arquivo:

- **Autenticidade:** confirma que o autor (quem tem a chave privada) realmente assinou o arquivo
- **Integridade:** garante que o arquivo **não foi alterado** depois da assinatura

Funciona como um "carimbo digital" que qualquer pessoa pode verificar usando a chave pública do autor.

---

## 3. O que foi feito?

Assinamos digitalmente o **README.md** usando nossa **chave privada GPG**. O GPG calcula um **hash** (resumo criptográfico) do arquivo original, cifra esse hash com nossa chave privada e gera o arquivo de assinatura (`.asc`). Quem receber o arquivo pode usar nossa **[chave pública](https://raw.githubusercontent.com/charles-josiah/Aulas/refs/heads/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/senai-public-key.asc)** para decifrar o hash, recalcular o hash do arquivo recebido e comparar os dois: se forem iguais, o arquivo é autêntico e não foi alterado.

```
┌─────────────────────────────────────┐
│  README.md  (arquivo original)      │
└──────────┬──────────────────────────┘
           │
           ▼
    gpg --armor --detach-sign README.md
           │
           ▼
┌─────────────────────────────────────┐
│  README.md.asc  (assinatura)        │
└─────────────────────────────────────┘
```

### Comando utilizado:

```bash
gpg --armor --detach-sign README.md
```

| Parâmetro | Significado |
|-----------|-------------|
| `--armor` | Gera saída em formato texto (ASCII-armored) |
| `--detach-sign` | Cria um arquivo de assinatura **separado** do arquivo original |

### Resultado:

- `README.md` — arquivo original (não foi modificado)
- `README.md.asc` — arquivo de assinatura digital (~833 bytes)

---

## 4. Pré-requisitos

- **GPG instalado** (GnuPG)
  - Linux: `sudo apt install gnupg` ou `sudo dnf install gnupg2`
  - macOS: `brew install gnupg`
  - Windows: [Gpg4win](https://www.gpg4win.org/)
- **Conexão com internet** para baixar os arquivos do GitHub
- **Chave pública do professor** importada no seu keyring

---

## 5. Passo a passo: validar a assinatura

### 5.1 — Baixar os arquivos

```bash
# Baixar o arquivo original
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/README.md

# Baixar a assinatura
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/README.md.asc

# Baixar a chave pública do professor
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/senai-public-key.asc
```

### 5.2 — Importar a chave pública

```bash
gpg --import senai-public-key.asc
```

Saída esperada:

```
gpg: key 1299BD017A0E77B235850DEEC880FC222955FFA3: public key "Charles Alandt <charles.alandt@edu.sc.senai.br>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

### 5.3 — Verificar a assinatura

```bash
gpg --verify README.md.asc README.md
```

Saída esperada (**assinatura válida**):

```
gpg: Signature made Wed Jul 29 13:23:00 2026 -03
gpg:                using RSA key 1299BD017A0E77B235850DEEC880FC222955FFA3
gpg: Good signature from "Charles Alandt <charles.alandt@edu.sc.senai.br>"
```

⚠️ Se aparecer `WARNING: This key is not certified with a trusted signature!` — é normal para chaves não assinadas por terceiros. Significa que você confia na chave manualmente.

---

## 6. Comandos rápidos (copia e cola)

```bash
# 1. Baixar tudo
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/README.md
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/README.md.asc
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/senai-public-key.asc

# 2. Importar a chave pública
gpg --import senai-public-key.asc

# 3. Verificar a assinatura
gpg --verify README.md.asc README.md
```

---

## 7. Entendendo o resultado

### ✅ "Good signature" — Assinatura válida

O arquivo `README.md` é **autêntico** (foi assinado pelo professor) e **não foi alterado**.

### ❌ "BAD signature" — Assinatura inválida

Se a mensagem for `BAD signature`, significa que o arquivo foi **alterado** ou a assinatura é **falsa**. Não confie no arquivo.

### ⚠️ WARNING sobre confiança

```
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
```

Isso **não invalida** a assinatura. Apenas significa que você não definiu manualmente o nível de confiança da chave. Para eliminar o aviso:

```bash
gpg --edit-key charles.alandt@edu.sc.senai.br
# Dentro do GPG, digite: trust → 5 → quit
```

---

## 8. Exercício prático: descriptografar e validar a mensagem de boas-vindas

O arquivo `mensagem_de_boas_vindas.md` foi **criptografado** e **assinado** com a chave GPG do professor. O arquivo original foi removido do repositório — só quem tem a **chave privada** pode descriptografar, mas **qualquer um** pode verificar a assinatura.

### Arquivos no repositório

| Arquivo | Descrição |
|---------|-----------|
| `mensagem_de_boas_vindas.md.gpg` | Mensagem criptografada (só o professor descriptografa) |
| `mensagem_de_boas_vindas.md.sig` | Assinatura digital destacada (qualquer um valida) |

---

### 8.1 — Baixar os arquivos

```bash
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/mensagem_de_boas_vindas.md.gpg
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/mensagem_de_boas_vindas.md.sig
```

---

### 8.2 — Verificar a assinatura (todos podem fazer)

Com a chave pública do professor importada:

```bash
# Importar a chave pública (se ainda não fez)
gpg --import senai-public-key.asc

# Verificar a assinatura .sig contra o .gpg
gpg --verify mensagem_de_boas_vindas.md.sig mensagem_de_boas_vindas.md.gpg
```

Saída esperada:

```
gpg: Signature made Wed Jul 29 13:43:00 2026 -03
gpg:                using RSA key 1299BD017A0E77B235850DEEC880FC222955FFA3
gpg: Good signature from "Charles Alandt <charles.alandt@edu.sc.senai.br>"
```

> **Nota:** validamos a assinatura **do arquivo `.gpg`**, não do texto original. Isso prova que o arquivo criptografado é autêntico e não foi adulterado.

---

### 8.3 — Descriptografar (só quem tem a chave privada)

```bash
gpg --decrypt mensagem_de_boas_vindas.md.gpg
```

O GPG pedirá a **senha da chave privada** e exibirá o conteúdo original no terminal.

Para salvar em arquivo:

```bash
gpg --decrypt mensagem_de_boas_vindas.md.gpg > mensagem_de_boas_vindas.md
```

---

### Fluxo completo

```
Exemplo do fluxo que realizamos em aula:

┌──────────────────┐      ┌───────────────────┐      ┌───────────────┐
│  Original (.md)  │ ───> │ Criptografado.gpg │ ───> │ Descriptografar│
│  (removido do    │      │ + assinatura.sig  │      │ + validar sig │
│   repositório)   │      │   (no GitHub)     │      │  (qualquer um)│
└──────────────────┘      └───────────────────┘      └───────────────┘
```

---

## 9. Para saber mais

### Como criar sua própria chave GPG

```bash
gpg --full-generate-key
```

### Como assinar um arquivo

```bash
# Assinatura destacada (gera .asc separado)
gpg --armor --detach-sign arquivo.txt

# Assinatura inline (incorporada ao arquivo)
gpg --armor --clearsign arquivo.txt
```

### Como criptografar um arquivo

```bash
gpg --encrypt --recipient charles.alandt@edu.sc.senai.br arquivo.txt
```

### Como descriptografar

```bash
gpg --decrypt arquivo.txt.gpg
```

---

## Resumo

| Operação | Comando |
|----------|---------|
| **Importar chave pública** | `gpg --import chave.asc` |
| **Verificar assinatura (.sig)** | `gpg --verify arquivo.sig arquivo.gpg` |
| **Assinar arquivo** | `gpg --armor --detach-sign arquivo` |
| **Criptografar para alguém** | `gpg --encrypt --recipient email arquivo` |
| **Descriptografar** | `gpg --decrypt arquivo.gpg` |

---

**Elaborado por:** Prof. Charles Alandt — SENAI/SC  
**Disciplina:** Criptografia e Segurança em Redes  
**Data:** 29/07/2026

---
📊 **Visualizações:** ![hits](https://hits.sh/github.com/charles-josiah/Aulas/2026-07-Lab-Cripto-e-SegRedes/Workshops/00-Criptografia_e_Assinatura_Digital_com_GPG/README.md.svg)
