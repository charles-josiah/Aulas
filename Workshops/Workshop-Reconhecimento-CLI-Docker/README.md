# Workshop: Reconhecimento CLI e Descoberta de Ativos (srvdocker01)

## 1. Contexto do Cenário

Este workshop simula o primeiro dia de trabalho de um analista com acesso SSH comum ao servidor `srvdocker01`. O ambiente é puramente CLI, sem interface gráfica, e o objetivo é aprender a reconhecer o host, entender quais serviços estão ativos, identificar sinais de containerização e descobrir ativos adjacentes na rede interna.

Premissas do laboratório:

- Você está autenticado via SSH como usuário comum.
- Você não possui privilégios administrativos.
- Você deve executar e validar os comandos um a um.
- A atividade deve ocorrer somente dentro da subrede autorizada do laboratório.
- Sempre substitua exemplos como `192.168.1.0/24` e `IP_ALVO` pelos valores reais encontrados no seu ambiente.

---

## 2. Fase 1: Reconhecimento Interno do Host (Mapeando o srvdocker01)

### Passo 1.1: Identificação do Ambiente e Usuário

#### Comando 1: identificar o usuário atual

```bash
whoami
```

Flags usadas:

- `whoami` não usa flags neste exemplo.
- Exibe o nome efetivo do usuário atual.

Resultado esperado:

```text
aluno
```

Análise:

- Confirma com qual conta você está operando.
- Útil para comparar com permissões de arquivos, processos e grupos.

Alternativas técnicas:

```bash
id -un
```

- `id`: exibe informações de identidade do usuário.
- `-u`: mostra o identificador do usuário.
- `-n`: mostra o nome em vez do número.

---

#### Comando 2: identificar UID, GID e grupos

```bash
id
```

Flags usadas:

- `id` sem flags exibe UID, GID primário e grupos suplementares.

Resultado esperado:

```text
uid=1001(aluno) gid=1001(aluno) groups=1001(aluno),27(sudo),999(docker)
```

Análise:

- `uid`: identificador numérico do usuário.
- `gid`: grupo primário.
- `groups`: grupos adicionais.
- Se o usuário estiver no grupo `docker`, isso é uma evidência importante: em muitos ambientes, acesso ao socket Docker pode equivaler a controle administrativo do host. Neste workshop, apenas registre a evidência; não execute ações administrativas.

Alternativas técnicas:

```bash
groups
```

- Lista os grupos do usuário atual em formato mais simples.

---

#### Comando 3: identificar kernel e arquitetura

```bash
uname -a
```

Flags usadas:

- `-a`: mostra todas as informações disponíveis: nome do kernel, hostname, versão do kernel, data de build, arquitetura e sistema operacional.

Resultado esperado:

```text
Linux srvdocker01 5.15.0-91-generic #101-Ubuntu SMP x86_64 GNU/Linux
```

Análise:

- `Linux`: família do kernel.
- `srvdocker01`: hostname.
- `5.15.0-91-generic`: versão do kernel.
- `x86_64`: arquitetura.
- A versão do kernel ajuda a avaliar compatibilidade de ferramentas, módulos, políticas de hardening e baseline de patches.

Alternativas técnicas:

```bash
uname -r
```

- `-r`: mostra somente a versão do kernel.

```bash
hostnamectl
```

- Quando disponível, exibe hostname, virtualização, kernel e informações do sistema em formato mais legível.

---

#### Comando 4: identificar distribuição do sistema operacional

```bash
cat /etc/os-release
```

Flags usadas:

- `cat` não usa flags neste exemplo.
- `/etc/os-release` é o arquivo padrão moderno para metadados da distribuição Linux.

Resultado esperado:

```text
NAME="Ubuntu"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
ID=ubuntu
VERSION_ID="22.04"
PRETTY_NAME="Ubuntu 22.04.3 LTS"
```

Análise:

- `PRETTY_NAME`: nome amigável da distribuição.
- `ID`: identificador usado por scripts.
- `VERSION_ID`: versão principal.
- Esses dados orientam comandos de administração, nomes de pacotes, caminhos padrão e métodos de hardening.

Alternativas técnicas:

```bash
lsb_release -a
```

- Pode não estar instalado em imagens mínimas.
- Quando disponível, resume a distribuição e versão.

---

### Passo 1.2: Auditoria de Processos Ativos

