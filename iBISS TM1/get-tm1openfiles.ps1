function Get-iBISSTM1OpenFiles (
    [Parameter(Mandatory = $true)][string[]]$TM1ServiceName
    # [Parameter(Mandatory = $true)][string[]]$Target,
    # [Parameter(Mandatory = $true)][string[]]$Source,
    # [Parameter(Mandatory = $true)][string[]]$ServiceName
    #[Parameter(Mandatory = $true)][string[]]$Log
    )

    {
        <#
        .SYNOPSIS
        Easy way to find open files locked by TM1 Server process.
        
        .DESCRIPTION
        Use this cmdlet to determine to locked files by TM1 Server process.
        
        .PARAMETER TM1ServiceName
        TM1 Service Name has to be provided.
        
        .EXAMPLE
        Get-iBISSTm1OpenFiles -TM1ServiceName SERVICENAME
        
        .NOTES
        This cmdlet needs administrativ permissions to output open files.
        #>

        Begin{

            if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
                Write-Warning "Please run with elevated privileges!"
                Break
            }
            $ProcessID = Get-WmiObject -Class Win32_Service -Filter "Name = '$TM1ServiceName'" | Select-Object -ExpandProperty ProcessId
            
            if ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit") {
                Set-Alias Get-Handle "$env:USERPROFILE\Downloads\Sysinternals\Handle\handle64.exe"
            }
            else {
                Set-Alias Get-Handle "$env:USERPROFILE\Downloads\Sysinternals\Handle\handle.exe"
            }
        }
        
        Process{
            Write-Host -ForegroundColor Yellow "List of open files for process $ProcessID"
            Get-Handle -p $ProcessID -nobanner
        }

        End{
            
        }
    }