#!/bin/bash

# Verify if PCI IDs have been provided
if [ $# -eq 0 ]; then
    echo " Require PCI Devices in the format : domain:bus:slot.function"
    exit 1
fi 

set -e 
# Verify if the xen_pciback(PV) or pciback(HVM) driver is not loaded
# then load it
[ ! -d /sys/bus/pci/drivers/pciback ] && \
    echo "loading xen_pciback"
    sudo modprobe xen_pciback

for pcidev in $@; do
    if [ -h /sys/bus/pci/devices/"$pcidev"/driver ]; then

        # For PCI devices with modules attached to them
        sudo echo "Unbinding $pcidev from  $(basename $(readlink /sys/bus/pci/devices/"$pcidev"/driver))"
        sudo echo -n "$pcidev" > /sys/bus/pci/devices/"$pcidev"/driver/unbind

        sudo echo "Binding $pcidev to pciback"
        sudo echo -n "$pcidev" > /sys/bus/pci/drivers/pciback/new_slot
        sudo echo -n "$pcidev" > /sys/bus/pci/drivers/pciback/bind
    else
        #For PCI devices with no modules attached to them
        sudo echo "Binding $pcidev to pciback"
        sudo echo -n "$pcidev" > /sys/bus/pci/drivers/pciback/new_slot
        sudo echo -n "$pcidev" > /sys/bus/pci/drivers/pciback/bind
    fi
done


