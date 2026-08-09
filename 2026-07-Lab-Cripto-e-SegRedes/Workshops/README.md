# Workshops

Workshops práticos da disciplina de Criptografia e Segurança em Redes — 2026/07.

## Workshop: Criptografia e Assinatura Digital com GPG

Acesse o [workshop completo](Workshop-Criptografia-e-Assinatura-Digital-com-GPG/README.md).

Tópicos abordados:
- Criptografia de arquivos com GPG/PGP
- Assinatura digital destacada
- Verificação de autenticidade e integridade
- Descriptografia e validação de assinaturas

---

## Workshop: Captura de Tráfego HTTP (Credenciais em Texto Claro)

Acesse o [workshop completo](01-Captura_de_Tráfego_HTTP.md).

Tópicos abordados:
- Por que HTTP sem criptografia expõe dados na rede
- Setup de servidor Flask vulnerável em Docker
- Captura de tráfego com tcpdump no Kali
- Extração de credenciais em plaintext (username/password)
- Entendendo por que HTTPS é essencial

---

## Workshop: Captura de Tráfego FTP (Senha e Comandos em Texto Claro)

Acesse o [workshop completo](02-Captura_de_Tráfego_FTP.md).

Tópicos abordados:
- Por que FTP sem criptografia expõe senha e comandos na rede
- Setup de servidor FTP vulnerável em Docker (pyftpdlib)
- Captura de tráfego com tcpdump no Kali (controle porta 21 + dados 30000-30100)
- Extração de credenciais e comandos em plaintext (USER/PASS/LIST/RETR/STOR)
- Entendendo por que SFTP/FTPS é essencial

---

## Workshop: Captura de Tráfego MySQL (Senha, Queries e Permissionamento em Texto Claro)

Acesse o [workshop completo](03-Captura_de_Tráfego_MySQL.md).

Tópicos abordados:
- Por que MySQL sem TLS expõe senhas, queries e dados na rede
- Setup de MySQL 8.0 em Docker (porta 3306) sem criptografia
- Captura de tráfego com tcpdump no Kali
- Extração de queries com tshark (`mysql.query`)
- Reconstrução de um banco completo a partir de um `.pcap`
- Mini-howto de permissionamento (GRANT/REVOKE) e princípio do menor privilégio
- Entendendo por que TLS é essencial em conexões de banco de dados

---

## Workshop: Ataques de Interceptação e Injeção de Dados em Protocolo MQTT (IoT) sem Criptografia

Acesse o [workshop completo](04-Captura_de_Tráfego_MQTT.md).

Tópicos abordados:
- Por que MQTT sem TLS expõe credenciais (usuário/senha no CONNECT) e dados na rede
- Setup de broker Eclipse Mosquitto 2.x em Docker (porta 1883) sem criptografia
- Sniffing de credenciais e payloads JSON com tcpdump/tshark no Kali
- Injeção de dados falsos (spoofing) de sensores IoT com `atacante.py` e `mosquitto_pub`
- Demonstração do impacto: alerta de temperatura crítica falsa no dashboard
- ACL por tópico como mitigação parcial e entendimento de por que TLS é essencial

---

📊 **Visualizações:** ![hits](https://hits.sh/github.com/charles-josiah/Aulas/2026-07-Lab-Cripto-e-SegRedes/Workshops/README.md.svg)

