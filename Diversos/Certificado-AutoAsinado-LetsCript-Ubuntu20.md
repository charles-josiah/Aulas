# Como criar um certificado SSL auto-assinado e LetScript para o Apache no Ubuntu 20.04

<hr>
Author: Charles Josiah
Email: charles.alandt(at)gmail.com
<hr>

## Introdução

O **TLS**, ou "segurança de camada de transporte" — versão para substituir o  **SSL** devido a questões de segurança  — são protocolos usados para proteger o tráfego normal de um serviço http, ou outro que desejar, em um pacote protegido, criptografado os mesmos. Ao usar esta tecnologia, os servidores podem enviar informações com segurança aos seus clientes sem que suas mensagens sejam interceptadas ou lidas por hackers e outras pragas digitais.

**Nota:** um certificado auto-assinado irá criptografar a comunicação entre seu servidor e qualquer cliente. No entanto, uma vez que ele não é assinado por nenhuma das autoridades de certificados confiáveis incluídas com navegadores Web e sistemas operacionais, os usuários não podem usar o certificado para validar a identidade do seu servidor automaticamente. Como resultado, seus usuários irão ver um erro de segurança ao visitar seu site.

Devido a esta limitação, certificados auto-assinados não são adequados para um ambiente de produção que atenda ao público e serviços de internet. Eles são normalmente usados para testes e desenvolvimento. 

Podemos optar em criar uma entidade certificadora e importar para o navegador, assim nossos certificados serão considerados válidos na navegação via browser.  Um exemplo num cenário corporativo onde podemos controlar os certificados disponíveis e instalados em nossas estações de trabalho. 

Para uma solução de certificado mais pronta para produção, confira o Let’s Encrypt, uma autoridade certificadora gratuita. 

## Pré-requisitos

Antes de iniciar este tutorial, você precisará do seguinte:

* Acesso a um servidor Ubuntu 20.04 
* Você também precisará ter o Apache instalado. 
* Apache já deve estar com configurações basicas e disponibilizando um site basico 
* Acesso root ou permissão de superusuário
* Liberação de firewalls tanto no servidor quanto na infraestrutura.

# Instalação de certificado auto-assinado 

## **Passo 1 — Habilitando o mod_ssl**

Antes de usarmos *qualquer* certificado de SSL, é necessário, primeiramente, habilitar o mod_ssl, um módulo do Apache compatível com criptografia SSL.

Habilite o mod_ssl com o comando a2enmod:

* sudo a2enmod ssl

Reinicie o Apache para ativar o módulo:

* sudo systemctl restart apache2

*O módulo mod_ssl agora está habilitado e pronto para uso.*

````
 a2enmod ssl

Considering dependency setenvif for ssl:
Module setenvif already enabled
Considering dependency mime for ssl:
Module mime already enabled
Considering dependency socache_shmcb for ssl:
Enabling module socache_shmcb.
Enabling module ssl.

See /usr/share/doc/apache2/README.Debian.gz on how to configure SSL and create self-signed certificates.
````

Para ativar a nova configuração: 

````
 systemctl restart apache2
 systemctl status apache2

● apache2.service - The Apache HTTP Server

     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2021-04-08 23:12:22 UTC; 5min ago
       Docs: https://httpd.apache.org/docs/2.4/
    Process: 8837 ExecReload=/usr/sbin/apachectl graceful (code=exited, status=0/SUCCESS)

   Main PID: 1598 (apache2)
    Tasks: 6 (limit: 1160)
     Memory: 30.4M
     CGroup: /system.slice/apache2.service
             ├─1598 /usr/sbin/apache2 -k start
             ├─8875 /usr/sbin/apache2 -k start
             ├─8876 /usr/sbin/apache2 -k start
             ├─8877 /usr/sbin/apache2 -k start
             ├─8878 /usr/sbin/apache2 -k start
             └─8879 /usr/sbin/apache2 -k start

