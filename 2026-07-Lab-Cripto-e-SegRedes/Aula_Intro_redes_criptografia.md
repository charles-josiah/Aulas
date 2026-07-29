# Aula Introdutória de Redes e Criptografia

---

## Bem-vindo(a)!

Se você chegou até aqui, está prestes a entender como a internet realmente funciona por baixo dos panos — e por que criptografia é o que mantém o mundo digital em pé.

**Não precisa saber nada de rede antes, sera?. Vamos juntos.**

---

## Por que isso importa? (3 exemplos reais)

1. **WhatsApp**: sem criptografia, alguém leria suas conversas. Com ela, só você e quem recebe conseguem ler.
2. **Pix/Bancos**: sem criptografia, sua senha trafegaria em texto claro — qualquer um na rede roubaria seu dinheiro.
3. **Wi-Fi público**: sem criptografia, todos os dados que você acessa (emails, senhas, fotos) seriam visíveis para quem estivesse por perto.

**A criptografia é o escudo que protege você.** 
- Porque te protege ? Como ela te protege ? O que ela traz de beneficio ? Não so mundo da TI, mas no dia a dia ? 

---

## Objetivos desta aula

- Entender o funcionamento basico de **roteadores, switches e hubs** — e por que hubs não existem mais (nao deveriam mais existir ;D ).
- Mapear o **modelo OSI** e descobrir **onde a criptografia atua** em cada camada.
- Conhecer **endereçamento IP**, **DHCP**, **DNS** na prática.
- Diferenciar **Cliente–Servidor** de **Ponto-a-Ponto (P2P)**.
- Entender **firewalls** e como eles protegem redes.
- Explorar **nuvem** (AWS, Azure, OCI) — como funciona por trás das cortinas.
- Aprender os **fundamentos da criptografia** (simétrica, assimétrica, TLS, IPsec, WPA3).

---

## Termos que você vai dominar até o fim

**Redes**: Roteador, Switch, Hub, TCP/IP, DNS, DHCP, IP, NAT, VLAN, Topologias  
**Segurança**: Firewall L3/L4/L7, UTM, NGFW, WAF, IDS/IPS  
**Criptografia**: TLS, IPsec, WPA2/WPA3, PGP/GPG, SSH, HTTPS/SFTP/FTPS  
**Comunicação**: Cliente–Servidor, P2P, HTTP, FTP  
**Nuvem**: OCI, AWS, Azure, VPC, Subnets

---

## Atividade 1min: Explore sua rede AGORA

Sem instalações, sem complicação. Abra o terminal e rode:

```bash
# Descubra seu IP público:
curl ifconfig.me

# Descubra por onde seu pacote passa até o Google:
traceroute google.com

# Veja os servidores DNS que você usa:
nslookup google.com
```

**O que você acabou de ver?** Pacotes viajando de verdade pela internet. Isso é real, agora, acontecendo.

---

## 1) História da Criptografia (O contexto)

Por que criptografia importa? Porque sempre importou.

### Linha do tempo resumida

| Época | O que acontecia | Como se protegia |
|-------|-----------------|-----------------|
| **~1900 aC** (Egito Antigo) | Faraós precisavam de mensagens secretas | Substituição de letras por símbolos |
| **~500 aC** (Grécia) | Guerreiros usavam **cifra de César** (shift 3) | `ABC → DEF` |
| **~1600 dC** (Renascimento) | Matemáticos criam **cifra de Vigenère** (multi-shift) | Muito mais forte que César |
| **~1940s** (WWII) | Alemanha usa **máquina Enigma** | Considerada inquebrável (mas Alan Turing quebrou) |
| **~1970s** | **RSA** inventado — primeira cripto de chave pública | Dois números primos gigantes: impossível fatorar |
| **Hoje** | **TLS/SSL**, **GPG**, **AES**, **Curvas Elípticas** | Protege bilhões de transações por segundo |

