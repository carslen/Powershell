$DPMServer = 'DPM'
$RecoveryLocationServer = $env:COMPUTERNAME
$DriveLetter = Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE Label='DPM Archive'" | Select-Object -ExpandProperty Name
$DriveLetter = $DriveLetter.Remove(2,1)
$Location = "$DriveLetter\GmbH\Exch"
$ProtectiongroupName = 'Exchange'
$Date = Get-Date

# Delete Restored data older than 7 days
Get-ChildItem $Location | Where-Object {($Date - $_.LastWriteTime).Days -gt 1} |  Remove-Item -Recurse

$PS = Get-DPMProductionServer -DPMServerName $DPMServer | Where-Object {$_.servername -eq $DPMServer}
Get-DPMDatasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null

$pg = Get-DPMProtectionGroup -DPMServerName $DPMServer | Where-Object {$_.name -match $ProtectiongroupName}
$ds = Get-DPMDatasource $pg
$rop = New-DPMRecoveryOption -E14Datasource -ExchangeOperationType NoOperation -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -TargetLocation $Location -RestoreSecurity

foreach ($entry in $ds) {
 
    $rpl = Get-DPMRecoveryPoint -Datasource $Entry | Sort-Object -Property BackupTime -Descending | Select-Object -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
}

Write-Host 'Warte auf Abschluß der letzten Wiederherstellung ...' -ForegroundColor DarkYellow -BackgroundColor DarkGray
do{ start-sleep -Seconds 5 }
while (Get-DPMJob -Datasource $ds -Type Recovery -Status InProgress)

Write-Host "Restore aller Exchange DBs abgeschlossen! Weiter geht's..." -ForegroundColor Green -BackgroundColor DarkGray

$DBDirs = (Get-ChildItem $Location).FullName
$RestoreDate = Get-Date -Format 'yyyy.MM.dd'

ForEach ($entry in $DBDirs) 
    {
    $DBName = (Get-ChildItem $entry -Recurse | Where-Object {$_.Extension -eq '.edb'}).BaseName
    Rename-Item -Path $entry -NewName $DBName
    Write-Host "Umbenennen nach $DBName abgeschlossen!"-ForegroundColor DarkYellow -BackgroundColor DarkGray
    }

Remove-Variable -Name DPMServer,RecoveryLocationServer,Location,Protectiongroupname,Date,PS,pg,ds,rop,entry,rpl,DBDirs,RestoreDate,DBName