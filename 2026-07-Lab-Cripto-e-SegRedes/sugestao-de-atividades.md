# Sugestão de Atividades — Criptografia e Segurança em Redes

**Professor:** Charles Josiah Rusch Alandt
**Turma:** GR CSTD 2026/1 1
**Modalidade:** EaD · 72h

---

## Filosofia de Ensino (Modus Operandi)

Baseado na experiência do semestre anterior (2025/2), a disciplina será conduzida no formato **Opção A**:

> **Mão na massa desde o primeiro dia.**

- Uso intensivo de laboratórios práticos (workshops)
- Demonstrações práticas dos serviços de rede
- Demonstrações práticas das ferramentas da UC
- Propostas de topologias e atividades para exemplificar visualmente o conteúdo
- Momentos síncronos para dúvidas e discussão
- Todo material publicado no GitHub da disciplina

---

## Ambiente de Laboratório

### Especificação Mínima (VirtualBox)

| VM | SO | CPU | RAM | Disco | Rede |
|----|----|-----|-----|-------|------|
| **serv1** | Ubuntu Server | 2 | 2 GB | 10 GB | Rede Interna |
| **serv2** | Ubuntu Server | 2 | 2 GB | 10 GB | Rede Interna |
| **firewall** | Debian Server | 2 | 2 GB | 5 GB | Bridge + Rede Interna |
| **kali** | Kali Linux (Live) | 2 | 2 GB | 10 GB | Rede Interna |

> O aluno pode usar **qualquer plataforma** (VirtualBox, VMware, Proxmox, AWS, OCI, Azure) desde que consiga executar as atividades propostas.

---

## Estrutura da Disciplina

A disciplina é dividida em **2 grandes blocos**:

### Bloco 1 — Serviços SEM Criptografia (Aulas 01–03)

Desenvolver todos os serviços de rede **sem qualquer proteção criptográfica**, analisar o tráfego, identificar vulnerabilidades e entender o "estado da arte" inseguro.

### Bloco 2 — Serviços COM Criptografia (Aulas 04–05)

Reconfigurar todos os serviços anteriores **ativando criptografia**, comparar com o bloco anterior e validar a eficácia das medidas.

---

## Sugestão de Atividades por Aula

---

### Aula 01 — Aula Inaugural

**Tema:** Fundamentos de Redes + História da Criptografia

| Atividade | Descrição | Tipo |
|-----------|-----------|------|
| **Quebra-gelo** | "Mapeando uma Rede" — usar traceroute + geolocation para mapear rota até um servidor | Prática guiada |
| **História da Criptografia** | Linha do tempo interativa (Egito Antigo → Criptografia Quântica) | Exposição dialogada |
| **Laboratório 1** | Instalação do VirtualBox + criação das VMs do ambiente base | Workshop |
| **Atividade complementar** | Pesquisar e postar no fórum: "qual o marco mais importante da história da criptografia?" | Assíncrona |

**Workshops relacionados:**
- Workshop de Criptografia e Assinatura Digital com GPG (apresentação do material)

---

### Aula 02 — Servidores e Serviços de Rede

**Tema:** Montagem do ambiente de serviços sem criptografia

| Atividade | Descrição | Tipo |
|-----------|-----------|------|
| **Laboratório 2** | Configurar servidor FTP (vsftpd) — **sem TLS** | Workshop |
| **Laboratório 3** | Configurar servidor Web (Apache/Nginx) — **sem HTTPS** | Workshop |
| **Laboratório 4** | Configurar SGBD (MySQL/PostgreSQL) — **sem SSL** | Workshop |
| **Análise** | Capturar tráfego FTP/HTTP com Wireshark/tcpdump — senha em texto claro | Prática guiada |
| **Desafio** | "O que um invasor consegue ver?" — demonstrar interceptação de tráfego com Kali | Demonstração |

**Objetivo:** Que o aluno veja com os próprios olhos como é exposto um serviço sem criptografia.

---

### Aula 03 — Criptografia na Prática

**Tema:** Introdução aos algoritmos criptográficos + GPG

