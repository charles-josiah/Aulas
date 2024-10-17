# Laboratorio Cripto e SegRedes

## Topologia proposta:


![image](https://github.com/user-attachments/assets/b9e8eaf9-08f3-473d-af7f-0d912504aa99)


## Inventario da bagaça:

- 2x Servidores ri-serv1 e ri-serv2:
     - Utilizam Ubuntu Server.
     - Estão em modo DHCP e conectados à "RedeInterna".
     - Configuração de 2 CPUs, 2048 MB de RAM e disco de até 10 GB (modo thin provision).

- 1x Servidorde Firewall fw-serv02-
     - Utiliza Debian Server.
     - Possui duas placas de rede: uma em modo bridge e outra conectada à "RedeInterna".
     -  Configuração de 2 CPUs, 2048 MB de RAM e disco de até 5 GB (modo thin provision).

- 1x Servidores ri-slax01:
     - Utilizam uma distro live CD (Slax) e estão conectados à "RedeInterna".
     - Configuração de 2 CPUs, 2048 MB de RAM, e disco de até 10 GB (modo thin provision).
     - Eles carregam uma imagem ISO do Slax como Live CD.

- 1x Servidores ri-kali:
     - Utilizam uma distro live CD (Kali) e estão conectados à "RedeInterna".
     - Configuração de 2 CPUs, 2048 MB de RAM, e disco de até 10 GB (modo thin provision).
     - Eles carregam uma imagem ISO do Kali como Live CD.

O ambiente acima esta disponivel neste repositorio pelo arquivo de setup do [Vagrantfile](https://raw.githubusercontent.com/charles-josiah/Aulas/refs/heads/master/2024-Lab-Cripto-e-SegRedes/Vagrantfile) e sua [explicacao](https://github.com/charles-josiah/Aulas/blob/master/2024-Lab-Cripto-e-SegRedes/vagrantfile.md).


## Objetivos 

### Aula 2
#### Observação:
As instalações de servidores e aplicativos serão realizadas em tempo real. troubleshooting serao necessarios.
#### Objetivos
- Objetivo 1 - Fazer a bagaça funcionar
- Objetivo 2 - Entender algumas coisas basicas de rede
    - dns / gw / ip / default gw / etc
- Objetivo 3 - ver umas capturas do wireshark
    - dhcp / origem / destino / camadas / conteudo
- Objetivo 4 - entender diferenca entre rede em nat e routeada
- Objetivo 5 - fazer a bagaca sair para internet, 
    - ver um pouco de tcpdump x wireshark
- Objetivo 6 - ver se achamos algo bom no wireshark
### Aula 3
#### Observação:
As instalações de servidores e aplicativos serão realizadas em tempo real. troubleshooting serao necessarios.
#### Objetivos
- Objetivo 1 - RECAP Express: Conectar o ambiente à internet
  - Garantir que o ambiente esteja funcional e a máquina virtual tenha acesso à internet.
- Objetivo 2 - Subir servidor virtual "ri-serv2" e configurar na "RedeInterna"
  - Criar e configurar a máquina virtual "ri-serv2", conectando-a à rede interna "RedeInterna".
- Objetivo 3 - Instalar e configurar um servidor HTTP com NGINX
  - Configuração simples e funcional.
    - Criar 3 vhosts na rede interna:
      - **2 vhosts**: Sites completos aleatórios, baixados do [FreeCSS](https://www.free-css.com/free-css-templates).
      - **1 vhost**: Sistema de login básico.
- Objetivo 4 - Instalar e configurar um servidor MySQL
  - Configuração básica e rápida.
  - Criar 1 banco de dados para autenticação de usuários do sistema de login.
- Objetivo 5 - Capturar tráfego e verificar senhas de acesso
  - Realizar capturas de tráfego no ambiente para identificar senhas de acesso ao sistema de login.
### Aula 4
#### Observação:
As instalações de servidores e aplicativos serão realizadas em tempo real. troubleshooting serao necessarios.
#### Objetivos
- Objetivo 1 - RECAP Express: Conectar o ambiente à internet, Servico HTTP
  - Assegurar que o ambiente esteja funcional e que a máquina virtual tenha acesso à internet, habilitando o serviço HTTP.
- Objetivo 2: Implantação do Servidor Virtual "ri-serv1" na Rede Interna
  - Criar e configurar a máquina virtual "ri-serv1", conectando-a à rede interna denominada "RedeInterna".
- Objetivo 3: Instalação e Configuração de um Servidor FTP (vsftpd)
  - Realizar uma configuração simples e funcional:
    - Adicionar dois usuários para gerenciar seus respectivos sites, **site1** e **site2**.
    - Corrigir as permissões dos diretórios correspondentes a **site1** e **site2**.
    - Permitir que os usuários façam upload de arquivos no FTP.
    - Restringir o acesso dos usuários para que não naveguem livremente pelo servidor.
- Objetivo 4: Instalação e Configuração do phpMyAdmin
  - Implementar uma configuração básica, rápida e funcional:
    - Instalar e configurar o phpMyAdmin.
    - Configurar o Virtual Host no NGINX para o phpMyAdmin.
    - Habilitar o acesso remoto ao phpMyAdmin e explorar a aplicação, incluindo a criação e administração de usuários e bancos de dados.
- Objetivo 5: Captura de Tráfego e Validação
  - Realizar capturas de tráfego no ambiente para identificar e capturar as senhas dos usuários do FTP e do MySQL.
- Objetivo 6: Brainstorm, Reflexões, Divagações, Devaneios, Discussões, Deliberações, Propostas, Contemplações, Digressões, Ideias sobre Proteção em Serviços sem Criptografia
- Objetivo 7: Conversa sobre Criptografia Simétrica e Exploração de Vulnerabilidades
  - Investigar e analisar potenciais vulnerabilidades relacionadas a algoritmos de criptografia simétrica.
  - Material de apoio:
    - [Guia basico](https://github.com/charles-josiah/Aulas/blob/master/2024-Lab-Cripto-e-SegRedes/Guia_Criptografia_Linux.md)
    - https://openbenchmarking.org/
    - https://pgbackrest.org/
  - [Exemplo usando John the Ripper em um arquivo ZIP com senha](https://github.com/charles-josiah/Aulas/blob/master/2024-Lab-Cripto-e-SegRedes/ExemploJohnZIP.md)  
  - Reverter senhas / Descobrir(?) senhas:
    - Ferramenta: [MD5Hashing](https://md5hashing.net)
      - d3e9091dbe0c29fdbb7eb272e38f80800011b325
      - 5356235270111a9c2792caebc20e6eb5a420fc5e
      - 3a7d8c592f0175b771293a6d22937f392d5b147ebb4daa4ffde4ab6d51a7fdc3
      - 20c946581a23e80233acef8866267e3a
### Aula 5
#### Observação:
As instalações de servidores e aplicativos serão realizadas em tempo real. troubleshooting serao necessarios.
Triste noticia meu PC deu falha... E vamos ter que improvisar/inovar com a infra da Oracle OCI e dockers, a lot of dockers...<br>
[Nova topologia](https://github.com/charles-josiah/Aulas/blob/master/2024-Lab-Cripto-e-SegRedes/NovoSetup-UsandoOracleOCI/readme.MD)
#### Objetivos
- Objetivo 1 - RECAP Express: Conectar o ambiente à internet, Servico HTTP
  - Assegurar que o ambiente esteja funcional e que a máquina virtual tenha acesso à internet, habilitando o serviço HTTP.
- Objetivo 2: Validação do servidor HTTP se esta funcional ainda, e adicionar certificados SSL providos pelo Lelt's Encrypt.
  - Verificar no wireshark as diferencas de com x sem criptografia.
- Objetivo 3: Validação do Servidor FTP (vsftpd) e ativar a criptografia usando certificados SSL providos pelo Lelt's Encrypt .
  - Realizar testes simples e funcional:
    - Adicionar dois usuários para gerenciar seus respectivos sites, **site1** e **site2**.
    - Corrigir as permissões dos diretórios correspondentes a **site1** e **site2**.
    - Verificar no wireshark as diferencas de com x sem criptografia.
- Objetivo 4: Verificação do phpMyAdmin e adição de certificado HTTPs, via proxy reverso.
  -  Verificar no wireshark as diferencas de com x sem criptografia.
- Objetivo 5: Captura de Tráfego e Validação
  - Realizar capturas de tráfego no ambiente para identificar e capturar as senhas dos usuários do FTP, HTTP, PHPMyAdmin, do MySQL em conexões sem criptografia, e com (se possivel).
- Objetivo 6: Brainstorm, Reflexões, Divagações, Devaneios, Discussões, Deliberações, Propostas, Contemplações, Digressões, Ideias sobre Proteção em Serviços sem Criptografia
- Objetivo 7: Conversar sobre Criptografia Assimétrica.
  - Material de apoio:
    - [Guia basico](https://github.com/charles-josiah/Aulas/blob/master/2024-Lab-Cripto-e-SegRedes/criptografia_simetrica_introducao.md)
    - https://www.sslchecker.com/
    - https://www.sslshopper.com/
    - https://www.ssllabs.com/ssltest/
    - https://github.com/kspviswa/local-packet-whisperer









<h6>:wq!</h6>
