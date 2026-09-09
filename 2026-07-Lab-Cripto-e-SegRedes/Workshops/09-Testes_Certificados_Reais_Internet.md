# Testes com Certificados Reais da Internet

Guia rápido de comandos Linux para baixar, inspecionar e validar **certificados TLS reais da internet** — o mesmo fluxo que um navegador faz ao acessar um site com 🔒.

> Complemento do **Workshop 07** (Etapa 10). Todos os comandos foram validados em 2026-09 no Ubuntu 26.04 com OpenSSL 3.5.5.

---

## 1. Baixar a cadeia completa de um site

Quando você acessa `https://google.com`, o servidor envia a **cadeia de certificados**: o certificado do site (folha), a CA intermediária e, às vezes, uma raiz extra.

```bash
mkdir -p ~/lab-cert-publicos && cd ~/lab-cert-publicos

echo | openssl s_client -connect google.com:443 -servername google.com -showcerts 2>/dev/null \
  | sed -n '/BEGIN CERT/,/END CERT/p' > cadeia.pem

grep -c "BEGIN CERTIFICATE" cadeia.pem   # quantos certificados vieram?
```

**Resultado esperado (google.com):**

```text
3
```

**Explicação:**
- `-showcerts`: mostra **todos** os certificados da cadeia (sem ele, só o do site).
- `sed -n '/BEGIN CERT/,/END CERT/p'`: extrai apenas os blocos `-----BEGIN CERTIFICATE-----` ... `-----END CERTIFICATE-----`.
- `grep -c`: conta quantos certificados a cadeia tem.

---

## 2. Separar os certificados da cadeia

```bash
awk 'BEGIN{n=0} /BEGIN CERT/{n++} {print > "cert-" n ".pem"}' cadeia.pem
ls -la cert-*.pem
```

Cada `cert-N.pem` é um certificado, na ordem em que o servidor enviou: `cert-1` é o do site, `cert-2` a intermediária, `cert-3` a raiz (quando enviada).

---

## 3. Inspecionar cada certificado

```bash
for i in 1 2 3; do
  echo "--- cert-$i ---"
  openssl x509 -in cert-$i.pem -noout -subject -issuer -dates
done
```

**Resultado esperado (google.com, validado em 2026-09):**

```text
--- cert-1 ---
subject=CN=*.google.com
issuer=C=US, O=Google Trust Services, CN=WR2
notBefore=Aug 10 08:37:35 2026 GMT
notAfter=Nov  2 08:37:34 2026 GMT
--- cert-2 ---
subject=C=US, O=Google Trust Services, CN=WR2
issuer=C=US, O=Google Trust Services LLC, CN=GTS Root R1
notBefore=Dec 13 09:00:00 2023 GMT
notAfter=Feb 20 14:00:00 2029 GMT
--- cert-3 ---
subject=C=US, O=Google Trust Services LLC, CN=GTS Root R1
issuer=C=BE, O=GlobalSign nv-sa, OU=Root CA, CN=GlobalSign Root CA
notBefore=Jun 19 00:00:42 2020 GMT
notAfter=Jan 28 00:00:42 2028 GMT
```

**Repare nos padrões:**
- A folha (`cert-1`) tem validade curta (~90 dias) — prática moderna de segurança.
- A intermediária (`cert-2`) dura anos e é assinada pela raiz.
- A raiz (`cert-3`) é **cross-assinada** pela GlobalSign (ver seção 5).

---

## 4. Conferir a cadeia contra o cofre de CAs do sistema

O Linux guarda as CAs confiáveis em `/etc/ssl/certs`. É contra esse cofre que o navegador valida a cadeia.

```bash
# Folha + intermediária, usando o cofre do sistema:
openssl verify -CApath /etc/ssl/certs -untrusted cert-2.pem cert-1.pem
```

**Resultado esperado:**

```text
cert-1.pem: OK
```

**Explicação:**
- `-CApath /etc/ssl/certs`: usa o cofre de CAs confiáveis do sistema (o mesmo do navegador).
- `-untrusted cert-2.pem`: fornece a intermediária como "não confiável por si só" — ela só vale se a cadeia fechar até uma raiz do cofre.
- `cert-1.pem`: o certificado a ser validado (a folha).

---

## 5. O caso da raiz cross-assinada (error 20 que "não importa")

Se você tentar validar a raiz `cert-3.pem` sozinha contra o cofre:

```bash
openssl verify -CApath /etc/ssl/certs cert-3.pem
```

**Resultado esperado:**

```text
C = US, O = Google Trust Services LLC, CN = GTS Root R1
error 20 at 1 depth lookup: unable to get local issuer certificate
error cert-3.pem: verification failed
```

