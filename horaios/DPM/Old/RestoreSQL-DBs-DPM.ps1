$DPMServer=$env:COMPUTERNAME
$RecoveryLocationServer="HyperV-Test"
$Location="D:\SCDPM\SQL\DPM"
$ProtectiongroupName="SQL SCDPM"

$Basedir = "\\$RecoveryLocationServer\SCDPM\SQL\DPM"
$Date = Get-Date

# Delete Restored data older than 7 days
Get-ChildItem $Basedir | Where-Object {($Date - $_.LastWriteTime).Days -gt 2} |  Remove-Item -Recurse

$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null

$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg | where {$_.Name -ne "BOS_ProLux_Daten_Dev"}
$rop = New-DPMRecoveryOption -RecoveryLocation CopyToFolder -RecoveryType Restore -SQL -TargetServer $RecoveryLocationServer -TargetLocation $Location

Write-Host "Starte Datenbankwiederherstellung nach $Basedir ..." -ForegroundColor DarkYellow -BackgroundColor DarkGray
foreach ($entry in $ds) {
 
    $rpl = Get-RecoveryPoint -Datasource $Entry | sort -Property BackupTime -Descending | select -First 1 
    $restoreJob = Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
    while (!$restoreJob.HasCompleted)
    {
        Write-Host "." -NoNewline
        sleep 3
    }
}

#Start-Sleep -Seconds 60
Write-Host "Warte auf Abschluß der letzten Wiederherstellung ..." -ForegroundColor DarkYellow -BackgroundColor DarkGray
do{ start-sleep -Seconds 5 }
while (Get-DPMJob -Datasource $ds -Type Recovery -Status InProgress)

Write-Host "Restore aller DBs abgeschlossen! Weiter geht's..." -ForegroundColor Green -BackgroundColor DarkGray


$DBDirs = (Get-ChildItem $Basedir).FullName
$RestoreDate = Get-Date -Format 'yyyy.MM.dd'

foreach ($entry in $DBDirs) 
    {
    $TEMPDBName = (Get-ChildItem $entry -Recurse| Where-Object {$_.Extension -eq ".mdf"}).Basename 
    $DBName = $TEMPDBName.Replace("_Primary","")
    Move-Item -Path $entry $Basedir\"$DBName" #-"$RestoreDate" 
    Write-Host "Umbenennen nach $DBName abgeschlossen!"-ForegroundColor DarkYellow -BackgroundColor DarkGray
    }

Write-Host "Restore aller DBs abgeschlossen!" -ForegroundColor Green -BackgroundColor DarkGray