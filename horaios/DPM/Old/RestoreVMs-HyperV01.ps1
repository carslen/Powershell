$DPMServer=$env:COMPUTERNAME
$RecoveryLocationServer="HyperV-Test"
$Location="D:\SCDPM\HyperV01"
$ProtectiongroupName="HyperV01 VM Backup"

$Basedir = "\\$RecoveryLocationServer\SCDPM\HyperV01"
$Date = Get-Date

# Delete Restored data older than 7 days
Get-ChildItem $Basedir | Where-Object {($Date - $_.LastWriteTime).Days -gt 6} |  Remove-Item -Recurse
 
$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null
 
$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg 
$rop = New-RecoveryOption -TargetServer $RecoveryLocationServer  -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetLocation $Location -HyperVDatasource

foreach ($entry in $DS) {
 
    $rpl = Get-RecoveryPoint -Datasource $Entry | sort -Property BackupTime -Descending | select -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
    Start-Sleep -Seconds 20
}

Write-Host "Warte auf Abschluß der letzten Wiederherstellung ..." -ForegroundColor DarkYellow -BackgroundColor DarkGray
do{ start-sleep -Seconds 5 }
while (Get-DPMJob -Datasource $ds -Type Recovery -Status InProgress)

Write-Host "Restore aller VMs abgeschlossen! Weiter geht's..." -ForegroundColor Green -BackgroundColor DarkGray

$VHDDirs = (Get-ChildItem $Basedir).FullName
$RestoreDate = Get-Date -Format 'yyyy.MM.dd'

foreach ($entry in $VHDDirs) 
    {
    $TEMPVHDName = (Get-ChildItem $entry -Recurse | where {($_.Extension -eq ".vhdx") -or ($_.Extenstion -eq ".vhd") -and ($_.BaseName -match "_c") }).BaseName
    $VHDName = $TEMPVHDName.Replace("_c","")
    Move-Item -Path $entry $Basedir\"$VHDName" #-"$RestoreDate"
    Write-Host "Umbenennen nach $VHDName abgeschlossen!"-ForegroundColor DarkYellow -BackgroundColor DarkGray
    }