#### Comando 1: listar processos com formato BSD

```bash
ps aux
```

Flags usadas:

- `a`: lista processos de todos os usuários associados a terminais.
- `u`: mostra o formato orientado a usuário, incluindo usuário, CPU, memória e tempo.
- `x`: inclui processos sem terminal controlador, como serviços e daemons.

Resultado esperado:

```text
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.1 167000 11000 ?        Ss   08:00   0:02 /sbin/init
root         812  0.1  1.2 1850000 98000 ?       Ssl  08:00   0:12 /usr/bin/containerd
root         944  0.2  2.1 2200000 170000 ?      Ssl  08:00   0:24 /usr/bin/dockerd -H fd://
root        1280  0.0  0.4 122000 34000 ?        Ss   08:01   0:01 /usr/sbin/sshd -D
```

Análise:

- Procure por processos como `dockerd`, `containerd`, `containerd-shim`, `docker-proxy` e nomes de runtimes como `runc`.
- Serviços comuns em servidores Docker incluem `sshd`, agentes de monitoramento, bancos de dados, proxies reversos e runtimes de container.
- Processos com usuário `root` não são necessariamente suspeitos; muitos serviços legítimos rodam como `root`.
- Sinais que merecem investigação defensiva:
  - Serviços inesperados escutando rede.
  - Processos com nomes fora do padrão.
  - Binários rodando a partir de diretórios temporários como `/tmp`, `/var/tmp` ou diretórios pessoais.
  - Comandos longos contendo credenciais em argumentos.

Alternativa técnica:

```bash
ps -ef
```

Flags usadas:

- `-e`: lista todos os processos.
- `-f`: usa formato completo, exibindo UID, PID, PPID, horário de início e comando.

Quando usar:

- `ps aux` é bom para visão operacional com CPU e memória.
- `ps -ef` é bom para observar hierarquia via `PPID`.

---

#### Comando 2: destacar processos relacionados ao Docker

```bash
ps aux | grep -Ei 'docker|containerd|runc|containerd-shim' | grep -v grep
```

Flags usadas:

- `grep -E`: habilita expressão regular estendida.
- `grep -i`: ignora maiúsculas e minúsculas.
- `grep -v grep`: remove a própria linha do comando `grep` da saída.

Resultado esperado:

```text
root 812 0.1 1.2 ... /usr/bin/containerd
root 944 0.2 2.1 ... /usr/bin/dockerd -H fd://
root 1321 0.0 0.3 ... /usr/bin/containerd-shim-runc-v2 ...
```

Análise:

- Confirma que componentes Docker/containerd estão ativos.
- A presença de `containerd-shim` geralmente indica containers em execução.
- Como usuário comum, você pode apenas observar; permissões para controlar containers dependem de grupos, socket e políticas locais.

Alternativa sem pipe:

```bash
pgrep -a -f 'docker|containerd|runc|containerd-shim'
```

Flags usadas:

- `-a`: mostra o comando completo.
- `-f`: pesquisa no comando completo, não apenas no nome do processo.

---

### Passo 1.3: Mapeamento de Portas e Sockets Locais

#### Comando 1: listar sockets TCP/UDP em escuta

```bash
ss -tulpn
```

Flags usadas:

- `-t`: mostra sockets TCP.
- `-u`: mostra sockets UDP.
- `-l`: mostra apenas sockets em estado de escuta.
- `-p`: tenta mostrar o processo associado ao socket.
- `-n`: não resolve nomes; exibe IPs e portas numéricas.

Resultado esperado:

```text
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:Port Process
tcp   LISTEN 0      128    127.0.0.1:5432     0.0.0.0:*       users:(("postgres",pid=1401,fd=5))
tcp   LISTEN 0      4096   0.0.0.0:22         0.0.0.0:*       users:(("sshd",pid=1280,fd=3))
tcp   LISTEN 0      4096   0.0.0.0:80         0.0.0.0:*       users:(("docker-proxy",pid=1601,fd=4))
tcp   LISTEN 0      4096   [::]:22            [::]:*          users:(("sshd",pid=1280,fd=4))
```

Análise:

