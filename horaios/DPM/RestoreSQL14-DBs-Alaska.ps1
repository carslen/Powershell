$DPMServer = 'DPM'
$RecoveryLocationServer = $env:COMPUTERNAME
$DriveLetter = Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE Label='DPM Archive'" | Select-Object -ExpandProperty Name
$DriveLetter = $DriveLetter.Remove(2,1)
$Location = "$DriveLetter\GmbH\SQL\Alaska\14"
$ProtectiongroupName="SQL 2014 Alaska"
$Date = Get-Date

# Delete Restored data older than 7 days
Get-ChildItem $Location | Where-Object {($Date - $_.LastWriteTime).Days -gt 2} |  Remove-Item -Recurse

$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null

$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg | where {$_.Name -notmatch 'Carsus_Daten'}
$rop = New-DPMRecoveryOption -RecoveryLocation CopyToFolder -RecoveryType Restore -SQL -TargetServer $RecoveryLocationServer -TargetLocation $Location

Write-Host "Starte Datenbankwiederherstellung nach $Location ..." -ForegroundColor DarkYellow -BackgroundColor DarkGray
foreach ($entry in $ds) {
 
    $rpl = Get-RecoveryPoint -Datasource $Entry | sort -Property BackupTime -Descending | select -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
    Start-Sleep -Seconds 5
}

#Start-Sleep -Seconds 60
Write-Host "Warte auf Abschluß der letzten Wiederherstellung ..." -ForegroundColor DarkYellow -BackgroundColor DarkGray
do{ start-sleep -Seconds 5 }
while (Get-DPMJob -Datasource $ds -Type Recovery -Status InProgress)

Write-Host "Restore aller DBs abgeschlossen! Weiter geht's..." -ForegroundColor Green -BackgroundColor DarkGray


$DBDirs = (Get-ChildItem $Location).FullName
$RestoreDate = Get-Date -Format 'yyyy.MM.dd'

foreach ($entry in $DBDirs) 
    {
    $TEMPDBName = (Get-ChildItem $entry -Recurse| Where-Object {$_.Extension -eq ".mdf"}).Basename 
    $DBName = $TEMPDBName.Replace("_Primary","")
    Rename-Item -Path $entry -NewName $DBName
    Write-Host "Umbenennen nach $DBName abgeschlossen!"-ForegroundColor DarkYellow -BackgroundColor DarkGray
    }

Write-Host "Restore aller DBs abgeschlossen!" -ForegroundColor Green -BackgroundColor DarkGray

Remove-Variable -Name DPMServer,RecoveryLocationServer,Location,Protectiongroupname,Date,PS,pg,ds,rop,entry,rpl,DBDirs,RestoreDate,TEMPDBName,DBName