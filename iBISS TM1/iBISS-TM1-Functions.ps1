function Start-iBISSTM1Log (
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Path,
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Task,
    [Parameter(Mandatory=$false)][ValidateNotNull()][string[]]$InstanceName
    )

    {
        <#
        .SYNOPSIS
        Function is supposed to start a iBISS TM1 Logfile with a predefined header.
        
        .DESCRIPTION
        With this function you are able to create logfiles always with the same format.
        
        .PARAMETER Path
        The Path to the logfile. In all iBISS TM1 Logfiles the path is set in the powershell script using this function, e.g. $log in iBISSTM1Maintenance.ps1.
        
        .PARAMETER Task
        The task for which the logfile is beeing created. In all iBISS TM1 Logfiles the task is set in the powershell script using this function, e.g. $task in iBISSTM1Maintenance.ps1.

        .PARAMETER InstanceName
        Optional parameter for TM1 instance Name, if not set in calling Powershell script itself.
        
        .EXAMPLE
        Start-iBISSTM1Log -Path $log -Task $Task
        
        .NOTES
        There are no general notes
        #>

        Begin{
            #$logDate = Get-Date -UFormat "%D %T"
            #$Value   = $logDate + " " + $Message
            $date = Get-Date -UFormat "%d.%m.%Y %T"
        }

        Process{
            Add-Content -Path $Path -Value "################################################################################"
            Add-Content -Path $Path -Value "#"
            Add-Content -Path $Path -Value "# Started processing at $date"
            Add-Content -Path $Path -Value "#"
            Add-Content -Path $Path -Value "################################################################################"
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value "  Running script task $Task"
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value "################################################################################"
            Add-Content -Path $Path -Value ""
        }

        End{

        }
}

function Stop-iBISSTM1Log (
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Path,
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Task,
    [Parameter(Mandatory=$false)][ValidateNotNull()][string[]]$InstanceName
    )

    {
        <#
        .SYNOPSIS
        Function is supposed to stop a iBISS TM1 Logfile with a predefined footer.
        
        .DESCRIPTION
        With this function you are able to create logfiles always with the same format.
        
        .PARAMETER Path
        The Path to the logfile. In all iBISS TM1 Logfiles the path is set in the powershell script using this function, e.g. $log in iBISSTM1Maintenance.ps1.
        
        .PARAMETER Task
        The task for which the logfile is beeing created. In all iBISS TM1 Logfiles the task is set in the powershell script using this function, e.g. $task in iBISSTM1Maintenance.ps1.
        
        .PARAMETER InstanceName
        Optional parameter for TM1 instance Name, if not set in calling Powershell script itself.

        .EXAMPLE
        Stop-iBISSTM1Log -Path $log -Task $Task
        
        .NOTES
        There are no general notes
        #>

        Begin{
            #$logDate = Get-Date -UFormat "%D %T"
            #$Value   = $logDate + " " + $Message
            $date = Get-Date -UFormat "%d.%m.%Y %T"
        }

        Process{
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value "################################################################################"
            Add-Content -Path $Path -Value "#"
            Add-Content -Path $Path -Value "# Stopped processing at $date"
            Add-Content -Path $Path -Value "#"
            Add-Content -Path $Path -Value "################################################################################"
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value "  Finished script task $Task"
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value "################################################################################"
        }

        End{

        }
}

