$DPMServer='DPM'
$RecoveryLocationServer = $env:COMPUTERNAME
$DriveLetter = Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE Label='DPM Archive'" | Select-Object -ExpandProperty Name
$DriveLetter = $DriveLetter.Remove(2,1)
$Location = "$DriveLetter\GmbH\iSCSI"
$ProtectiongroupName="iSCSI Daten"

$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null

$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg
#$rop = New-DPMRecoveryOption -FileSystem -OverwriteType Overwrite -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -AlternateLocation $Location
$rop = New-DPMRecoveryOption -FileSystem -OverwriteType Overwrite -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -AlternateLocation $Location -RestoreSecurity

foreach ($entry in $ds) {
 
    $rpl = Get-RecoveryPoint -Datasource $Entry | sort -Property BackupTime -Descending | select -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
}

#Get-ProductionServer -DPMServerName DPM | Where-Object {$_.ServerName -eq "$env:COMPUTERNAME"} | Get-Datasource -Inquire