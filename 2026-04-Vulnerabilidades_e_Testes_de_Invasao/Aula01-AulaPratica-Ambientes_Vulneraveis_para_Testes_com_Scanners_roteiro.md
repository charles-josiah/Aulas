# 📘 UC – Ambientes Vulneráveis para Testes com Scanners
---

# ⚖️ 1. PREMISSAS E RESPONSABILIDADE

A execução de testes de segurança deve observar, obrigatoriamente:

- utilização de ambiente isolado (laboratório controlado)
- autorização expressa para realização dos testes
- segregação de rede (Host-Only, NAT ou VLAN isolada)

> ⚠️ Testes sem autorização configuram infração legal.

---

# 🧠 2. ESTRUTURA DO LABORATÓRIO (2026)

## 📌 Topologia recomendada

- 🔴 Máquina atacante:
  - Kali Linux / Parrot OS

- 🟡 Alvos vulneráveis:
  - Metasploitable2 (ambiente legado)
  - DVWA (aplicação web)
  - OWASP Juice Shop (ambiente moderno)
  - APIs vulneráveis (OWASP API Security)
  - Containers vulneráveis (Docker)

- 🔵 Camada de controle:
  - Firewall (pfSense / OPNsense – opcional)
  - Monitoramento de logs

## Sugestão de topologia 

<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/aaffabad-ad5f-4be9-9234-761146d5bf8e" />
<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/35a0eb5d-7cbc-44d2-815a-353e1d787882" />
---

# 🔍 3. FASE 1 — ANÁLISE COM SCANNERS

## 🎯 Objetivo
Mapear a superfície de ataque.

## 🛠️ Ferramentas recomendadas

- Nmap (descoberta de rede)
- Nikto (análise web)
- OpenVAS / Greenbone (vulnerabilidades)
- OWASP ZAP (scanner moderno)
- Burp Suite (proxy e análise web)

## 📌 O que identificar

- hosts ativos  
- portas abertas  
- serviços e versões  
- possíveis vulnerabilidades  

> ⚖️ Scanner aponta indícios — não conclusões definitivas.

---

# 🧪 4. FASE 2 — VALIDAÇÃO MANUAL

## 🎯 Objetivo
Confirmar a existência real da vulnerabilidade.

## 📌 Técnicas

- análise manual de requisições HTTP
- manipulação de parâmetros
- validação de autenticação
- inspeção de respostas

> ⚖️ Nem todo alerta é vulnerabilidade real.  
> ⚖️ Validação é obrigatória.

---

# 💣 5. FASE 3 — EXPLORAÇÃO CONTROLADA

## 🎯 Objetivo
Comprovar o impacto da vulnerabilidade.

## ⚠️ Restrição
Somente em ambiente controlado.

## 📌 Exemplos

- SQL Injection validado  
- XSS funcional  
- bypass de autenticação  
- brute force controlado  

> ⚖️ Explorar para provar — não para causar dano.

---

# 🌐 6. SEGURANÇA EM AMBIENTES MODERNOS (2026)

## 📌 APIs

- falhas de autenticação  
- exposição indevida de endpoints  
- ausência de rate limiting  
- OWASP API Top 10  

## 📌 Containers

- imagens vulneráveis  
- portas expostas  
- falhas de isolamento  
- configurações inseguras  

## 📌 Cloud

- credenciais expostas  
- permissões excessivas  
- storage público  

---

# 🔐 7. HARDENING (DEFESA)

## 🎯 Objetivo
Reduzir a superfície de ataque.

## 📌 Ações recomendadas

- atualização contínua de sistemas  
- remoção de serviços desnecessários  
- políticas de senha + MFA  
- segmentação de rede  
- monitoramento e logs  

> ⚖️ Segurança começa antes do ataque.

---

# 📊 8. SEVERIDADE E CLASSIFICAÇÃO

## 📌 Modelo

- CVSS (FIRST)

## 📌 Critérios

- impacto  
- explorabilidade  
- contexto  

## 📊 Classificação

- Baixo  
- Médio  
- Alto  
- Crítico  

---

# 🧾 9. RELATÓRIO TÉCNICO

## 📌 Estrutura mínima

- identificação do alvo  
- descrição da vulnerabilidade  
- evidência técnica  
- nível de severidade  
- impacto  
- recomendação  

> ⚖️ Se não está documentado, não existe.

---

# 📎 10. EVIDÊNCIAS ESPERADAS DO ALUNO

Cada achado deverá conter, obrigatoriamente:

- 🎯 Alvo (IP ou aplicação)  
- 🔌 Porta  
- ⚙️ Serviço  
- 🐞 Vulnerabilidade identificada  
- 📊 Severidade (CVSS)  
- 📸 Evidência (print, log ou requisição)  
- 💣 Prova de conceito (quando aplicável)  
- 🛡️ Mitigação recomendada  

> ⚠️ Entregas sem evidência técnica não validam o achado.

---

# 🎓 11. DIRETRIZ FINAL

Scanner encontra.  
Analista valida.  
Profissional comprova.  
Especialista documenta e resolve.

---

# 🔥 MENSAGEM FINAL

Em segurança da informação:

**Conhecer não basta.  
Executar é obrigatório.**
