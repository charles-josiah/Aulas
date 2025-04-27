

sysctl -w net.ipv4.ip_forward=1
echo 0 > /proc/sys/net/ipv4/ip_forward

vi /etc/sysctl.conf
net.ipv4.ip_forward = 1
:wq!

ip route show


sudo sysctl -p


https://github.com/charles-josiah/Aulas/blob/master/2024-Lab-Cripto-e-SegRedes/README.md
20c946581a23e80233acef8866267e3a



https://anycript.com/crypto
https://www.md5.cz/
https://md5hashing.net/hash/md5
https://cryptii.com/pipes/aes-encryption
https://www.base64decode.org/

------------------------------------------------------


  apt-get install isc-dhcp-server


 cat dhcpd.conf
### Arquivo de configuracao do DHCP no servidor firewall 

option domain-name "intranet.faznada.lan";

subnet 172.31.234.0 netmask 255.255.255.0 { }

subnet 192.168.123.0 netmask 255.255.255.0 {
  range 192.168.123.10 192.168.123.100;
  option routers 192.168.123.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  default-lease-time 600;
  max-lease-time 7200;
}

cat  dhcpd6.conf 
default-lease-time 600;
max-lease-time 7200;
log-facility local7;
option dhcp6.domain-search "intranet.faznada.lan";


# Interface enp0s3 - rede pública IPv6
subnet6 2804:4d98:166:4c00::/64 {
  range6 2804:4d98:166:4c00::100 2804:4d98:166:4c00::200;
  option dhcp6.name-servers 2804:4d98:166:4c00::1;

}

# Interface enp0s8 - rede interna ULA
subnet6 fd00:1234:5678:abcd::/64 {
  range6 fd00:1234:5678:abcd::100 fd00:1234:5678:abcd::200;
  option dhcp6.name-servers fd00:1234:5678:abcd::1;
}


------------------------------------------------------


apt-get install rsyslog




ping  -p 73616920666f7261206d616c616e64726f 192.168.123.255 -b


------------------------------------------------------

root@RourterInternet:/etc/network# cat interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug enp0s3
iface enp0s3 inet dhcp

auto enp0s8
iface enp0s8 inet static
 address 192.168.123.1
 netmask 255.255.255.0



ip a
vi /etc/netplan/01-netcfg.yaml

network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: yes
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.123.1/24
      gateway4: 192.168.123.254
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1

netplan apply

------------------------------------------------------

Scanners 
 nmap -O 172.30.234.0/24
 nmap -sP 172.30.234.0/24


------------------------------------------------------
apt-get install nginx




