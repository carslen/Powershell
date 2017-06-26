Param (
    # Parameter help description
    #[Parameter(Mandatory=$true)][string[]]$ComputerName,
    #[Parameter(Mandatory=$true)][ValidateSet("proc","service")]$print
    [Parameter(Mandatory=$true,Position=1)][ValidateSet("CopyLogs", "PurgeBackup", "PurgeLogs", "OfflineBackup", "OnlineBackup")] [string[]]$Task,
    [Parameter(Mandatory=$true,Position=2)][ValidateNotNull()] [string[]]$InstanceName #= "testInstance"
)

<#function LogWarning ([string]$warnValue) {
    $logDate = Get-Date -UFormat "%D %T"
    Add-Content -Path $logPath/$logName -Value "$logDate $warnValue"
}#>

$date = Get-Date -UFormat "%Y-%m-%d"

if (!(Get-Service -Name wuauserv -ErrorAction SilentlyContinue)) { # wuauserv durch $InstanceName ersetzen auf TM1 Maschinen!
    Write-Warning -Message "Service ""$InstanceName"" doesn't exists!"
}
else {
    if ($Task -eq "CopyLogs") {

        #Settings for deleting Backups
        #$InstanceName = "TestInstance"       # test, wieder löschen!
        #$date = Get-Date -UFormat "%Y-%m-%d" # test, wieder löschen!
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\logfiles"
        $logName = "$InstanceName-CopyLogs-$date.log"
        $log     = "$logPath\$logName"
        if (!(Test-Path $logPath)) {
            Write-Host -ForegroundColor Yellow "Creating logdirs for Task:"$Task" ... " -NoNewline
            New-Item -Path $logPath -ItemType "Directory" | Out-Null
            New-Item -Name $logName -Path $logPath -ItemType "file" | Out-Null
            Write-Host -ForegroundColor Green "Done!"
            $logDate = Get-Date -UFormat "%D %T"
            Add-Content -Path $log -Value "$logDate"":" "Initial creation of logdir completet!" 
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }
    elseif ($Task -eq "PurgeBackup") {
        #Settings for deleting Backups
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\backups"
        $logName = "$InstanceName-PurgeBackup-$date.log"
        if (!(Test-Path $logPath)) {
            New-Item -Path $logPath -ItemType "Directory"
            New-Item -Name $logName -Path $logPath -ItemType "file"
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }
    elseif ($Task -eq "PurgeLogs") {
        #Settings for deleting Logs
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\logfiles"
        $logName = "$InstanceName-PurgeLogs-$date.log"
        if (!(Test-Path $logPath)) {
            New-Item -Path $logPath -ItemType "Directory"
            New-Item -Name $logName -Path $logPath -ItemType "file"
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }
    elseif ($Task -eq "OfflineBackup") {
        #Settings for OfflineBackup
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\backups"
        $logName = "$InstanceName-OfflineBackup-$date.log"
        if (!(Test-Path $logPath)) {
            New-Item -Path $logPath -ItemType "Directory"
            New-Item -Name $logName -Path $logPath -ItemType "file"
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }
    elseif ($Task -eq "OnlineBackup") {
        #Settings for OnlineBackup
        $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\backups"
        $logName = "$InstanceName-OnlineBackup-$date.log"
        if (!(Test-Path $logPath)) {
            New-Item -Path $logPath -ItemType "Directory"
            New-Item -Name $logName -Path $logPath -ItemType "file"
        }
        else {
            New-Item -Name $logName -Path $logPath -ItemType "file"        
        }
    }

}