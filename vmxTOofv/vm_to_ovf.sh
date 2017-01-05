#!/bin/bash
############################
##                        ##
##  VMX to OVF            ##
##  Emanuele Filippello   ##
##                        ##
############################
## Relese ##################
# 0.1 - Initial version   ##
#                         ##
############################
#pre-check before starting
rm -f VMtOvf_status
######### EDIT ONLY IF YOU CHANGE URL OR PKGS VERSION ##################################
URLBASE="https://github.com/emanuelefilippello/vmware/blob/master/vmxTOofv/pkgs/"
d_ofvtool="VMware-ovftool-4.2.0-4586971-lin.x86_64.bundle"
d_powershell="powershell-6.0.0_alpha.13-1.el7.centos.x86_64.rpm"
d_modulePowerCLI_Vds="PowerCLI.Vds.zip"
d_modulePowerCLI_ViCore="PowerCLI.ViCore.zip"
########################################################################################
#################
## DO NOT EDIT ##
#################
################
export LD_LIBRARY_PATH=/opt/shibboleth/lib64/:$LD_LIBRARY_PATH
power_module_path="/root/.local/share/powershell/Modules"
powershell_module_PowerCLI_Vds="${power_module_path}/PowerCLI.Vds"
powershell_module_PowerCLI_ViCore="${power_module_path}/PowerCLI.ViCore"
wget=/usr/bin/wget
unzip=/usr/bin/unzip
## COLOR
RED='\033[0;31m'
GREEN='\033[0;32m'
BLU='\e[34mBlue'
NC='\033[0m' # No Color
BOLD='\033[1m'
####
f_wget_ovf () {
read -r -p "
$(echo Do you want to download?) " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

 if [ ! -x "$wget" ]; then
  echo -e "${RED}ERROR: No wget command found.${NC}"
  exit 1
   else
  wget $URLBASE/${1}?raw=true -O /root/$1
  sh /root/$1 --eulas-agreed
    fi
   else
   exit 1
   fi
 }
f_wget_powershell () {
read -r -p "
$(echo Do you want to download?) " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

 if [ ! -x "$wget" ]; then
  echo -e "${RED}ERROR: No wget command found.${NC}"
  exit 1
   else
  wget $URLBASE/${1}?raw=true -O /root/$1
  yum localinstall -y /root/$1
    fi
   else
   exit 1
   fi
 }

f_wget_PowerCLI_Vds () {
read -r -p "
$(echo Do you want to download? y/n) " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
      then
       if [ ! -x "$wget" ]; then
            echo -e "${RED}ERROR: No wget command found.${NC}"
            exit 1
         else
       if [ ! -x "$unzip" ]; then
            echo -e "${RED}ERROR: No unzip command found.${NC}"
            exit 1
       else
       mkdir -p ${power_module_path}/
        cd ${power_module_path}/
        wget $URLBASE/${1}?raw=true
        unzip $1
        rm -f $1
    fi
  fi
fi
}

f_check_env () {
if [ $? -eq 0 ]; then
    echo -e "Powershell: ${GREEN}ok${NC}"
else
    echo -e "Powershell: ${RED}not found${NC}"
        f_wget_powershell $d_powershell
fi
which ovftool > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "OVFTool: ${GREEN}ok${NC}"
else
    echo -e "OVFTool: ${RED}not found${NC}"
        f_wget_ovf $d_ofvtool
fi
if [ -d "$powershell_module_PowerCLI_Vds" ]; then
        echo -e "Module PowerCLI.Vds: ${GREEN}ok${NC}"
else
        echo -e "Module PowerCLI.Vds: ${RED}not found${NC}"
        f_wget_PowerCLI_Vds $d_modulePowerCLI_Vds
fi
if [ -d "$powershell_module_PowerCLI_ViCore" ]; then
       echo -e "Module PowerCLI.ViCore: ${GREEN}ok${NC}"
else
       echo -e "Module PowerCLI.ViCore: ${RED}not found${NC}"
       f_wget_PowerCLI_Vds $d_modulePowerCLI_ViCore
fi
}
echo ""
echo "Checking requirement.."
f_check_env
## parsing config.file.ps1
# Verify OVF export Path
ovf_dst_path=$(cat src/config.file.ps1 | grep ovf_dst_path |sed 's/^.*ovf_dst_path/ovf_dst_path/' |sed s/\"//g |awk '{print $2}')
path=$(df -h $ovf_dst_path | awk '{ print  $4 " " $1 }')

if [ -d "$ovf_dst_path" ] ; then
 echo ""
else
  echo -e "${RED}Destination path non exists${NC}, please verify."
  exit 0
fi

#f_vm_clone_list() {

#IFS=', ' read -r -a vm_array <<< "$VMSource_lnx"
#for element in "${vm_array[@]}"
#do
#  echo -n "${element}_clone "
#done
#}
#f_vm_clone_list
var_vCenter_server=$(cat src/config.file.ps1 | grep vcenter_server |sed 's/^.*vcenter_server/vcenter_server/' | awk -F '=' '{print $2}' | sed 's/\#.*//')
var_vCenter_user=$(cat src/config.file.ps1 | grep vcenter_user |sed 's/^.*vcenter_user/vcenter_user/' | awk -F '=' '{print $2}' | sed 's/\#.*//')
var_VMSource=$(cat src/config.file.ps1 | grep VMSource |sed 's/^.*VMSource/VMSource/' | awk -F '=' '{print $2}' | sed 's/\#.*//')
var_dest_mail=$(cat src/config.file.ps1 | grep dest_mail |sed 's/^.*dest_mail/dest_mail/' | awk -F '=' '{print $2}' | sed 's/\#.*//')

echo "How to works:
      - Clone VM running.
      - Export clone VM in .ovf format.
      - Delete a temp _clone VM.
      - Send email recap to ${var_dest_mail}"
echo "
Recap Information:

     vCenter Server: ${var_vCenter_server}
     vCenter User  : ${var_vCenter_user}

     VM Name Source: ${var_VMSource}
     Export Path Destination: ${ovf_dst_path}

     Clone VM will be remove automatically."
 read -r -p "

Continue to export OVF ? (y/N) " response
   if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          powershell -f powershell/vm_to_ovf.ps1
            else
        echo "Something goes wrong.."
      exit 1
  fi