Apr 08 23:12:21 ip-172-31-52-173 systemd[1]: Starting The Apache HTTP Server...
Apr 08 23:12:22 ip-172-31-52-173 systemd[1]: Started The Apache HTTP Server.
Apr 08 23:17:18 ip-172-31-52-173 systemd[1]: Reloading The Apache HTTP Server.
Apr 08 23:17:18 ip-172-31-52-173 systemd[1]: Reloaded The Apache HTTP Server.

````

**Passo 2 — Criando o certificado SSL**

Podemos criar a chave SSL e os arquivos de certificado com o comando openssl:

````
 sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

 ````

Opções utilizadas pelo openssl

* openssl: esta é a ferramenta  para criação e gerenciamento de certificados OpenSSL, chaves e outros arquivos.

* req -x509: isto especifica que queremos usar o gerenciamento X.509 de solicitação de assinatura de certificado (CSR). O X.509 é um padrão de infraestrutura de chave pública ao qual o SSL e o TLS aderem para gerenciamento de chaves e certificados.

* -nodes: isso diz ao OpenSSL para pular a opção de proteger nosso certificado com uma frase secreta. Precisamos que o Apache consiga ler o arquivo, sem a intervenção do usuário, quando o servidor for iniciado. Uma frase secreta impediria que isso acontecesse porque teríamos que digitá-la após cada reinício.

* -days 365: esta opção define o período de tempo em que o certificado será considerado válido. Aqui, nós configuramos ela para um ano. Muitos navegadores modernos irão rejeitar quaisquer certificados que sejam válidos por mais de um ano.

* -newkey rsa:2048: isso especifica que queremos gerar um novo certificado e uma nova chave ao mesmo tempo. Não criamos a chave necessária para assinar o certificado em um passo anterior, então precisamos criá-la junto com o certificado. A parte rsa:2048 diz a ele para criar uma chave RSA com 2048 bits.

* -keyout: esta linha diz ao OpenSSL onde colocar o arquivo de chave privada gerado que estamos criando.

* -out: isso diz ao OpenSSL onde colocar o certificado que estamos criando.

***Vamos criar nosso certificado:***
````
root@ip-172-31-52-173:/var/www/html# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

Generating a RSA private key

.............+++++
............+++++
writing new private key to '/etc/ssl/private/apache-selfsigned.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.

What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----

Country Name (2 letter code) [AU]:BR
State or Province Name (full name) [Some-State]:SantaCatarina
Locality Name (eg, city) []:Florianopolis
Organization Name (eg, company) [Internet Widgits Pty Ltd]:XYZ Corp
Organizational Unit Name (eg, section) []:Very Security Security Team
Common Name (e.g. server FQDN or YOUR name) []:brocolis.faznada.xyz                       
Email Address []:brocolis@xyz.security.team

root@ip-172-31-52-173:/var/www/html# 
root@ip-172-31-52-173:/var/www/html# 

````

obs.: o FQDN precisa ser obrigatoriamente o endereço do site disponível no servidor.


## **Passo 3 — Configurando o Apache para usar SSL**

Agora que temos nosso certificado auto-assinado e a chave disponíveis, precisamos atualizar nossa configuração do Apache para usá-los. No Ubuntu, você pode colocar novos arquivos de configuração do Apache (eles devem terminar em .conf) dentro de /etc/apache2/sites-available/ e eles serão carregados da próxima vez que o processo do Apache for recarregado ou reiniciado.

Para nosso exemplo, criaremos um novo arquivo de configuração mínima. Abra um novo arquivo no diretório /etc/apache2/sites-available:

* sudo vi /etc/apache2/sites-available/000-default-ssl.conf

Cole nele a seguinte configuração mínima do VirtualHost:

````
root@ip-172-31-52-173:/etc/apache2/sites-enabled# cat 000-default-ssl.conf

