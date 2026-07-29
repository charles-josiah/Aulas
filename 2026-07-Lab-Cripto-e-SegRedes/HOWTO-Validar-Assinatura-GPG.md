# HOWTO — Validar Assinatura Digital GPG

## Laboratório de Criptografia e Segurança em Redes — 2026/02

**Curso:** Superior de Tecnologia em Segurança Cibernética  
**Docente:** Charles Alandt  
**Chave GPG:** `1299 BD01 7A0E 77B2 3585  0DEE C880 FC22 2955 FFA3`

---

## Índice

1. [O que é uma assinatura digital GPG?](#1-o-que-é-uma-assinatura-digital-gpg)
2. [O que foi feito?](#2-o-que-foi-feito)
3. [Pré-requisitos](#3-pré-requisitos)
4. [Passo a passo: validar a assinatura](#4-passo-a-passo-validar-a-assinatura)
5. [Comandos rápidos (copia e cola)](#5-comandos-rápidos-copia-e-cola)
6. [Entendendo o resultado](#6-entendendo-o-resultado)
7. [Para saber mais](#7-para-saber-mais)

---

## 1. O que é uma assinatura digital GPG?

Uma assinatura digital comprova **autenticidade** e **integridade** de um arquivo:

- **Autenticidade:** confirma que o autor (quem tem a chave privada) realmente assinou o arquivo
- **Integridade:** garante que o arquivo **não foi alterado** depois da assinatura

Funciona como um "carimbo digital" que qualquer pessoa pode verificar usando a chave pública do autor.

---

## 2. O que foi feito?

Neste laboratório, o **README.md** foi assinado digitalmente com a chave GPG do docente:

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

## 3. Pré-requisitos

- **GPG instalado** (GnuPG)
  - Linux: `sudo apt install gnupg` ou `sudo dnf install gnupg2`
  - macOS: `brew install gnupg`
  - Windows: [Gpg4win](https://www.gpg4win.org/)
- **Conexão com internet** para baixar os arquivos do GitHub
- **Chave pública do professor** importada no seu keyring

---

## 4. Passo a passo: validar a assinatura

### 4.1 — Baixar os arquivos

```bash
# Baixar o arquivo original
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/README.md

# Baixar a assinatura
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/README.md.asc

# Baixar a chave pública do professor
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/senai-public-key.asc
```

### 4.2 — Importar a chave pública

```bash
gpg --import senai-public-key.asc
```

Saída esperada:

```
gpg: key 1299BD017A0E77B235850DEEC880FC222955FFA3: public key "Charles Alandt <charles.alandt@edu.sc.senai.br>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

### 4.3 — Verificar a assinatura

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

## 5. Comandos rápidos (copia e cola)

```bash
# 1. Baixar tudo
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/README.md
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/README.md.asc
curl -O https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/senai-public-key.asc

# 2. Importar a chave pública
gpg --import senai-public-key.asc

# 3. Verificar a assinatura
gpg --verify README.md.asc README.md
```

---

## 6. Entendendo o resultado

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

## 7. Para saber mais

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
| **Verificar assinatura** | `gpg --verify arquivo.asc arquivo` |
| **Assinar arquivo** | `gpg --armor --detach-sign arquivo` |
| **Criptografar** | `gpg --encrypt --recipient email arquivo` |
| **Descriptografar** | `gpg --decrypt arquivo.gpg` |

---

**Elaborado por:** Prof. Charles Alandt — SENAI/SC  
**Disciplina:** Criptografia e Segurança em Redes  
**Data:** 29/07/2026