**Lição**: Criptografia sempre evoluiu porque pessoas sempre quiseram manter segredos.

### Exemplo prático: a Cifra de César (shift 3)

A cifra de César "empurra" cada letra 3 posições à frente no alfabeto (`A→D`, `B→E`, `C→F`...). Veja uma mensagem real do campo de batalha:

**Mensagem original:**
```
ATAQUE AO AMANHECER
INIMIGO NAO SUSPEITA
```

**Mensagem cifrada (o que o inimigo interceptaria):**
```
DWDTXH DR DPDQKHFHU
LQLPLJR QDR VXVSHLWD
```

> Só quem souber o **shift (3)** consegue desfazer. Essa "chave" secreta é o coração de toda criptografia — desde César até o RSA moderno.

---

## 2) O Modelo OSI — O Mapa da Rede (e onde vive a criptografia)

O modelo OSI é uma **receita** que explica como dados trafegam de A até B. Cada camada tem um "dever" e uma unidade de trabalho (PDU): a L1 envia bits, a L2 envia quadros, a L3 envia pacotes...

E aqui está a magia: **criptografia vive em praticamente todas elas.**

### As 7 camadas com criptografia mapeada

| Camada | PDU (Unidade) | Função | Protocolos | 🔐 Criptografia |
|---|---|---|---|---|
| **7 — Aplicação** | **Dados** | Onde você interage (browser, app) | HTTP, DNS, FTP, SMTP, PGP | ✅ **PGP/GPG**, **SSH** |
| **6 — Apresentação** | **Dados** | Formata os dados | TLS, compressão | ✅ **TLS handshake** |
| **5 — Sessão** | **Dados** | Mantém a conversa acontecendo | NetBIOS, RPC, TLS | 🔄 **TLS continua aqui** |
| **4 — Transporte** | **Segmento/Datagrama** | Garante entrega (TCP) ou apenas envia (UDP) | TCP, UDP, QUIC | 🔄 **TLS/QUIC** |
| **3 — Rede** | **Pacote** | Roteia pacotes (IP) | IP, ICMP, IPsec, BGP, OSPF | ✅ **IPsec** |
| **2 — Enlace** | **Quadro/Frame** | Envia quadros/frames (MAC) | Ethernet, Wi-Fi, ARP, VLAN | ✅ **WPA2/WPA3**, **MACsec** |
| **1 — Física** | **Bit** | Bits no fio/fibra/ar | Cabo UTP, fibra óptica, RF | ❌ Nenhuma |

### Exemplo prático: a jornada de um e-mail

Imagine que você envia um e-mail do seu Gmail para um amigo. É isso que acontece por baixo dos panos, camada por camada:

#### ➡️ A Descida (No seu PC)

1. **(L7) Aplicação**: você clica em "Enviar". Seu navegador entrega os dados do e-mail (texto, anexos) para a camada de baixo.
2. **(L6) Apresentação**: seu navegador (via **TLS**) codifica os caracteres, negocia a criptografia e prepara tudo para a transmissão segura.
3. **(L5) Sessão**: o TLS mantém a conexão segura com o servidor do Google.
4. **(L4) Transporte**: o texto do e-mail é quebrado em **segmentos** (TCP). Cada um ganha um "número de sequência" para garantir que cheguem na ordem certa.
5. **(L3) Rede**: cada segmento vira um **pacote**. Ele ganha o "endereço do remetente" (seu IP) e o "endereço do destinatário" (IP do servidor do Google).
6. **(L2) Enlace**: cada pacote vira um **quadro**. Ele ganha o "endereço físico" do seu PC (MAC) e do próximo salto na rede (roteador).
7. **(L1) Física**: o quadro vira uma sequência de **bits** (zeros e uns) e viaja pelo cabo de rede ou Wi-Fi.

#### ↗️ A Subida (No PC do seu amigo)

O processo inverso acontece:

