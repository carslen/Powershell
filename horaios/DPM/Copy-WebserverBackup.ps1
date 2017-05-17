$User               = Read-Host -Prompt "Please enter your Username (Admin Account required!)"
$Credential         = Get-Credential -Credential horaios\$User
$BackupTarget       = "\\nevada\Backup"
$DriveLetter        = Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE Label='DPM Archive'" | Select-Object -ExpandProperty Name
$DriveLetter        = $DriveLetter.Remove(2,1)
$ArchiveDestination = "$DriveLetter\GmbH\"
$Date               = Get-Date


Write-Host -ForegroundColor Yellow "Cleanup $ArchiveDestination"

Remove-Item $ArchiveDestination\Webserver\* -Recurse -Force

do
{
    Write-Host ". " -NoNewLine
    Start-Sleep -Seconds 5
}
while ((Get-ChildItem -Path $ArchiveDestination\Webserver\).Length -ne "0")
Write-Host -ForegroundColor Green "Cleanup done!"

Write-Host -ForegroundColor Yellow "Mounting remote Filesystem"
New-PSDrive -Name "Nevada" -PSProvider FileSystem -Root "$BackupTarget" -Credential $Credential

Write-Host -ForegroundColor Yellow "Copy started ... " -NoNewline

Copy-Item -Path Nevada:\Webserver\* -Destination  $ArchiveDestination\Webserver -Recurse
Write-Host -ForegroundColor Green "Copy finished"

Remove-PSDrive -Name Nevada