<VirtualHost *:443>
   ServerName brocolis.faznada.xyz
   DocumentRoot /var/www/html
   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>

````

**Certifique-se de atualizar a linha ServerName para o que você pretende endereçar ao seu servidor. Isso pode ser um nome de host, nome de domínio completo, ou um endereço IP. Verifique se o que você escolhe corresponde ao Common Name e FQDN que você escolheu ao criar o certificado.** 

As linhas restantes especificam um diretório DocumentRoot a partir do qual serão apresentados os arquivos e as opções SSL necessárias para apontar o Apache para nosso certificado e chave recém-criados.

 

Em seguida, vamos testar à procura de erros de configuração e reiniciar o serviço para aplicar as devidas configurações.

 
* root@ip-172-31-52-173:~# cd /etc/apache2/sites-enabled/
* root@ip-172-31-52-173:/etc/apache2/sites-enabled# ls
000-default-ssl.conf  000-default.conf

* root@ip-172-31-52-173:/etc/apache2/sites-enabled# vi 000-default-ssl.conf 

* root@ip-172-31-52-173:/etc/apache2/sites-enabled# vi 000-default-ssl.conf 

* root@ip-172-31-52-173:/etc/apache2/sites-enabled# apache2ctl configtest

**Syntax OK**

* root@ip-172-31-52-173:/etc/apache2/sites-enabled# systemctl restart apache2.service 

● apache2.service - The Apache HTTP Server

     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)

     Active: active (running) since Thu 2021-04-08 23:36:41 UTC; 5s ago

       Docs: https://httpd.apache.org/docs/2.4/

    Process: 12403 ExecStart=/usr/sbin/apachectl start (code=exited, status=0/SUCCESS)

   Main PID: 12417 (apache2)

      Tasks: 6 (limit: 1160)

     Memory: 16.9M

     CGroup: /system.slice/apache2.service
             ├─12417 /usr/sbin/apache2 -k start
             ├─12418 /usr/sbin/apache2 -k start
             ├─12419 /usr/sbin/apache2 -k start
             ├─12420 /usr/sbin/apache2 -k start
             ├─12421 /usr/sbin/apache2 -k start
             └─12422 /usr/sbin/apache2 -k start

Apr 08 23:36:41 ip-172-31-52-173 systemd[1]: Starting The Apache HTTP Server...

 

Se tudo for bem-sucedido, você receberá um resultado que se parecerá com este:

 

Agora, carregue seu site em um navegador, garantindo usar https:// no início e tudo deve dar certo.

![image alt text](image_0.png)

Obs.: por estarmos utilizando um certificado auto-assinado a comunicação ocorre criptografada porem, o browser não reconhece a entidade certificado. Apresentanda o certificado de forma "quebrada".

# Agora implementando um certificado letsencrypt.org….

Para um correto funcionamento do certificado precisamos queo nome do site completo (FQDN) esta acessível na internet, pois um teste de validação da let 's encrypt, tentará acesso ao nosso servidor utilizando este nome. Caso não encontre, ele não emitirá o certificado.

## **Passo 1 - Instalando o Certbot**

* sudo apt install certbot

**root@ip-172-31-52-173:~#   apt -y install certbot **

Reading package lists... Done

Building dependency tree       

Reading state information... Done

The following additional packages will be installed:

  python3-acme python3-certbot python3-configargparse python3-future python3-icu python3-josepy python3-mock python3-parsedatetime python3-pbr

  python3-requests-toolbelt python3-rfc3339 python3-tz python3-zope.component python3-zope.event python3-zope.hookable

Suggested packages:

  python3-certbot-apache python3-certbot-nginx python-certbot-doc python-acme-doc python-future-doc python-mock-doc

The following NEW packages will be installed:

  certbot python3-acme python3-certbot python3-configargparse python3-future python3-icu python3-josepy python3-mock python3-parsedatetime python3-pbr

  python3-requests-toolbelt python3-rfc3339 python3-tz python3-zope.component python3-zope.event python3-zope.hookable

