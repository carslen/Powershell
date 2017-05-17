 [CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$computerName,
	
   [Parameter(Mandatory=$True,Position=2)]
   [string]$vhdPath
   )


$credetial = Get-Credential horaios\
$vmVHds = get-vm -ComputerName $computerName | foreach{($_.Harddrives).Path}
$fsVHDs = Invoke-Command -ComputerName $computerName -Credential $credetial -ScriptBlock {Get-ChildItem -Path $args[0] -File -Recurse | where {$_.Extension -eq ".vhd" -or $_.Extension -eq ".vhdx"}|foreach{(get-vhd $_.Fullname).Path}} -ArgumentList $vhdPath


foreach($item in $fsVHds){
    if
        ($vmVHDs -contains $item)
        {Write-Host -ForegroundColor Red "Darf nicht gelöscht werden: `t$item"}
      else
        {Write-Host -ForegroundColor Green "Kann gelöscht werden `t`t$item"}
}

