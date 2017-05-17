$DPMServer='DPM'
$RecoveryLocationServer = $env:COMPUTERNAME
$DriveLetter = Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE Label='DPM Archive'" | Select-Object -ExpandProperty Name
$DriveLetter = $DriveLetter.Remove(2,1)
$Location = "$DriveLetter\GmbH\HyperV02"
$ProtectiongroupName="HyperV02 VM Backup"
$Date = Get-Date

# Delete Restored data older than 7 days
Get-ChildItem $Location | Where-Object {($Date - $_.LastWriteTime).Days -gt 1} |  Remove-Item -Recurse
 
$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null
 
$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg 
$rop = New-RecoveryOption -TargetServer $RecoveryLocationServer  -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetLocation $Location -HyperVDatasource

foreach ($entry in $DS) {
 
    $rpl = Get-RecoveryPoint -Datasource $entry | sort -Property BackupTime -Descending | select -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
    Start-Sleep -Seconds 20
}

Write-Host "Warte auf Abschluß der letzten Wiederherstellung ..." -ForegroundColor DarkYellow -BackgroundColor DarkGray
do{ start-sleep -Seconds 5 }
while (Get-DPMJob -Datasource $ds -Type Recovery -Status InProgress)

Write-Host "Restore aller VMs abgeschlossen! Weiter geht's..." -ForegroundColor Green -BackgroundColor DarkGray

$VHDDirs = (Get-ChildItem $Location).FullName

foreach ($entry in $VHDDirs) 
    {
        $TEMPVHDName = (Get-ChildItem $entry -Recurse | where {($_.Extension -eq ".vhdx") -or ($_.Extenstion -eq ".vhd") -and ($_.BaseName -match "_c$") }).BaseName
        if ($TEMPVHDName -cmatch "_c") {
            $VHDName = $TEMPVHDName.Replace("_c","")
            Rename-Item -Path $entry -NewName $VHDName
    }
        else {
            $VHDName = $TEMPVHDName.Replace("_C","")
            Rename-Item -Path $entry -NewName $VHDName
        }
        
        Write-Host "Umbenennen nach $VHDName abgeschlossen!"-ForegroundColor DarkYellow -BackgroundColor DarkGray
    }

Remove-Variable -Name DPMServer,RecoveryLocationServer,Location,Protectiongroupname,Date,PS,pg,ds,rop,entry,rpl,VHDDirs,RestoreDate,TEMPVHDName