0 upgraded, 16 newly installed, 0 to remove and 27 not upgraded.

Need to get 1152 kB of archives.

After this operation, 6066 kB of additional disk space will be used.

Get:1 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/universe amd64 python3-josepy all 1.2.0-2 [28.1 kB]

Get:2 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/main amd64 python3-pbr all 5.4.5-0ubuntu1 [64.0 kB]

Get:3 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/universe amd64 python3-mock all 3.0.5-1build1 [25.6 kB]

Get:4 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/universe amd64 python3-requests-toolbelt all 0.8.0-1.1 [35.2 kB]

Get:5 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/main amd64 python3-tz all 2019.3-1 [24.4 kB]

Get:6 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/main amd64 python3-rfc3339 all 1.1-2 [6808 B]

Get:7 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/universe amd64 python3-acme all 1.1.0-1 [29.6 kB]

Get:8 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/universe amd64 python3-configargparse all 0.13.0-2 [22.6 kB]

Get:9 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/main amd64 python3-future all 0.18.2-2 [336 kB]

Get:10 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/universe amd64 python3-parsedatetime all 2.4-5 [32.6 kB]

Get:11 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/universe amd64 python3-zope.hookable amd64 5.0.0-1build1 [11.2 kB]

Get:12 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/universe amd64 python3-zope.event all 4.4-2build1 [7704 B]

Get:13 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/universe amd64 python3-zope.component all 4.3.0-3 [38.3 kB]

Get:14 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal-updates/universe amd64 python3-certbot all 0.40.0-1ubuntu0.1 [223 kB]

Get:15 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal/main amd64 python3-icu amd64 2.4.2-0ubuntu3 [250 kB]

Get:16 http://us-east-1.ec2.archive.ubuntu.com/ubuntu focal-updates/universe amd64 certbot all 0.40.0-1ubuntu0.1 [17.9 kB]

Fetched 1152 kB in 0s (7284 kB/s)

Selecting previously unselected package python3-josepy.

(Reading database ... 93109 files and directories currently installed.)

Preparing to unpack .../00-python3-josepy_1.2.0-2_all.deb ...

Unpacking python3-josepy (1.2.0-2) ...

Selecting previously unselected package python3-pbr.

Preparing to unpack .../01-python3-pbr_5.4.5-0ubuntu1_all.deb ...

Unpacking python3-pbr (5.4.5-0ubuntu1) ...

Selecting previously unselected package python3-mock.

Preparing to unpack .../02-python3-mock_3.0.5-1build1_all.deb ...

Unpacking python3-mock (3.0.5-1build1) ...

Selecting previously unselected package python3-requests-toolbelt.

Preparing to unpack .../03-python3-requests-toolbelt_0.8.0-1.1_all.deb ...

Unpacking python3-requests-toolbelt (0.8.0-1.1) ...

Selecting previously unselected package python3-tz.

Preparing to unpack .../04-python3-tz_2019.3-1_all.deb ...

Unpacking python3-tz (2019.3-1) ...

Selecting previously unselected package python3-rfc3339.

Preparing to unpack .../05-python3-rfc3339_1.1-2_all.deb ...

Unpacking python3-rfc3339 (1.1-2) ...

Selecting previously unselected package python3-acme.

Preparing to unpack .../06-python3-acme_1.1.0-1_all.deb ...

Unpacking python3-acme (1.1.0-1) ...

Selecting previously unselected package python3-configargparse.

Preparing to unpack .../07-python3-configargparse_0.13.0-2_all.deb ...

Unpacking python3-configargparse (0.13.0-2) ...

Selecting previously unselected package python3-future.

Preparing to unpack .../08-python3-future_0.18.2-2_all.deb ...

Unpacking python3-future (0.18.2-2) ...

Selecting previously unselected package python3-parsedatetime.

