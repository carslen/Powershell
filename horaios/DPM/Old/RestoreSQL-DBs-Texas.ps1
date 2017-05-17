$DPMServer=$env:COMPUTERNAME
$RecoveryLocationServer="HyperV-Test"
$Location="D:\SCDPM\SQL\Texas"
$ProtectiongroupName="TFS DBs Texas"

$Basedir = "\\$RecoveryLocationServer\SCDPM\SQL\Texas"
$Date = Get-Date

# Delete Restored data older than 7 days
Get-ChildItem $Basedir | Where-Object {($Date - $_.LastWriteTime).Days -gt 2} |  Remove-Item -Recurse

$PS=Get-ProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
Get-Datasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null

$pg = Get-ProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
$ds = Get-Datasource $pg | where {$_.Name -ne "BOS_ProLux_Daten_Dev"}
$rop = New-DPMRecoveryOption -RecoveryLocation CopyToFolder -RecoveryType Restore -SQL -TargetServer $RecoveryLocationServer -TargetLocation $Location

foreach ($entry in $ds) {
 
    $rpl = Get-RecoveryPoint -Datasource $Entry | sort -Property BackupTime -Descending | select -First 1 
    Recover-RecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
}

Start-Sleep -Seconds 60
$DBDirs = (Get-ChildItem $Basedir).FullName
$RestoreDate = Get-Date -Format 'yyyy.MM.dd'

foreach ($entry in $DBDirs) 
    {
    $TEMPDBName = (Get-ChildItem $entry -Recurse| Where-Object {$_.Extension -eq ".mdf"}).Basename 
    $DBName = $TEMPDBName.Replace("_Primary","")
    Move-Item -Path $entry $Basedir\"$DBName" #-"$RestoreDate" 
    }