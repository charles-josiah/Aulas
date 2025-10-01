
# Wireshark — Laboratório prático: Telnet & vsftpd
> Laboratório para captura e análise de pacotes com **Wireshark / tcpdump / tshark**, focado em **Telnet** e **vsftpd (FTP em texto claro)**.  
> **Servidor alvo:** `192.168.100.11`

---

## 1. Aviso de ética e segurança
**IMPORTANTE:** execute este laboratório **somente** em redes/hosts que você administra ou para os quais possui autorização explícita por escrito. Capturar tráfego de terceiros sem permissão é ilegal. Use este material para fins de auditoria, ensino e mitigação.

---

## 2. Objetivos
- Demonstrar que Telnet e FTP transmitem credenciais e conteúdo em texto claro.  
- Aprender a capturar tráfego com `tcpdump`/`tshark` e analisar com Wireshark.  
- Extrair credenciais e conteúdo via **Follow TCP Stream** e filtros.  
- Apontar/discutir mitigação (SSH/SFTP/FTPS, VPN, IDS/IPS).
- Executar exploit no ftp server - https://github.com/padsalatushal/CVE-2011-2523

---

## 3. Pré-requisitos e ambiente
- Máquina analista com Wireshark (GUI) e/ou `tcpdump`/`tshark` (CLI).  
- Acesso de rede à sub-rede do servidor `192.168.100.11`.  
- Serviços ativos no servidor:
  - Telnet (TCP 23)
  - vsftpd (TCP 21; portas de dados conforme configuração)
- Acesso a switch com SPAN/Mirror se a captura for em rede fisicamente separada.  
- Permissão administrativa para executar captura na interface (ex.: `sudo`).

---

## 4. Topologia de exemplo
```
[Cliente (telnet/ftp)] --- [Switch (SPAN para)] --- [Capturador (Wireshark/tcpdump)]
                                 |
                              [Servidor 192.168.100.11 (telnet, vsftpd)]
```
Alternativa: execute a captura diretamente na máquina cliente enquanto se conecta ao servidor.

---

## 5. Comandos de captura (salvar para análise posterior)

### Capturar tudo do host alvo (arquivo pcap):
```bash
sudo tcpdump -i eth0 -w captura_lab.pcap host 192.168.100.11
```

### Filtrar apenas Telnet/FTP:
```bash
sudo tcpdump -i eth0 -w captura_lab.pcap 'host 192.168.100.11 and (port 21 or port 20 or port 23)'
```

### Captura com tshark (linha de comando):
```bash
sudo tshark -i eth0 -f 'host 192.168.100.11 and (port 21 or port 20 or port 23)' -w captura_lab.pcap
```

---

## 6. Filtros Wireshark (Display Filters)
- Tráfego com o servidor:
```
ip.addr == 192.168.100.11
```
- Telnet:
```
tcp.port == 23
# ou
telnet
```
- FTP (controle):
```
tcp.port == 21
# ou
ftp
```
- FTP (dados — porta 20 e portas passivas):
```
tcp.port == 20 || ftp.data
```
- Conversas Telnet/FTP do servidor:
```
ip.addr == 192.168.100.11 && (tcp.port == 21 || tcp.port == 20 || tcp.port == 23)
```

---

## 7. Passo a passo do laboratório (fluxo sugerido)
1. Inicie captura no Wireshark (ou `tcpdump`) na interface correta com filtro para `192.168.100.11`.  
2. No cliente, abra sessão Telnet:
```bash
telnet 192.168.100.11
# login: <USER>
# password: <PASS>
# comandos: whoami; ls -la
```
> **ATENÇÃO:** substitua `<USER>` e `<PASS>` por credenciais de laboratório autorizadas. Não use credenciais reais em materiais públicos.

3. Em seguida, testar FTP (vsftpd) em modo passivo:
```bash
ftp 192.168.100.11
# USER <FTP_USER>
# PASS <FTP_PASS>
# get segredo.txt
```
4. Durante cada atividade observe a captura no Wireshark em tempo real.  
5. Pare a captura quando concluir e salve o `.pcap` para análise.

---

