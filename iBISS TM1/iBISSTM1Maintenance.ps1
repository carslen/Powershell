Param (
    [Parameter(Mandatory=$true,Position=1)][ValidateSet("CopyLogs", "PurgeBackup", "PurgeLogs", "OfflineBackup", "OnlineBackup")] [string[]]$Task,
    [Parameter(Mandatory=$true,Position=2)][ValidateNotNull()] [string[]]$InstanceName #= "testInstance"
)


. "C:\Users\CARSLEN\Documents\git\Powershell\iBISS TM1\iBISS-TM1-Logging_Functions.ps1"
$date = Get-Date -UFormat "%Y-%m-%d"

if (!(Get-Service -Name wuauserv -ErrorAction SilentlyContinue)) { # wuauserv durch $InstanceName ersetzen auf TM1 Maschinen!
    Write-Warning -Message "Service ""$InstanceName"" doesn't exists!"
    Break
}
else {
    if ($Task -eq "CopyLogs") {
        # Setting up Log environment
        #
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\logfiles"
        $logName = "$InstanceName-CopyLogs-$date.log"
        $log     = "$logPath\$logName"
        
        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $logPath)) {
            Write-Host -ForegroundColor Yellow "Creating logdirs for Task:"$Task" ... " -NoNewline
            New-Item -Path $logPath -ItemType "Directory" | Out-Null
            New-Item -Name $logName -Path $logPath -ItemType "file" | Out-Null
            Write-Host -ForegroundColor Green "Done!"
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Created logdirs for Task $Task"
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }
    elseif ($Task -eq "PurgeBackup") {
        # Setting up Log environment
        #
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\backups"
        $logName = "$InstanceName-PurgeBackup-$date.log"
        $log     = "$logPath\$logName"

        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $logPath)) {
            New-Item -Path $logPath -ItemType "Directory"
            New-Item -Name $logName -Path $logPath -ItemType "file"
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }
    elseif ($Task -eq "PurgeLogs") {
        # Setting up Log environment
        #
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\logfiles"
        $logName = "$InstanceName-PurgeLogs-$date.log"
        $log     = "$logPath\$logName"

        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $logPath)) {
            New-Item -Path $logPath -ItemType "Directory"
            New-Item -Name $logName -Path $logPath -ItemType "file"
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }
    elseif ($Task -eq "OfflineBackup") {
        # Setting up Log environment
        #
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\backups"
        $logName = "$InstanceName-OfflineBackup-$date.log"
        $log     = "$logPath\$logName"
        
        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $logPath)) {
            New-Item -Path $logPath -ItemType "Directory"
            New-Item -Name $logName -Path $logPath -ItemType "file"
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }
    elseif ($Task -eq "OnlineBackup") {
        # Setting up Log environment
        #
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\backups"
        $logName = "$InstanceName-OnlineBackup-$date.log"
        $log     = "$logPath\$logName"

        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $logPath)) {
            New-Item -Path $logPath -ItemType "Directory"
            New-Item -Name $logName -Path $logPath -ItemType "file"
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }

}