**Por que isso acontece e por que não importa:**
- O `cert-3` é a **GTS Root R1** assinada pela **GlobalSign Root CA** (cross-assinatura).
- A GlobalSign Root CA **não está** no cofre do Ubuntu — mas a **GTS Root R1 está** (arquivo `GTS_Root_R1.pem`).
- O navegador confia na GTS Root R1 **diretamente**; o `cert-3` é só um atalho para sistemas antigos. Por isso a cadeia da seção 4 valida com `OK` mesmo assim.

**Confira no cofre:**

```bash
ls /etc/ssl/certs/ | grep -i gts        # GTS_Root_R1.pem presente
ls /etc/ssl/certs/ | grep -i globalsign # várias raízes GlobalSign (R3/R4/R5/R6/E46/R46)...
ls /etc/ssl/certs/ | grep "GlobalSign_Root_CA.pem"  # ...mas a "GlobalSign Root CA" (R1) NÃO está
```

O cofre do Ubuntu tem várias raízes GlobalSign, mas **não** a `GlobalSign Root CA` (R1) que assinou a cross-assinatura da GTS Root R1 — por isso o `error 20` na seção anterior.

---

## 6. Testar outros sites

```bash
# GitHub — raiz Sectigo (ECC):
echo | openssl s_client -connect github.com:443 -servername github.com -showcerts 2>/dev/null \
  | grep -E "s:|i:" | head -6

# SENAI — hospedado no Azure (Microsoft), CDN:
echo | openssl s_client -connect www.senai.br:443 -servername www.senai.br -showcerts 2>/dev/null \
  | grep -E "s:|i:" | head -6
```

**Resultado esperado (validado em 2026-09):**

```text
# github.com — cadeia com raiz ECC (Sectigo):
 0 s:CN=github.com
   i:C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36
 1 s:C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36
   i:C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication Root E46
 2 s:C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication Root E46
   i:C=US, ST=New Jersey, L=Jersey City, O=The USERTRUST Network, CN=USERTrust ECC Certification Authority

# www.senai.br — site num CDN (Azure); o certificado é do provedor, não do site:
 0 s:C=US, ST=WA, L=Redmond, O=Microsoft Corporation, CN=*.web.core.windows.net
   i:C=US, O=Microsoft Corporation, CN=Microsoft TLS G2 RSA CA OCSP 10
 1 s:C=US, O=Microsoft Corporation, CN=Microsoft TLS G2 RSA CA OCSP 10
   i:C=US, O=Microsoft Corporation, CN=Microsoft TLS RSA Root G2
 2 s:C=US, O=Microsoft Corporation, CN=Microsoft TLS RSA Root G2
   i:C=US, O=DigiCert Inc, OU=www.digicert.com, CN=DigiCert Global Root G2
```

**Análise — o que cada caso ensina:**
- **github.com:** raiz **ECC** (`Sectigo Public Server Authentication Root E46`) — nem toda cadeia usa RSA.
- **www.senai.br:** o certificado é `*.web.core.windows.net` da **Microsoft** — o site está hospedado no Azure (CDN/cloud). O certificado é do **provedor de infraestrutura**, não do dono do site. Isso é comum em sites que usam CDN ou cloud hosting.

---

## 7. Comandos rápidos de inspeção (qualquer certificado)

```bash
# Campos principais:
openssl x509 -in cert.pem -noout -subject -issuer -dates

# Nomes cobertos (SAN):
openssl x509 -in cert.pem -noout -ext subjectAltName

# O nome acessado está coberto?
openssl x509 -in cert.pem -noout -checkhost www.exemplo.com.br

# Impressão digital (fingerprint):
openssl x509 -in cert.pem -noout -fingerprint -sha256

# Texto completo (todos os campos):
openssl x509 -in cert.pem -text | less
```

---

## 8. Códigos de erro do `openssl verify` (cola rápida)

| Código | Significado | Quando aparece |
|--------|-------------|----------------|
| `0` | OK | Cadeia válida até uma raiz confiável |
| `10` | Certificado expirado | Fora da validade (`-dates`) |
| `18` | Autoassinado não confiável | issuer = subject e não está no cofre |
| `19` | Autoassinado na cadeia | Uma CA da cadeia é autoassinada e não confiável |
| `20` | Issuer não encontrado | A CA que assinou não está no cofre (cadeia quebrada) |
| `62` | Hostname mismatch | O nome acessado não está no SAN (`-checkhost`) |

---

## 9. Ver o certificado no navegador (conferência final)

1. Acesse `https://www.exemplo.com.br`.
2. Clique no cadeado 🔒 na barra de endereço.
3. Clique em "Conexão segura" → "O certificado é válido" (ou similar).
4. Explore os campos: emissor, validade, nomes (SAN).

**Compare com o laboratório:** o `subject`, `issuer`, `dates` e `SAN` que você inspecionou com `openssl x509` são exatamente os mesmos campos que o navegador mostra.

---

<p align="right">
  <sub>Disciplina de Criptografia e Segurança em Redes — 2026/07</sub><br>
  <sub>Charles Alandt</sub>
</p>