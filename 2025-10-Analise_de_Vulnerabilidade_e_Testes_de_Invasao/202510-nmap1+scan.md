
# 🚀  NMAP - 1 

**Atacante:** Kali Linux  
**Alvo:** Metasploitable2 (ex.: 192.168.56.101)

---

## 1 — Introdução ao Nmap 

Nmap é usado para:
- Descobrir hosts
- Mapear portas
- Identificar versões
- Descobrir SO
- Executar scripts NSE
- Localizar vulnerabilidades

Instalação:
```bash
sudo apt install nmap
nmap -V
```

---

## 2 — Preparando o Laboratório 

Descobrir sua rede:
```bash
ip a
ip route
```

Descobrir IP do Metasploitable:
```bash
netdiscover -r 192.168.56.0/24
```

---

## 3 — Host Discovery

Ping scan:
```bash
nmap -sn 192.168.56.101
```

Varredura da rede:
```bash
nmap -sn 192.168.56.0/24
```

ARP discovery:
```bash
sudo nmap -PR -sn 192.168.56.0/24
```

---

## 4 — Varredura de Portas 

Scan rápido:
```bash
nmap 192.168.56.101
```

Stealth scan:
```bash
sudo nmap -sS 192.168.56.101
```

Todas as portas:
```bash
sudo nmap -p- -sS 192.168.56.101
```

UDP scan:
```bash
sudo nmap -sU 192.168.56.101
```

---

## 5 — Identificação de Serviços

Version scan:
```bash
nmap -sV 192.168.56.101
```

Modo agressivo:
```bash
sudo nmap -A 192.168.56.101
```

---

## 6 — Identificação do Sistema Operacional

```bash
sudo nmap -O 192.168.56.101
```

---

## 7 — NSE (Parte 1) — Scripts Básicos

Listar scripts:
```bash
ls /usr/share/nmap/scripts/
```

Rodar categorias:
```bash
nmap --script default,safe 192.168.56.101
```

Scripts de vulnerabilidade:
```bash
sudo nmap --script vuln 192.168.56.101
```

---

## 8 — NSE (Parte 2) — Vulnerabilidades Reais 

Samba MS17-010:
```bash
sudo nmap --script smb-vuln-ms17-010 -p445 192.168.56.101
```

FTP Anônimo:
```bash
nmap -p21 --script ftp-anon 192.168.56.101
```

MySQL sem senha:
```bash
nmap --script mysql-empty-password -p3306 192.168.56.101
```

Vulnerabilidades HTTP:
```bash
nmap --script http-vuln* -p80 192.168.56.101
```

---

## 9 — Varredura Completa Integrada

```bash
sudo nmap -A -sV --script vuln 192.168.56.101 -oN metasploitable_full_scan.txt
```

---

## 10 — Scan Total

```bash
sudo nmap -sS -sV -sU -A -O -p- --script vuln 192.168.56.101 -oN full_metasploit_scan.txt
```

---

## 📊 Achados comuns no Metasploitable2
- FTP permite login anônimo  
- SSH fraco  
- Telnet exposto  
- Apache 2.2 vulnerável  
- Samba vulnerável  
- MySQL sem senha  
- PostgreSQL vulnerável  
- Tomcat Manager fraco  

---

