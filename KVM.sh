#!/bin/bash
#above line is a shebang ;) (i'll leave this here for i remeber its important ;)
########################################
#This script is desighned to run KVM
#on selected hosts on linux
#plesase note that KVM is a type 2 hypervisor
#and requires linux to be installed
########################################

#example taken from https://www.cyberciti.biz/faq/installing-kvm-on-ubuntu-16-04-lts-server/ and https://www.howtogeek.com/117635/how-to-install-kvm-and-create-virtual-machines-on-ubuntu/
# and https://www.linux.com/learn/intro-to-linux/2017/5/creating-virtual-machines-kvm-part-2-networking

vm_create () {
    echo "downloading CentOS"
    cd /var/lib/libvirt/boot
    sudo wget https://mirrors.kernel.org/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1708.iso
    sudo virt-install \
--virt-type=kvm \
--name centos7 \
--ram 2048 \
--vcpus=2 \
--os-variant=centos7.0 \
--virt-type=kvm \
--hvm \
--cdrom=/var/lib/libvirt/boot/CentOS-7-x86_64-DVD-1708.iso \
--network=enp1s0,model=virtio \
--graphics vnc \
--disk path=/var/lib/libvirt/images/centos7.qcow2,size=40,bus=virtio,format=qcow2

    echo "checking vnc login ports"
    sleep 2
    sudo virsh vncdisplay centos 7

}


diagnostics () {
    echo "showing all vms"
    sleep 2
    virsh list --all
    echo "showing eithernet bridges"
    sleep 2
    virsh net-list --all
    echo "showing all virtual networks"
    sleep 2
    virsh net-list --all
    
}




install () {
    echo "installing kvm"
    sleep 2
    sudo apt-get install qemu-kvm libvirt-bin virtinst bridge-utils cpu-checker virt-manager -y
    echo "verifing kvm install"
    kvm-ok
#    DATE=$(date +%F)
#    sudo cp /etc/network/interfaces /etc/network/interfaces.bakup-$DATE
sudo adduser $(whoami) libvirtd

cat << EOF
##########################################
Please exit the console and log back in
to be able to run the command 
virsh -c qemu:///system list
then run the function vm_create and 
modify the paramters as needed
then run diagnostics for moreinformation
##########################################
EOF
sleep 5
}



VT_D_AMD_V_CHECK () {
    cat << EOF
##########################################
Checking to see if the system is capable of 
virtualization through checking to see 
if the processor has the flags vmx or svm
##########################################
EOF
sleep 5

VIRT=$(grep -E -c '(svm|vmx)' /proc/cpuinfo)

if [ "$VIRT" ]; then
echo "This system supports virtualisation proceeding with install"
install
else
    cat << EOF
##########################################
This system does not support virtualisation 
please enable it in the BIOS if supported 
On intell systems this feature of the CPU
would be VT-X
on AMD this is AMD-V
Please check that youe CPU is compatible
if in netested VM please ensure that you 
have updated your config
if using vmware see https://communities.vmware.com/docs/DOC-8970
exiting install
##########################################
EOF
sleep 5
exit 0
fi
}

os_selector_array () {
#above is a way to create a function it is not executed in the code unless told to
arr=(CentOS Ubuntu) #array created with
for OS in "${arr[@]}" # this is a for loop it says for any value in the array arr asighn it to the variable OS (this is denoted as @ in this example but you can also use * which does the same thing), we then call back the contents of the variable OS as a string
do
        OPERATING_SYSTEM=$(grep "$OS" /etc/os-release)
echo "$OPERATING_SYSTEM"
done

if [[ "$OPERATING_SYSTEM" = *"Ubuntu"* ]]; then #"**" means contains the word
echo "This operating system is Ubuntu"

VT_D_AMD_V_CHECK

else
echo "I couldn't find your operating system in /etc/os-release"
fi
}


os_selector_array