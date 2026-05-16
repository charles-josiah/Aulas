# Workshop: Reconhecimento CLI e Descoberta de Ativos (srvdocker01)

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
> - As técnicas demonstradas envolvem reconhecimento de host, descoberta de rede e enumeração de serviços, devendo permanecer restritas ao escopo autorizado do laboratório.
> - Ambientes de laboratório são sensíveis e dependentes de hardware, configuração de rede e versões de pacotes.
> - Falhas podem ocorrer devido a drivers, virtualização desativada (BIOS/VT-x/AMD-V), firewall local, ausência de pacotes ou conflitos de rede.
> - **Ajustes manuais podem ser necessários** durante o processo para adequar o lab à sua máquina específica.

---

## Índice

- [1. Contexto do Cenário](#1-contexto-do-cenário)
- [2. Fase 1: Reconhecimento Interno do Host](#2-fase-1-reconhecimento-interno-do-host-mapeando-o-srvdocker01)
  - [Passo 1.1: Identificação do Ambiente, Usuário e Contas Locais](#passo-11-identificação-do-ambiente-usuário-e-contas-locais)
  - [Passo 1.2: Superfície Local Privilegiada](#passo-12-superfície-local-privilegiada)
  - [Passo 1.3: Auditoria de Processos Ativos](#passo-13-auditoria-de-processos-ativos)
  - [Passo 1.4: Mapeamento de Portas, Sockets e Exposição SSH](#passo-14-mapeamento-de-portas-sockets-e-exposição-ssh)
  - [Passo 1.5: Evidências de Containerização Docker](#passo-15-evidências-de-containerização-docker)
- [3. Fase 2: Descoberta de Rede e Hosts Adjacentes](#3-fase-2-descoberta-de-rede-e-hosts-adjacentes-pivoting-e-varredura)
  - [Passo 2.1: Descoberta de Subredes e Interfaces](#passo-21-descoberta-de-subredes-e-interfaces)
  - [Passo 2.2: Varredura de Ping](#passo-22-varredura-de-ping-host-discovery)
  - [Passo 2.3: Varredura de Serviços e Banners](#passo-23-varredura-de-serviços-e-banners-port-scan)
- [4. Mitigação e Hardening do srvdocker01](#4-mitigação-e-hardening-do-srvdocker01)
- [Checklist de Validação do Aluno](#checklist-de-validação-do-aluno)

---

## 1. Contexto do Cenário

Você está no primeiro dia de trabalho em um ambiente técnico controlado e recebeu acesso via SSH ao servidor `srvdocker01` com um usuário comum, sem privilégios administrativos diretos. O ambiente é puramente CLI, sem interface gráfica, e o objetivo do laboratório é aprender a mapear o host local, identificar sinais de serviços ativos, reconhecer evidências de containerização e descobrir hosts adjacentes na rede interna.

Neste workshop, cada comando deve ser executado individualmente, observado e validado antes de avançar para o próximo passo.

---

## 2. Fase 1: Reconhecimento Interno do Host (Mapeando o srvdocker01)

Nesta fase, o foco é responder perguntas iniciais de reconhecimento local:

- Quem sou eu dentro do sistema?
- Que contas locais, grupos e políticas de privilégio são visíveis?
- Qual sistema operacional e kernel estão em execução?
- Quais mecanismos locais executam com privilégios especiais?
- Quais processos e serviços estão ativos?
- O host tem sinais de Docker, containerização ou exposição de sockets sensíveis?

### Passo 1.1: Identificação do Ambiente, Usuário e Contas Locais

#### Identificar o usuário atual

```bash
whoami
```

**Flags utilizadas:** nenhuma.

**Resultado esperado:** o comando retorna apenas o nome do usuário atual, por exemplo:

```text
user1
```

**Análise:** esse é o contexto de execução inicial. Se o retorno for `root`, o laboratório está com privilégio administrativo direto. Se o retorno for um usuário comum, as próximas etapas ajudam a entender quais informações ainda são visíveis sem `sudo`.

#### Identificar UID, GID e grupos

```bash
id
```

**Flags utilizadas:** nenhuma.

**Resultado esperado:** saída semelhante a:

```text
uid=1000(user1) gid=1000(user1) groups=1000(user1),27(sudo),983(docker)
```

**Análise:** observe:

- `uid`: identificador numérico do usuário.
- `gid`: grupo primário.
- `groups`: grupos adicionais.

Se o usuário estiver no grupo `sudo`, isso é um indicativo de potencial privilégio administrativo, pois o usuário pode conseguir executar comandos com elevação mediante autenticação e política local do `sudoers`.

Se o usuário estiver no grupo `docker`, isso também é uma informação crítica. Em muitos ambientes Linux, acesso ao socket Docker pode permitir controle administrativo indireto sobre containers e, dependendo da configuração, sobre o host.

#### Inspecionar contas locais e usuários com UID 0

```bash
cat /etc/passwd
```

**Flags utilizadas:** nenhuma.

**Resultado esperado:** lista de contas locais no formato:

```text
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
user1:x:1000:1000:User One:/home/user1:/bin/bash
```

**Formato dos campos:** cada linha segue o padrão:

```text
usuario:senha:UID:GID:comentario:diretorio_home:shell
```

**Análise:** o campo mais importante nesta etapa é o `UID`. Em Linux, o usuário efetivamente administrativo é identificado pelo `UID 0`, não apenas pelo nome `root`. Em um sistema saudável, normalmente apenas a conta `root` possui `UID 0`. Se outra conta aparecer com `UID 0`, isso deve ser tratado como achado crítico de auditoria.

Para listar somente contas com `UID 0`, use:

```bash
awk -F: '$3 == 0 {print $1 ": UID=" $3 ": GID=" $4 ": HOME=" $6 ": SHELL=" $7}' /etc/passwd
```

**Flags e componentes utilizados:**

- `awk`: processa texto por campos.
- `-F:`: define `:` como separador de campos.
- `$3 == 0`: filtra linhas em que o terceiro campo, o UID, é igual a `0`.
- `$1`: nome do usuário.
- `$4`: GID primário.
- `$6`: diretório home.
- `$7`: shell de login.
- `/etc/passwd`: base local de contas do sistema.

**Resultado esperado em sistema normal:**

```text
root: UID=0: GID=0: HOME=/root: SHELL=/bin/bash
```

**Resultado que exige investigação:**

```text
root: UID=0: GID=0: HOME=/root: SHELL=/bin/bash
suporte: UID=0: GID=0: HOME=/home/suporte: SHELL=/bin/bash
```

**Análise:** a segunda linha indica uma conta adicional com privilégios equivalentes ao `root`. Em laboratório, isso é uma evidência importante para discutir controle de identidade, persistência administrativa indevida, trilhas de auditoria e revisão de contas privilegiadas.

Para listar usuários com shell interativo, use:

```bash
awk -F: '$7 ~ /(bash|sh|zsh)$/ {print $1 ": UID=" $3 ": SHELL=" $7}' /etc/passwd
```

**Análise:** contas com shell como `/bin/bash`, `/bin/sh` ou `/bin/zsh` podem iniciar sessão interativa. Contas com `/usr/sbin/nologin` ou `/bin/false` normalmente são contas de serviço sem login interativo.

Para verificar grupos administrativos conhecidos, use:

```bash
getent group sudo admin wheel docker
```

**Componentes utilizados:**

- `getent`: consulta bases do sistema, incluindo arquivos locais e fontes externas configuradas como LDAP/SSSD.
- `group`: seleciona a base de grupos.
- `sudo admin wheel docker`: nomes de grupos administrativos comuns em distribuições Linux.

**Resultado esperado:**

```text
sudo:x:27:user1
docker:x:983:user1
```

**Análise:** membros de `sudo`, `admin` ou `wheel` podem ter capacidade administrativa dependendo da política local. Membros de `docker` podem interagir com o Docker Engine caso o socket esteja acessível. Esses grupos não significam necessariamente `UID 0`, mas indicam caminhos legítimos de elevação administrativa controlados por política.

Se o usuário tiver permissão para consultar sua própria política sudo, valide com:

```bash
sudo -l
```

**Flags utilizadas:**

- `-l`: lista comandos que o usuário atual pode executar via `sudo`, conforme a política local.

**Análise:** esse comando pode solicitar senha. O objetivo é entender autorização administrativa, não executar comandos privilegiados. Uma saída com `(ALL : ALL) ALL` indica permissão ampla; entradas específicas indicam comandos limitados.

**Resultado validado no laboratório:**

```text
User user1 may run the following commands on srvdocker01:
    (ALL : ALL) ALL
```

**Interpretação:** esse resultado não significa que `user1` já está executando como `root` no momento atual. Ele indica que `user1` possui autorização para elevar privilégios via `sudo`, mediante autenticação e conforme a política local. No contexto do laboratório, isso deve ser registrado como caminho administrativo legítimo e como ponto de atenção para auditoria de contas privilegiadas.

#### Validar permissões de arquivos sensíveis, política de senha e PATH

```bash
ls -l /etc/passwd /etc/shadow /etc/sudoers
```

**Flags utilizadas:**

- `-l`: exibe permissões, dono, grupo, tamanho, data de modificação e caminho.

**Resultado validado no laboratório:**

```text
-rw-r--r-- 1 root root   1788 May 12 01:51 /etc/passwd
-rw-r----- 1 root shadow  967 May 12 01:51 /etc/shadow
-r--r----- 1 root root   1800 Jan 21 15:09 /etc/sudoers
```

**Análise:** `/etc/passwd` está legível para todos, o que é esperado em Linux porque contém metadados de contas, não hashes de senha. `/etc/shadow` está restrito ao usuário `root` e ao grupo `shadow`, protegendo os hashes de senha. `/etc/sudoers` está em modo somente leitura e restrito, reduzindo risco de alteração indevida da política de privilégios.

Para verificar a política de expiração da conta atual, use:

```bash
chage -l user1
```

**Flags utilizadas:**

- `-l`: lista informações de aging e expiração da conta.

**Resultado validado no laboratório:**

```text
Last password change                                    : May 12, 2026
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
```

**Análise:** a senha de `user1` não expira, a conta não expira e o valor `99999` em `Maximum number of days` indica uma política praticamente sem rotação obrigatória. Em ambiente de laboratório isso pode ser aceitável por simplicidade operacional, mas em ambientes corporativos deve gerar discussão sobre governança de identidade, validade de contas, MFA, chaves SSH e ciclo de vida de acessos.

Para validar a ordem de busca de binários no shell, use:

```bash
echo "$PATH"
```

**Resultado validado no laboratório:**

```text
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
```

**Análise:** o `PATH` observado está saudável para este contexto. Não há diretórios como `/tmp`, `.`, `/home/user1/bin` ou outros caminhos graváveis pelo usuário antes dos diretórios de sistema. Essa validação ajuda a discutir risco de execução acidental de binários ou scripts posicionados em locais inseguros.

#### Identificar o kernel e arquitetura

```bash
uname -a
```

**Flags utilizadas:**

- `-a`: mostra todas as informações disponíveis do kernel, incluindo nome do kernel, hostname, versão, data de build e arquitetura.

**Resultado esperado:** saída semelhante a:

```text
Linux srvdocker01 7.0.0-15-generic #15-Ubuntu SMP PREEMPT_DYNAMIC Wed Apr 22 16:06:43 UTC 2026 x86_64 GNU/Linux
```

**Análise:** campos importantes:

- `srvdocker01`: hostname.
- `7.0.0-15-generic`: versão do kernel.
- `x86_64`: arquitetura.
- `GNU/Linux`: família do sistema.

Versões antigas de kernel, builds customizados e arquiteturas específicas ajudam a entender compatibilidade de ferramentas, containers e módulos carregados.

#### Identificar a distribuição Linux

```bash
cat /etc/os-release
```

**Flags utilizadas:** nenhuma.

**Resultado esperado:** conteúdo com variáveis como:

```text
PRETTY_NAME="Ubuntu 26.04 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04 (Resolute Raccoon)"
VERSION_CODENAME=resolute
ID=ubuntu
ID_LIKE=debian
```

**Análise:** `PRETTY_NAME`, `VERSION_ID` e `ID` indicam a distribuição base. Isso ajuda a prever nomes de pacotes, caminhos padrão, versão do systemd, comportamento do firewall e disponibilidade de comandos como `ss`, `ip`, `ps` e `nmap`.

**Alternativas técnicas:**

```bash
hostnamectl
```

```bash
lsb_release -a
```

`hostnamectl` pode mostrar sistema operacional, kernel, arquitetura, virtualização e hostname. `lsb_release` nem sempre está instalado em servidores mínimos.

---

### Passo 1.2: Superfície Local Privilegiada

Depois de entender identidade e grupos, o próximo passo é inventariar mecanismos locais que podem executar com privilégios especiais. Esta etapa não executa esses binários; ela apenas mapeia superfície de auditoria para discussão defensiva.

#### Inventariar binários SUID

```bash
find / -perm -4000 -type f 2>/dev/null
```

**Flags e componentes utilizados:**

- `find /`: inicia a busca a partir da raiz do filesystem.
- `-perm -4000`: localiza arquivos com o bit SUID ativo.
- `-type f`: limita o resultado a arquivos regulares.
- `2>/dev/null`: oculta erros de permissão esperados para usuário comum.

**Análise:** binários SUID executam com o UID efetivo do dono do arquivo, frequentemente `root`. Isso é necessário para ferramentas legítimas como `passwd`, `su`, `sudo`, `mount` e utilitários similares, mas também representa uma superfície sensível que deve ser inventariada. Em auditoria, procure por binários incomuns, caminhos fora de `/usr/bin`, `/usr/sbin`, `/bin` e `/sbin`, ou arquivos SUID recentemente alterados.

#### Inventariar binários SGID

```bash
find / -perm -2000 -type f 2>/dev/null
```

**Flags e componentes utilizados:**

- `-perm -2000`: localiza arquivos com o bit SGID ativo.
- `-type f`: limita o resultado a arquivos regulares.
- `2>/dev/null`: oculta erros de permissão.

**Análise:** binários SGID executam com o GID efetivo do grupo dono do arquivo. Eles podem ser legítimos para tarefas que exigem acesso a grupos específicos, mas devem ser revisados quando aparecem em caminhos não padronizados ou associados a grupos sensíveis.

#### Inventariar Linux capabilities

```bash
getcap -r / 2>/dev/null
```

**Flags e componentes utilizados:**

- `getcap`: lista capabilities atribuídas a arquivos.
- `-r /`: executa busca recursiva a partir da raiz.
- `2>/dev/null`: oculta erros de permissão.

**Análise:** capabilities permitem conceder privilégios específicos a binários sem usar SUID completo. Exemplos comuns incluem capacidades para manipulação de rede, binding em portas privilegiadas ou operações administrativas específicas. Em auditoria, capabilities devem ser revisadas porque representam exceções finas ao modelo tradicional de permissões Unix.

**Alternativa técnica:** se `getcap` não estiver instalado, registre a ausência da ferramenta e siga para os próximos passos. Em Debian/Ubuntu, ela costuma fazer parte do pacote `libcap2-bin`.

#### Verificar capabilities do processo atual

```bash
capsh --print 2>/dev/null || grep Cap /proc/self/status
```

**Componentes utilizados:**

- `capsh --print`: mostra, quando disponível, os conjuntos de capabilities do processo atual em formato legível.
- `2>/dev/null`: oculta erro caso `capsh` não esteja instalado.
- `grep Cap /proc/self/status`: alternativa nativa que exibe os campos de capabilities do processo atual em hexadecimal.

**Resultado validado no laboratório:**

```text
Current: =
Bounding set =cap_chown,cap_dac_override,...,cap_net_admin,cap_net_raw,...,cap_sys_admin,...
Ambient set =
uid=1000(user1) euid=1000(user1)
gid=1000(user1)
groups=27(sudo),983(docker),1000(user1)
```

**Análise:** enquanto `getcap` olha para capabilities atribuídas a arquivos, este comando observa o contexto do processo atual. No resultado validado, `Current: =` indica que o shell de `user1` não está executando com capabilities efetivas no momento. O `Bounding set` lista capacidades que fazem parte do limite permitido pelo sistema para processos descendentes, mas isso não significa que todas estejam ativas no processo atual. Em auditoria, capabilities como `cap_sys_admin`, `cap_net_admin` e `cap_net_raw` merecem atenção quando aparecem como efetivas em processos ou binários específicos, pois ampliam significativamente o impacto de uma configuração incorreta.

#### Inventariar diretórios graváveis pelo usuário atual

```bash
find / -xdev -type d -writable 2>/dev/null | grep -vE '^/(proc|sys|run|dev)' | head -30
```

**Flags e componentes utilizados:**

- `-xdev`: evita atravessar para outros filesystems montados.
- `-type d`: limita a busca a diretórios.
- `-writable`: lista diretórios onde o usuário atual possui permissão de escrita.
- `grep -vE '^/(proc|sys|run|dev)'`: reduz ruído de filesystems virtuais e diretórios voláteis.
- `head -30`: limita a saída para facilitar validação em sala.

**Resultado validado no laboratório:**

```text
/var/tmp
/var/crash
/tmp
/home/user1
/home/user1/.config
/home/user1/.cache
/home/user1/.ssh
/docker
/docker/vapi
/docker/vapi/database
```

**Análise:** este comando não procura necessariamente diretórios graváveis por todos; ele lista o que é gravável pelo usuário atual. No laboratório, os diretórios pessoais são esperados. Já a presença de caminhos como `/docker` e `/docker/vapi` é relevante para discussão, pois indica que `user1` consegue alterar áreas usadas pelo ambiente de containers/aplicação. Isso pode ser legítimo em laboratório, mas em ambiente corporativo exigiria revisão de ownership, grupos e fluxo de deploy.

#### Inventariar diretórios graváveis por qualquer usuário

```bash
find / -xdev -type d -perm -0002 -printf '%M %u %g %p\n' 2>/dev/null | head -30
```

**Flags e componentes utilizados:**

- `-perm -0002`: filtra diretórios com permissão de escrita para `others`.
- `-printf '%M %u %g %p\n'`: imprime permissões, dono, grupo e caminho.

**Resultado validado no laboratório:**

```text
drwxrwxrwt root root /var/tmp
drwxrwxrwt root root /var/crash
drwxrwxrwt root root /tmp
```

**Análise:** os diretórios listados possuem sticky bit (`t`), comportamento esperado para diretórios temporários compartilhados. O sticky bit impede que um usuário comum remova ou renomeie arquivos de outro usuário dentro daquele diretório, reduzindo risco operacional.

Para localizar diretórios graváveis por qualquer usuário sem sticky bit, use:

```bash
find / -xdev -type d -perm -0002 ! -perm -1000 -printf '%M %u %g %p\n' 2>/dev/null | head -30
```

**Resultado validado no laboratório:**

```text
sem saída
```

**Análise:** ausência de saída é o resultado desejável. Diretórios world-writable sem sticky bit costumam ser achados relevantes, pois permitem interferência entre usuários locais.

#### Inventariar arquivos executáveis graváveis pelo usuário atual

```bash
find / -xdev -type f -writable -executable -printf '%M %u %g %p\n' 2>/dev/null | head -30
```

**Resultado validado no laboratório:**

```text
-rwxr-xr-x user1 docker /docker/vapi/vendor/spatie/array-to-xml/composer.json
-rwxr-xr-x user1 docker /docker/vapi/vendor/spatie/array-to-xml/README.md
-rwxr-xr-x user1 docker /docker/vapi/vendor/spatie/array-to-xml/LICENSE.md
-rwxr-xr-x user1 docker /docker/vapi/vendor/spatie/array-to-xml/CHANGELOG.md
-rwxr-xr-x user1 docker /docker/vapi/vapi/bootstrap/cache/services.php
-rwxr-xr-x user1 docker /docker/vapi/vapi/bootstrap/cache/packages.php
```

**Análise:** arquivos executáveis e graváveis pelo usuário atual merecem revisão porque combinam capacidade de alteração com possibilidade de execução. No laboratório, os achados estão sob `/docker/vapi`, pertencem a `user1:docker` e parecem relacionados à aplicação vulnerável do ambiente. Em uma auditoria real, o próximo passo seria entender se algum processo, serviço ou rotina automatizada executa esses arquivos.

### Passo 1.3: Auditoria de Processos Ativos

#### Listar todos os processos em formato BSD

```bash
ps aux
```

**Flags utilizadas:**

- `a`: lista processos de todos os usuários associados a terminais.
- `u`: exibe formato orientado a usuário, incluindo usuário dono do processo, uso de CPU e memória.
- `x`: inclui processos sem terminal associado, como serviços e daemons.

**Resultado esperado:** saída com colunas semelhantes a:

```text
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.5 167000 11800 ?        Ss   09:00   0:01 /sbin/init
root         721  0.1  2.1 1450000 45000 ?       Ssl  09:01   0:05 /usr/bin/dockerd -H fd://
root         891  0.0  1.0 1200000 21000 ?       Ssl  09:01   0:02 containerd
user1       2100  0.0  0.1   8200  3200 pts/0    Ss   09:20   0:00 -bash
```

**Análise:** procure por processos relacionados a Docker e containerização:

- `dockerd`: daemon principal do Docker Engine.
- `containerd`: runtime de containers usado pelo Docker.
- `containerd-shim`: processo intermediário associado a containers em execução.
- `runc`: runtime de baixo nível usado para criar containers.
- `docker-proxy`: processo usado em alguns cenários de publicação de portas.

Também observe processos de serviços expostos:

- `nginx`, `apache2`, `httpd`: servidores web.
- `mysqld`, `mariadbd`, `postgres`: bancos de dados.
- `redis-server`, `mongod`, `memcached`: serviços de dados ou cache.
- `sshd`: serviço SSH.
- `python`, `node`, `java`, `gunicorn`, `uvicorn`: aplicações ou APIs.

**Como identificar processos suspeitos ou relevantes:** compare o usuário dono, caminho do binário e argumentos. Processos rodando como `root`, escutando rede ou apontando para diretórios temporários (`/tmp`, `/dev/shm`) merecem análise adicional em laboratório.

#### Alternativa em formato SysV

```bash
ps -ef
```

**Flags utilizadas:**

- `-e`: lista todos os processos.
- `-f`: usa formato completo, incluindo UID, PID, PPID, horário de início e comando.

**Resultado esperado:** saída com colunas como:

```text
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 09:00 ?        00:00:01 /sbin/init
root         721       1  0 09:01 ?        00:00:05 /usr/bin/dockerd -H fd://
```

**Análise:** a coluna `PPID` ajuda a montar relações de parentesco entre processos. Por exemplo, containers frequentemente aparecem como filhos indiretos de `containerd` ou `containerd-shim`.

#### Filtrar evidências de Docker e containers

```bash
ps aux | grep -Ei 'docker|containerd|runc|containerd-shim|docker-proxy' | grep -v grep
```

**Flags utilizadas:**

- `grep -E`: habilita expressão regular estendida.
- `grep -i`: ignora maiúsculas e minúsculas.
- `grep -v grep`: remove o próprio processo `grep` da saída.

**Resultado esperado:** se o Docker estiver ativo, a saída pode mostrar `dockerd`, `containerd`, `containerd-shim` ou `docker-proxy`.

**Alternativas técnicas:**

```bash
pgrep -a dockerd
```

```bash
pgrep -a containerd
```

`pgrep -a` mostra o PID e a linha de comando completa dos processos encontrados. É mais limpo do que encadear `ps` e `grep`, mas pode não estar disponível em imagens muito mínimas.

---

### Passo 1.4: Mapeamento de Portas, Sockets e Exposição SSH

#### Listar portas TCP e UDP em escuta

```bash
ss -tulpn
```

**Flags utilizadas:**

- `-t`: mostra sockets TCP.
- `-u`: mostra sockets UDP.
- `-l`: mostra apenas sockets em estado de escuta.
- `-p`: tenta mostrar o processo associado ao socket.
- `-n`: não resolve nomes; exibe IPs e portas em formato numérico.

**Resultado esperado:** saída semelhante a:

```text
Netid State  Recv-Q Send-Q Local Address:Port Peer Address:Port Process
tcp   LISTEN 0      128        127.0.0.1:5432      0.0.0.0:*     users:(("postgres",pid=910,fd=5))
tcp   LISTEN 0      4096         0.0.0.0:22        0.0.0.0:*     users:(("sshd",pid=690,fd=3))
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*     users:(("nginx",pid=850,fd=6))
tcp   LISTEN 0      4096            [::]:22           [::]:*     users:(("sshd",pid=690,fd=4))
```

**Análise de endereços locais:**

- `127.0.0.1:PORTA`: serviço escutando apenas em loopback IPv4. Normalmente acessível apenas a partir do próprio host.
- `::1:PORTA`: serviço escutando apenas em loopback IPv6.
- `0.0.0.0:PORTA`: serviço escutando em todas as interfaces IPv4. Pode estar acessível pela rede interna se firewall e rotas permitirem.
- `[::]:PORTA`: serviço escutando em todas as interfaces IPv6.
- `IP_INTERNO:PORTA`: serviço escutando especificamente em uma interface de rede.

**Interpretação prática:** um banco em `127.0.0.1:5432` sugere exposição local. Um serviço em `0.0.0.0:5432` sugere exposição em todas as interfaces, o que aumenta a superfície exposta dentro da rede.

#### Revisar exposição e política efetiva do SSH

```bash
sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|pubkeyauthentication|allowusers|allowgroups'
```

**Flags e componentes utilizados:**

- `sshd -T`: imprime a configuração efetiva do servidor SSH após aplicar padrões e arquivos de configuração.
- `grep -E`: habilita expressão regular estendida.
- `grep -i`: ignora maiúsculas e minúsculas.
- `permitrootlogin`: indica se login SSH direto como `root` é permitido.
- `passwordauthentication`: indica se autenticação por senha está habilitada.
- `pubkeyauthentication`: indica se autenticação por chave pública está habilitada.
- `allowusers` e `allowgroups`: indicam restrições explícitas de usuários ou grupos autorizados.

**Resultado esperado:** a saída varia conforme a configuração do laboratório, mas pode aparecer como:

```text
permitrootlogin prohibit-password
passwordauthentication yes
pubkeyauthentication yes
```

**Análise:** esta validação conecta identidade e rede. Se `passwordauthentication` estiver habilitado, a segurança depende fortemente de senha, política de bloqueio, MFA quando disponível e exposição da porta SSH. Se `permitrootlogin` estiver como `yes`, há maior risco operacional porque permite tentativa direta contra a conta administrativa. Restrições com `allowusers` ou `allowgroups` reduzem a superfície de login remoto.

**Alternativas técnicas:**

```bash
grep -Ei '^[[:space:]]*(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|AllowUsers|AllowGroups)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null
```

Esta alternativa lê arquivos de configuração diretamente. Ela pode não refletir todos os padrões efetivos, mas ajuda quando `sshd -T` não estiver disponível ou exigir permissões específicas.

#### Listar conexões TCP estabelecidas e em escuta

```bash
ss -antp
```

**Flags utilizadas:**

- `-a`: mostra sockets em todos os estados.
- `-n`: saída numérica.
- `-t`: sockets TCP.
- `-p`: tenta mostrar processo associado.

**Resultado esperado:** além de portas em `LISTEN`, a saída pode mostrar conexões `ESTAB`, `TIME-WAIT`, `CLOSE-WAIT` e outros estados TCP.

**Análise:** conexões `ESTAB` mostram comunicação ativa. Observe pares `Local Address:Port` e `Peer Address:Port` para identificar com quais hosts o `srvdocker01` está falando.

#### Alternativa com netstat

```bash
netstat -tulpn
```

**Flags utilizadas:**

- `-t`: TCP.
- `-u`: UDP.
- `-l`: sockets em escuta.
- `-p`: processo associado.
- `-n`: saída numérica.

**Observação:** `netstat` pertence ao pacote `net-tools`, que pode não estar instalado em distribuições modernas.

#### Alternativa CLI nativa via /proc/net/tcp

Se `ss` e `netstat` não estiverem disponíveis, é possível ler `/proc/net/tcp`, onde o kernel expõe sockets TCP em formato hexadecimal.

```bash
while read -r sl local_address rem_address st rest; do [[ "$sl" == "sl" ]] && continue; ip_hex="${local_address%:*}"; port_hex="${local_address#*:}"; printf "endereco_hex=%s porta=%d state=%s\n" "$ip_hex" "$((16#$port_hex))" "$st"; done < /proc/net/tcp
```

**Componentes do comando:**

- `while read -r`: lê o arquivo linha por linha.
- `[[ "$sl" == "sl" ]] && continue`: ignora o cabeçalho.
- `${local_address%:*}`: extrai o endereço local em hexadecimal.
- `${local_address#*:}`: extrai a porta em hexadecimal.
- `$((16#$port_hex))`: converte a porta hexadecimal para decimal usando aritmética nativa do Bash.
- `state`: mostra o estado TCP em hexadecimal.

**Estados TCP comuns em `/proc/net/tcp`:**

- `0A`: `LISTEN`.
- `01`: `ESTABLISHED`.
- `06`: `TIME_WAIT`.

**Limitação:** o IP aparece em hexadecimal little-endian, por exemplo `0100007F` representa `127.0.0.1`. Para uma visão mais legível de portas em escuta, use:

```bash
while read -r sl local_address rem_address st rest; do [[ "$sl" == "sl" || "$st" != "0A" ]] && continue; ip_hex="${local_address%:*}"; port_hex="${local_address#*:}"; printf "porta_tcp_listen=%d endereco_hex=%s\n" "$((16#$port_hex))" "$ip_hex"; done < /proc/net/tcp
```

**Alternativa ainda mais simples para validar portas:**

```bash
cat /proc/net/tcp
```

Essa opção não é amigável, mas funciona em praticamente qualquer Linux com `/proc` montado.

---

### Passo 1.5: Evidências de Containerização Docker

O objetivo é descobrir indícios de Docker sem executar o comando `docker`.

#### Verificar grupos do usuário

```bash
groups
```

**Flags utilizadas:** nenhuma.

**Resultado esperado:** saída semelhante a:

```text
user1 sudo docker
```

**Análise:** presença no grupo `docker` indica que o usuário pode ter permissão para interagir com o Docker Engine, caso o socket esteja acessível.

#### Verificar cgroups do processo init

```bash
cat /proc/1/cgroup
```

**Flags utilizadas:** nenhuma.

**Resultado esperado:** em hosts tradicionais, a saída pode ser genérica. Dentro de containers, pode aparecer referência a caminhos com `docker`, `containerd`, `kubepods` ou IDs longos de containers.

**Exemplos de indícios:**

```text
0::/system.slice/docker.service
```

```text
0::/docker/4f2a8c9b7d...
```

```text
0::/kubepods.slice/kubepods-burstable.slice/...
```

**Análise:** essa leitura ajuda a diferenciar se o aluno está no host Docker ou dentro de um container. Em cgroup v2, o formato pode ser menos explícito, então combine com outras evidências.

#### Procurar socket Docker

```bash
ls -l /var/run/docker.sock
```

**Flags utilizadas:**

- `-l`: listagem longa, mostrando tipo, permissões, dono, grupo e caminho.

**Resultado esperado:** se o Docker estiver ativo, pode aparecer:

```text
srw-rw---- 1 root docker 0 May 16 10:00 /var/run/docker.sock
```

**Análise:**

- O primeiro caractere `s` indica socket Unix.
- Dono normalmente é `root`.
- Grupo frequentemente é `docker`.
- Permissões `rw` para o grupo indicam que usuários no grupo `docker` podem conversar com o daemon.

Se o arquivo não existir, o Docker pode não estar instalado, pode estar parado ou pode usar caminho diferente.

#### Listar diretórios comuns de Docker

```bash
ls -ld /var/lib/docker /etc/docker /run/docker /var/run/docker.sock 2>/dev/null
```

**Flags e redirecionamentos utilizados:**

- `ls -l`: saída longa.
- `ls -d`: lista o diretório em si, não o conteúdo interno.
- `2>/dev/null`: oculta mensagens de erro para caminhos inexistentes ou sem permissão.

**Resultado esperado:** qualquer caminho listado indica evidência de Docker instalado ou ativo.

**Análise:** usuários comuns normalmente não conseguem ler `/var/lib/docker`, mas a existência do diretório já é um indicador de containerização no host.

#### Verificar pistas de container no ambiente atual

```bash
test -f /.dockerenv && echo "Possivel container Docker" || echo "Arquivo /.dockerenv nao encontrado"
```

**Componentes do comando:**

- `test -f /.dockerenv`: verifica se o arquivo existe.
- `&&`: executa o próximo comando se o teste for verdadeiro.
- `||`: executa o próximo comando se o teste falhar.

**Análise:** `/.dockerenv` costuma existir dentro de containers Docker, mas não é garantia absoluta. A ausência dele também não prova que não há containerização.

---

## 3. Fase 2: Descoberta de Rede e Hosts Adjacentes (Pivoting e Varredura)

Agora o aluno deve descobrir quais hosts estão na mesma rede interna do `srvdocker01`. A ideia é primeiro identificar interfaces e subredes, depois descobrir hosts vivos e, por fim, mapear serviços básicos nos alvos encontrados.

### Passo 2.1: Descoberta de Subredes e Interfaces

#### Listar interfaces e endereços IP

```bash
ip addr show
```

**Flags utilizadas:** nenhuma flag curta; `addr show` é o subcomando para exibir endereços associados às interfaces.

**Resultado esperado:** saída semelhante a:

```text
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 192.168.56.101/24 brd 192.168.56.255 scope global eth0
       valid_lft forever preferred_lft forever
```

**Análise:**

- `eth0`: nome da interface.
- `inet 192.168.56.101/24`: IP e prefixo CIDR.
- `/24`: máscara equivalente a `255.255.255.0`.
- `brd 192.168.56.255`: endereço de broadcast.

Nesse exemplo, a subrede a ser analisada é:

```text
192.168.56.0/24
```

#### Mostrar saída resumida por interface

```bash
ip -br addr
```

**Flags utilizadas:**

- `-br`: modo brief, com saída compacta.
- `addr`: mostra endereços IP.

**Resultado esperado:**

```text
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             192.168.56.101/24 fe80::a00:27ff:fe00:1234/64
docker0          DOWN           172.17.0.1/16
```

**Análise:** ignore `lo` para descoberta de rede externa. Interfaces como `eth0`, `ens33`, `enp0s3` e `docker0` podem indicar redes relevantes. `docker0` normalmente representa a bridge local do Docker.

#### Identificar rotas e gateway

```bash
ip route show
```

**Resultado esperado:**

```text
default via 192.168.56.1 dev eth0
192.168.56.0/24 dev eth0 proto kernel scope link src 192.168.56.101
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1
```

**Análise:** linhas sem `default` indicam redes diretamente conectadas. Essas redes são candidatas para descoberta de hosts adjacentes. No exemplo:

- `192.168.56.0/24`: rede interna do laboratório.
- `172.17.0.0/16`: rede bridge Docker local.

#### Alternativa com ifconfig

```bash
ifconfig -a
```

**Flags utilizadas:**

- `-a`: mostra todas as interfaces, inclusive inativas.

**Observação:** `ifconfig` pertence ao pacote `net-tools` e pode não estar instalado.

#### Como calcular a subrede

Se o IP for `192.168.56.101/24`, o `/24` significa que os 24 primeiros bits são rede. A subrede é:

```text
192.168.56.0/24
```

Se o IP for `10.10.5.37/24`, a subrede é:

```text
10.10.5.0/24
```

Se o IP for `172.16.10.50/16`, a subrede é:

```text
172.16.0.0/16
```

Para o laboratório, prefira validar primeiro redes `/24`, pois são menores e mais previsíveis para análise didática.

---

### Passo 2.2: Varredura de Ping (Host Discovery)

#### Descobrir hosts ativos com nmap

Substitua `192.168.56.0/24` pela subrede identificada no passo anterior.

```bash
nmap -sn -v 192.168.56.0/24
```

**Flags utilizadas:**

- `-sn`: executa host discovery sem port scan. O objetivo é descobrir hosts vivos.
- `-v`: modo verbose, mostrando mais detalhes durante a execução.

**Resultado esperado:** saída com hosts marcados como ativos:

```text
Nmap scan report for 192.168.56.1
Host is up (0.0010s latency).
Nmap scan report for 192.168.56.101
Host is up (0.00015s latency).
Nmap scan report for 192.168.56.30
Host is up (0.0021s latency).
```

**Análise:** anote os IPs ativos, exceto o próprio IP do `srvdocker01` se o objetivo for analisar vizinhos. Em redes locais, o `nmap -sn` pode usar ARP quando possível, além de ICMP e outros probes dependendo do contexto e privilégios.

**Alternativas técnicas:**

```bash
nmap -sn --disable-arp-ping -v 192.168.56.0/24
```

`--disable-arp-ping` força o nmap a não usar ARP ping em redes locais. Isso pode ser útil para comparar comportamento, mas tende a reduzir precisão em alguns cenários.

#### Alternativa em Bash puro com ping

Substitua `192.168.56` pelos três primeiros octetos da sua rede `/24`.

```bash
for i in $(seq 1 254); do ping -c 1 -W 1 192.168.56.$i >/dev/null 2>&1 && echo "Host ativo: 192.168.56.$i"; done
```

**Componentes do comando:**

- `seq 1 254`: gera os endereços finais válidos mais comuns de uma rede `/24`.
- `ping -c 1`: envia apenas 1 pacote ICMP.
- `ping -W 1`: espera até 1 segundo por resposta.
- `>/dev/null 2>&1`: oculta saída normal e erros.
- `&& echo`: imprime o IP apenas se o ping teve sucesso.

**Resultado esperado:**

```text
Host ativo: 192.168.56.1
Host ativo: 192.168.56.101
Host ativo: 192.168.56.30
```

**Limitações:** hosts podem bloquear ICMP e ainda assim estarem ativos. Por isso, ausência de resposta a ping não prova que o host está desligado.

#### Alternativa Bash com paralelismo leve

```bash
for i in $(seq 1 254); do (ping -c 1 -W 1 192.168.56.$i >/dev/null 2>&1 && echo "Host ativo: 192.168.56.$i") & done; wait
```

**Análise:** executa pings em paralelo e reduz o tempo total. Use com cuidado em máquinas muito limitadas, pois dispara vários processos simultâneos.

---

### Passo 2.3: Varredura de Serviços e Banners (Port Scan)

Depois de identificar hosts vivos, escolha um IP alvo e execute uma varredura focada. Substitua `192.168.56.30` pelo IP encontrado no passo anterior.

```bash
nmap -sV -Pn --top-ports 20 192.168.56.30
```

**Flags utilizadas:**

- `-sV`: tenta identificar versão e banner dos serviços encontrados.
- `-Pn`: trata o host como ativo, sem depender de host discovery prévio.
- `--top-ports 20`: varre as 20 portas mais comuns segundo a base do nmap.

**Resultado esperado:** saída semelhante a:

```text
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 10.x Ubuntu
80/tcp   open  http    nginx 1.22.1
3306/tcp open  mysql   MariaDB 10.11.6
```

**Análise:** observe:

- `PORT`: porta e protocolo.
- `STATE`: estado da porta, como `open`, `closed` ou `filtered`.
- `SERVICE`: serviço provável.
- `VERSION`: banner ou versão estimada.

Com esses dados, o aluno pode inferir papéis do host:

- `22/tcp ssh`: administração remota Linux/Unix.
- `80/tcp` ou `443/tcp`: aplicação web ou proxy.
- `3306/tcp`, `5432/tcp`, `6379/tcp`, `27017/tcp`: banco ou serviço de dados.
- `8080/tcp`, `8000/tcp`, `5000/tcp`: aplicações web alternativas, APIs ou painéis.

#### Varredura em múltiplos IPs

Se os hosts ativos forem `192.168.56.10`, `192.168.56.101` e `192.168.56.30`, use:

```bash
nmap -sV -Pn --top-ports 20 192.168.56.10 192.168.56.101 192.168.56.30
```

#### Salvar resultado para análise posterior

```bash
nmap -sV -Pn --top-ports 20 -oN nmap-servicos-iniciais.txt 192.168.56.30
```

**Flags adicionais:**

- `-oN nmap-servicos-iniciais.txt`: salva o resultado em formato normal legível.

**Análise:** salvar evidências é uma prática importante para comparação entre turmas, auditoria do laboratório e documentação do raciocínio técnico.

#### Alternativa sem detecção de versão

```bash
nmap -Pn --top-ports 20 192.168.56.30
```

**Análise:** sem `-sV`, a execução tende a ser mais rápida e menos verbosa, mas perde banners e detalhes de versão. É útil para triagem inicial.

---

## 4. Mitigação e Hardening do srvdocker01

As medidas abaixo são voltadas ao administrador do `srvdocker01` para reduzir vazamento de informação para usuários comuns. Aplique apenas após validar impacto operacional.

### 4.1 Ocultar processos de outros usuários com hidepid

Criar grupo autorizado para observabilidade:

```bash
sudo groupadd procmon
```

Remontar `/proc` ocultando processos de outros usuários, permitindo exceção ao grupo `procmon`:

```bash
sudo mount -o remount,rw,hidepid=2,gid=procmon /proc
```

Persistir a configuração em `/etc/fstab`:

```bash
echo 'proc /proc proc defaults,hidepid=2,gid=procmon 0 0' | sudo tee -a /etc/fstab
```

**Análise:** `hidepid=2` impede que usuários comuns vejam detalhes de processos de outros usuários em `/proc`. Isso reduz enumeração via `ps`, leitura de cmdline e inspeção de processos sensíveis. Antes de aplicar em produção, valide compatibilidade com agentes de monitoramento, EDR, backup e ferramentas de suporte.

### 4.2 Restringir acesso ao socket Docker

Verificar permissões atuais:

```bash
ls -l /var/run/docker.sock
```

Remover usuários não administrativos do grupo `docker`:

```bash
sudo gpasswd -d user1 docker
```

Reiniciar a sessão do usuário afetado para aplicar a mudança de grupo:

```bash
id user1
```

**Análise:** pertencer ao grupo `docker` normalmente equivale a um privilégio administrativo relevante. O ideal é limitar esse grupo a operadores autorizados e, quando possível, exigir fluxo auditável com `sudo`, RBAC externo ou orquestrador.

### 4.3 Reduzir exposição de serviços em rede

Listar portas em escuta:

```bash
sudo ss -tulpn
```

Aplicar política padrão restritiva com UFW:

```bash
sudo ufw default deny incoming
```

Permitir SSH a partir de uma rede administrativa específica:

```bash
sudo ufw allow from 192.168.56.0/24 to any port 22 proto tcp
```

Ativar o firewall:

```bash
sudo ufw enable
```

Verificar regras aplicadas:

```bash
sudo ufw status verbose
```

**Análise:** serviços que escutam em `0.0.0.0` ficam potencialmente acessíveis por qualquer interface. Sempre que possível, configure serviços internos para `127.0.0.1`, use firewall local e exponha apenas portas necessárias para redes específicas.

### 4.4 Restringir binários de varredura por política operacional

Identificar caminho do nmap:

```bash
command -v nmap
```

Verificar permissões:

```bash
ls -l "$(command -v nmap)"
```

Remover pacote quando não for necessário no servidor:

```bash
sudo apt remove nmap -y
```

**Análise:** remover ferramentas de varredura não impede reconhecimento com recursos nativos do sistema, mas reduz conveniência operacional para usuários comuns. Essa prática deve ser combinada com hardening de `/proc`, firewall, segmentação e monitoramento.

### 4.5 Telemetria recomendada para detecção

Monitorar execução de comandos de enumeração:

```bash
sudo auditctl -w /usr/bin/nmap -p x -k network_scan_tool
```

Monitorar acesso ao socket Docker:

```bash
sudo auditctl -w /var/run/docker.sock -p rwxa -k docker_socket_access
```

Consultar eventos auditados:

```bash
sudo ausearch -k docker_socket_access
```

**Análise:** regras de auditoria ajudam a detectar uso de ferramentas de varredura e acesso ao socket Docker. Para persistência, converta essas regras para arquivos em `/etc/audit/rules.d/` conforme o padrão da distribuição.

---

## Checklist de Validação do Aluno

- Identifiquei usuário, grupos, contas locais e usuários com UID 0.
- Validei permissões de arquivos sensíveis, política de senha, PATH e política sudo.
- Inventariei SUID, SGID e capabilities como superfície local privilegiada.
- Listei processos e reconheci sinais de Docker ou serviços relevantes.
- Mapeei portas locais, revisei exposição SSH e diferenciei `127.0.0.1`, `0.0.0.0` e IPs específicos.
- Encontrei evidências de Docker sem usar o comando `docker`.
- Identifiquei IP, máscara, subrede e rotas do `srvdocker01`.
- Executei descoberta de hosts com `nmap -sn` ou alternativa em Bash.
- Executei varredura de serviços com `nmap -sV -Pn --top-ports 20`.
- Relacionei pelo menos três medidas de hardening aplicáveis ao cenário.
