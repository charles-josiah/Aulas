# Vagrantfile

Este Vagrantfile configura um ambiente com várias máquinas virtuais (VMs) usando Vagrant e VirtualBox. Abaixo está o detalhamento da configuração:

```ruby
Vagrant.configure("2") do |config|

  # Obter o timestamp atual
  timestamp = Time.now.to_i

  # Configurações globais
  config.vm.provider "virtualbox" do |vb|
    # Todas as máquinas em modo promíscuo
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
  end

  # Configurações de rede interna
  internal_network_options = {
    type: "private_network",
    virtualbox__intnet: "RedeInterna",
    auto_config: false
  }

  # Servidor 1 (Ubuntu)
  config.vm.define "serv1" do |serv1|
    serv1.vm.box = "ubuntu/bionic64"
    serv1.vm.hostname = "serv1"
    serv1.vm.network "private_network", virtualbox__intnet: "RedeInterna", auto_config: false
    serv1.vm.provider "virtualbox" do |vb|
      vb.name = "ri-serv1_#{timestamp}"
      vb.memory = "2048"
      vb.cpus = 2
      # Nome do disco com timestamp
      disk_name = "serv1_#{timestamp}.vdi"
      vb.customize ["createhd", "--filename", disk_name, "--size", 10000, "--variant", "Standard"]
      # Descomente para remover NIC1
      # vb.customize ["modifyvm", :id, "--nic1", "none"]
    end
  end

  # Servidor 2 (Ubuntu)
  config.vm.define "serv2" do |serv2|
    serv2.vm.box = "ubuntu/bionic64"
    serv2.vm.hostname = "serv2"
    serv2.vm.network "private_network", virtualbox__intnet: "RedeInterna", auto_config: false
    serv2.vm.provider "virtualbox" do |vb|
      vb.name = "ri-serv2_#{timestamp}"
      vb.memory = "2048"
      vb.cpus = 2
      # Nome do disco com timestamp
      disk_name = "serv2_#{timestamp}.vdi"
      vb.customize ["createhd", "--filename", disk_name, "--size", 10000, "--variant", "Standard"]
      # Descomente para remover NIC1
      # vb.customize ["modifyvm", :id, "--nic1", "none"]
    end
  end

  # Firewall Servidor (Debian)
  config.vm.define "fw-serv02" do |fw|
    fw.vm.box = "debian/buster64"
    fw.vm.hostname = "fw-serv02"
    fw.vm.network "public_network", bridge: "wlp0s20f3", use_dhcp_assigned_default_route: true
    fw.vm.network "private_network", virtualbox__intnet: "RedeInterna", auto_config: false
    fw.vm.provider "virtualbox" do |vb|
      vb.name = "fw-serv02_#{timestamp}"
      vb.memory = "2048"
      vb.cpus = 2
      # Nome do disco com timestamp
      disk_name = "fw-serv02_#{timestamp}.vdi"
      vb.customize ["createhd", "--filename", disk_name, "--size", 5000, "--variant", "Standard"]
    end
  end

  # Servidor Slax 1 (CentOS com XFCE)
  config.vm.define "slax01" do |slax1|
    slax1.vm.box = "pure360/centos-7.0-64-puppet-xfce"
    slax1.vm.hostname = "slax01"
    slax1.vm.network "private_network", virtualbox__intnet: "RedeInterna", auto_config: false
    slax1.vm.provider "virtualbox" do |vb|
      vb.name = "ri-slax01_#{timestamp}"
      vb.memory = "2048"
      vb.cpus = 2
      # Nome do disco com timestamp e tamanho ajustado
      disk_name = "slax01_#{timestamp}.vdi"
      vb.customize ["createhd", "--filename", disk_name, "--size", 1024, "--variant", "Standard"]
      # Descomente para remover NIC1
      # vb.customize ["modifyvm", :id, "--nic1", "none"]
    end
  end

  # Servidor Kali Linux
  config.vm.define "kali" do |kali|
    kali.vm.box = "kalilinux/rolling"
    kali.vm.hostname = "kali"
    kali.vm.network "private_network", virtualbox__intnet: "RedeInterna", auto_config: false
    kali.vm.provider "virtualbox" do |vb|
      vb.name = "ri-kali_#{timestamp}"
      vb.memory = "2048"
      vb.cpus = 2
      # Nome do disco com timestamp
      disk_name = "kali_#{timestamp}.vdi"
      vb.customize ["createhd", "--filename", disk_name, "--size", 10000, "--variant", "Standard"]
      # Descomente para remover NIC1
      # vb.customize ["modifyvm", :id, "--nic1", "none"]
    end
  end
end
```
## Explicação do Vagrantfile

- Timestamp:

```ruby
timestamp = Time.now.to_i
```

Obtém o timestamp atual para garantir que cada máquina virtual e disco tenha um identificador único.

