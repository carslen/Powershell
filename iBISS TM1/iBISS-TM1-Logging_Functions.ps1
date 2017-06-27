function Start-iBISSTM1Log (
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Path,
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Task
    )

    {
        Begin{
            #$logDate = Get-Date -UFormat "%D %T"
            #$Value   = $logDate + " " + $Message
        }

        Process{
            Add-Content -Path $Path -Value '################################################################################'
            Add-Content -Path $Path -Value '#'
            Add-Content -Path $Path -Value '# Started processing at [$([DateTime]::Now)].'
            Add-Content -Path $Path -Value '#'
            Add-Content -Path $Path -Value '################################################################################'
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value " Running script task [$Task]."
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value '################################################################################'
            Add-Content -Path $Path -Value ""
        }

        End{

        }
}

function Write-iBISSTM1Log (
    [Parameter(Mandatory=$true)][string[]]$Path,
    [Parameter(Mandatory=$true)][string[]]$Message
    )
    
    {
        Begin{
            $logDate = Get-Date -UFormat "%D %T"
            $Value   = $logDate + " " + "INFO" + " " + $Message
        }

        Process{
            Add-Content -Path $Path -Value $Value
        }

        End{
            
        }
}

function Write-iBISSTM1Warn (
    [Parameter(Mandatory=$true)][string[]]$Path,
    [Parameter(Mandatory=$true)][string[]]$Message
    )
    
    {
        Begin{
            $logDate = Get-Date -UFormat "%D %T"
            $Value   = $logDate + " " + "WARN" + " " + $Message
        }

        Process{
            Add-Content -Path $Path -Value $Value
        }

        End{
            
        }
}

function Write-iBISSTM1ERROR (
    [Parameter(Mandatory=$true)][string[]]$Path,
    [Parameter(Mandatory=$true)][string[]]$Message
    )
    
    {
        Begin{
            $logDate = Get-Date -UFormat "%D %T"
            $Value   = $logDate + " " + "ERROR" + " " + $Message
        }

        Process{
            Add-Content -Path $Path -Value $Value
        }

        End{
            
        }
}

function Create-iBISSTM1Backup (
    [Parameter(Mandatory = $true)][ValidateSet("Online", "Offline")][string[]]$Type,
    [Parameter(Mandatory = $true)][string[]]$Target,
    [Parameter(Mandatory = $true)][string[]]$Source,
    [Parameter(Mandatory = $true)][string[]]$Log
    )
    
    {
    Begin{
        if (Test-Path -Path $env:ProgramFiles\7-zip\7z.exe) {
            Set-Alias 7z "$env:ProgramFiles\7-zip\7z.exe"
        }
        else {
            Write-iBISSTM1ERROR -Path $log -Message "7-Zip executable missing, or no 64 version installed!"
        }
    }
    
    Process{
        if ($Type -eq "Online") {
            7z a -x!*.cub$ -x!*.sub$ -x!*.vue$ -r $Target $Source >> $log       # Online verwendete andere 7z Opts
        }
        elseif ($Type -eq "Offline") {
            7z a -r $Target $Source >> $log                                     # Offline verwendet andere 7z Opts
        }
    }

    End{

    }
}