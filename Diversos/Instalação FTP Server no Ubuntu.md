# Instalação FTP Server no Ubuntu

<hr>
Author: Charles Josiah
Email: charles.alandt(at)gmail.com
<hr>

## Pré-requisitos

Antes de iniciar este tutorial, você precisará do seguinte:

* Acesso a um servidor linux Ubuntu 20.04 
* Acesso root ou permissão de superusuário
* Liberação de firewalls tanto no servidor quanto na infraestrutura.

# 1 - Instalando os pacotes basicos 
````
apt-get update
apt-get install vsftpd
````
Apos a finalização da instação, vamos validar o funcionamento.
````
systemctl status vsftpd
````

No arquivo de configuração iremos configurar algumas linhas.... 
Adicione as seguinte linhas,

```` 
editar arquivo /etc/vsftpd.conf
Adicionar as seguintes linhas:


pasv_enable=yes
pasv_min_port=40000
pasv_max_port=50000
pasv_address= (endereço ip da instancia aws, curl ifconfig.me)
#Editar as regras de firewall, security group, da AWS, para permitir o o trafego 40000 ate 50000
#salvar e sair

````

Reiniciar o FTP

````
systemctl restart vsftpd
systemctl status vsftpd
````

# 2 - Configurar os usuários: 


````
useradd site1 -d /var/www/html/site1
passwd site1
useradd site2 -d /var/www/html/site2
passwd site2
useradd site3 -d /var/www/html/site3
passwd site3
````

Validar se o usuario acessa o FTP e se navega em todas as pastas…

-> Validar se realmente o usuario esta conseguindo navegar pelo sistema operacional.

````
ftp <IP DA INSTANCIA>
usuario: site1
paswd: site1
````

***E navegar pelo sistema operacional para validar que possui acesso full ao SO.***

Restringir essa navegação ao sistema operacional:


````
editar o /etc/vsftpd.conf

e "descomentar" a linha:
chroot_local_user=YES
#ir ao final do arquivo vsftpd.conf e adicioanr as linhas:
write_enable=YES
allow_writeable_chroot=YES


#salvar e sair :wq!)

````

systemctl restart vsftpd

-> Validar se realmente o usuario esta “preso” do diretorio.


# 3 - Ajustar o permissionamento:

dos sites disponíveis (site1, site2, site3):

````
cd /var/www/html/
chown site1.site1 site1
chown site1.site1 site1/*
````


-> Acessar novamente via ftp e validar se é possivel criar e copiar arquivos.

Alterar a configuração do vsftpd (/etc/vsftpd.conf), descomentando as seguintes linhas.

````
#local_enable=YES -> local_enable=YES
#local_umask=022 -> local_umask=022 

#salvar e sair  :wq! 

systemctl restart vsftpd
````


Testar com o filezila ou outro app de FTP.