1. **(L1) Física**: os bits chegam pela internet.
2. **(L2) Enlace**: os bits são remontados em **quadros**.
3. **(L3) Rede**: os quadros são remontados em **pacotes**.
4. **(L4) Transporte**: os pacotes são remontados em **segmentos** na ordem correta.
5. **(L5) Sessão**: a sessão TLS garante que a conexão é segura.
6. **(L6) Apresentação**: o TLS decifra e formata os dados.
7. **(L7) Aplicação**: o Gmail do seu amigo recebe os dados e exibe o e-mail na caixa de entrada.

**Conclusão**: o que você vê como "enviar email" é, na verdade, uma complexa operação de empacotamento, endereçamento, envio, desempacotamento e remontagem.

### Visualização do fluxo

```
  Aplicação      7 │ 🔐 PGP/GPG, SSH, HTTPS, SFTP
  Apresentação   6 │ 🔐 TLS (handshake, certificados) ╮
  Sessão         5 │ 🔄 TLS (sessão aberta)           ║ TLS atua
  Transporte     4 │ ══ TCP/UDP ←─────────────────────╯ "entre camadas"
  Rede           3 │ 🔐 IPsec (VPN, túneis)
  Enlace         2 │ 🔐 WPA2/WPA3 (Wi-Fi), MACsec
  Física         1 │ ❌ Nenhuma
```

### Modelo TCP/IP (a versão "real" da internet)

TCP/IP é OSI **simplificado** em 4 camadas. É isso que rodas de verdade:

| Camada TCP/IP | = OSI | Criptografia típica |
|---|---|---|
| Aplicação | L5 + L6 + L7 | TLS/HTTPS, SSH, PGP/GPG |
| Transporte | L4 | (TLS atua acima dela) |
| Internet | L3 | IPsec (VPNs) |
| Acesso à rede | L1 + L2 | WPA2/WPA3, MACsec |

### Exemplos do seu dia a dia (mapeados ao OSI)

| Você usa… | Camada OSI | Como é protegido? |
|-----------|-----------|---|
| **WhatsApp** (conversa encriptada) | L7 | Criptografia na aplicação — só o app cifra/decifera |
| **Site com 🔒 (HTTPS)** | Entre L4–L7 | TLS — seu navegador e servidor "apertam mão" e negocia cifra |
| **Wi-Fi com senha** | L2 | WPA2/WPA3 — cifra dados L2 antes de sair pelo ar |
| **VPN do trabalho** | L3 | IPsec — cifra **todo** pacote IP dentro de um túnel |
| **Arquivo .gpg** | L7 | PGP — arquivo cifrado no disco; só você descriptografa |
| **SSH (terminal remoto)** | L7 | SSH — terminal toda criptografado, inclusve senhas |

**Punchline**: De cima a baixo, criptografia está lá. Não há "um lugar seguro" — segurança é **múltiplas camadas**.

---

## 3) Dispositivos de Rede (Os personagens)

Três atores principais aparecem em toda rede. Entender cada um é metade da batalha.

### Hub (Camada 1) — O repetidor "burrão"

- **O que faz**: recebe bit de uma porta, envia para **todas** as outras (broadcast puro).
- **Segurança**: zero. Qualquer máquina na rede vê todo tráfego.
- **Hoje**: defunto. Mataram porque é arriscado (ninguém quer transparência total).

### Switch (Camada 2) — O "gestor de quadros"

- **O que faz**: aprende endereço MAC de cada máquina e envia quadros **só para quem precisa** (não broadcast).
- **Proteção L2**: VLAN (802.1Q) — cria sub-redes lógicas.
- **Hoje**: onipresente. Base de toda LAN moderna.
- **Analogia**: central telefônica — sabe quem liga para quem e conecta direto.

### Roteador (Camada 3) — O "viajante entre mundos"

