$ComputerName       = "HyperV02"
$User               = Read-Host -Prompt "Please enter your Username (Admin Account required!)"
$Credential         = Get-Credential -Credential horaios\$User
$DriveLetter        = Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE Label='DPM Archive'" | Select-Object -ExpandProperty Name
$DriveLetter        = $DriveLetter.Remove(2,1)
$ArchiveDestination = "$DriveLetter\GmbH\$ComputerName"

Invoke-Command -ComputerName $ComputerName -Credential $Credential -ArgumentList "$VMNames","$ExportDest" -ScriptBlock {
                                    
                  $VMNames    = @("LX-C6-Web01","LX-C7-MailGW")
                  $ExportDest = "E:\Export"
                  $Date       = Get-Date

                  Get-ChildItem $ExportDest | Where-Object {($Date - $_.LastWriteTime).Days -gt 2} |  Remove-Item -Recurse

                  foreach ($VM in $VMNames) {

                      # VM Shutdown
                      if ((Get-VM -Name $VM).State -eq "Running")
                      {
                          Write-Host -ForegroundColor Yellow "Shutdown VM: " -NoNewline
                          Write-Host "$VM ..." -NoNewline
                          Stop-VM -Name $VM
                          Write-Host -ForegroundColor Green "Done!"
                      }
                      else
                      {
                          Write-Host -ForegroundColor Yellow "$VM already shut down"
                      }
                      
                      # VM Export
                      Write-Host -ForegroundColor Yellow "Export VM: " -NoNewline
                      Write-Host "$VM ..." -NoNewline
                      Export-VM -Name $VM -Path $ExportDest
                      do {
                          Start-Sleep -Seconds 10
                      } while ((Get-VM -Name $VM).Status -eq "Virtueller Computer wird exportiert...")
                      Write-Host -ForegroundColor Green "Done!"

                      # VM Start
                      Write-Host -ForegroundColor Yellow "Start VM: " -NoNewline
                      Write-Host "$VM ..." -NoNewline
                      Start-VM -Name $VM
                      Write-Host -ForegroundColor Green "Done!"
                      Get-VM -Name $VM
                      
                  }
                  
              }

Write-Host -ForegroundColor Cyan "Mounting Source Filesystem"
New-PSDrive -Name HyperV02 -PSProvider FileSystem -Root "\\Hyperv02\E$\export" -Description "HyperV02 $ExportDest"

if ((Get-ChildItem -Path Hyperv02:\).Length -ne "0" )
{
    Write-Host -ForegroundColor Yellow "Moving VM Exports to archive destination $ArchiveDestination ... " -NoNewline
    Move-Item -Path Hyperv02:\LX-* -Destination $ArchiveDestination
    Write-Host -ForegroundColor Green "Done!"
}
else
{
    Write-Host -ForegroundColor Red "No Exports available for moving to $ArchiveDestination"
}


Write-Host -ForegroundColor Cyan "Umounting Source FileSystem... " -NoNewline
Remove-PSDrive -Name HyperV02
Write-Host -ForegroundColor Green "Done!"