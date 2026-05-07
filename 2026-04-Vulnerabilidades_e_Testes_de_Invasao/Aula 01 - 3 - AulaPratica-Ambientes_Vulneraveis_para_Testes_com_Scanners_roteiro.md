# 📘 UC - Ambientes Vulneraveis para Testes com Scanners

---

> [!CAUTION]
> **AVISO DE ÉTICA E RESPONSABILIDADE**
> Este conteúdo e ambiente foram elaborados exclusivamente para fins educacionais, laboratoriais e de pesquisa em ambiente controlado.
>
> **Uso estritamente proibido** em sistemas de terceiros ou redes de produção sem autorização formal. O uso deste material em qualquer contexto que viole normas legais é de inteira responsabilidade do executor.
>
> **DISCLAIMER DE ESTABILIDADE E SUPORTE:**
> Este laboratório foi testado e validado pelo instrutor. No entanto, o ecossistema de TI (versões de kernels, imagens Docker e provedores do Vagrant) evolui rapidamente. 
> 
> **Fique atento:**
> - A execução é permitida apenas em laboratório isolado (VM dedicada, Docker Lab, NAT/Host-Only ou rede segregada).
> - Ambientes de laboratório são sensíveis e dependentes de hardware.
> - Falhas podem ocorrer devido a drivers, virtualização desativada (BIOS/VT-x) ou conflitos de rede local.
> - **Ajustes manuais podem ser necessários** durante o processo para adequar o lab à sua máquina específica.

---

---

## ⚖️ 1. Premissas e responsabilidade

A execucao de testes de seguranca deve observar, obrigatoriamente:

- utilizacao de ambiente isolado (laboratorio controlado);
- autorizacao expressa para realizacao dos testes;
- segregacao de rede (Host-Only, NAT ou VLAN isolada).

---

## 🧠 2. Estrutura do laboratorio

### 2.1 Topologia recomendada

- **Maquina atacante:** Kali Linux ou Parrot OS;
- **alvos vulneraveis:** Metasploitable2, DVWA, OWASP Juice Shop, APIs vulneraveis e containers vulneraveis;
- **camada de controle:** firewall (pfSense/OPNsense, opcional) e monitoramento de logs.

### 2.2 Sugestao de topologia

## [Topologia sugerida](https://github.com/charles-josiah/Aulas/blob/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/Aula 01 - 4 - Proposta_de_estrutura_do_Laboratorio_Baseada_em_docker.md)

## 🔍 3. Fase 1 - Analise com scanners

### 3.1 Objetivo

Mapear a superficie de ataque do ambiente.

### 3.2 Ferramentas recomendadas

- Nmap (descoberta de rede);
- Nikto (analise web);
- OpenVAS/Greenbone (vulnerabilidades);
- OWASP ZAP (scanner moderno);
- Burp Suite (proxy e analise web).

### 3.3 O que identificar

- hosts ativos;
- portas abertas;
- servicos e versoes;
- possiveis vulnerabilidades.

> Scanner aponta indicios; nao produz conclusoes definitivas sem validacao.

---

## 🧪 4. Fase 2 - Validacao manual

### 4.1 Objetivo

Confirmar a existencia real das vulnerabilidades indicadas.

### 4.2 Tecnicas sugeridas

- analise manual de requisicoes HTTP;
- manipulacao de parametros;
- validacao de autenticacao;
- inspecao de respostas.

> Nem todo alerta e vulnerabilidade real. Validacao tecnica e obrigatoria.

---

## 💣 5. Fase 3 - Exploracao controlada

### 5.1 Objetivo

Comprovar o impacto pratico da vulnerabilidade validada.

### 5.2 Restricao obrigatoria

Somente em ambiente controlado e autorizado.

### 5.3 Exemplos de provas de conceito

- SQL Injection validado;
- XSS funcional;
- bypass de autenticacao;
- brute force controlado.

> Explorar para comprovar impacto, nunca para causar dano.

---

## 🌐 6. Seguranca em ambientes modernos

### 6.1 APIs

- falhas de autenticacao;
- exposicao indevida de endpoints;
- ausencia de rate limiting;
- OWASP API Top 10.

### 6.2 Containers

- imagens vulneraveis;
- portas expostas;
- falhas de isolamento;
- configuracoes inseguras.

### 6.3 Cloud

- credenciais expostas;
- permissoes excessivas;
- storage publico.

---

## 🔐 7. Hardening (defesa)

### 7.1 Objetivo

Reduzir a superficie de ataque antes, durante e apos os testes.

### 7.2 Acoes recomendadas

- atualizacao continua de sistemas;
- remocao de servicos desnecessarios;
- politicas de senha com MFA;
- segmentacao de rede;
- monitoramento e logs.

> Seguranca eficaz comeca antes do ataque.

---

## 📊 8. Severidade e classificacao

### 8.1 Modelo de referencia

- CVSS (FIRST).

### 8.2 Criterios de analise

- impacto;
- explorabilidade;
- contexto.

### 8.3 Escala de classificacao

- baixo;
- medio;
- alto;
- critico.

---

## 🧾 9. Relatorio tecnico

### 9.1 Estrutura minima

- identificacao do alvo;
- descricao da vulnerabilidade;
- evidencia tecnica;
- nivel de severidade;
- impacto;
- recomendacao.

> Se nao esta documentado, nao existe do ponto de vista tecnico.

---

## 📎 10. Evidencias esperadas

Cada achado deve conter obrigatoriamente:

- alvo (IP ou aplicacao);
- porta;
- servico;
- vulnerabilidade identificada;
- severidade (CVSS);
- evidencia (print, log ou requisicao);
- prova de conceito (quando aplicavel);
- mitigacao recomendada.

> Entregas sem evidencia tecnica nao validam o achado.

---

## 🎓 11. Diretriz final

- Scanner encontra.  
- Analista valida.  
- Profissional comprova.  
- Especialista documenta e resolve.

---

> [!CAUTION]
> **AVISO DE ÉTICA E RESPONSABILIDADE**
> Este conteúdo e ambiente foram elaborados exclusivamente para fins educacionais, laboratoriais e de pesquisa em ambiente controlado.
>
> **Uso estritamente proibido** em sistemas de terceiros ou redes de produção sem autorização formal. O uso deste material em qualquer contexto que viole normas legais é de inteira responsabilidade do executor.
>
> **DISCLAIMER DE ESTABILIDADE E SUPORTE:**
> Este laboratório foi testado e validado pelo instrutor. No entanto, o ecossistema de TI (versões de kernels, imagens Docker e provedores do Vagrant) evolui rapidamente. 
> 
> **Fique atento:**
> - A execução é permitida apenas em laboratório isolado (VM dedicada, Docker Lab, NAT/Host-Only ou rede segregada).
> - Ambientes de laboratório são sensíveis e dependentes de hardware.
> - Falhas podem ocorrer devido a drivers, virtualização desativada (BIOS/VT-x) ou conflitos de rede local.
> - **Ajustes manuais podem ser necessários** durante o processo para adequar o lab à sua máquina específica.

---