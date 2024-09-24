#!/bin/bash

# Lista todas as máquinas virtuais
vm_list=$(VBoxManage list vms | awk -F\" '{print $2}')

# Remove NIC1 de cada máquina virtual
for vm in $vm_list; do
  VBoxManage controlvm "$vm" poweroff
  VBoxManage modifyvm "$vm" --nic1 none
  VBoxManage startvm "$vm" --type headless
done
