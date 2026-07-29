# Sugestão de Atividades — Criptografia e Segurança em Redes

**Professor:** Charles Josiah Rusch Alandt
**Turma:** GR CSTD 2026/1 1
**Modalidade:** EaD · 72h

---

## Filosofia de Ensino (Modus Operandi)

A disciplina é fortemente inspirada na experiência prática do semestre anterior (2025/2), mantendo o formato **mão na massa desde o primeiro dia**:

- Laboratórios práticos como espinha dorsal do aprendizado
- Demonstrações ao vivo de serviços de rede e ferramentas de segurança
- Topologias e cenários que ilustram visualmente cada conceito
- Momentos síncronos focados em dúvidas e discussão
- Todo o material publicado e versionado no GitHub da disciplina
- Incentivo à experimentação e à curiosidade técnica

> O aluno não é espectador — é protagonista da própria aprendizagem.

> 💡 **Tem um tema que acha interessante? Peça!** Tópicos sugeridos pelos alunos são sempre bem-vindos — se tiver algum item relacionado ao conteúdo que ache relevante, me avise com antecedência para que eu possa preparar e adicionar durante nossas aulas.

---



## Ambiente de Laboratório

Estamos trabalhando em uma versão enxuta e moderna do ambiente, substituindo múltiplas VMs por uma abordagem **leve e baseada em containers**:

### Estrutura Atual (em evolução)


| Componente                 | Função                                                                | Tecnologia                 |
| -------------------------- | --------------------------------------------------------------------- | -------------------------- |
| **VM 1 — Servidor**        | Docker host com todos os serviços empacotados                         | Ubuntu Server + Docker     |
| **VM 2 — Kali/Atacante**   | Testes, varreduras e análise de tráfego                               | Kali Linux                 |
| **Containers**             | Serviços individuais (FTP, Web, SGBD, etc.)                           | Docker                     |
| **Containers vulneráveis** | Alvos propositalmente inseguros para validar criptografia e segurança | Juice Shop, dvwa, vulnapps |




### Por que containers?

- **Menos recursos**: 2 VMs substituem 4+ máquinas
- **Mais flexibilidade**: sobe e derruba serviços em segundos
- **Cenários vulneráveis**: containers como Juice Shop e DVWA permitem testar ataques reais em ambiente controlado
- **Portabilidade**: o mesmo `docker-compose.yml` funciona no VirtualBox, OCI, AWS, ou qualquer servidor Linux



### Quando precisar de mais poder computacional

O **Oracle Cloud Free Tier** oferece recursos Always Free que podem complementar o laboratório:

