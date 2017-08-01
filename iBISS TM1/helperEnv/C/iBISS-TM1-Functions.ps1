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

function Write-iBISSTM1Error (
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
    [Parameter(Mandatory = $true)][string[]]$Source,
    [Parameter(Mandatory = $true)][string[]]$ServiceName
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
                Write-iBISSTM1Log -Path $log -Message "Checking TM1 Service for $ServiceName"

                # Checking Instance status (runnung, or not)
                #
                if ((Get-Service -Name "$ServiceName").Status -eq "Running") {
                    Write-iBISSTM1Log -Path $log -Message "Service $ServiceName is running, stopping."
                    Stop-Service -Name $ServiceName
                    Write-iBISSTM1Log -Path $log -Message "Waiting for service $ServiceName to be stopped. "
                    while ((Get-Service -Name "$ServiceName").Status -eq "Running") {
                        Write-iBISSTM1Log -Path $log -Message ". "
                        Start-Sleep -Seconds 3
                    }
                    Write-iBISSTM1Log -Path $log -Message "$ServiceName Stopped!"
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
                    Write-iBISSTM1Log -Path $log -Message "Starting service $ServiceName"
                    Start-Service -Name $ServiceName
                    if ((Get-Service -Name "$ServiceName").Status -eq "Running") {
                        Write-iBISSTM1Log -Path $log -Message "$ServiceName started successful."
                    }
                    
                }
                else {
                    Write-iBISSTM1Warn -Path $log -Message "Instance $ServiceName already stopped"
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
            elseif ((Get-Service -Name $TM1ServiceName -ErrorAction SilentlyContinue).Status -ne "Running") {
                Write-Warning "Service $TM1ServiceName not running!"
                Break
            }
            elseif (!(Get-Service -Name $TM1ServiceName -ErrorAction SilentlyContinue)) {
                Write-Warning "Service $TM1ServiceName doesn't exist!"
                Break
            }
            $ProcessID = Get-WmiObject -Class Win32_Service -Filter "Name = '$TM1ServiceName'" | Select-Object -ExpandProperty ProcessId
            
            if ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit") {
                Set-Alias Get-Handle "C:\Services\helperEnv\Tools\Sysinternals\Handle\handle64.exe"
            }
            else {
                Set-Alias Get-Handle "C:\Services\helperEnv\Tools\Sysinternals\Handle\handle.exe"
            }
        }
        
        Process{
            Write-Host -ForegroundColor Yellow "List of open files for service $TM1ServiceName with PID $ProcessID"
            Write-Host ""
            Get-Handle -p $ProcessID  -nobanner -accepteula
            Write-Host ""
        }

        End{
            
        }
}

function Configure-iBISSTM1Tasks (
    [Parameter(Mandatory = $true)][string[]]$InstanceFilesystemBaseName = "Tomcat82"
    ) 
    {
        Begin {
            #$BaseDir            = "D:\TM1" # Muss aktiviert werden, wenn das Script in den Template-Ordner wandert/produktiv geht
            $BaseDir            = "C:\Users\CARSLEN\Desktop\Test"
            $InstanceBaseDir    = "$BaseDir\$InstanceFilesystemBaseName"
            $helperEnvBase      = "$InstanceBaseDir\helperEnv"
            $TaskBase           = "$helperEnvBase\Tasks"
            
            if (!(Test-Path -Path $InstanceBaseDir)) {
                Write-Warning "Path $InstanceBaseDir not found!"
                Break
            }
        }

        Process {
            Write-Host ""
            $TaskTemplates = Get-ChildItem -Path $TaskBase -File
            foreach ($Task in $TaskTemplates) {
                $FilePath = $Task.FullName
                $FileName = $Task.BaseName

                Write-Host -ForegroundColor Yellow "Configure Task " -NoNewline
                Write-Host "$($FileName): " -NoNewline
                (Get-Content -Path $FilePath).Replace('XXX',"$InstanceFilesystemBaseName") | Set-Content -Path $FilePath
                Write-Host -ForegroundColor Green "`tOK"
            }
            Write-Host ""
            Write-Host "Configuration finished."
        }

        End {
            Write-Host ""
            Write-Host "You can now start Task Scheduler and import tasks from $TaskBase"
            Write-Host ""
        }
}