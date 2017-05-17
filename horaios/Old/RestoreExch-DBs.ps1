$DPMServer=$env:COMPUTERNAME
$RecoveryLocationServer="idaho"
$Location="D:\SCDPM\Exch"
$ProtectiongroupName="Exchange"

$Basedir = '\\idaho\SCDPM\Exch'
$RestoreDirs = Get-ChildItem $Basedir\DPM_*
$RenameDate = Get-Date -Format 'yyyy-MM-dd_HH.mm.ss'
$Date = Get-Date

# Delete Restored data older than 7 days
Get-ChildItem $Basedir | Where-Object {($Date - $_.LastWriteTime).Days -gt 6} |  Remove-Item -Recurse

$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null

$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg
$rop = New-DPMRecoveryOption -E14Datasource -ExchangeOperationType NoOperation -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -TargetLocation $Location

<#
foreach ($entry in $ds) {
 
    Get-RecoveryPoint $Entry | sort -Property BackupTime -Descending | select -First 1
}
#>

foreach ($entry in $ds) {
 
    $rpl = Get-RecoveryPoint $Entry | sort -Property BackupTime -Descending | select -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
}