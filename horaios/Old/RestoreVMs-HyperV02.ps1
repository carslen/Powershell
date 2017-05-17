$DPMServer=$env:COMPUTERNAME
$RecoveryLocationServer="idaho"
$Location="D:\SCDPM\HyperV02"
$ProtectiongroupName="HyperV02 VM Backup"




# Delete Restored data older than 7 days
Get-ChildItem $Basedir | Where-Object {($Date - $_.LastWriteTime).Days -gt 6} |  Remove-Item -Recurse
 
$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null
 
$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg 
$rop = New-RecoveryOption -TargetServer $RecoveryLocationServer  -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetLocation $Location -HyperVDatasource

foreach ($entry in $DS) {
 
    $rpl = Get-RecoveryPoint $Entry | sort -Property BackupTime -Descending | select -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
}


foreach($_ in $RestoreDirs)
{       
	$almostServerName = get-childitem $_ -include *.vhdx -recurse|select Name -First 1 
	#$almostServerName.Name
	$serverName = $almostServerName.Name.Replace(".vhdx","").Replace("_C","").Replace("_c","")
	#$ServerName
	Rename-Item -Path $_.FullName -NewName "$ServerName $RenameDate"
}
#Get-ChildItem $Basedir\*


