# Apresentação: Introdução à Segurança em Redes e Criptografia

## Slide 1: Título e Introdução
**Título**: Introdução à Segurança em Redes e Criptografia  
**Conteúdo**:  
- Boas-vindas à turma de graduação em Segurança da Informação.  
- Objetivo: Entender os fundamentos de segurança em redes, criptografia, programas maliciosos e formas de ataques.  
- Por que este tema é relevante? Vivemos em um mundo conectado, onde dados são alvos constantes de ataques.  
- Estrutura da apresentação: Conceitos, ameaças, ataques e reflexão final.  
**Visual**: Imagem de uma rede digital com cadeado (símbolo de segurança).  
**Duração**: 2 minutos.

## Slide 2: Por que a Segurança da Informação é tão importante?  
**Pergunta Reflexiva**:  
- Por que a Segurança da Informação é tão importante?  
**Conteúdo**:  
- A Segurança da Informação protege dados sensíveis (pessoais, financeiros, corporativos).  
- Impactos de falhas: roubo de identidade, prejuízos financeiros, perda de privacidade.  
- Exemplos reais: Vazamento de dados (ex.: Equifax, 2017) e ataques ransomware (ex.: WannaCry).  
- Discussão: O que acontece se não protegermos nossos sistemas?  
**Visual**: Gráfico mostrando aumento de ciberataques (ex.: estatísticas de 2020-2025).  
**Duração**: 3 minutos (com interação).

## Slide 3: Por que a Criptografia é tão importante hoje? Onde a utilizamos?  
**Pergunta Reflexiva**:  
- Por que a criptografia é essencial nos dias de hoje? Onde ela está presente no nosso cotidiano?  
**Conteúdo**:  
- **Importância**: Garante confidencialidade, integridade e autenticidade dos dados.  
- **Onde usamos?**:  
  - HTTPS em sites (ex.: bancos, e-commerce).  
  - Mensagens em aplicativos (ex.: WhatsApp com criptografia ponta a ponta).  
  - Assinaturas digitais, VPNs, blockchain (ex.: Bitcoin).  
- Sem criptografia, dados em trânsito podem ser interceptados.  
- Exemplo: Como o HTTPS usa TLS para proteger suas compras online.  
**Visual**: Diagrama simples de criptografia (chave pública/privada ou HTTPS).  
**Duração**: 3 minutos (com exemplos práticos).

## Slide 4: Fundamentos de Segurança em Redes  
**Conteúdo**:  
- Definição: Segurança em redes protege a infraestrutura de comunicação contra acesso não autorizado, ataques e vazamentos.  
- Princípios: Confidencialidade, Integridade, Disponibilidade (CIA).  
- Componentes: Firewalls, IDS/IPS, VPNs, segmentação de rede.  
- Desafios: Redes modernas (cloud, IoT) aumentam a superfície de ataque.  
**Visual**: Esquema de uma rede com camadas de proteção.  
**Duração**: 3 minutos.

## Slide 5: Introdução à Criptografia  
**Conteúdo**:  
- Definição: Transformação de dados legíveis em dados ilegíveis sem a chave correta.  
- Tipos:  
  - **Simétrica**: Mesma chave para criptografar/descriptografar (ex.: AES).  
  - **Assimétrica**: Chave pública e privada (ex.: RSA).  
- Aplicações: Assinaturas digitais, certificados SSL/TLS, criptografia de discos.  
**Visual**: Exemplo de criptografia simétrica vs. assimétrica.  
**Duração**: 3 minutos.

## Slide 6: Programas Maliciosos - Visão Geral  
**Conteúdo**:  
- O que são? Softwares projetados para causar danos, roubar dados ou comprometer sistemas.  
- Principais tipos abordados:  
  - Cavalos de Troia.  
  - Vírus.  
  - Worms.  
  - Backdoors.  
- Impactos: Perda de dados, interrupção de serviços, roubo de credenciais.  
**Visual**: Ícones representando diferentes malwares.  
**Duração**: 2 minutos.

## Slide 7: Cavalos de Troia  
**Conteúdo**:  
- Definição: Programas que parecem legítimos, mas executam ações maliciosas.  
- Exemplos: Falso antivírus, apps piratas.  
- Como funcionam: Enganam o usuário para instalação; podem roubar dados ou abrir backdoors.  
- Prevenção: Não baixar software de fontes não confiáveis, usar antivírus.  
**Visual**: Imagem de um cavalo de Troia digital.  
**Duração**: 3 minutos.

## Slide 8: Vírus  
**Conteúdo**:  
- Definição: Código malicioso que se anexa a programas legítimos e se espalha ao executá-los.  
- Características: Precisa de ação do usuário para se propagar.  
- Exemplo: Vírus em anexos de e-mail.  
- Prevenção: Atualizar sistemas, evitar anexos suspeitos.  
**Visual**: Fluxograma de propagação de um vírus.  
**Duração**: 3 minutos.

## Slide 9: Worms  
**Conteúdo**:  
- Definição: Malware que se propaga sozinho pela rede, explorando vulnerabilidades.  
- Exemplo: WannaCry (explorou falha no Windows).  
- Impactos: Consome recursos, derruba redes.  
- Prevenção: Atualizações regulares, firewalls.  
**Visual**: Diagrama de propagação de um worm em uma rede.  
**Duração**: 3 minutos.

## Slide 10: Backdoors  
**Conteúdo**:  
- Definição: Ponto de entrada secreto em um sistema, permitindo acesso não autorizado.  
- Como são criados? Por malwares, falhas de configuração ou intencionalmente.  
- Exemplo: Backdoors em roteadores mal configurados.  
- Prevenção: Monitoramento de rede, auditorias de segurança.  
**Visual**: Imagem de uma “porta dos fundos” digital.  
**Duração**: 3 minutos.

