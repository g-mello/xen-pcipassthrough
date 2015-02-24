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
    modprobe xen_pciback

for pcidev in $@; do
    [ ${pcidev%%:*:*.*} != "0000" ] && pcidev=0000:${pcidev}

    if [ -h /sys/bus/pci/devices/"$pcidev"/driver ]; then

        # For PCI devices with modules attached to them
        echo "Unbinding $pcidev from  $(basename $(readlink /sys/bus/pci/devices/"$pcidev"/driver))"
        echo $pcidev > /sys/bus/pci/devices/"$pcidev"/driver/unbind

        echo "Binding $pcidev to pciback"
        echo $pcidev > /sys/bus/pci/drivers/pciback/new_slot
        echo $pcidev > /sys/bus/pci/drivers/pciback/bind
    else
        #For PCI devices with no modules attached to them
        echo "Binding $pcidev to pciback"
        echo $pcidev > /sys/bus/pci/drivers/pciback/new_slot
        echo $pcidev > /sys/bus/pci/drivers/pciback/bind
    fi
done


