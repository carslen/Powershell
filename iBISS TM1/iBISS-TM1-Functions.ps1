function Start-iBISSTM1Log (
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Path,
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Task
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
            Add-Content -Path $Path -Value " Running script task $Task for instance ""$InstanceName""."
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value "################################################################################"
            Add-Content -Path $Path -Value ""
        }

        End{

        }
}

function Stop-iBISSTM1Log (
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Path,
    [Parameter(Mandatory=$true)][ValidateNotNull()][string[]]$Task
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
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value "################################################################################"
            Add-Content -Path $Path -Value "#"
            Add-Content -Path $Path -Value "# Stopped processing at $date"
            Add-Content -Path $Path -Value "#"
            Add-Content -Path $Path -Value "################################################################################"
            Add-Content -Path $Path -Value ""
            Add-Content -Path $Path -Value " Finished script task $Task for instance ""$InstanceName""."
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
            7z a -r $Target $Source >> $log                                     # Offline verwendet andere 7z Opts
        }
    }

    End{
        s
    }
}

function Confirm-iBISSTM1InstanceName (
    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "TM1 instance name")][ValidateNotNull()] [string[]]$InstanceName,
    [Parameter(Mandatory = $false, Position = 2, HelpMessage = "Validate TM1 instance service name")][ValidateNotNull()] [switch]$CheckService,
    [Parameter(Mandatory = $false, Position = 2, HelpMessage = "TM1 instance filesystem basedirectory")][ValidateNotNull()] [switch]$CheckFilesystem,
    [Parameter(Mandatory = $false, Position = 2, HelpMessage = "Path to logfile for output")][ValidateNotNull()] [string[]]$LogFile
    )

    {
        <#
        .SYNOPSIS
        Confirm existance of TM1 instance base filesystem directory and TM1 instance service.
        
        .DESCRIPTION
        Confirm-iBISTM1InstanceName has two functions:
            - Get the right filesystem directory for given TM1 instance name, which is normaly located under D:\TM1.
            - Check if there is a service registered as named in InstanceName
        
        .PARAMETER InstanceName
        InstanceName expexts the TM1 instance name as STRING.
        
        .PARAMETER CheckService
        With this switch selected the function will search registered windows services for InstanceName. This switch cannot be combined with "CheckFilesystem".
        
        .PARAMETER CheckFilesystem
        With this switch selected the function will determine the TM1 instance base directory which is normaly located under D:\TM1. This switch cannot be combined with "CheckService".
        
        .PARAMETER LogFile
        Logfile expects a path to a logfile. This is optionaly and will possibly removed with one of the next releases of this function.
        
        .EXAMPLE
        To get the TM1 instance filesystem base directory use:
            Confirm-iBISSTM1InstanceName -InstanceName "TM1_Instance" -CheckFilesystem
        
        To verify the TM1 instance service use:
            Confirm-iBISSTM1InstanceName -InstanceName "TM1_Instance" -CheckService
                
        .NOTES
        Version 0.1:
            General availability of function deployed.
        #>
        if (!$CheckFilesystem -and !$CheckService) {
            Write-Warning -Message "To check Instance please select either '-CheckFilesystem' or '-CheckService' switch"
            break
        }

        if ($CheckFilesystem) {
            #if (!(Get-Service -Name $InstanceName -ErrorAction SilentlyContinue)) {
            if (!(Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue)) {
                #Write-Warning -Message "No TM1 service registered with given InstanceName ""$InstanceName"". Abort!"
                Write-Error -Message "Service $InstanceName not found" -ErrorId ServiceNotFound -Category ObjectNotFound -RecommendedAction "Use correct TM1 instance name!"
                break
            }
            else {
                [string[]]$BaseDir = "C:\Users\CARSLEN\Desktop\Test"
                #[string[]]$BaseDir = "D:\TM1"
                if (Test-Path -Path "$BaseDir\$InstanceName") {
                    return "$BaseDir\$InstanceName"
                }
                else {
                    $temp = Get-ChildItem -Path $BaseDir -Directory
                    #$temp = Get-ChildItem -Path $BaseDir -Directory
                    foreach ($dir in $temp) {
                        $BaseName = $dir.BaseName
                        if ($InstanceName -match $BaseName) {
                            $InstanceName = $BaseName
                            return "$BaseDir\$InstanceName"
                        }
                    }
                }
            }
        }
        elseif ($CheckService) {
            #if (!(Get-Service -Name $InstanceName -ErrorAction SilentlyContinue)) {
            if (!(Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue)) {
                Write-Error -Message "Service $InstanceName not found" -ErrorId ServiceNotFound -Category ObjectNotFound -RecommendedAction "Use correct TM1 instance name!"
                break
            }
            else {
                $InstanceSRVName = Get-Service -Name wuauserv # Wird während Entwicklung genutzt.
                $InstanceSRVName = Get-Service -Name $InstanceName # Production use!
                return $InstanceSRVName
            }
        }
    }