# Aula de Redes e Segurança – Laboratório 1

---

## Objetivos
1. Fazer o ambiente funcionar (roteador + rede interna).
2. Entender conceitos básicos de rede (IP, gateway, DNS).
3. Observar DHCP em funcionamento com Wireshark.
4. Diferenciar rede NAT x rede roteada.
5. Navegar na internet a partir da rede interna.
6. Comparar tcpdump x Wireshark.
7. Se possível: introduzir conceitos de OSI/TCP-IP, TLS, Firewalls.

---

## Estrutura da Aula

### **Parte 1 – Introdução e diagrama **
- Mostrar o diagrama do laboratório:
  - Rede externa (172.31.234.54).
  - Firewall/Roteador (fw-serv02).
  - Rede interna (192.168.123.0/24).
  - Servidores internos (ri-serv1, ri-slax01, ri-kali).
- Pontos de comentário:
  - “fw-serv02 faz papel de roteador + firewall.”
  - “Queremos que as VMs internas tenham internet via NAT.”
  - Conceitos: IP, máscara, gateway, DNS.

---

### **Parte 2 – Montando o roteador com script **
- Abrir e explicar `setup-router-only-for-lab.sh`. https://raw.githubusercontent.com/charles-josiah/scriptz/5e86225bd14ca208ff692388e0c23bcd095648e2/setup-router-only-for-lab.sh
- Etapas do script:
  1. **Ativar IP forwarding** (`net.ipv4.ip_forward=1`).
  2. **Regras de NAT com iptables** (`MASQUERADE`).
  3. **Servidor DHCP** (instalação + configuração).
  4. **Configuração estática da LAN** (192.168.100.1/24).
  5. **Persistência das regras** (iptables-save).
- Demonstrações práticas:
  - `ip a` (endereços de rede).
  - `systemctl status isc-dhcp-server`.
  - Cliente pedindo IP com `dhclient`.

---

### **Parte 3 – DHCP no Wireshark **
- Capturar tráfego em `ri-kali` ou `ri-slax01`.
- Renovar IP: `dhclient -r && dhclient`.
- Observar pacotes:
  - DISCOVER → OFFER → REQUEST → ACK.
- Destacar:
  - Origem (0.0.0.0) e destino (255.255.255.255).
  - IP oferecido.
  - Máscara, gateway, DNS.
- “Wireshark mostra tudo que o DHCP entregou.”

---

### **Parte 4 – NAT e saída para internet **
- Testes:
  - `ping 8.8.8.8` (sem DNS).
  - `ping google.com` (com DNS).
  - `curl http://ifconfig.me` (ver IP público).
- Pontos de comentário:
  - NAT mascara todos os clientes como um único IP.
  - Diferença:
    - NAT do VirtualBox (pronto, oculto).
    - NAT manual (nosso firewall).

---

### **Parte 5 – tcpdump x Wireshark**
- No firewall:  
  `tcpdump -i enp0s3 port 80 or port 443`
- No Kali: captura gráfica no Wireshark.
- Comparar:
  - **tcpdump**: leve, CLI, bom para servidores.
  - **Wireshark**: visual, detalhado, ótimo para análise.

---

### **Parte 6 – Conceitos extras rápidos**
1. **DNS**
   - `dig openai.com A`
   - `dig openai.com MX`
   - Explicar registros A, MX, TXT.
2. **Camadas OSI/TCP-IP**
   - Localizar DHCP, NAT, TLS.
3. **TLS**
   - `openssl s_client -connect google.com:443`
   - Mostrar validade do certificado.
4. **Firewalls**
   - Diferença L3/L4 (IP/porta) x L7 (aplicação).

---

### **Parte 7 – Fechamento e Duvidas**
- Quiz relâmpago:
  1. DHCP atua em qual camada?  
     → Aplicação (usa UDP 67/68).
  2. O que o NAT mascara?  
     → IPs privados → único IP público.
  3. HTTPS usa qual protocolo de segurança?  
     → TLS.
- Conclusão:
  - DHCP entrega IP automático.
  - NAT permite saída para internet.
  - tcpdump/Wireshark permitem diagnóstico.

---

:wq!
