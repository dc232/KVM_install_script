#!/bin/bash
#above line is a shebang ;) (i'll leave this here for i remeber its important ;)
########################################
#This script is desighned to run KVM
#on selected hosts on linux
#plesase note that KVM is a type 2 hypervisor
#and requires linux to be installed
########################################

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
VT_D_AMD_V_CHECK