$DPMServer=$env:COMPUTERNAME
#$DPMServer='DPM'
$RecoveryLocationServer='HyperV-Test'
$Location='D:\SCDPM\Exch'
$ProtectiongroupName='Exchange'

$Basedir = "\\$RecoveryLocationServer\SCDPM\Exch"
$Date = Get-Date

# Delete Restored data older than 7 days
Get-ChildItem $Basedir | Where-Object {($Date - $_.LastWriteTime).Days -gt 2} |  Remove-Item -Recurse -WhatIf

$PS=Get-DPMProductionServer -DPMServerName $DPMServer | Where-Object {$_.servername -eq $DPMServer}
Get-DPMDatasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null

$pg = Get-DPMProtectionGroup -DPMServerName $DPMServer | Where-Object {$_.name -match $ProtectiongroupName}
$ds = Get-DPMDatasource $pg
$rop = New-DPMRecoveryOption -E14Datasource -ExchangeOperationType NoOperation -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -TargetLocation $Location

foreach ($entry in $ds) {
 
    $rpl = Get-DPMRecoveryPoint -Datasource $Entry | Sort-Object -Property BackupTime -Descending | Select-Object -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
}

Write-Host 'Warte auf Abschluß der letzten Wiederherstellung ...' -ForegroundColor DarkYellow -BackgroundColor DarkGray
do{ start-sleep -Seconds 5 }
while (Get-DPMJob -Datasource $ds -Type Recovery -Status InProgress)

Write-Host "Restore aller Exchange DBs abgeschlossen! Weiter geht's..." -ForegroundColor Green -BackgroundColor DarkGray

$DBDirs = (Get-ChildItem $Basedir).FullName
$RestoreDate = Get-Date -Format 'yyyy.MM.dd'

ForEach ($entry in $DBDirs) 
    {
    $DBName = (Get-ChildItem $entry -Recurse | Where-Object {$_.Extension -eq '.edb'}).BaseName
    Move-Item -Path $entry $Basedir\"$DBName" #-"$RestoreDate"
    Write-Host "Umbenennen nach $DBName abgeschlossen!"-ForegroundColor DarkYellow -BackgroundColor DarkGray
    }