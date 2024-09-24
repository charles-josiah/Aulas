
Explicação:

    Servidores serv1 e serv2:
        Utilizam Ubuntu Server.
        Estão em modo DHCP e conectados à "RedeInterna".
        Configuração de 2 CPUs, 2048 MB de RAM e disco de até 10 GB (modo thin provision).

    Servidor de Firewall fw-serv02:
        Utiliza Debian Server.
        Possui duas placas de rede: uma em modo bridge e outra conectada à "RedeInterna".
        Configuração de 2 CPUs, 2048 MB de RAM e disco de até 5 GB (modo thin provision).

    Servidores slax01 e slax02:
        Utilizam uma distro live CD (Slax) e estão conectados à "RedeInterna".
        Configuração de 2 CPUs, 2048 MB de RAM, e disco de até 10 GB (modo thin provision).
        Eles carregam uma imagem ISO do Slax como Live CD.

Observações:

    Substitua path/to/slax.iso pelo caminho correto da ISO do Slax.
    Você pode ajustar a box do Slax ou do Debian conforme sua preferência, já que o Vagrant não tem uma box oficial para Slax.

Rodando esse script, ele criará e configurará as VMs conforme descrito.