Preparing to unpack .../09-python3-parsedatetime_2.4-5_all.deb ...

Unpacking python3-parsedatetime (2.4-5) ...

Selecting previously unselected package python3-zope.hookable.

Preparing to unpack .../10-python3-zope.hookable_5.0.0-1build1_amd64.deb ...

Unpacking python3-zope.hookable (5.0.0-1build1) ...

Selecting previously unselected package python3-zope.event.

Preparing to unpack .../11-python3-zope.event_4.4-2build1_all.deb ...

Unpacking python3-zope.event (4.4-2build1) ...

Selecting previously unselected package python3-zope.component.

Preparing to unpack .../12-python3-zope.component_4.3.0-3_all.deb ...

Unpacking python3-zope.component (4.3.0-3) ...

Selecting previously unselected package python3-certbot.

Preparing to unpack .../13-python3-certbot_0.40.0-1ubuntu0.1_all.deb ...

Unpacking python3-certbot (0.40.0-1ubuntu0.1) ...

Selecting previously unselected package python3-icu.

Preparing to unpack .../14-python3-icu_2.4.2-0ubuntu3_amd64.deb ...

Unpacking python3-icu (2.4.2-0ubuntu3) ...

Selecting previously unselected package certbot.

Preparing to unpack .../15-certbot_0.40.0-1ubuntu0.1_all.deb ...

Unpacking certbot (0.40.0-1ubuntu0.1) ...

Setting up python3-configargparse (0.13.0-2) ...

Setting up python3-requests-toolbelt (0.8.0-1.1) ...

Setting up python3-icu (2.4.2-0ubuntu3) ...

Setting up python3-zope.event (4.4-2build1) ...

Setting up python3-pbr (5.4.5-0ubuntu1) ...

update-alternatives: using /usr/bin/python3-pbr to provide /usr/bin/pbr (pbr) in auto mode

Setting up python3-tz (2019.3-1) ...

Setting up python3-mock (3.0.5-1build1) ...

Setting up python3-zope.hookable (5.0.0-1build1) ...

Setting up python3-josepy (1.2.0-2) ...

Setting up python3-future (0.18.2-2) ...

update-alternatives: using /usr/bin/python3-futurize to provide /usr/bin/futurize (futurize) in auto mode

update-alternatives: using /usr/bin/python3-pasteurize to provide /usr/bin/pasteurize (pasteurize) in auto mode

Setting up python3-rfc3339 (1.1-2) ...

Setting up python3-parsedatetime (2.4-5) ...

Setting up python3-zope.component (4.3.0-3) ...

Setting up python3-acme (1.1.0-1) ...

Setting up python3-certbot (0.40.0-1ubuntu0.1) ...

Setting up certbot (0.40.0-1ubuntu0.1) ...

Created symlink /etc/systemd/system/timers.target.wants/certbot.timer → /lib/systemd/system/certbot.timer.

Processing triggers for man-db (2.9.1-1) ...

## **Passo 2 - Configurando o nosso Certbot**

O Certbot vai oferecer várias maneiras de obter certificados SSL através de plug-ins.  Lembrando que neste momento não podemos ter nenhum servidor web ou serviço consumindo a porta 80 do nosso servidor, pois a Let 's Encrypt fará um teste de comunicação, como dito anteriormente, para o nosso servidor.

No comando do certboot temos que informar obrigatoriamente a opção -d para dizer qual é o nosso site/servidor/FQDN

root@ip-172-31-52-173:~# **certbot certonly --webroot -w /var/www/html -d brocolis.faznada.xyz**

Saving debug log to /var/log/letsencrypt/letsencrypt.log

Plugins selected: Authenticator webroot, Installer None

Enter email address (used for urgent renewal and security notices) (Enter 'c' to

cancel): brocolis@faznada.xyz

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Please read the Terms of Service at

https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must

agree in order to register with the ACME server at

