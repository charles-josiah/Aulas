# Aula Introdutória de Redes e Criptografia (Nível Graduação)

> Material base para uma aula de 1h–1h30. Este arquivo **não** traz marcações de tempo por tópico e **não** inclui a “sequência sugerida”; os módulos são independentes e podem ser reordenados conforme a turma.

---

## Objetivos
- Compreender funções de **roteadores, switches e hubs** (e por que hubs caíram em desuso).
- Mapear os **modelos OSI e TCP/IP** e localizar onde a **criptografia** atua.
- Entender **endereçamento IP**, **DHCP**, **DNS**, e noções de **HTTP/FTP**.
- Diferenciar **Cliente–Servidor** de **Ponto-a-Ponto (P2P)**.
- Reconhecer diferenças entre **firewalls L3/L4/L7**, **UTM** e **NGFW**.
- Ter uma visão inicial de **nuvem** (**OCI, AWS, Azure**).
- Assimilar os fundamentos de **criptografia** (simétrica x assimétrica, **TLS**, **IPsec**, **WPA3**, **PGP**).

---

## Nuvem de tags (panorama)
**Roteador**, **Switch**, **Hub**, **TCP/IP**, **DNS**, **DHCP**, **HTTP/HTTPS**, **FTP/SFTP/FTPS**, **ARP**, **ICMP**, **NAT**, **VLAN**, **VPN**, **QoS**, **SNMP**, **SSH**, **NTP**, **BGP/OSPF**, **Firewall L3/L4/L7**, **UTM**, **NGFW**, **WAF**, **IDS/IPS**, **TLS**, **IPsec**, **WPA2**, **MAC**, **P2P**, **Cliente–Servidor**, **Topologias** (Barramento, Anel, Estrela, Malha), **Cloud**, **OCI**, **AWS**, **Azure**.

> **Nota “FDP?”**: não é acrônimo padrão de redes.

---

## 1) Dispositivos de rede
### Hub (Camada 1)
- Repetidor elétrico: **replica tudo para todas as portas**.
- Gera **colisões**, **sem segurança**. Uso atual: laboratório/legado.

### Switch (Camada 2)
- Comuta **quadros** por **endereços MAC** (tabela MAC).
- **STP/RSTP** evitam loops; **VLAN (802.1Q)** segmenta L2.
- Reduz domínio de colisão; base da LAN moderna.

### Roteador (Camada 3)
- Encaminha **pacotes IP** entre redes diferentes (LAN↔WAN).
- Tabela de rotas, **NAT**, **ACLs**. Conecta e isola domínios IP.

> **Regra de bolso**: **Hub morreu**, **Switch manda na LAN**, **Roteador liga redes**.

---

## 2) Modelos de referência (OSI x TCP/IP)
### OSI (7 camadas)
1. **Física** — bits no meio físico (cabo, rádio).  
2. **Enlace** — quadros/MAC, **ARP**, **STP**, **VLAN**.  
3. **Rede** — **IP**, roteamento (**OSPF/BGP**), **IPsec**.  
4. **Transporte** — **TCP/UDP** (portas).  
5. **Sessão** — controle de sessão.  
6. **Apresentação** — codificação, compressão, **TLS** (conceitualmente).  
7. **Aplicação** — **HTTP, DNS, FTP, SSH** etc.

### TCP/IP (4 camadas)
- **Acesso à rede** (equivale a L1–L2 OSI)  
- **Internet** (L3 OSI)  
- **Transporte** (L4 OSI)  
- **Aplicação** (L5–L7 OSI)

### Onde a criptografia aparece?
- **L2**: **WPA2/WPA3** (Wi‑Fi), **MACsec (802.1AE)**.  
- **L3**: **IPsec** (túneis site‑to‑site/cliente).  
- **L4/5/6**: **TLS** (entre app e transporte).  
- **L7**: **PGP/GPG**, **SSH**, cripto na aplicação.

---

## 3) Endereçamento IP, DHCP e DNS
### IP e Sub-redes
- IPv4 (32 bits) e IPv6 (128).  
- **Máscara/Prefixo**, **Gateway**, **MTU**.  
- CIDR: ex. `192.168.10.0/24` → hosts `192.168.10.1–254`.

### DHCP (App; usa UDP 67/68)
- Fornece IP, máscara, gateway, DNS, opções (ex.: tempo de lease).  
- **Comandos úteis**:  
  - Windows: `ipconfig /all`, `ipconfig /release`, `ipconfig /renew`  
  - Linux: `ip a`, `sudo dhclient -r && sudo dhclient`