## Slide 11: Formas de Ataques - Visão Geral  
**Conteúdo**:  
- O que são? Técnicas usadas por atacantes para comprometer sistemas ou redes.  
- Tipos abordados:  
  - Honeypot/Honeynet.  
  - Hoax.  
  - Buffer Overflow.  
  - DNS Spoofing.  
  - DoS.  
  - Sniffing.  
  - IP Spoofing.  
- Objetivo: Entender como funcionam e como se proteger.  
**Visual**: Ícones representando diferentes ataques.  
**Duração**: 2 minutos.

## Slide 12: Honeypot e Honeynet  
**Conteúdo**:  
- **Honeypot**: Sistema falso para atrair e estudar atacantes.  
- **Honeynet**: Rede de honeypots para simular ambientes complexos.  
- Uso: Identificar táticas de invasores, coletar dados para defesa.  
- Exemplo: Honeypot capturando tentativas de login SSH.  
**Visual**: Diagrama de um honeypot em uma rede.  
**Duração**: 3 minutos.

## Slide 13: Hoax  
**Conteúdo**:  
- Definição: Falsas ameaças ou alertas disseminados para enganar usuários.  
- Exemplo: E-mails falsos prometendo prêmios ou alertando sobre vírus inexistentes.  
- Impactos: Desinformação, pânico, cliques em links maliciosos.  
- Prevenção: Verificar fontes, evitar compartilhar sem checar.  
**Visual**: Exemplo de e-mail hoax.  
**Duração**: 2 minutos.

## Slide 14: Buffer Overflow  
**Conteúdo**:  
- Definição: Exploração de falhas em software que permite sobrescrever memória.  
- Como funciona? Envia mais dados do que o programa pode lidar, permitindo executar código malicioso.  
- Exemplo: Ataques em softwares desatualizados.  
- Prevenção: Atualizações, validação de entrada de dados.  
**Visual**: Diagrama de um buffer overflow.  
**Duração**: 3 minutos.

## Slide 15: DNS Spoofing  
**Conteúdo**:  
- Definição: Falsificação de respostas DNS para redirecionar usuários a sites maliciosos.  
- Exemplo: Redirecionar “banco.com” para um site falso.  
- Impactos: Roubo de credenciais, phishing.  
- Prevenção: DNSSEC, verificação de certificados.  
**Visual**: Esquema de DNS spoofing.  
**Duração**: 3 minutos.

## Slide 16: DoS (Denial of Service)  
**Conteúdo**:  
- Definição: Ataque que sobrecarrega um sistema para torná-lo indisponível.  
- Tipos: DDoS (distribuído), SYN flood.  
- Exemplo: Ataques DDoS em servidores de jogos.  
- Prevenção: Firewalls, mitigação em nuvem (ex.: Cloudflare).  
**Visual**: Gráfico de tráfego durante um ataque DoS.  
**Duração**: 3 minutos.

## Slide 17: Sniffing  
**Conteúdo**:  
- Definição: Interceptação de dados em trânsito em uma rede.  
- Exemplo: Captura de senhas em redes Wi-Fi públicas.  
- Ferramentas: Wireshark (legítima), mas usada por atacantes.  
- Prevenção: Criptografia (HTTPS, VPN), evitar redes públicas.  
**Visual**: Diagrama de sniffing em uma rede.  
**Duração**: 3 minutos.

## Slide 18: IP Spoofing  
**Conteúdo**:  
- Definição: Falsificação de endereço IP para enganar sistemas.  
- Uso: Em ataques como DDoS ou para burlar autenticação.  
- Exemplo: Pacotes falsos em ataques de amplificação.  
- Prevenção: Filtros de pacotes, validação de origem.  
**Visual**: Esquema de IP spoofing.  
**Duração**: 3 minutos.

## Slide 19: Reflexão Final - O que é Segurança da Informação?  
**Conteúdo**:  
- **Definição**: Segurança da Informação é proteger dados contra acesso, uso, divulgação, interrupção ou destruição não autorizados.  
- Envolve tecnologia, processos e pessoas.  
- Não é apenas prevenir, mas também detectar e responder a incidentes.  
**Visual**: Triângulo CIA (Confidencialidade, Integridade, Disponibilidade).  
**Duração**: 2 minutos.

## Slide 20: Como se Defender?  
**Conteúdo**:  
- **Indivíduos**: Senhas fortes, autenticação multifator, cuidado com links.  
- **Organizações**: Firewalls, SIEM, políticas de segurança, treinamentos.  
- **Boas práticas**: Atualizações regulares, backups, monitoramento.  
- Exemplo: Como a autenticação multifator impede acessos não autorizados.  
**Visual**: Checklist de boas práticas de segurança.  
**Duração**: 3 minutos.

## Slide 21: Como Viver com a Insegurança?  
**Conteúdo**:  
- A segurança absoluta não existe; o risco é inerente ao mundo digital.  
- Estratégia: Reduzir riscos, estar preparado para incidentes.  
- Reflexão: Como equilibrar conveniência e segurança no dia a dia?  
- Exemplo: Usar VPN em redes públicas vs. conveniência de conexão rápida.  
**Visual**: Imagem de balança (segurança vs. conveniência).  
**Duração**: 3 minutos.

## Slide 22: Encerramento e Perguntas  
**Conteúdo**:  
- Recapitulação: Segurança em redes e criptografia são fundamentais para proteger dados. Malwares e ataques evoluem, exigindo defesas proativas.  
- Convite à reflexão: Como você pode aplicar esses conceitos na sua carreira?  
- Abertura para perguntas e discussão.  
**Visual**: Imagem de um cadeado digital com “Fique Seguro!”.  
**Duração**: 5 minutos (com interação).
