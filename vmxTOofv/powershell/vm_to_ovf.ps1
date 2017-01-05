# Source config.file
. src/config.file.ps1
$ErrorActionPreference = 'silentlycontinue'
#Import VMware module
Get-module -ListAvailable PowerCLI* | Import-module
##Connect to vCenter
write-host ""
write-host "Connecting to vCenter Server $vcenter_server.. " -NoNewLine
$connect_vcenter = connect-viserver -server $vcenter_server -User $vcenter_user -Password $vcenter_pwd #-WarningAction 0 | out-null 2>&1
if ([bool]$connect_vcenter -eq $true) 
{
  write-host "connected." -foregroundcolor green
}
else
{
  write-host "not connected!" -foregroundcolor red
  exit
}
#### LOOP
Foreach($arrVMSourceName in $VMSource){
           Write-Host "Verify if VM $arrVMSourceName is present.. " -NoNewLine
   if (GET-VM -Name $arrVMSourceName) { 
          write-host "found." -foregroundcolor green
           $VMClonehost = (Get-VM $arrVMSourceName| Get-VMHost).Name
           $VMCloneName = $arrVMSourceName
           $VMCloneName = "${VMCloneName}_clone"
          write-host "Creating temporary clone.. " -NoNewLine
           New-VM -VM $arrVMSourceName -Name $VMCloneName -Location $VMClonelocation -Notes $VMClonenotes -VMhost $VMClonehost >$null 2>&1
           write-host "done." -foregroundcolor green -NoNewLine
           write-host ""
          write-host "Creating OVF in ${ovf_dst_path}/${VMCloneName}.ovf.. " -NoNewLine
           ovftool --noSSLVerify vi://${ovf_user}:${vcenter_pwd}@${vcenter_server}/${VMPath}/${VMCloneName} ${ovf_dst_path}/${VMCloneName}/${VMCloneName}.ovf >$null 2>&1
           write-host "done." -foregroundcolor green
           "${arrVMSourceName} has been exported." >> VMtOvf_status
           write-host "Deleting VM temporary ${VMCloneName}.. " -NoNewLine
            Remove-VM $VMCloneName -DeletePermanently -Confirm:$false
           write-host "done." -foregroundcolor green 
           }
      else {
           write-host "not found, skipped." -foregroundcolor red
            $arrVMSource = $arrVMSource | where {$_ -ne "$arrVMSourceName"}
            "${arrVMSourceName} has been skipped, not found." >> VMtOvf_status  
           }        
}
## Linux mail recap
dos2unix VMtOvf_status >/dev/null 2>&1
cat VMtOvf_status | mail -s "VM to OFV Status Report" -r $sender_mail $dest_mail