### DNS (tradução nome↔IP)
- Tipos: **A/AAAA**, **CNAME**, **MX**, **TXT**…  
- **Comandos**: `nslookup`, `dig dominio.com +trace`, `dig A www…`, `dig MX`, `dig TXT`.

---

## 4) HTTP, FTP e modelos de comunicação
### HTTP/HTTPS
- **HTTP** é aplicação; **HTTPS = HTTP + TLS**.  
- Versões: 1.1, 2 e **3 (QUIC/UDP)**.  
- Cabeçalhos (ex.: `curl -I https://exemplo.com`).

### FTP x SFTP x FTPS
- **FTP**: legado, **sem criptografia**.  
- **FTPS**: FTP + TLS.  
- **SFTP**: protocolo de transferência sobre **SSH** (**não** é FTP).

### Cliente–Servidor vs Ponto‑a‑Ponto (P2P)
- **Cliente–Servidor**: papéis fixos, centralização (web, bancos).  
- **P2P**: pares atuam como clientes e servidores (BitTorrent, WebRTC).

---

## 5) Firewalls e segurança de rede
- **L3/L4 (Tradicional)**: filtra **IP/protocolo/portas**; pode ser **stateful** e **stateless**.  
- **L7 (Aplicação)**: compreensão de **HTTP/JSON/SQL**, **DPI**.  
- **UTM**: “tudo‑em‑um” (FW, IPS, AV, filtro web, VPN).  
- **NGFW**: controle por **aplicação/usuário**, **IPS**, inspeção SSL/TLS, sandbox.  
- **Correlatos**: **WAF** (focado em HTTP/HTTPS), **IDS/IPS** (detectar/bloquear ameaças).

---

## 6) Introdução à criptografia
### Tríade CIA
- **Confidencialidade**, **Integridade**, **Autenticidade**.

### Chave simétrica vs assimétrica
- **Simétrica**: 1 chave (ex.: **AES**). Rápida; desafio na distribuição.  
- **Assimétrica**: **pública/privada** (ex.: **RSA**, **ECC**). Facilita troca de chaves e assinatura.

### Protocolos e camadas
- **TLS** (web): certificado do servidor, cadeias de confiança (CA), negociação (ECDHE).  
- **IPsec** (rede): protege **IP** ponto‑a‑ponto.  
- **WPA3** (Wi‑Fi): proteção L2 com SAE/Dragonfly.  
- **PGP/GPG** (aplicação): cifra/assina arquivos/emails.

### Boas práticas
- RSA ≥ 2048 ou curvas seguras (**P‑256+**).  
- **PFS** (Perfect Forward Secrecy) com **ECDHE**.  
- Rotação de chaves e gestão segura de segredos.  
- Em web: **HSTS**, TLS 1.2+ (preferir 1.3).

### Exemplos práticos (terminais)
```bash
# Verificar certificado/TLS de um site (cadeia e datas)
openssl s_client -connect exemplo.com:443 -servername exemplo.com | openssl x509 -noout -issuer -subject -dates

# Portas em uso
ss -tulpn    # Linux
netstat -ano # Windows

# GPG simétrico (demonstração)
printf 'segredo' | gpg --symmetric --cipher-algo AES256 --armor
```

---

## 7) Topologias (físicas e lógicas)
### Físicas
- **Barramento** — um único meio compartilhado (legado).  
- **Anel** — **Token Ring/FDDI** (legado; latência previsível).  
- **Estrela** — **switch** no centro (padrão moderno).  
- **Malha (Mesh)** — múltiplos caminhos/redundância (datacenters, malhas Wi‑Fi).

### Lógicas
- **VLANs** (L2), **sub‑redes** (L3), **overlays** (VXLAN, GRE).  
- Isolamento de tráfego e virtualização de redes.

> **FDDI** (se o “FDP” era isso): anel duplo em fibra (100 Mb/s), típico dos anos 90; substituído por Ethernet comutada.

---

## 8) Nuvem (conceitos e provedores)
### Modelos de serviço
- **IaaS** (VMs/rede), **PaaS** (DB gerenciado), **SaaS** (aplicativo pronto).

### Rede por provedor
- **AWS**: **VPC**, Subnets, **IGW**, **NAT GW**, **Security Groups** (L4 stateful), **NACL** (stateless).  
- **Azure**: **VNet**, Subnets, **NSG**, **UDR**, **ExpressRoute**.  
- **OCI**: **VCN**, Subnets (priv/púb), **DRG**, **IG**, **NSG**, **LPG**, **FastConnect**.