- Configurações Globais do VirtualBox:

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
end
```
Configura todas as máquinas para operar em modo promíscuo para a segunda interface de rede (nicpromisc2).

- Configuração de Rede Interna:

```ruby
internal_network_options = {
  type: "private_network",
  virtualbox__intnet: "RedeInterna",
  auto_config: false
}
```
Define as configurações de rede interna para ser uma rede privada com o nome "RedeInterna" e sem configuração automática de IP.

- Configuração dos Servidores:

Servidor 1 e 2 (Ubuntu):

```ruby
config.vm.define "serv1" do |serv1|
  serv1.vm.box = "ubuntu/bionic64"
  serv1.vm.hostname = "serv1"
  serv1.vm.network "private_network", virtualbox__intnet: "RedeInterna", auto_config: false
  serv1.vm.provider "virtualbox" do |vb|
    vb.name = "ri-serv1_#{timestamp}"
    vb.memory = "2048"
    vb.cpus = 2
    disk_name = "serv1_#{timestamp}.vdi"
    vb.customize ["createhd", "--filename", disk_name, "--size", 10000, "--variant", "Standard"]
  end
end
```
Configura as VMs serv1 e serv2 com Ubuntu, uma rede privada e uma memória de 2048 MB. O nome do disco é gerado com um timestamp para garantir unicidade.

- Firewall Servidor (Debian):

```ruby
config.vm.define "fw-serv02" do |fw|
  fw.vm.box = "debian/buster64"
  fw.vm.hostname = "fw-serv02"
  fw.vm.network "public_network", bridge: "wlp0s20f3", use_dhcp_assigned_default_route: true
  fw.vm.network "private_network", virtualbox__intnet: "RedeInterna", auto_config: false
  fw.vm.provider "virtualbox" do |vb|
    vb.name = "fw-serv02_#{timestamp}"
    vb.memory = "2048"
    vb.cpus = 2
    disk_name = "fw-serv02_#{timestamp}.vdi"
    vb.customize ["createhd", "--filename", disk_name, "--size", 5000, "--variant", "Standard"]
  end
end
```
Configura o firewall fw-serv02 com Debian, com uma rede pública e uma privada, e com um disco menor comparado aos outros servidores.

- Servidor Slax 1 (CentOS com XFCE):

```ruby
config.vm.define "slax01" do |slax1|
  slax1.vm.box = "pure360/centos-7.0-64-puppet-xfce"
  slax1.vm.hostname = "slax01"
  slax1.vm.network "private_network", virtualbox__intnet: "RedeInterna", auto_config: false
  slax1.vm.provider "virtualbox" do |vb|
    vb.name = "ri-slax01_#{timestamp}"
    vb.memory = "2048"
    vb.cpus = 2
    disk_name = "slax01_#{timestamp}.vdi"
    vb.customize ["createhd", "--filename", disk_name, "--size", 1024, "--variant", "Standard"]
  end
end
```
Configura o servidor slax01 com CentOS e XFCE, com uma rede privada e um disco menor.

- Servidor Kali Linux:

```ruby
config.vm.define "kali" do |kali|
  kali.vm.box = "kalilinux/rolling"
  kali.vm.hostname = "kali"
  kali.vm.network "private_network", virtualbox__intnet: "RedeInterna", auto_config: false
  kali.vm.provider "virtualbox" do |vb|
    vb.name = "ri-kali_#{timestamp}"
    vb.memory = "2048"
    vb.cpus = 2
    disk_name = "kali_#{timestamp}.vdi"
    vb.customize ["createhd", "--filename", disk_name, "--size", 10000, "--variant", "Standard"]
  end
end
```
Configura a VM kali com Kali Linux, com uma rede privada e uma memória de 2048 MB.

# Script adjust_interfaces.sh

Este script é usado para parar, ajustar e reiniciar as máquinas virtuais no VirtualBox.

```bash
#!/bin/bash

# Lista todas as máquinas virtuais
vm_list=$(VBoxManage list vms | awk -F\" '{print $2}')

# Remove NIC1 de cada máquina virtual
for vm in $vm_list; do
  VBoxManage controlvm "$vm" poweroff
  VBoxManage modifyvm "$vm" --nic1 none
  VBoxManage startvm "$vm" --type headless
done
```

## Explicação do Script

- Lista Todas as Máquinas Virtuais:
``` bash
vm_list=$(VBoxManage list vms | awk -F\" '{print $2}')
```
Obtém a lista de todas as VMs registradas no VirtualBox. O comando VBoxManage list vms lista as VMs e awk -F\" '{print $2}' extrai os nomes das VMs da saída.

- Loop para Ajustar as Máquinas Virtuais:
```bash
for vm in $vm_list; do
  VBoxManage controlvm "$vm" poweroff
  VBoxManage modifyvm "$vm" --nic1 none
  VBoxManage startvm "$vm" --type headless
done
```

### Para cada VM:

- Desliga a VM:
```bash
VBoxManage controlvm "$vm" poweroff
```

- Remove a NIC1:
```bash
VBoxManage modifyvm "$vm" --nic1 none
```

- Reinicia a VM em modo headless:
```bash
VBoxManage startvm "$vm" --type headless
```

Nota: Certifique-se de que o comando VBoxManage está disponível no PATH e o script é executado no host onde o VirtualBox está instalado, não dentro das VMs.
