# Workshops

Workshops práticos da disciplina de Criptografia e Segurança em Redes — 2026/07.

## Workshop: Criptografia e Assinatura Digital com GPG

Acesse o [workshop completo](05-Criptografia_e_Assinatura_Digital_com_GPG/README.md).

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

## Workshop: Criptografia Híbrida Corporativa (Simétrica + Assimétrica)

Acesse o [workshop completo](06-Criptografia_Simetrica_e_Assimetrica_Corporativa.md).

Tópicos abordados:
- Cenário corporativo: compartilhar relatório confidencial com garantia de autoria, integridade e sigilo
- As três chaves em uso combinado: chave privada, chave pública e chave simétrica
- Hash SHA-256, efeito avalanche e verificação de integridade
- Cifragem simétrica com AES-256-CBC e compactação + cifragem de múltiplos arquivos
- Assinatura digital com RSA-2048: diferença entre criptografar e assinar
- Distribuição segura da chave simétrica (envelopamento RSA) — base da criptografia híbrida
- Mensagem secreta de retorno destinada exclusivamente ao dono da chave privada
- Ataques: vazamento de chave simétrica, chave privada incorreta, substituição de chave pública (MITM), adulteração de arquivo e senha fraca (dicionário)
- Desafio final com solução comentada (Diretor Financeiro → Diretor Jurídico)

---

## Workshop: Certificados Digitais, PKI e TLS na Prática

Acesse o [workshop completo](07-Certificados_Digitais_PKI_e_TLS.md).

Tópicos abordados:
- O problema: como confiar em uma chave pública (MITM do Workshop 06)
- Certificado digital X.509: campos, SAN, validade, assinatura da CA
- PKI, Autoridade Certificadora (AC) e ICP-Brasil (A1/A3/A4/S/T)
- Cadeia de confiança: do certificado até a raiz confiável
- Certificado autoassinado × emitido por CA
- Geração de certificado autoassinado e inspeção com `openssl x509`
- Mini-CA com OpenSSL: AC raiz, CSR e emissão de certificado para servidor
- Verificação de cadeia com `openssl verify` e hostname com `-checkhost`
- HTTPS na prática: `s_server`/`s_client` com validação de ponta a ponta
- HTTP × HTTPS com tcpdump (fechando o ciclo dos Workshops 01–04)
- Auditoria com `testssl.sh` (opcional)
- Ataques: certificado expirado, hostname mismatch, cadeia quebrada, autoassinado não confiável e MITM com certificado falso
- Desafio final com solução comentada (portal interno da empresa)

---

## Workshop: HTTP vs HTTPS — Sniffing com Nginx em Docker

Acesse o [workshop completo](08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker.md) e os [arquivos do laboratório](08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker/).

Tópicos abordados:
- Servidor nginx em Docker usando os certificados da PKI criada no Workshop 07
- Duas portas servindo o mesmo conteúdo: 80 (HTTP, sem criptografia) e 443 (HTTPS, com TLS)
- Área restrita com login e senha (basic auth) nas duas portas
- Sniffing com tcpdump de outra estação e comparação dos pacotes
- Prova: senha em base64 e documento inteiro legíveis no HTTP; apenas handshake ilegível no HTTPS
- Decodificação da senha capturada (`base64 -d`) e por que base64 não é criptografia

---

📊 **Visualizações:** ![hits](https://hits.sh/github.com/charles-josiah/Aulas/2026-07-Lab-Cripto-e-SegRedes/Workshops/README.md.svg)