- `127.0.0.1:5432`: serviço escutando apenas em localhost. Normalmente acessível somente a partir do próprio host.
- `0.0.0.0:22`: serviço escutando em todas as interfaces IPv4. Pode estar acessível pela rede, conforme firewall e roteamento.
- `[::]:22`: serviço escutando em todas as interfaces IPv6.
- `docker-proxy` pode indicar porta publicada por container.
- Em alguns sistemas, a coluna `Process` pode aparecer vazia para usuário comum por restrição de permissão.

Como diferenciar exposição local e rede:

- `127.0.0.1:<porta>`: loopback IPv4, somente local.
- `::1:<porta>`: loopback IPv6, somente local.
- `0.0.0.0:<porta>`: todas as interfaces IPv4.
- `[::]:<porta>`: todas as interfaces IPv6.
- `<IP_da_interface>:<porta>`: escuta somente naquela interface específica.

Alternativa TCP com conexões estabelecidas e portas em escuta:

```bash
ss -antp
```

Flags usadas:

- `-a`: mostra sockets em escuta e não escuta.
- `-n`: mostra endereços e portas numéricas.
- `-t`: mostra TCP.
- `-p`: tenta mostrar processos associados.

Quando usar:

- Use `ss -tulpn` para serviços expostos.
- Use `ss -antp` para observar também conexões ativas.

---

#### Alternativa: usando netstat

```bash
netstat -tulpn
```

Flags usadas:

- `-t`: TCP.
- `-u`: UDP.
- `-l`: sockets em escuta.
- `-p`: mostra processo associado quando permitido.
- `-n`: não resolve nomes.

Observação:

- `netstat` faz parte do pacote `net-tools`, que pode não estar presente em instalações modernas e imagens mínimas.

---

#### Alternativa nativa: ler `/proc/net/tcp`

Use esta alternativa se `ss` e `netstat` não estiverem disponíveis.

```bash
awk 'NR>1 {split($2,a,":"); ip=a[1]; port=strtonum("0x"a[2]); state=$4; if (state=="0A") print ip ":" port " LISTEN"}' /proc/net/tcp
```

Componentes usados:

- `awk`: processa texto linha a linha.
- `NR>1`: ignora o cabeçalho.
- `split($2,a,":")`: separa endereço local e porta.
- `strtonum("0x"a[2])`: converte porta hexadecimal para decimal.
- `state=="0A"`: filtra sockets TCP em `LISTEN`.
- `/proc/net/tcp`: tabela TCP IPv4 exposta pelo kernel.

Resultado esperado:

```text
0100007F:5432 LISTEN
00000000:22 LISTEN
00000000:80 LISTEN
```

Análise:

- `0100007F` representa `127.0.0.1` em hexadecimal little-endian.
- `00000000` representa `0.0.0.0`.
- Esta saída é menos amigável, mas funciona sem pacotes adicionais.

Versão com conversão simples de IPv4 hexadecimal para decimal:

```bash
awk 'function hex2dec(h){return strtonum("0x"h)} function iphex2dec(h){return hex2dec(substr(h,7,2)) "." hex2dec(substr(h,5,2)) "." hex2dec(substr(h,3,2)) "." hex2dec(substr(h,1,2))} NR>1 {split($2,a,":"); if ($4=="0A") print iphex2dec(a[1]) ":" strtonum("0x"a[2]) " LISTEN"}' /proc/net/tcp
```

Resultado esperado:

```text
127.0.0.1:5432 LISTEN
0.0.0.0:22 LISTEN
0.0.0.0:80 LISTEN
```

Alternativa para IPv6:

```bash
awk 'NR>1 {split($2,a,":"); if ($4=="0A") print a[1] ":" strtonum("0x"a[2]) " LISTEN"}' /proc/net/tcp6
```

---

### Passo 1.4: Evidências de Containerização (Docker)

#### Comando 1: verificar grupos do usuário

```bash
groups
```

Resultado esperado:

```text
aluno sudo docker
```

Análise:

- A presença do grupo `docker` indica que o usuário pode ter permissão de interação com o daemon Docker.
- A ausência do grupo `docker` não significa que Docker não está instalado ou ativo.

Alternativa técnica:

```bash
id
```

- Mostra os mesmos grupos com UID/GID numéricos.

---

#### Comando 2: verificar cgroups do processo PID 1

```bash
cat /proc/1/cgroup
```

Resultado esperado em host físico ou VM comum:

```text
0::/init.scope
```

Resultado esperado dentro de container:

```text
0::/docker/7f3c...
```