| Atividade | Descrição | Tipo |
|-----------|-----------|------|
| **Workshop GPG** | Geração de par de chaves, criptografia simétrica e assimétrica, assinatura digital | Workshop |
| **Laboratório 5** | Criptografar/assinar mensagens entre colegas (troca de chaves públicas) | Atividade em dupla |
| **Laboratório 6** | Configurar Apache com HTTPS (SSL/TLS — certificado auto-assinado) | Workshop |
| **Laboratório 7** | Configurar vsftpd com TLS explícito (FTPES) | Workshop |
| **Comparação** | Capturar tráfego HTTPS vs HTTP e FTPES vs FTP — comparar o que o Wireshark "enxerga" | Prática guiada |

**Workshops relacionados:**
- Workshop-Criptografia-e-Assinatura-Digital-com-GPG

---

### Aula 04 — Segurança Avançada

**Tema:** Firewall, Proxy, PKI e autenticação segura

| Atividade | Descrição | Tipo |
|-----------|-----------|------|
| **Laboratório 8** | Configurar firewall (iptables/nftables) — bloqueio por porta/IP | Workshop |
| **Laboratório 9** | Configurar proxy Squid com autenticação | Workshop |
| **Laboratório 10** | PKI na prática: criar CA própria, emitir certificados para servidores | Workshop |
| **Laboratório 11** | Configurar MySQL/PostgreSQL com SSL/TLS | Workshop |
| **Análise** | Testar bloqueios do firewall — o que passa, o que é barrado? | Prática guiada |

---

### Aula 05 — Projeto Final e Comparação

**Tema:** Síntese, comparação e apresentação

| Atividade | Descrição | Tipo |
|-----------|-----------|------|
| **Laboratório 12** | Revisão geral: todos os serviços rodando COM criptografia | Workshop |
| **Comparação final** | Antes vs Depois: tabela comparativa de segurança de cada serviço | Atividade |
| **Hacking ético** | Tentativa de quebra de criptografia (John the Ripper, hashcat — demonstração) | Demonstração |
| **Plano de Resposta** | Elaborar plano de resposta a incidentes com base no cenário montado | Atividade |
| **Encerramento** | Discussão: "O que muda quando ativamos a criptografia?" | Debate |

---

## Fluxo de Trabalho Recomendado

```
Aula 01         Aula 02              Aula 03              Aula 04              Aula 05
  │                │                    │                    │                    │
  ▼                ▼                    ▼                    ▼                    ▼
┌────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│Setup   │   │ FTP   Web    │   │ GPG   HTTPS  │   │ Firewall     │   │ Revisão      │
│VMs     │──▶│ SGBD  (SEM)  │──▶│ FTPES (COM)  │──▶│ PKI   Proxy  │──▶│ Comparação   │
│Rede    │   │ Wireshark    │   │ Comparação   │   │ SGBD SSL     │   │ Hacking      │
└────────┘   └──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
                  │                                      │                    │
              Tráfego                                    │              "Antes vs
              visível                                    │              Depois"
              (senha em                                  │
              texto claro)                               │
                                                         ▼
                                              Tráfego cifrado
                                              (dados protegidos)
```

---

## Workshops Disponíveis no Repositório

| Workshop | Descrição | Localização |
|----------|-----------|-------------|
| Criptografia e Assinatura Digital com GPG | Geração de chaves, criptografia simétrica/assimétrica, assinatura digital | `Workshops/Workshop-Criptografia-e-Assinatura-Digital-com-GPG/` |

> Novos workshops serão adicionados conforme o avanço da turma.

---

## Dicas para o Aluno

1. **Monte o laboratório na primeira semana** — não deixe para depois
2. **Tire prints de cada etapa** — vai usar no relatório final
3. **Teste SEM criptografia primeiro** — só depois ative a proteção
4. **Use o Wireshark/tcpdump em cada etapa** — visualizar a diferença é o que fixa o aprendizado
5. **Participe dos momentos síncronos** — tire dúvidas ao vivo
6. **Repositório GitHub** — todo material fica disponível em:
   `https://github.com/charles-josiah/Aulas/tree/master/2026-07-Lab-Cripto-e-SegRedes/`
