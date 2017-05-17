 [CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$computerName,
	
   [Parameter(Mandatory=$True,Position=2)]
   [string]$vhdPath
   )


#$vhdPath = "D:\vhds"
#$computerName = "hyperv-test"


$credetial = Get-Credential horaios\cleadm
$vmVHds = get-vm -ComputerName $computerName | foreach{($_.Harddrives).Path}
$fsVHDs = Invoke-Command -ComputerName $computerName -Credential $credetial -ScriptBlock {Get-ChildItem -Path $args[0] -File -Recurse | where {$_.Extension -eq ".vhd" -or $_.Extension -eq ".vhdx"}|foreach{(get-vhd $_.Fullname).Path}} -ArgumentList $vhdPath


foreach($item in $fsVHds){
    if  ($vmVHDs -contains $item)
        {$keepVHD += @($item)}
      else
        {$orphanVHD += @($item)}
 }


if ($orphanVHD.Count -gt 1)
{
    Write-Host -ForegroundColor Green "Folgende VHDs können aus dem Dateisystem gelöscht werden:"
    foreach($item in $orphanVHD){$item}
}
else
{
    Write-Host -ForegroundColor Red "Es können keinen VHDs aus dem Dateisystem gelöscht werden!"
}
 

#Write-Host -ForegroundColor Red Folgende VHDs dürfen nicht gelöscht werden:
#foreach($item in $keepVHD){$item}


#Clear-Variable -Name keepVHD,orphanVHD,item