ou:

```text
0::/kubepods.slice/...
```

Análise:

- `/proc/1/cgroup` revela em quais cgroups o processo PID 1 está.
- Referências a `docker`, `containerd`, `kubepods` ou IDs longos de container sugerem que a sessão está dentro de um container.
- Em sistemas com cgroup v2, o formato pode ser mais compacto.

Alternativas técnicas:

```bash
cat /proc/self/cgroup
```

- Mostra cgroups do processo atual, útil quando o PID 1 não é conclusivo.

```bash
test -f /.dockerenv && echo "Possivel container Docker" || echo "Arquivo /.dockerenv ausente"
```

- `test -f`: verifica se o arquivo existe e é arquivo regular.
- `/.dockerenv`: marcador comum em containers Docker, mas nem sempre presente.

---

#### Comando 3: verificar socket do Docker

```bash
ls -l /var/run/docker.sock
```

Resultado esperado:

```text
srw-rw---- 1 root docker 0 May 16 08:00 /var/run/docker.sock
```

Análise:

- `s` no início das permissões indica socket Unix.
- Dono `root` e grupo `docker` são comuns.
- Se o usuário atual estiver no grupo `docker`, ele pode ter permissão de acesso ao socket.
- A presença do socket indica que o daemon Docker está disponível naquele host ou namespace.

Alternativa técnica:

```bash
find /var/run /run -maxdepth 2 -type s -name 'docker.sock' 2>/dev/null
```

Flags usadas:

- `/var/run /run`: caminhos comuns para sockets.
- `-maxdepth 2`: limita a profundidade da busca.
- `-type s`: procura sockets Unix.
- `-name 'docker.sock'`: filtra pelo nome.
- `2>/dev/null`: oculta erros de permissão.

---

#### Comando 4: verificar diretórios comuns do Docker

```bash
ls -ld /var/lib/docker /etc/docker /run/docker 2>/dev/null
```

Flags usadas:

- `-l`: formato longo.
- `-d`: lista o diretório em si, não seu conteúdo.
- `2>/dev/null`: oculta erros de permissão ou caminhos inexistentes.

Resultado esperado:

```text
drwx--x--- 13 root root   4096 May 16 08:00 /var/lib/docker
drwxr-xr-x  2 root root   4096 May 16 08:00 /etc/docker
drwx------  6 root root    160 May 16 08:00 /run/docker
```

Análise:

- A presença desses diretórios reforça que Docker está instalado ou foi utilizado.
- Usuários comuns geralmente não conseguem listar `/var/lib/docker`, mas podem ver metadados do diretório com `ls -ld`.

---

## 3. Fase 2: Descoberta de Rede e Hosts Adjacentes (Pivoting e Varredura)

Nesta fase, o aluno identifica vizinhos do `srvdocker01` na rede interna autorizada. Execute varreduras somente no escopo definido pelo instrutor.

### Passo 2.1: Descoberta de Subredes e Interfaces

#### Comando 1: listar interfaces e endereços IP

```bash
ip address show
```

Flags usadas:

- `address`: objeto do comando `ip` para endereços.
- `show`: exibe as interfaces e endereços configurados.

Resultado esperado:

```text
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 192.168.1.37/24 brd 192.168.1.255 scope global eth0
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
```

Análise:

- `eth0`: interface de rede principal no exemplo.
- `inet 192.168.1.37/24`: IP e prefixo CIDR.
- `/24`: máscara equivalente a `255.255.255.0`.
- Subrede resultante: `192.168.1.0/24`.
- `docker0`: bridge padrão do Docker, normalmente usada para containers locais.

Alternativa resumida:

```bash
ip -brief address
```

Flags usadas:

- `-brief`: saída compacta.
- `address`: mostra endereços.

Resultado esperado:

```text
lo       UNKNOWN        127.0.0.1/8 ::1/128
eth0     UP             192.168.1.37/24
docker0  DOWN           172.17.0.1/16
```

---

#### Comando 2: identificar rotas e gateway

```bash
ip route show
```

Resultado esperado:

```text
default via 192.168.1.1 dev eth0
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.37
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1
```

Análise:

- `default via 192.168.1.1`: gateway padrão.
- `192.168.1.0/24 dev eth0`: subrede diretamente conectada.
- `src 192.168.1.37`: IP local usado como origem para essa rota.

