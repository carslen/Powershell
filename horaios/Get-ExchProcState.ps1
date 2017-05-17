<#
.Synopsis
    Get-ExchProcState liefert Informationen über die Exchange Prozesse auf dem angegebenen Exchange Server
.Description
    asdf
.Example
    asdf
#>

function Get-ExchProcState
{
    Param(
        [String[]]$ComputerName = "localhost",
        [Switch]$NotRunning,
        [Parameter(Mandatory=$False)] [ValidateNotNull()] [System.Management.Automation.PSCredential] [System.Management.Automation.Credential()] $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    
    
    if ($NotRunning -eq $true) {
        $ExchProc = Get-WmiObject -Class Win32_Service -ComputerName $ComputerName -Credential $Credential -Filter "Name like 'MSExch%' AND StartMode='Auto' AND State='Stopped'"
        
        if (!$ExchProc) {
            Write-Host "Exchange Prozess-Informationen" -ForegroundColor Yellow
            Write-Host "Exchange Server: " -ForegroundColor Yellow -NoNewline
            Write-Host "$ComputerName"
            Write-Host ""
            Write-Host "Alle Exchange Prozesse laufen!" -ForegroundColor Green
            Write-Host ""
        }
        else {
            Write-Host "Exchange Prozess-Informationen" -ForegroundColor Yellow
            Write-Host "Exchange Server: " -ForegroundColor Yellow -NoNewline
            Write-Host "$ComputerName"
            Write-Host ""
            $ExchProc | Format-Table @{n="Prozessname"  ; e={$_.Name}},
                                     @{n="Startart"     ; e={$_.StartMode}},
                                     @{n="Prozessstatus"; e={$_.State}}
        }
                
    }
    else {
        $ExchProc = Get-WmiObject -Class Win32_Service -ComputerName $ComputerName -Credential $Credential -Filter "Name like 'MSExch%' AND StartMode='Auto'"
        
        Write-Host "Exchange Prozess-Informationen" -ForegroundColor Yellow
        Write-Host "Exchange Server: " -ForegroundColor Yellow -NoNewline
        Write-Host "$ComputerName"
        $ExchProc | Format-Table @{n="Dienstname"          ; e={$_.Name}},
                                 @{n="Dienst Startmodus"   ; e={$_.StartMode}},
                                 @{n="Status"              ; e={$_.State}}
    }

}