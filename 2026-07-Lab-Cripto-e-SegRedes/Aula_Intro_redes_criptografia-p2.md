# Aula Introdutória de Redes e Criptografia — Parte 2: Visão Avançada 

> **Público-alvo:** Estudantes que já dominam o básico (Parte 1) e profissionais iniciando em Infra/Sec.
> **Foco:** O que *realmente* acontece no fio, por que falha, e como defender.
> **Pré-requisito:** Ter lido a [Parte 1 - Conceitos Fundamentais](Aula_Intro_redes_criptografia.md).

---

## 1. Visão de Redes: O "Encanamento" Invisível

### 1.1 Anatomia Real de um Pacote (Headers na Prática)
Esqueça a analogia da carta. Veja o que *realmente* vai no fio (captura real `tcpdump -n -vv`):

```text
### Camada 2 (Ethernet) - 14 bytes
Dst MAC: aa:bb:cc:dd:ee:ff  | Src MAC: 11:22:33:44:55:66 | Type: 0x0800 (IPv4)

### Camada 3 (IPv4) - 20 bytes (mínimo)
Version: 4 | IHL: 5 | DSCP: 0x2E (EF/VoIP) | Total Len: 1500
ID: 0x1a2b | Flags: DF (Don't Fragment) | TTL: 64
Protocol: 6 (TCP) | Header Checksum: 0x7a3f
Src IP: 192.168.1.45 | Dst IP: 8.8.8.8

### Camada 4 (TCP) - 20 bytes (mínimo)
Src Port: 54321 | Dst Port: 443 (HTTPS)
Seq: 1001 | Ack: 1 | Flags: [SYN] | Window: 65535 (WS=256) | Options: [MSS=1460, SACK_PERM, TS]
```

