# Laboratorio Cripto e SegRedes

## Topologia proposta:


![image](https://github.com/user-attachments/assets/b9e8eaf9-08f3-473d-af7f-0d912504aa99)


## Inventario da bagaça:

- 1x Servidores ri-serv1 e ri-serv2:
     - Utilizam Ubuntu Server.
     - Estão em modo DHCP e conectados à "RedeInterna".
     - Configuração de 2 CPUs, 2048 MB de RAM e disco de até 10 GB (modo thin provision).

- 1x Servidorde Firewall fw-serv02-
     - Utiliza Debian Server.
     - Possui duas placas de rede: uma em modo bridge e outra conectada à "RedeInterna".
     -  Configuração de 2 CPUs, 2048 MB de RAM e disco de até 5 GB (modo thin provision).

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
#### Links
- [Nota da Aula](https://github.com/charles-josiah/Aulas/blob/master/2025-09-Lab-Cripto-e-SegRedes/Nota01.md)
- [ + Nota da Aula](https://github.com/charles-josiah/Aulas/blob/master/2025-09-Lab-Cripto-e-SegRedes/lab_cripto_1.md)



<h6>:wq!</h6>
