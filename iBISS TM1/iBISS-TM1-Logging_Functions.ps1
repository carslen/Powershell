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

function Start-iBISSTM1Backup (
    [Parameter(Mandatory = $true)][ValidateSet("Online", "Offline")][string[]]$Type,
    [Parameter(Mandatory = $true)][string[]]$Target,
    [Parameter(Mandatory = $true)][string[]]$Source
    #[Parameter(Mandatory = $true)][string[]]$Log
    )
    
    {
    Begin{
        if (Test-Path -Path $env:ProgramFiles\7-zip\7z2.exe) {
            Set-Alias 7z "$env:ProgramFiles\7-zip\7z.exe"
        }
        else {
            Write-iBISSTM1ERROR -Path $log -Message "7-Zip executable missing, or no 64 version installed!"
            Break
        }
    }
    
    Process{
        if ($Type -eq "Online") {
            Write-iBISSTM1Log -Path $log -Message "Starting TM1 $Task"
            7z a -tzip '-xr!*.cub' '-xr!*.sub' '-xr!*.vue' $Target $Source -bso1 > $env:TEMP\7ztemp.log
            Add-Content -Path $log -Value (Get-Content $env:TEMP\7ztemp.log)
            Remove-Item -Path "$env:TEMP\7ztemp.log"
            if ($LASTEXITCODE -eq "0") {
                Add-Content -Path $log -Value ""
                Write-iBISSTM1Log -Path $log -Message "Backup completed successful."
            }
            elseif ($LASTEXITCODE -eq "1") {
                Add-Content -Path $log -Value ""
                Write-iBISSTM1Warn -Path $log -Message "Backup completed with warnings."
            }
            elseif ($LASTEXITCODE -eq "2") {
                Add-Content -Path $log -Value ""
                Write-iBISSTM1ERROR -Path $log -Message "Backup failed!"
            }
        }
        elseif ($Type -eq "Offline") {
            7z a -r $Target $Source >> $log                                     # Offline verwendet andere 7z Opts
        }
    }

    End{

    }
}