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
            Add-Content -Path $Path -Value "################################################################################################"
            Add-Content -Path $Path -Value " Started processing at [$([DateTime]::Now)]."
            Add-Content -Path $Path -Value "################################################################################################"
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value " Running script task [$Task]."
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value "################################################################################################"
            Add-Content -Path $Path -Value ""

            #Write to screen for debug mode
            Write-Debug -Path $Path -Value "################################################################################################"
            Write-Debug -Path $Path -Value " Started processing at [$([DateTime]::Now)]."
            Write-Debug -Path $Path -Value "################################################################################################"
            Write-Debug -Path $Path -Value ""
            Write-Debug -Path $Path -Value " Running script task [$Task]."
            Write-Debug -Path $Path -Value ""
            Write-Debug -Path $Path -Value "################################################################################################"
            Write-Debug -Path $Path -Value ""
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
            $Value   = $logDate + " " + $Message
        }

        Process{
            Add-Content -Path $Path -Value $Value
        }

        End{
            
        }
    
}