- **O que faz**: conecta **redes diferentes** (LAN local ↔ internet). Usa endereço IP (não MAC).
- **Proteção**: NAT (traduz IPs privados para públicos), ACL (regras de quem passa).
- **Hoje**: ponta de entrada/saída de toda rede.
- **Analogia**: guarda de fronteira — sabe para qual país (rede) cada pacote precisa ir.

**Resumão**: Hub = antigo/burro. Switch = governa LAN. Roteador = governa inter-redes.

---

## 4) Comunicação: Cliente–Servidor vs Ponto-a-Ponto (P2P)

Existem dois "formatos" fundamentais de conversa na rede.

### Cliente–Servidor (assimétrico)

- **Papéis fixos**: um é **servidor** (que espera requisição), outro é **cliente** (que pede).
- **Exemplos**: seu navegador (cliente) pede página ao Google (servidor); seu phone (cliente) pede emails ao Gmail (servidor).
- **Vantagem**: servidor é um ponto único de controle, fácil monitorar e proteger.
- **Desvantagem**: se servidor cair, ninguém consegue nada.

### P2P — Ponto-a-Ponto (simétrico)

- **Papéis dinâmicos**: todo nó é **cliente E servidor** ao mesmo tempo.
- **Exemplos**: BitTorrent (arquivo vem de múltiplas fontes simultaneamente); WhatsApp (seu phone envia e recebe de outros).
- **Vantagem**: sem ponto único de falha; muito mais resiliente.
- **Desvantagem**: mais difícil de governar (quem policia?).

**Lição**: A maioria da internet é Cliente–Servidor (centralizadora). P2P é usado quando você quer **descentralização**.

### Portas: Pra que servem?

Pense na comunicação como um telefonema para uma grande empresa. O **endereço IP** é o número de telefone do prédio (o servidor), mas a **porta** é o **ramal** específico do departamento que você quer (ex: ramal 80 para "Páginas Web", ramal 22 para "Acesso Remoto"). Seu computador também abre um ramal temporário (uma porta efêmera) para receber a chamada de volta. Esse sistema permite que um único servidor tenha múltiplas conversas diferentes ao mesmo tempo.

- **Portas Fixas (Well-Known Ports: 0-1023):** São os "ramais" padronizados para serviços famosos. O servidor sempre "escuta" nelas.
  - **Exemplos:** HTTP (80), HTTPS (443), SSH (22), FTP (21).
- **Portas Efêmeras (Altas/Privadas: 49152-65535):** Seu navegador ou app escolhe uma dessas aleatoriamente para iniciar a conversa. Ela só existe durante a conexão e depois é liberada. Você pode ver quais estão em uso com `netstat -an`.

---

## 5) Endereçamento IP, DHCP e DNS

Três pilares que fazem a internet funcionar.

### IP (Internet Protocol)

O IP é o "CEP" da internet. Cada dispositivo conectado (seu celular, um servidor do Google) tem um endereço IP que o identifica. A principal função do protocolo IP é o **endereçamento** e **roteamento**: garantir que um pacote de dados saia do seu computador, viaje por dezenas de roteadores no caminho e chegue exatamente ao destino correto, não importa onde ele esteja. É o que torna a comunicação global possível.

- **IPv4**: 32 bits (ex. `192.168.1.1`) — já está lotado.
- **IPv6**: 128 bits (ex. `2001:db8::1`) — espaço infinito, ainda em adoção.
- **CIDR notation**: `192.168.10.0/24` = "rede com 256 endereços (10.1 a 10.254)".
- **Gateway**: "portão de saída" para fora da rede local.

### DHCP (Dynamic Host Configuration Protocol)

Servidor DHCP é tipo um **cartório de IPs**: quando você chega numa rede, pede um IP emprestado.

```bash
# Ver qual IP o DHCP deu para você:
Windows:  ipconfig /all
Linux:    ip a
          sudo dhclient -r && sudo dhclient  # renovar
```