- [Visão Geral do Free Tier](https://docs.oracle.com/pt-br/iaas/Content/FreeTier/freetier.htm)
- [Recursos Always Free](https://docs.oracle.com/pt-br/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)

> O aluno é livre para usar **qualquer plataforma** (VirtualBox, VMware, Proxmox, OCI, AWS, Azure) — desde que consiga executar as atividades propostas, o ambiente é de sua escolha.

---



## Estrutura da Disciplina

A unidade curricular está organizada em **2 grandes blocos** que se complementam:

### Bloco 1 — Antes da Criptografia

Desenvolver e analisar serviços de rede **sem qualquer proteção criptográfica**. O objetivo é que o aluno veja com os próprios olhos o tráfego exposto, senhas em texto claro e a fragilidade de um ambiente inseguro — criando a motivação real para a criptografia.

### Bloco 2 — Depois da Criptografia

Reconfigurar os mesmos serviços **ativando criptografia** (GPG, SSL/TLS, HTTPS, FTPS, certificados digitais). Comparar os cenários, medir a diferença e validar a eficácia das medidas de proteção.

> A chave do aprendizado está na **comparação**: ver o antes e o depois com as mesmas ferramentas de análise (Wireshark, tcpdump, nmap).

---



## Workshop Inaugural — Criptografia e Assinatura Digital com GPG

**Tema desta semana:** Introdução prática à criptografia de chave pública com GPG.


| Atividade                  | Descrição                                                 |
| -------------------------- | --------------------------------------------------------- |
| Geração de par de chaves   | `gpg --full-generate-key` — RSA 4096                      |
| Criptografia simétrica     | Proteger um arquivo com senha (`gpg --symmetric`)         |
| Criptografia assimétrica   | Criptografar mensagem com a chave pública do destinatário |
| Assinatura digital         | Assinar um documento e validar a autenticidade            |
| Troca de chaves            | Alunos exportam e importam chaves públicas entre si       |
| Verificação de integridade | Comparar hash, assinatura e validação no GitHub           |


**Material de apoio:**
`Workshops/Workshop-Criptografia-e-Assinatura-Digital-com-GPG/README.md`

---



## Laboratórios e Workshops Planejados

A lista abaixo é um **cardápio**, uma **sugestão**, de possíveis laboratórios — serão escolhidos e adaptados conforme o andamento da turma, dúvidas que surgirem e o tempo disponível.

### Serviços de Rede (Bloco 1 — sem criptografia)


| #   | Laboratório            | Descrição                                                                                    |
| --- | ---------------------- | -------------------------------------------------------------------------------------------- |
| 01  | **Setup do Ambiente**  | Instalação do Docker, docker-compose e primeiros containers - somente tira duvidas eventuais |
| 02  | **FTP sem TLS**        | Servidor vsftpd em container — capturar senha em texto claro com Wireshark                   |
| 03  | **HTTP sem TLS**       | Servidor Nginx/Apache em container — tráfego HTTP visível                                    |
| 04  | **SGBD sem SSL**       | MySQL/PostgreSQL em container — consultas e credenciais expostas                             |
| 05  | **Análise de Tráfego** | Uso de tcpdump, Wireshark e nmap para enxergar o que trafega na rede                         |
| 06  | **DNS e Proxy**        | Consultas DNS expostas, proxy sem autenticação                                               |




### Criptografia e Segurança (Bloco 2 — com criptografia)


| #   | Laboratório                             | Descrição                                                            |
| --- | --------------------------------------- | -------------------------------------------------------------------- |
| 07  | **GPG na Prática**                      | Criptografia simétrica/assimétrica, assinatura digital e verificação |
| 08  | **HTTPS com Certificado Auto-Assinado** | Nginx/Apache com SSL/TLS — comparar tráfego com HTTP                 |
| 09  | **FTP com TLS (FTPS)**                  | FTP com TLS explícito — ver a diferença no Wireshark                 |
| 10  | **SGBD com SSL**                        | MySQL/PostgreSQL com conexão cifrada                                 |
| 11  | **PKI Caseira**                         | Criar própria Autoridade Certificadora (CA) e emitir certificados    |
| 12  | **Firewall (iptables/nftables)**        | Bloqueio por porta, IP e inspeção de tráfego                         |




### Cenários Vulneráveis e Hacking


| #   | Laboratório              | Descrição                                                                                |
| --- | ------------------------ | ---------------------------------------------------------------------------------------- |
| 13  | **Juice Shop**           | Loja vulnerável — testar SQLi, XSS e ver como a criptografia (ou falta dela) expõe dados |
| 14  | **Container Vulnerável** | Alvo propositalmente inseguro para demonstrar ataques de rede                            |
| 15  | **Quebra de Hash**       | John the Ripper / hashcat — demonstração de fragilidade de senhas fracas                 |
| 16  | **Wireshark Forense**    | Capturar tráfego de um ataque simulado e identificar as evidências                       |


---



## Fluxo de Trabalho Recomendado

```
┌──────────────────────────────────────────────────────────────────────┐
│                    BLOCO 1 — SEM CRIPTOGRAFIA                       │
│                                                                      │
│   Setup     FTP      Web      SGBD     Análise     Visualização     │
│   Docker   (sem     (sem     (sem     Wireshark   "tudo exposto"    │
│   + Kali   TLS)     TLS)     SSL)     /tcpdump    🚨               │
└──────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    BLOCO 2 — COM CRIPTOGRAFIA                       │
│                                                                      │
│   GPG      HTTPS    FTPES    SGBD      PKI          Comparação      │
│   Chaves   (TLS)    (TLS)    (SSL)     + CA        "dados seguros   │
│   + .asc                                                      ✅    │
└──────────────────────────────────────────────────────────────────────┘
```

---



## Workshops Publicados no Repositório


| Workshop                                  | Descrição                                                                             | Caminho                                                         |
| ----------------------------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| Criptografia e Assinatura Digital com GPG | Geração de chaves, criptografia simétrica/assimétrica, assinatura digital e validação | `Workshops/Workshop-Criptografia-e-Assinatura-Digital-com-GPG/` |


> Novos workshops e laboratórios serão adicionados conforme a turma avança.

---



## Dicas para o Aluno

1. **Monte o laboratório o quanto antes** — Docker + Kali rodando é o suficiente para começar
2. **Teste SEM criptografia primeiro** — só depois ative a proteção. A comparação é o que fixa o conteúdo
3. **Use o Wireshark/tcpdump em cada etapa** — ver a diferença entre tráfego cifrado e não cifrado é o aprendizado mais valioso da disciplina
4. **Container é seu amigo** — se errar, derruba e sobe de novo em segundos
5. **Participe dos momentos síncronos** — dúvidas ao vivo aceleram o aprendizado
6. **Repositório GitHub** — todo o material fica disponível em:
  `https://github.com/charles-josiah/Aulas/tree/master/2026-07-Lab-Cripto-e-SegRedes/`
7. **Free Tier da OCI** — se precisar de servidor adicional, aproveite os recursos gratuitos da Oracle Cloud