## 8. Como analisar — passos práticos no Wireshark

### A. Telnet
1. Aplique o filtro `telnet` ou `tcp.port == 23`.  
2. Selecione um pacote de dados da sessão Telnet.  
3. Clique com o botão direito → **Follow** → **TCP Stream**.  
4. No diálogo, escolha **Show data as: ASCII**. Você verá prompts, usuário, senha e comandos em texto claro.  
5. Pode salvar o conteúdo com **Save As** no diálogo.

### B. FTP (controle e dados)
1. Aplique `ftp` ou `tcp.port == 21` para ver controle. Mensagens `USER` e `PASS` aparecem aqui.  
2. Use **Follow → TCP Stream** para visualizar a sessão de controle (mostrará `USER` e `PASS`).  
3. Para o canal de dados:
   - Em **modo passivo**, identifique o comando `227 Entering Passive Mode (h1,h2,h3,h4,p1,p2)`. Calcule a porta: `p1*256 + p2`. Filtre por essa porta e use **Follow TCP Stream** para ver o conteúdo do arquivo (se texto).
   - Em **modo ativo**, o servidor conecta de volta do porto 20 do servidor para uma porta efêmera do cliente — filtre por essa conexão.

---

## 9. Exemplos esperados (ilustrativos)
- Telnet stream mostra algo como:
```
login: labuser
password: labpass
$ whoami
labuser
$ ls
secreto.txt
```

- FTP controle mostra:
```
USER ftpuser
331 Password required
PASS FTPpwd123
230 Login successful
PASV
227 Entering Passive Mode (192,168,100,11,195,21)
RETR segredo.txt
```

- Porta de dados calculada (exemplo): `195*256 + 21 = 49941`  
> Observação: os valores de `p1`/`p2` variam; calcule sempre com a fórmula `p1*256 + p2`.

---

## 10. Extração via CLI (tshark)
- Seguir TCP stream Telnet (stream index 0 — adaptável):
```bash
tshark -r captura_lab.pcap -qz follow,tcp,raw,0
```

- Listar pacotes FTP:
```bash
tshark -r captura_lab.pcap -Y ftp -V
```

> Nota: a sintaxe pode variar entre versões; o GUI do Wireshark tem **Follow TCP Stream** mais amigável.

---

## 11. Check-list antes do hands-on
- [ ] Autorização escrita para testes.  
- [ ] Serviços ativos em `192.168.100.11` (Telnet/FTP).  
- [ ] Capturador com Wireshark/tshark/tcpdump instalado.  
- [ ] Se em rede física: switch com SPAN configurado ou captura na máquina cliente.  
- [ ] Salvamento de pcap para registro.

---

## 12. Mitigações e recomendações
1. Substituir **Telnet** por **SSH** (utiliza criptografia).  
2. Substituir **FTP** por **SFTP** (via SSH) ou **FTPS** (FTP sobre TLS).  
3. Implementar VPN para conexões administrativas entre redes.  
4. Habilitar log detalhado e IDS/IPS que detectem credenciais em texto claro.  
5. Segmentar rede e isolar serviços legados em VLANs protegidas.

---

## 13. Anexos úteis (blocos de comando copiados)
```bash
# tcpdump salvando só Telnet/FTP
sudo tcpdump -i eth0 -w captura_lab.pcap 'host 192.168.100.11 and (port 21 or port 20 or port 23)'

# tshark: extrair streams (exemplo)
sudo tshark -r captura_lab.pcap -qz follow,tcp,raw,0

# simples filtro Wireshark
ip.addr == 192.168.100.11 && (tcp.port == 21 || tcp.port == 23 || tcp.port == 20)
```

---

## 14. Notas finais e boas práticas
- Mantenha cópias dos pcap geradas e registre horário/objetivo da captura.  
- **Nunca** poste em repositórios públicos pcap com credenciais reais. Se for subir demonstrações no GitHub, **remova/anonymize** credenciais e dados sensíveis (substitua por `<USER>` / `<PASS>` e `secreto.txt` por conteúdo fictício).  
- Para material didático público, inclua um aviso de não executar sem autorização.
---  


:wq!