Como calcular o escopo:

- Se o IP for `192.168.1.37/24`, a rede é `192.168.1.0/24`.
- Se o IP for `10.10.5.23/24`, a rede é `10.10.5.0/24`.
- Se o IP for `172.16.12.50/16`, a rede é `172.16.0.0/16`. Em laboratório, confirme com o instrutor antes de varrer escopos grandes.

Alternativa com `ifconfig`:

```bash
ifconfig
```

Observação:

- `ifconfig` pode não estar instalado por padrão.
- Quando disponível, mostra IP, máscara e status das interfaces.

---

### Passo 2.2: Varredura de Ping (Host Discovery)

#### Comando 1: descobrir hosts vivos com nmap

```bash
nmap -sn -v 192.168.1.0/24
```

Flags usadas:

- `-sn`: host discovery sem port scan. O nmap tenta descobrir quais hosts estão ativos.
- `-v`: saída verbosa, útil para acompanhar o progresso.
- `192.168.1.0/24`: subrede alvo do laboratório. Substitua pelo escopo autorizado.

Resultado esperado:

```text
Nmap scan report for 192.168.1.1
Host is up (0.0020s latency).
Nmap scan report for 192.168.1.10
Host is up (0.0041s latency).
Nmap scan report for 192.168.1.37
Host is up (0.00010s latency).
Nmap done: 256 IP addresses (3 hosts up) scanned in 4.20 seconds
```

Análise:

- Cada bloco `Nmap scan report for` representa um host encontrado.
- `Host is up` indica que o nmap recebeu algum tipo de resposta.
- Latência baixa geralmente indica vizinhos próximos na mesma rede.
- Este comando faz descoberta de hosts e evita enumerar portas nesta etapa, deixando o exercício mais previsível para validação em sala.

Alternativas técnicas:

```bash
nmap -sn -v 192.168.1.1-254
```

- Usa faixa explícita em vez de CIDR.
- Útil para alunos ainda não confortáveis com notação CIDR.

```bash
nmap -sn -v -oG hosts.gnmap 192.168.1.0/24
```

Flags adicionais:

- `-oG hosts.gnmap`: salva saída em formato grepable.

Uso:

- Facilita extrair IPs ativos com ferramentas de texto.

---

#### Alternativa em Bash puro: ping sweep simples

Caso o `nmap` não esteja instalado e o usuário não tenha permissão para instalar pacotes, use um loop com `ping`.

```bash
for i in $(seq 1 254); do ping -c 1 -W 1 192.168.1.$i >/dev/null 2>&1 && echo "Host ativo: 192.168.1.$i"; done
```

Componentes usados:

- `for i in $(seq 1 254)`: percorre os endereços de `.1` até `.254`.
- `ping`: envia ICMP Echo Request.
- `-c 1`: envia apenas 1 pacote.
- `-W 1`: aguarda até 1 segundo por resposta.
- `>/dev/null 2>&1`: oculta saída normal e erros.
- `&& echo`: imprime somente quando o `ping` retorna sucesso.

Resultado esperado:

```text
Host ativo: 192.168.1.1
Host ativo: 192.168.1.10
Host ativo: 192.168.1.37
```

Análise:

- Hosts que bloqueiam ICMP podem não aparecer.
- Em redes locais, ARP pode revelar hosts mesmo quando ICMP é filtrado, mas isso depende das ferramentas disponíveis.
- Para subredes diferentes de `/24`, ajuste o loop e o prefixo IP conforme orientação do instrutor.

Alternativa com paralelismo controlado:

```bash
for i in $(seq 1 254); do (ping -c 1 -W 1 192.168.1.$i >/dev/null 2>&1 && echo "Host ativo: 192.168.1.$i") & done; wait
```

Análise:

- Executa pings em paralelo, reduzindo o tempo total.
- Pode gerar mais tráfego simultâneo; use somente se o instrutor autorizar.

---

### Passo 2.3: Varredura de Serviços e Banners (Port Scan)

#### Comando 1: varrer portas comuns em um host encontrado

```bash
nmap -sV -Pn --top-ports 20 IP_ALVO
```

Flags usadas:

- `-sV`: tenta identificar versão do serviço por banners e sondas de aplicação.
- `-Pn`: pula host discovery e trata o alvo como ativo.
- `--top-ports 20`: verifica as 20 portas mais comuns segundo a base do nmap.
- `IP_ALVO`: substitua por um IP encontrado no passo anterior, por exemplo `192.168.1.10`.