**O que o Sênior olha primeiro:**
1.  **Flags TCP:** `SYN`, `SYN/ACK`, `ACK`, `FIN`, `RST` (estado da conexão).
2.  **Flags IP:** `DF` (Don't Fragment) → indica PMTUD ativo.
3.  **TTL/Hop Limit:** Detecta loops (`TTL=1`) ou distância (`TTL=64` Linux, `128` Windows).
4.  **Portas Efêmeras (>49152):** Identifica o lado cliente.

---

### 1.2 ARP / NDP: A Ponte Invisível (L2 ↔ L3)
O IP **não** chega ao MAC sozinho.
- **IPv4 (ARP):** `Who has 192.168.1.1? Tell 192.168.1.45` → Broadcast L2. Resposta Unicast.
- **IPv6 (NDP/NS/NA):** `Neighbor Solicitation` (Multicast Solicited-Node) → `Neighbor Advertisement`.
- **Ataque Clássico:** **ARP Spoofing / NDP Spoofing** → MITM na LAN. Defesa: **DAI (Dynamic ARP Inspection)**, **RA Guard**, **DHCP Snooping**.

---

### 1.3 MTU, Fragmentação & PMTUD (O "Pacote Grande" Quebra a VPN)
- **MTU Ethernet Padrão:** 1500 bytes.
- **Overhead Comum:** IPsec (ESP) ~60-80 bytes, GRE 24B, VXLAN 50B, PPPoE 8B.
- **Bit `DF` (Don't Fragment):** Se pacote > MTU do caminho e `DF=1` → Roteador descarta + envia **ICMP Type 3 Code 4 (Fragmentation Needed / Packet Too Big)**.
- **PMTUD (Path MTU Discovery):** Host descobre MTU do caminho diminuindo tamanho até passar.
- **Problema Real:** Firewall bloqueia ICMP "Packet Too Big" → **Black Hole PMTUD** (VPN conecta, handshake TLS OK, mas transferência de arquivo/website grande trava).
- **Solução Moderna:** **PLPMTUD (Packetization Layer PMTUD - RFC 8899)** no QUIC/TCP (não depende de ICMP).

---

### 1.4 NAT Real: Além da Tradução Simples
| Tipo | Direção | Uso Comum | Armadilha |
| :--- | :--- | :--- | :--- |
| **SNAT (Masquerade)** | Outbound (LAN→WAN) | Acesso internet | Porta efêmera colide? (PAT/NAPT resolve). |
| **DNAT (Port Forward)** | Inbound (WAN→LAN) | Servidor público | Hairpin NAT (acessar IP público de dentro). |
| **1:1 NAT** | Bidirecional | IP Público dedicado | IP público escasso (IPv4 exhaustion). |
| **CGNAT (Carrier Grade NAT)** | ISP → Cliente | IPv4 escasso | **Quebra:** P2P, VoIP, VPN site-to-site, port forwarding. **Solução:** IPv6, PCP, STUN/TURN. |

---

### 1.5 IPv6 na Prática (Não é "Futuro")
- **Endereçamento:** `2001:db8::/32` (docs), `fe80::/10` (Link-Local), `ff02::1` (All Nodes).
- **SLAAC (Stateless):** `fe80::` + `Prefix` (RA) + `EUI-64` ou **Privacy Extensions (RFC 4941/7217)** → Endereço temporário/aleatório (privacidade).
- **DHCPv6 (Stateful):** Prefixo delegado (PD) + Opções (DNS, NTP).
- **Sem NAT (Idealmente):** End-to-end restaurado. Firewall **Stateful** continua obrigatório (IPv6 ≠ Inseguro).

---

## 2. Visão de Segurança: Mentalidade "Assume Breach"

### 2.1 Threat Modeling Rápido (STRIDE) — Antes de Codificar/Configurar
| Ameaça | Pergunta Chave | Contramedida Básica |
| :--- | :--- | :--- |
| **S**poofing | "Quem é você?" | Autenticação forte (mTLS, FIDO2, Certificados). |
| **T**ampering | "Alteraram meus dados?" | Integridade (HMAC, AEAD, Assinaturas, Git signed commits). |
| **R**epudiation | "Negam que fizeram?" | Logs imutáveis (WORM, SIEM, Blockchain/Transparency Logs). |
| **I**nformation Disclosure | "Vazou?" | Criptografia (TLS 1.3, AES-GCM, Age), Minimização de dados. |
| **D**enial of Service | "Aguenta a carga?" | Rate limiting, WAF, Anycast/CDN, Backpressure/Backoff. |
| **E**levation of Privilege | "Viraram admin?" | Least Privilege, RBAC/ABAC, `sudo` auditado, `no-new-privs`. |

---

### 2.2 PKI Real: A Cadeia de Confiança (Não é Só "Ter Certificado")
```text
Root CA (Offline, Air-gapped, HSM)
   │  Assina (Basic Constraints: CA:TRUE, Key Usage: keyCertSign, cRLSign)
   ▼
Intermediate CA (Online, HSM, Políticas)
   │  Assina (Name Constraints, EKU: serverAuth/clientAuth)
   ▼
Leaf Certificate (Servidor/Cliente)
   ├── CN / SAN (Subject Alternative Name): DNS:app.exemplo.com
   ├── Key Usage: digitalSignature, keyEncipherment
   ├── Extended Key Usage: serverAuth (1.3.6.1.5.5.7.3.1)
   ├── Validade: 90 dias (Let's Encrypt) / 1 ano (Pago)
   ├── CT Logs (Certificate Transparency): Obrigatório p/ público
   └── Revogação: OCSP Stapling (rápido) / CRL (legado)
```
**Checklist de Validação (O que o cliente/browser faz):**
1.  Cadeia válida até Root confiável (Trust Store do SO/Browser).
2.  Não expirado / Não revogado (OCSP Stapling preferido).
3.  `SAN` bate com hostname acessado (`CN` legado ignorado).
4.  `Key Usage` / `EKU` compatíveis com uso (serverAuth).
5.  Algoritmo forte (RSA ≥ 2048 / ECDSA P-256+ / Ed25519).
6.  **CT Logs** presentes (SCTs válidos).

---

### 2.3 TLS Hardening Checklist (Configuração de Produção)
```nginx
# nginx exemplo (aplicável a Apache, HAProxy, Nginx, Envoy, Go, Java, .NET)
ssl_protocols TLSv1.2 TLSv1.3;           # 1.0/1.1/SSLv3 PROIBIDOS
ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers on;            # Necessário p/ TLS 1.2
ssl_ecdh_curve X25519:prime256v1:secp384r1; # Curvas modernas

# Forward Secrecy Obrigatório (ECDHE) - já default no 1.3
ssl_session_timeout 1h;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;                 # Tickets quebram PFS se chave roubada

# HSTS (Força HTTPS)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# OCSP Stapling (Performance + Privacidade)
ssl_stapling on;
ssl_stapling_verify on;
resolver 1.1.1.1 8.8.8.8 valid=300s;
resolver_timeout 5s;

# Security Headers (Defesa em Profundidade)
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```
**Cipher Suites Permitidas (Ordem de Preferência):**
1. `TLS_AES_256_GCM_SHA384` (TLS 1.3, AES-NI)
2. `TLS_CHACHA20_POLY1305_SHA256` (TLS 1.3, Sem AES-NI / Mobile)
3. `TLS_AES_128_GCM_SHA256` (TLS 1.3, Performance)
4. `ECDHE-ECDSA-AES256-GCM-SHA384` (TLS 1.2, FS)
5. `ECDHE-RSA-AES256-GCM-SHA384` (TLS 1.2, FS)

---

### 2.4 Ataques Reais & Defesas (O "Dia a Dia" do Adversário)

| Ataque | Vetor | Impacto | Defesa Efetiva |
| :--- | :--- | :--- | :--- |
| **ARP/NDP Spoofing** | L2 (LAN) | MITM, Interceptação, Modificação | **DAI (Dynamic ARP Inspection)**, **RA Guard**, **Port Security**, **IPv6 RA Guard** |
| **DNS Hijacking / Cache Poisoning** | L7 (DNS) | Redirecionamento phishing/malware | **DNSSEC** (Validação), **DoH/DoT** (Criptografa query), `dnssec-validation yes` |
| **TLS Downgrade (POODLE, FREAK, Logjam)** | L4/L7 (Handshake) | Força cifra fraca / Export grade | **Desabilitar TLS 1.0/1.1/SSLv3**, Desabilitar `EXPORT` ciphers, `TLS_FALLBACK_SCSV` |
| **Padding Oracle (Lucky 13, POODLE)** | L7 (CBC Mode) | Descriptografia byte a byte | **Usar apenas AEAD (AES-GCM, ChaCha20-Poly1305)**, Desabilitar CBC |
| **Replay Attack** | L4/L7 | Repetição de transação | **Nonce/Timestamp**, `idempotency-key`, TLS Sequence Numbers (Stateful) |
| **BGP Hijacking / Route Leak** | L3 (BGP) | Roteamento tráfego p/ atacante | **RPKI (ROA/ROV)**, `bgpsec` (futuro), IRR filtering |
| **Credential Stuffing / Spraying** | L7 (Auth) | Acesso não autorizado | **MFA (FIDO2/WebAuthn)**, Rate Limit, `haveibeenpwned` check, CAPTCHA |

---

### 2.5 Segredos & Key Management (O "Não Faça Isso")
| ❌ Erro Fatal | ✅ Prática Sênior |
| :--- | :--- |
| `API_KEY="sk_live_..."` no código / `.env` no repo | **Vault / AWS Secrets Manager / 1Password CLI / SOPS / SealedSecrets** |
| Chave privada RSA sem senha (`-----BEGIN RSA PRIVATE KEY-----`) | **Chave criptografada (PKCS#8 + AES-256)**, **HSM / TPM / YubiKey (PIV)** |
| Mesma chave para Dev / Homolog / Prod | **Ambientes isolados**, **Workload Identity (SPIFFE/SPIRE)** |
| Chave nunca rotacionada (anos) | **Rotação automatizada** (Cert-Manager, Vault, `cron` + `acme.sh`) |
| Segredo em `docker build` (cache layer) | **BuildKit `--secret`**, Multi-stage build, `COPY --from=secrets` |

---

### 2.6 Criptografia Pós-Quântica (PQC) — Prepare-se Agora
| Algoritmo (NIST FIPS 203/204/205) | Tipo | Uso | Status |
| :--- | :--- | :--- | :--- |
| **ML-KEM (CRYSTALS-Kyber)** | KEM (Key Encapsulation) | Substitui RSA/ECDH (Key Exchange) | **FIPS 203 (2024)** |
| **ML-DSA (CRYSTALS-Dilithium)** | Assinatura Digital | Substitui RSA/ECDSA (Certificados, Assinaturas) | **FIPS 204 (2024)** |
| **SLH-DSA (SPHINCS+)** | Assinatura Stateless | Backup/Long-term (Conservador) | **FIPS 205 (2024)** |

**Estratégia de Migração (Híbrido):**
```text
TLS 1.3 Hybrid Key Exchange:
  ClientHello: 
    Key Share: X25519 (Clássico) + ML-KEM-768 (PQC)
    Signature: ECDSA P-256 (Clássico) + ML-DSA-65 (PQC)
```
> **Ameaça Real:** **"Harvest Now, Decrypt Later"** (Guardar tráfego TLS 1.2/1.3 hoje para quebrar com Computador Quântico amanhã). Dados sensíveis (saúde, financeiro, estado) **já estão em risco**.

---

## 3. Fragilidades da Criptografia no Dia a Dia (Cenários Reais & Sucintos)

> **Regra de Ouro:** Criptografia **não** resolve bugs de lógica, configuração ruim ou factor humano.

| Cenário Cotidiano | A Falha Real | Consequência | Mitigação Prática |
| :--- | :--- | :--- | :--- |
| **"TLS 1.2 com Cifra Antiga (CBC/SHA1)"** | Servidor legado / Load Balancer mal configurado | **Lucky 13 / POODLE** → Descriptografia passiva | `ssl_ciphers 'HIGH:!aNULL:!MD5:!3DES:!CBC'` + TLS 1.3 only |
| **Certificado Auto-assinado / Expirado / CN ≠ Host** | Dev ignora erro (`curl -k`, `verify=False`) | **MITM Trivial** (Qualquer proxy intercepta) | **Nunca** `verify=False` em Prod. `cert-manager` + `cert-manager.io/issuer` automático. |
| **Chave Privada no Docker Image / GitHub / Log** | `COPY key.pem .` / `echo $PRIVATE_KEY` / `printenv` | **Comprometimento Total** (Identidade roubada) | **BuildKit `--mount=type=secret`**, Vault Agent Injector, `.gitignore` + `git-secrets`/`gitleaks` no CI. |
| **Senha Fraca / Reutilizada + Sem MFA** | Humano fraco (Phishing, Reuse, Leak) | **Account Takeover (ATO)** → Ransomware, Data Leak | **FIDO2/WebAuthn (Passkeys)** Obrigatório. Rate Limit + `haveibeenpwned` API. |
| **JWT `alg: none` / Chave Fraca / `exp` Longo** | Lib padrão insegura / Config default | **Token Forgery** → Admin Access | `alg: RS256/ES256` only. Chave ≥ 2048/ES256. `exp` curto (15min) + Refresh Token Rotation. |
| **IV/Nonce Reutilizado (AES-GCM / ChaCha20)** | Contador reiniciado / Random ruim | **Quebra Confidencialidade/Integridade** (Key Recovery) | **Contador Monotônico (96-bit)** ou `XChaCha20-Poly1305` (Nonce 192-bit). |
| **ECB Mode (ECB = Electronic Codebook)** | `AES.new(key, AES.MODE_ECB)` | **Padrão Visível** (Imagem do pinguim) | **Nunca ECB.** Use `AES-GCM` (AEAD) ou `CBC + HMAC` (Encrypt-then-MAC). |
| **Chave Derivada Fraca (PBKDF2 < 100k iters)** | `PBKDF2(password, salt, 1000)` | **Brute-force GPU** (Bilhões/s) | **Argon2id** (Memória-dura), `iterations ≥ 600k` (PBKDF2), `scrypt`. |
| **Chave Simétrica Hardcoded em Firmware/IoT** | `key = "1234567890abcdef"` | **Extração Física/Eng. Reversa** → Todos dispositivos expostos | **Unique Key per Device** (Key Injection na fábrica), **Secure Element / TPM**. |
| **Falta de Rotação de Chaves / Certificados** | "Funciona, não mexe" | **Comprometimento Silencioso Longo** | **Automação:** Cert-Manager (90 dias), Vault Rotation (30-90 dias), Alertas `expiry < 30d`. |

---

## 4. Labs "Break/Fix" (Aprenda Quebrando)

> **Metodologia:** Dê o PCAP / Container vulnerável → Aluno *quebra* → Aluno *corrige* → Aluno *documenta*.

| Lab | Objetivo | Ferramentas | Entregável |
| :--- | :--- | :--- | :--- |
| **Lab 1: ARP Spoofing & DAI** | Fazer MITM na LAN → Ativar DAI no Switch → Ver falha | Kali (Bettercap/Ettercap), Switch Gerenciável (Cisco/Ubiquiti), Wireshark | PCAP "Antes/Depois" + Config DAI |
| **Lab 2: TLS Downgrade & Cipher Scan** | Forçar TLS 1.0 / Cifra EXPORT → Hardening Server → Ver bloqueio | `testssl.sh`, `nmap --script ssl-enum-ciphers`, OpenSSL `s_client` | Relatório `testssl.sh` (A+ no SSL Labs) |
| **Lab 3: JWT Forgery (alg:none / Weak Key)** | Forjar token `admin=true` → Assinar com chave fraca / `none` → Validar | `jwt_tool`, `python-jwt`, Burp Suite | PoC Token Forjado + Código validação segura (`alg` allowlist) |
| **Lab 4: PCAP Analysis - MITM Real** | Analisar PCAP com ARP Spoof + DNS Hijack + TLS Strip | Wireshark (Display filters: `arp`, `dns`, `tls.handshake`) | Relatório: "O que vazou?", "Como detectar?" |
| **Lab 5: Secret Leak & Rotation** | Vazar chave no GitHub (Simulado) → Rotacionar via Vault → Revogar antiga | HashiCorp Vault (Dev mode), `git-secrets`, `trufflehog`, `trufflehog github --repo=...` | Runbook de Rotação de Emergência (Runbook) |

---

## 5. Checklist de Hardening Rápido (Runbook de Bolso)

```bash
# 1. Sistema Base
apt update && apt upgrade -y && apt install -y ufw fail2ban auditd aide lynis
ufw default deny incoming; ufw default allow outgoing; ufw allow 22/tcp; ufw enable

# 2. SSH Hardening (/etc/ssh/sshd_config)
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
Protocol 2
Port 2222 # Não padrão
AllowUsers usuario_admin
# systemctl reload sshd

# 3. Auditoria & Integridade
auditctl -w /etc/passwd -p wa -k identity
auditctl -w /etc/shadow -p wa -k identity
aideinit && aide --check # Rodar diário via cron

# 4. Kernel Hardening (/etc/sysctl.d/99-hardening.conf)
net.ipv4.ip_forward=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.tcp_syncookies=1
net.ipv6.conf.all.disable_ipv6=1 # Se não usa IPv6
kernel.dmesg_restrict=1
kernel.kptr_restrict=2
fs.protected_hardlinks=1
fs.protected_symlinks=1
# sysctl --system

# 5. Logs Centralizados (rsyslog → Loki/ELK/Splunk)
# /etc/rsyslog.d/99-remote.conf
*.* @logserver:514

# 6. Container Hardening (Docker/K8s)
# Dockerfile: USER nonroot, READONLY_ROOTFS, --cap-drop=ALL, --security-opt=no-new-privileges
# K8s: PodSecurityPolicy (deprecated) → PodSecurity Standards (Restricted), Kyverno/OPA Gatekeeper
```

---

## 6. Referências Sênior (O Que Ler Depois)

| Livro / RFC / Site | Foco |
| :--- | :--- |
| **RFC 8446** (TLS 1.3) | Protocolo moderno |
| **RFC 8447** (TLS 1.3 IANA) | Parâmetros |
| **NIST SP 800-57** | Key Management |
| **NIST SP 800-53 Rev 5** | Controles de Segurança |
| **CIS Benchmarks** | Hardening OS/Apps/Cloud |
| **OWASP ASVS / MASVS** | Requisitos App Seguro |
| **RFC 9000** (QUIC) | Transporte Moderno |
| **RFC 9001** (TLS over QUIC) | HTTPS/3 |
| **RFC 8484** (ACME) | Automação Certificados |
| **RFC 8555** (ACME) | Let's Encrypt Protocol |
| **Real World Crypto (RWC)** | Conferência Anual (Vídeos no YouTube) |
| **Crypto Failures (crypto.fail)** | Base de falhas reais |
| **Cryptopals Challenges** | Aprenda cripto quebrando |

---

> **Lembrete Final:** Segurança não é um produto que você instala. **É um processo contínuo de redução de superfície de ataque, detecção rápida e resposta eficaz.** Criptografia é uma ferramenta poderosa, mas **configuração errada = vulnerabilidade garantida**.

---

📊 **Visualizações:** ![hits](https://hits.sh/github.com/charles-josiah/Aulas/2026-07-Lab-Cripto-e-SegRedes/Aula_Intro_redes_criptografia-p2.md.svg)
