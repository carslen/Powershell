$DPMServer=$env:COMPUTERNAME
$RecoveryLocationServer="idaho"
$Location="D:\SCDPM\iSCSI"
$ProtectiongroupName="iSCSI Daten"

$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null

$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg
#$rop = New-DPMRecoveryOption -FileSystem -OverwriteType Overwrite -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -AlternateLocation $Location
$rop = New-DPMRecoveryOption -FileSystem -OverwriteType Overwrite -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -AlternateLocation $Location -RestoreSecurity

<#
foreach ($entry in $ds) {
 
    Get-RecoveryPoint $Entry | sort -Property BackupTime -Descending | select -First 1
}
#>

foreach ($entry in $ds) {
 
    $rpl = Get-RecoveryPoint $Entry | sort -Property BackupTime -Descending | select -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
}