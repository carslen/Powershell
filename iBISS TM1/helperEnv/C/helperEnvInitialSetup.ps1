# Check if we are using an elevated powershell session
#

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run with elevated privileges!"
    Break
}

# Some Variables
#

$ServicesDir        = "C:\Services"
$helperEnvBaseC     = "$ServicesDir\helperEnv"
$PSBaseC            = "$helperEnvBaseC\Powershell"

# Copy Powershell profile.ps1 file to $profile.AllUsersAllHosts to get iBISS-TM1-Functions available
#

Write-Host ""
Write-Host -ForegroundColor Yellow "Copying PowerShell profile file profile.ps1: " -NoNewline
Copy-Item -Path "$PSBaseC\profile.ps1" -Destination $profile.AllUsersAllHosts
Write-Host -ForegroundColor Green "Done"
Write-Host ""
Write-Host "With next start of Powershell all iBISS-TM1-Functions will be available. Have fun!"
Write-Host ""