### Conectividade
- **VPN IPsec**, **links dedicados** (Direct Connect/ExpressRoute/FastConnect).  
- Segmentação por **subnets/VLANs**; **WAF** e **IAM** robustos.

---

## 9) Laboratórios rápidos (para demonstração)
1. **DHCP & IP**
   - Win: `ipconfig /all`; Linux: `ip a`  
   - Identificar **IP**, **Máscara**, **Gateway**, **DNS**.

2. **DNS**
   - `nslookup chat.openai.com`  
   - `dig chat.openai.com A +trace` (recursão e autoridade).

3. **HTTP/HTTPS**
   - `curl -I https://exemplo.com` (status, headers)  
   - `curl --http3 -I https://cloudflare.com` (quando disponível)

4. **Rota/TTL**
   - Win: `tracert exemplo.com` ; Linux/macOS: `traceroute exemplo.com`

5. **TLS**
   - `openssl s_client -connect exemplo.com:443 -servername exemplo.com | openssl x509 -noout -issuer -subject -dates`

---

## 10) Glossário essencial
- **ARP**: IP→MAC em L2.  
- **ICMP**: mensagens de controle (ping, traceroute).  
- **NAT**: tradução de endereços (privado↔público).  
- **VLAN (802.1Q)**: segmentação L2 por tagging.  
- **QoS**: priorização (voz/vídeo).  
- **SNMP**: monitoração de rede.  
- **SSH**: acesso remoto cifrado.  
- **NTP**: sincronização de horário.  
- **BGP/OSPF**: roteamento dinâmico (inter/intra‑domínio).  
- **WAF**: firewall de aplicação web.  
- **IDS/IPS**: detecção/prevenção de intrusões.  
- **MACsec / WPA3**: criptografia em L2 (fio/Wi‑Fi).  
- **IPsec**: criptografia em L3.  
- **TLS**: criptografia na camada de aplicação/transporte (conceitual).  
- **SFTP/FTPS**: transferência segura (via SSH / via TLS).

---

## 11) Quiz relâmpago
1. Em quais camadas você encontra **TLS**, **IPsec** e **WPA3**?  
2. Diferencie **Switch** de **Roteador** em uma frase cada.  
3. **HTTPS** usa qual protocolo para criptografar e em qual “camada” conceitual ele se encaixa?

---

## 12) Materiais e dicas para o instrutor
- Use analogias: **estradas** (IP), **interseções** (roteadores), **prédios** (switches/VLANs), **porteiros** (firewalls).  
- Mostre `curl -I` para status e cabeçalhos; `dig` para DNS e `traceroute` para caminho/latência.  
- Enfatize **chaves** (simétrica/assimétrica), **cadeia de confiança** (AC raiz → intermediária → servidor) e **PFS**.

---

## 13) Acréscimos essenciais (DHCP + “XYZ”)
> Tópicos correlatos que costumam aparecer junto de DHCP. Aqui listados **sem ordem sequencial** (o professor pode escolher a ordem didática).

### NAT
- Traduz IPs privados ↔ públicos (saída: **SNAT/masquerade**; entrada: **DNAT**).  
- **Exemplo (Linux, nftables)**:
  ```bash
  nft add table ip nat
  nft add chain ip nat POSTROUTING '{ type nat hook postrouting priority 100; }'
  nft add rule ip nat POSTROUTING oifname "eth0" masquerade
  ```

### VLAN
- Segmentação lógica L2 por **tag 802.1Q**.  
- **Exemplo (Linux)**:
  ```bash
  ip link add link eth0 name eth0.10 type vlan id 10
  ip addr add 192.168.10.1/24 dev eth0.10
  ip link set eth0.10 up
  ```

### VPN
- Túneis criptografados (**IPsec**, **SSL/TLS**, **WireGuard**).  
- Atenção a **sobreposição de sub-redes**, **NAT‑exempt** e **MTU/MSS**.

### QoS
- **Marcação** (802.1p/CoS, **DSCP**) e **enfileiramento** (HTB, FQ‑CoDel).  
- **Exemplo (Linux)**:
  ```bash
  # marcar voz como EF (DSCP 46) – exemplo
  iptables -t mangle -A POSTROUTING -p udp --dport 5060 -j DSCP --set-dscp-class EF
  tc qdisc add dev eth0 root fq_codel
  ```

---

## Observações finais
- **Hub** é legado; prefira **switch**.  
- O uso de **FTP** sem criptografia não é recomendado; prefira **SFTP/FTPS**.  
- Caso “**FDP**” refira-se a outro termo (e não **FDDI**), indique para inclusão correta no glossário.