### DNS (Domain Name System)

Traduz nome (`google.com`) em IP (`142.251.41.14`).

```bash
# Descobrir qual IP é google.com:
nslookup google.com
dig google.com A +trace     # ver a trajetória da requisição
```

---

## 6) HTTP/HTTPS, FTP/SFTP/FTPS — Protocolos de Aplicação

Cada um tem um "padrão de conversa". Alguns têm cripto, outros não.

| Protocolo | O que faz | Tem cripto? | Hoje é seguro? |
|-----------|-----------|-----------|---|
| **HTTP** | Transfere páginas/arquivos | ❌ Não | ❌ Nunca use para dados sensíveis |
| **HTTPS** | HTTP + TLS | ✅ Sim | ✅ Padrão hoje (🔒 no navegador) |
| **FTP** | Transfere arquivos | ❌ Não | ❌ Legado, evite |
| **SFTP** | Arquivos sobre SSH | ✅ Sim | ✅ Substituto seguro de FTP |
| **FTPS** | FTP + TLS | ✅ Sim | ✅ Funciona, menos usado que SFTP |

**Regra de ouro**: Se tem senha ou dados sensíveis, exija **cripto**. Hoje, HTTPS e SFTP são padrão.

---

## 7) Firewalls — Os Porteiros da Rede

Firewalls dizem **"sim" ou "não"** a cada pacote que tenta entrar/sair.

| Tipo | O que filtra | Nivel de detalhe | Uso |
|------|-------------|---|---|
| **Firewall L3/L4** | IP, porta, protocolo | Básico | Router caseiro, borda de rede |
| **Firewall L7** | Conteúdo (HTTP, JSON, SQL) | Avançado | Proteção contra XSS, SQL injection |
| **UTM** | FW + IPS + antivírus + filtro web | Tudo junto | Redes médias/grandes |
| **NGFW** | Aplicação, usuário, inteligência | Muito avançado | Empresas, gov |
| **WAF** | Só HTTP/HTTPS | Focado web | Proteção de sites |

**Analogia**: Firewall = guarda de portaria; olha documento (IP:porta) e decide deixa passar ou não.

---

## 8) Introdução à Criptografia (Por quê? Como?)

### A Tríade CIA

Todo sistema de segurança deve garantir:
- **Confidencialidade**: ninguém lê seus dados (cripto simétrica)
- **Integridade**: ninguém altera seus dados (hash, assinatura)
- **Autenticidade**: você sabe quem enviou (certificado, assinatura digital)

### Simétrica vs Assimétrica (diferença crucial)

| Simétrica | Assimétrica |
|-----------|---|
| 1 chave compartilhada | Chave pública + privada |
| Rápida | Mais lenta |
| Desafio: como compartilhar a chave com segurança? | Chave pública é... pública; privada só você tem |
| Exemplo: **AES** | Exemplo: **RSA**, **curvas elípticas** |

### Protocolos em ação

- **TLS/HTTPS**: browser e servidor fazem handshake (negociam chave simétrica usando assimétrica), depois comunicam com simétrica.
- **IPsec**: cria túnel criptografado entre dois IPs. Base das VPNs.
- **WPA3**: protege Wi-Fi com criptografia moderna (SAE).
- **PGP/GPG**: você cifra e assina arquivos. Ninguém lê, ninguém altera.

### Boas práticas

- Use **RSA ≥ 2048 bits** ou **curvas elípticas modernas** (P-256+).
- Exija **TLS 1.3** em sites (não 1.2 ou 1.0).
- Ative **HSTS** (força HTTPS mesmo se você digitar HTTP).
- Rode **TLS com PFS** (chave não é reutilizável; cada sessão gera nova).

---

## 9) Topologias de Rede

### Físicas (como os cabos estão arrumados)

