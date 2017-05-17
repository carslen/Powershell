<#
Parameters: Folder Path, File to Restore, Deletion Date
Example Usage: 
.\RecoverFile.ps1 "ClientName\Folder\2010\02\03\" "mydoc.pdf" "2010-08-04 09:54:24.117" 
#>

$filePath = [IO.Path]::Combine("D:\ClientData\", $args[0] )
$fileName = $args[1]
$dateDeleted = Get-Date $args[2]

$filePath = "E:\Benutzer\cle\alt\"
$fileName = "Horn.pcf"
$dateDeleted = Get-Date "2014-05-08 09:54:24.117"


Write-Host "Wiederherstellung der Datei '" -NoNewLine
Write-Host $filePath -NoNewLine
Write-Host $fileName -NoNewLine
Write-Host "' ,die gelöscht wurde am '" -NoNewLine
Write-Host $dateDeleted -NoNewLine
Write-Host "'"

$recoveryDate = Get-Date $dateDeleted.AddDays(-1).ToShortDateString()
$pg = Get-ProtectionGroup -DPMServerName DPM | Where-Object {$_.FriendlyName -eq "iSCSI Daten"} 
$ds = Get-Datasource $pg
$so = New-SearchOption -FromRecoveryPoint $recoveryDate.AddDays(-1).ToShortDateString() -ToRecoveryPoint $recoveryDate.ToShortDateString() -SearchDetail FilesFolders -SearchType exactMatch -Location $filePath -SearchString $fileName
$ri = Get-RecoverableItem -Datasource $ds -SearchOption $so
<# $ro = New-RecoveryOption -TargetServer DPM -RecoveryLocation CopyToFolder -FileSystem -OverwriteType overwrite -RecoveryType Recover #>
$ro = New-RecoveryOption -DPMServerName DPM -RecoveryLocation CopyToFolder -RecoveryType Recover -TargetServer DPM -TargetLocation "C:\tmp"
$recoveryJob = Recover-RecoverableItem -RecoverableItem $ri -RecoveryOption $ro
#4.3 Wait till the recovery job completes
while (! $recoveryJob.hasCompleted )
{
    # Show a progress bar
    Write-Host "." -NoNewLine
    Start-Sleep 1
}
if($recoveryJob.Status -ne "Succeeded")
{
    Write-Host "Wiederherstellung fehlgeschlagen!" -ForegroundColor Red
}
else
{
    Write-Host "Wiederherstellung erfolgreich!" -ForeGroundColor Green
}