function Write-iBISSTM1Log (
    [Parameter(Mandatory=$true)][string[]]$Path,
    [Parameter(Mandatory=$true)][string[]]$Message
    )
    
    {
        
        <#
        .SYNOPSIS
        Add a log entry.
        
        .DESCRIPTION
        Function is supposed to add a log entry with loglevel INFO.
        
        .PARAMETER Path
        The Path to the logfile. In all iBISS TM1 Logfiles the path is set in the powershell script using this function, e.g. $log in iBISSTM1Maintenance.ps1.
        
        .PARAMETER Task
        The task for which the logfile is beeing created. In all iBISS TM1 Logfiles the task is set in the powershell script using this function, e.g. $task in iBISSTM1Maintenance.ps1.
        
        .PARAMETER InstanceName
        Optional parameter for TM1 instance Name, if not set in calling Powershell script itself.
        
        .EXAMPLE
        Write-iBISSTM1Log -Path $log -Message "some information" 
        
        .NOTES
        General notes

        .LINK
        Original code can be found on GitHub: https://github.com/carslen
        #>

        Begin{
            $logDate = Get-Date -UFormat "%d.%m.%Y %T"
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

        <#
        .SYNOPSIS
        Add a log entry.
        
        .DESCRIPTION
        Function is supposed to add a log entry with loglevel WARN.
        
        .PARAMETER Path
        The Path to the logfile. In all iBISS TM1 Logfiles the path is set in the powershell script using this function, e.g. $log in iBISSTM1Maintenance.ps1.
        
        .PARAMETER Task
        The task for which the logfile is beeing created. In all iBISS TM1 Logfiles the task is set in the powershell script using this function, e.g. $task in iBISSTM1Maintenance.ps1.
        
        .PARAMETER InstanceName
        Optional parameter for TM1 instance Name, if not set in calling Powershell script itself.
        
        .EXAMPLE
        Write-iBISSTM1Warn -Path $log -Message "some information" 
        
        .NOTES
        General notes

        .LINK
        Original code can be found on GitHub: https://github.com/carslen
        #>

        Begin{
            $logDate = Get-Date -UFormat "%d.%m.%Y %T"
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

        <#
        .SYNOPSIS
        Add a log entry.
        
        .DESCRIPTION
        Function is supposed to add a log entry with loglevel ERROR.
        
        .PARAMETER Path
        The Path to the logfile. In all iBISS TM1 Logfiles the path is set in the powershell script using this function, e.g. $log in iBISSTM1Maintenance.ps1.
        
        .PARAMETER Task
        The task for which the logfile is beeing created. In all iBISS TM1 Logfiles the task is set in the powershell script using this function, e.g. $task in iBISSTM1Maintenance.ps1.
        
        .PARAMETER InstanceName
        Optional parameter for TM1 instance Name, if not set in calling Powershell script itself.
        
        .EXAMPLE
        Write-iBISSTM1Error -Path $log -Message "some information" 
        
        .NOTES
        General notes

        .LINK
        Original code can be found on GitHub: https://github.com/carslen
        #>

        Begin{
            $logDate = Get-Date -UFormat "%d.%m.%Y %T"
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
            if (Test-Path -Path $env:ProgramFiles\7-zip\7z.exe) {
                Set-Alias 7z "$env:ProgramFiles\7-zip\7z.exe"
            }
            elseif (Test-Path -Path ${env:ProgramFiles(x86)}\7-zip\7z.exe) {
                Set-Alias -Name 7z -Value "${env:ProgramFiles(x86)}\7-zip\7z.exe"
            }
            else {
                Write-iBISSTM1ERROR -Path $log -Message "7-Zip executable missing/not found!"
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
                    Write-iBISSTM1Log -Path $log -Message "Backup of $Source completed successful."
                }
                elseif ($LASTEXITCODE -eq "1") {
                    Add-Content -Path $log -Value ""
                    Write-iBISSTM1Warn -Path $log -Message "Backup of $Source completed with warnings."
                }
                elseif ($LASTEXITCODE -eq "2") {
                    Add-Content -Path $log -Value ""
                    Write-iBISSTM1ERROR -Path $log -Message "Backup of $Source failed!"
                }
            }
            elseif ($Type -eq "Offline") {
                Write-iBISSTM1Log -Path $log -Message "Starting TM1 $Task"
                Write-iBISSTM1Log -Path $log -Message "Checking TM1 Service for $InstanceName"

                # Checking Instance status (runnung, or not)
                #
                if ((Get-Service -Name "$InstanceName").Status -eq "Running") {
                    Write-iBISSTM1Log -Path $log -Message "$InstanceName service is running, stopping..."
                    Stop-Service -Name $InstanceName
                    Write-iBISSTM1Log -Path $log -Message "Waiting for $InstanceName to be stopped. "
                    while ((Get-Service -Name "$InstanceName").Status -eq "Running") {
                        Write-iBISSTM1Log -Path $log -Message ". "
                        Start-Sleep -Seconds 3
                    }
                    Write-iBISSTM1Log -Path $log -Message "$InstanceName stopped."
                    Write-iBISSTM1Log -Path $log -Message "Creating backup container"
                    
                # Start creating the zip for backup
                #
                    7z a -tzip -r $Target $Source -bso1 > $env:TEMP\7ztemp.log
                    
                # Logging workaraound
                #
                    Add-Content -Path $log -Value (Get-Content $env:TEMP\7ztemp.log)
                    Remove-Item -Path "$env:TEMP\7ztemp.log"
                    
                # Exitcodes for zip creation
                #
                    if ($LASTEXITCODE -eq "0") {
                    Add-Content -Path $log -Value ""
                    Write-iBISSTM1Log -Path $log -Message "Backup of $Source completed successful."
                    }
                    elseif ($LASTEXITCODE -eq "1") {
                        Add-Content -Path $log -Value ""
                        Write-iBISSTM1Warn -Path $log -Message "Backup of $Source completed with warnings."
                    }
                    elseif ($LASTEXITCODE -eq "2") {
                        Add-Content -Path $log -Value ""
                        Write-iBISSTM1ERROR -Path $log -Message "Backup of $Source failed!"
                    }
                
                # Start instance after backup
                # 
                    Write-iBISSTM1Log -Path $log -Message "Starting $InstanceName service"
                    Start-Service -Name $InstanceName
                    if ((Get-Service -Name "$InstanceName").Status -eq "Running") {
                        Write-iBISSTM1Log -Path $log -Message "$InstanceName started successful."
                    }
                    
                }
                else {
                    Write-iBISSTM1Warn -Path $log -Message "Instance $InstanceName already stopped"
                    Write-iBISSTM1Log -Path $log -Message "Creating backup container"
                    
                # Start creating the zip for backup
                #
                    7z a -tzip -r $Target $Source -bso1 > $env:TEMP\7ztemp.log
                    
                # Logging workaraound
                #
                    Add-Content -Path $log -Value (Get-Content $env:TEMP\7ztemp.log)
                    Remove-Item -Path "$env:TEMP\7ztemp.log"
                    
                # Exitcodes for zip creation
                #
                    if ($LASTEXITCODE -eq "0") {
                    Add-Content -Path $log -Value ""
                    Write-iBISSTM1Log -Path $log -Message "Backup of $Source completed successful."
                    }
                    elseif ($LASTEXITCODE -eq "1") {
                        Add-Content -Path $log -Value ""
                        Write-iBISSTM1Warn -Path $log -Message "Backup of $Source completed with warnings."
                    }
                    elseif ($LASTEXITCODE -eq "2") {
                        Add-Content -Path $log -Value ""
                        Write-iBISSTM1ERROR -Path $log -Message "Backup of $Source failed!"
                    }
                }
                
            }
        }

        End{
            
        }
}