https://acme-v02.api.letsencrypt.org/directory

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(A)gree/(C)ancel: A

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Would you be willing to share your email address with the Electronic Frontier

Foundation, a founding partner of the Let's Encrypt project and the non-profit

organization that develops Certbot? We'd like to send you email about our work

encrypting the web, EFF news, campaigns, and ways to support digital freedom.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(Y)es/(N)o: Y

Obtaining a new certificate

Performing the following challenges:

http-01 challenge for brocolis.faznada.xyz

Using the webroot path /var/www/html for all unmatched domains.

Waiting for verification...

Cleaning up challenges

Saving debug log to /var/log/letsencrypt/letsencrypt.log

Plugins selected: Authenticator webroot, Installer None

Obtaining a new certificate

IMPORTANT NOTES:

 - Congratulations! Your certificate and chain have been saved at:

**   /etc/letsencrypt/live/brocolis.faznada.xyz/fullchain.pem**

   Your key file has been saved at:

**   /etc/letsencrypt/live/brocolis.faznada.xyz/privkey.pem**

   Your cert will expire on 2021-07-07. To obtain a new or tweaked

   version of this certificate in the future, simply run certbot

   again. To non-interactively renew *all* of your certificates, run

   "certbot renew"

 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate

   Donating to EFF:                    https://eff.org/donate-le

root@ip-172-31-52-173:~# 

Obs.: No final da execução do certbot, ele informou qual é a localização dos nossos arquivos  de certificados.

## **Passo 3 - Configurando o nosso Apache**

Para finalizar o processo, temos que atualizar a coniguração do nosso site HTTPS. Lembra, do 000-default-ssl.conf ? Então esse é o arquivo que temos que atualizar o certificado.

root@ip-172-31-52-173:/etc/apache2/sites-enabled# cat 000-default-ssl.conf 

<VirtualHost *:443>

   ServerName brocolis.faznada.xyz

   DocumentRoot /var/www/html

   SSLEngine on

   SSLCertificateFile **/etc/letsencrypt/live/brocolis.faznada.xyz/fullchain.pem**

**   SSLCertificateKeyFile    /etc/letsencrypt/live/brocolis.faznada.xyz/privkey.pem**

</VirtualHost>

root@ip-172-31-52-173:/etc/apache2/sites-enabled# 

Os caminhos do certificado foram fornecidos na etapa anterior.

Vamos reiniciar/reload o apache, e testar.

root@ip-172-31-52-173:/etc/apache2/sites-enabled# **apache2ctl configtest **

**Syntax OK**

root@ip-172-31-52-173:/etc/apache2/sites-enabled# 

root@ip-172-31-52-173:/etc/apache2/sites-enabled# 

root@ip-172-31-52-173:/etc/apache2/sites-enabled# 

root@ip-172-31-52-173:/etc/apache2/sites-enabled#** systemctl restart apache2.service** 

● apache2.service - The Apache HTTP Server

     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)

     Active: active (running) since Thu 2021-04-08 23:36:41 UTC; 5s ago

       Docs: https://httpd.apache.org/docs/2.4/

    Process: 12403 ExecStart=/usr/sbin/apachectl start (code=exited, status=0/SUCCESS)

   Main PID: 12417 (apache2)

      Tasks: 6 (limit: 1160)

     Memory: 16.9M

     CGroup: /system.slice/apache2.service

             ├─12417 /usr/sbin/apache2 -k start

             ├─12418 /usr/sbin/apache2 -k start

             ├─12419 /usr/sbin/apache2 -k start

             ├─12420 /usr/sbin/apache2 -k start

             ├─12421 /usr/sbin/apache2 -k start

             └─12422 /usr/sbin/apache2 -k start

Apr 08 23:36:41 ip-172-31-52-173 systemd[1]: Starting The Apache HTTP Server...

Se tudo for bem-sucedido, você receberá um resultado que se parecerá com este:

![image alt text](image_1.png)