Resultado esperado:

```text
Nmap scan report for 192.168.1.10
Host is up (0.0030s latency).

PORT     STATE  SERVICE VERSION
22/tcp   open   ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.6
80/tcp   open   http    nginx 1.22.1
443/tcp  closed https
3306/tcp open   mysql   MySQL 8.0.35
```

Análise:

- `PORT`: porta e protocolo.
- `STATE`: estado observado. `open` indica serviço aceitando conexão.
- `SERVICE`: serviço inferido pelo nmap.
- `VERSION`: banner ou versão estimada.
- `OpenSSH ... Ubuntu`: pode sugerir distribuição ou família do sistema.
- `nginx`, `Apache`, `MySQL`, `PostgreSQL`, `Redis` e `Docker Registry` são exemplos de serviços comuns em ambientes internos.

Como deduzir o sistema ou papel do vizinho:

- `22/tcp OpenSSH ... Ubuntu`: provável Linux/Ubuntu.
- `3389/tcp ms-wbt-server`: provável Windows com RDP.
- `445/tcp microsoft-ds`: SMB, comum em Windows ou Samba.
- `5432/tcp postgresql`: banco PostgreSQL.
- `6379/tcp redis`: cache ou fila Redis.
- `5000/tcp registry`: possível Docker Registry interno.

Alternativas técnicas:

```bash
nmap -sV -Pn -p 22,80,443,5432,3306,6379,8080 IP_ALVO
```

Flags adicionais:

- `-p`: define lista explícita de portas.

Quando usar:

- Bom para laboratórios em que o instrutor quer validar serviços específicos.

```bash
nmap -sT -sV -Pn --top-ports 20 IP_ALVO
```

Flags adicionais:

- `-sT`: usa TCP connect scan, que não exige privilégios de root.

Quando usar:

- Em muitos sistemas, usuários comuns não podem executar tipos de scan que dependem de raw sockets.
- `-sT` é compatível com usuários sem privilégios, embora possa ser mais visível em logs de conexão.

---

#### Comando 2: salvar resultado para análise posterior

```bash
nmap -sV -Pn --top-ports 20 -oN nmap-IP_ALVO.txt IP_ALVO
```

Flags adicionais:

- `-oN nmap-IP_ALVO.txt`: salva a saída normal em arquivo texto.

Resultado esperado:

```text
Nmap done: 1 IP address (1 host up) scanned in 8.71 seconds
```

Análise:

- O arquivo `nmap-IP_ALVO.txt` facilita comparação entre execuções e elaboração de relatório.
- Substitua `IP_ALVO` no nome do arquivo pelo IP real, por exemplo `nmap-192.168.1.10.txt`.

---

## 4. Mitigação e Hardening do srvdocker01

As práticas abaixo são destinadas ao administrador do sistema. Elas reduzem exposição de metadados para usuários comuns e ajudam a limitar reconhecimento interno excessivo.

### Prática 1: ocultar processos de outros usuários com `hidepid`

Comando para aplicar em tempo de execução:

```bash
sudo mount -o remount,rw,hidepid=2 /proc
```

Flags e opções:

- `sudo`: executa com privilégios administrativos.
- `mount`: gerencia sistemas de arquivos montados.
- `-o`: define opções de montagem.
- `remount`: remonta um filesystem já montado.
- `rw`: mantém leitura e escrita.
- `hidepid=2`: impede usuários comuns de verem processos de outros usuários em `/proc`.
- `/proc`: filesystem de processos do Linux.

Resultado esperado:

- Usuários comuns passam a ver menos detalhes de processos que não pertencem a eles.
- Comandos como `ps aux` deixam de revelar boa parte da superfície operacional do host.

Configuração persistente em `/etc/fstab`:

```text
proc /proc proc defaults,hidepid=2 0 0
```

Análise:

- Valide cuidadosamente antes de aplicar em produção.
- Alguns agentes de monitoramento podem precisar de ajustes ou grupo dedicado.

Alternativa técnica:

```bash
sudo groupadd -f procmon
sudo usermod -aG procmon agente_monitoramento
sudo mount -o remount,rw,hidepid=2,gid=procmon /proc
```

