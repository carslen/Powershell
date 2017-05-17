$DPMServer=$env:COMPUTERNAME
$RecoveryLocationServer="idaho"
$Location="D:\SCDPM\SQL\DPM"
$ProtectiongroupName="SQL SCDPM"

$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null

$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg | where {$_.Name -ne "BOS_ProLux_Daten_Dev"}
$rop = New-DPMRecoveryOption -RecoveryLocation CopyToFolder -RecoveryType Restore -SQL -TargetServer $RecoveryLocationServer -TargetLocation $Location

<#
foreach ($entry in $ds) {
 
    Get-RecoveryPoint $Entry | sort -Property BackupTime -Descending | select -First 1
}
#>

foreach ($entry in $ds) {
 
    $rpl = Get-RecoveryPoint $Entry | sort -Property BackupTime -Descending | select -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
}