- **Barramento**: 1 fio compartilhado (antigo, colisões garantidas).
- **Anel**: máquinas em círculo, token passa de um a outro (Token Ring/FDDI, defunto).
- **Estrela**: switch no centro, todos conectados a ele (padrão hoje).
- **Malha**: múltiplos caminhos, redundância total (datacenters, Wi-Fi mesh).

### Lógicas (como os dados se veem)

- **VLAN** (L2): máquinas diferentes "fingem" estar na mesma rede (802.1Q tags).
- **Sub-redes** (L3): redes diferentes com mascaras IP diferentes.
- **Overlays** (VXLAN, GRE): rede lógica em cima de rede física.

---

## 10) Nuvem (AWS, Azure, OCI)

Nuvem = **computação alugada**. Você não tem servidor em casa; um provedor tem para você.

### Modelos de serviço

- **IaaS** (Infrastructure as a Service): alugar VM, rede, storage. Ex: EC2 (AWS).
- **PaaS** (Platform as a Service): alugar banco de dados gerenciado, sem cuidar do hardware. Ex: RDS (AWS).
- **SaaS** (Software as a Service): alugar aplicativo pronto. Ex: Gmail, Salesforce.

### Por provedor

| Provedor | Rede VPC | Firewall | VPN |
|----------|----------|----------|---|
| **AWS** | VPC + Subnets | Security Groups (L4) + NACL (L3) | Site-to-site / Client VPN |
| **Azure** | VNet | Network Security Groups | VPN Gateway |
| **OCI** | VCN | Network Security Groups | FastConnect (dedicado) |

**Custo**: pague só pelo que usa.

---

## 11) Laboratórios Rápidos (Faça AGORA)

### 1. Descubra seu IP e máscara

```bash
Windows: ipconfig /all
Linux:   ip addr show
```

Procure por `IPv4 Address` / `inet` e `Subnet Mask` / `netmask`.

### 2. Mapeie seus servidores DNS

```bash
nslookup google.com
```

Veja qual servidor DNS respondeu.

### 3. Veja o caminho até o Google

```bash
Windows: tracert google.com
Linux:   traceroute google.com
```

Conta quantos "saltos" (routers) leva.

### 4. Veja o certificado de um site

```bash
openssl s_client -connect google.com:443 -servername google.com 2>/dev/null | openssl x509 -noout -dates
```

Veja quando expira.

### 5. Teste uma VPN

Se tiver acesso a uma VPN, ative e rode `curl ifconfig.me` de novo. O IP deve mudar.

---

## 12) Glossário Essencial

- **ARP**: descobrir qual MAC corresponde a qual IP (L2).
- **ICMP**: mensagens de controle (ping, traceroute); "alô, você tá aí?".
- **NAT**: traduzir IPs privados (10.0.0.1) para públicos (8.8.8.8).
- **VLAN**: criar sub-redes lógicas via tagging (L2).
- **SSH**: terminal remoto encriptado; mais seguro que telnet.
- **TLS**: protocolo de cripto; base de HTTPS, FTPS.
- **IPsec**: criptografia de rede (L3); base de VPN.
- **WPA3**: criptografia de Wi-Fi moderna.
- **BGP/OSPF**: protocolos que roteadores usam pra aprender rotas.
- **WAF**: firewall só pra HTTP/HTTPS; bloqueia ataques web.
- **IDS/IPS**: sistemas que **detectam** (IDS) ou **bloqueiam** (IPS) ataques.

---

## Próximos Passos

Parabéns. Você entendeu o mapa da rede e onde criptografia vive.

**Na próxima aula**, vamos sujar as mãos: montar um laboratório com Docker, criar nossas próprias chaves GPG, criptografar mensagens de verdade, e atacar/defender redes simuladas.

Traga curiosidade.

---

📊 **Visualizações:** ![hits](https://hits.sh/github.com/charles-josiah/Aulas/2026-07-Lab-Cripto-e-SegRedes/Aula_Intro_redes_criptografia.md.svg)
