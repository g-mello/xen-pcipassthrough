#!/bin/bash

#
### BEGIN INIT INFO
# Required-Start: $local_fs
# Default-Start: 2 3 4 5
# Description: Hide a PCI Device from Domain0
### END INIT INFO

check_if_loaded_or_in_kernel(){
   
    [ -d /sys/module/xen_pciback ]&& echo " xen_pciback driver/module already loaded"; exit 0
}

hideme(){ 
    modprobe -r e1000
    modprobe xen_pciback
}

case $1 in
    start) 
        check_if_loaded_or_in_kernel
        hideme
        ;;
    stop)
        echo "xen_pciback: no reason to unhide"
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        ;;
esac
exit $?
