############################
##                        ##
##  VMX to OVF            ##
##  Emanuele Filippello   ##
##                        ##
############################
## Release #################
# 0.1 - Initial version   ##
############################

Requirement:
 - OS RHEL6/7 - Centos6/7

PKGS Version:
 - VMware-ovftool-4.2.0-4586971-lin.x86_64.bundle
 - powershell-6.0.0_alpha.13-1.el7.centos.x86_64.rpm

Features:
 - Check and install dependence
 - Clone VM running.
 - Export clone VM in .ovf format.
 - Delete a temp _clone VM.
 - Send email recap

Provide configuration file for declare all variables.