- `gid=procmon` permite que membros do grupo `procmon` mantenham visibilidade operacional.

---

### Prática 2: restringir acesso ao socket Docker

Comando para auditar permissões:

```bash
sudo ls -l /var/run/docker.sock
```

Resultado esperado:

```text
srw-rw---- 1 root docker 0 May 16 08:00 /var/run/docker.sock
```

Comando para remover usuário comum do grupo Docker:

```bash
sudo gpasswd -d aluno docker
```

Flags e argumentos:

- `gpasswd`: administra membros de grupos.
- `-d`: remove usuário do grupo.
- `aluno`: usuário a ser removido.
- `docker`: grupo alvo.

Resultado esperado:

```text
Removing user aluno from group docker
```

Análise:

- O grupo `docker` deve ser tratado como altamente privilegiado.
- Usuários comuns não devem pertencer a esse grupo sem justificativa operacional.
- Após alteração de grupos, o usuário precisa encerrar e abrir nova sessão para refletir a mudança.

Alternativas técnicas:

```bash
sudo chmod 660 /var/run/docker.sock
sudo chown root:docker /var/run/docker.sock
```

- Mantém acesso restrito ao usuário `root` e grupo `docker`.
- Deve ser combinado com governança rígida de membros do grupo.

---

### Prática 3: reduzir exposição de serviços em interfaces amplas

Comando para identificar serviços escutando em todas as interfaces:

```bash
sudo ss -tulpn | awk '$5 ~ /(^0\.0\.0\.0:|^\[::\]:)/ {print}'
```

Componentes usados:

- `sudo ss -tulpn`: lista sockets com processos, usando privilégio administrativo.
- `awk`: filtra a coluna de endereço local.
- `$5`: coluna `Local Address:Port` em saídas comuns do `ss`.
- `0.0.0.0`: todas as interfaces IPv4.
- `[::]`: todas as interfaces IPv6.

Resultado esperado:

```text
tcp LISTEN 0 4096 0.0.0.0:22 0.0.0.0:* users:(("sshd",pid=1280,fd=3))
tcp LISTEN 0 4096 0.0.0.0:80 0.0.0.0:* users:(("docker-proxy",pid=1601,fd=4))
```

Mitigação conceitual:

- Serviços administrativos devem preferir bind em interface de gerenciamento ou `127.0.0.1` quando não precisarem ser expostos à rede.
- Firewalls locais devem permitir somente origens necessárias.
- Portas publicadas por containers devem ser revisadas explicitamente.

Exemplo com UFW para permitir SSH somente da rede de administração:

```bash
sudo ufw allow from 192.168.1.0/24 to any port 22 proto tcp
sudo ufw deny 22/tcp
sudo ufw status verbose
```

Flags e argumentos:

- `allow from 192.168.1.0/24`: permite origem específica.
- `to any port 22`: destino local na porta 22.
- `proto tcp`: restringe ao protocolo TCP.
- `deny 22/tcp`: nega outras conexões TCP para SSH conforme ordem/política do UFW.
- `status verbose`: mostra regras e política ativa.

Análise:

- Ajuste a subrede de administração conforme o laboratório.
- Cuidado para não bloquear sua própria sessão SSH. Em ambiente real, valide acesso alternativo antes de aplicar.

Alternativa com nftables:

```bash
sudo nft add rule inet filter input ip saddr 192.168.1.0/24 tcp dport 22 accept
sudo nft add rule inet filter input tcp dport 22 drop
sudo nft list ruleset
```

Análise:

- `nftables` é comum em distribuições modernas.
- A política final deve ser desenhada considerando regras existentes, ordem de avaliação e persistência.

---

## Checklist de Validação do Aluno

- Identifiquei meu usuário, UID, GID e grupos.
- Identifiquei distribuição, versão do kernel e hostname.
- Listei processos ativos e reconheci sinais de Docker/containerd.
- Mapeei portas locais e diferenciei `localhost` de interfaces expostas.
- Verifiquei evidências de containerização sem usar o comando `docker`.
- Identifiquei IP, interface, rota e subrede autorizada.
- Descobri hosts ativos na subrede do laboratório.
- Executei varredura de serviços em pelo menos um host autorizado.
- Registrei evidências e resultados esperados para discussão defensiva.
- Revisei práticas de hardening aplicáveis ao `srvdocker01`.
