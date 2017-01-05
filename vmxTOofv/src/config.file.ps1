###### VCENTER ACCOUNT ###################################################
$vcenter_server="<vcenter_name>"
$vcenter_user="<vcenter_username>"
$vcenter_pwd="<vcenter_password>"
####### PATHs #############################################################
$VMSource="<vm01>","<vm02>","<vm03>" # for multiple vm use "<vm_name>","<vm_name>"
###########################################################################
$ovf_user="<vcenter_username>" # Use "%5c" for backslash "\"
$VMPath="<datacenter>/vm/<folder>" # /<datacenter>/vm/<folder>
$VMClonelocation= "<vm_path>" # Folder location
$ovf_dst_path= "<local_path>" ### Local Path to .ovf file
$VMClonenotes = "Clone created by VMtOVF"
####### MAIL CONFIG #######################################################
$sender_mail="<sender_@email>"
$dest_mail="<dest_@email>"
###########################################################################
