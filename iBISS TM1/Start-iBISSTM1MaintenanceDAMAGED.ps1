
# Specifies a task to operate
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1)][ValidateSet("CopyLogs", "PurgeBackup", "PurgeLogs", "OfflineBackup", "OnlineBackup")] [string[]]$Task, 
    #[Parameter(Mandatory=$true, Position=1, ParameterSetName="InstanceName")][ValidateNotNullOrEmpty()][string[]]$InstanceName
    [Parameter(Mandatory=$true,Position=2)][ValidateNotNull()] [string[]]$InstanceName #= "testInstance"
)

$date = Get-Date -UFormat "%Y-%m-%d"

if ($Task -eq "CopyLogs") {
    #Settings for deleting Backups
    #$InstanceName = "TestInstance"       # test, wieder löschen!
    #$date = Get-Date -UFormat "%Y-%m-%d" # test, wieder löschen!
    $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName"
    $logName = "$InstanceName-CopyLogs-$date.log"
    if (!(Test-Path $logPath)) {
        New-Item -Path $logPath -ItemType "Directory"
        New-Item -Name $logName -Path $logPath -ItemType "file"
    }
    else {
        New-Item -Name $logName -Path $logPath -ItemType "file"        
    }
}
elseif ($Task -eq "PurgeBackup") {
    #Settings for deleting Backups
    $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName"
    $logName = "$InstanceName-PurgeBackup-$date.log"
    New-Item -Name $logName -Path $logPath -ItemType "file"
}
elseif ($Task -eq "PurgeLogs") {
    #Settings for deleting Logs
    $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName"
    $logName = "$InstanceName-PurgeLogs-$date.log"
    New-Item -Name $logName -Path $logPath -ItemType "file"
}
elseif ($Task -eq "OfflineBackup") {
    #Settings for OfflineBackup
    $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName"
    $logName = "$InstanceName-OfflineBackup-$date.log"
    New-Item -Name $logName -Path $logPath -ItemType "file"
}
elseif ($Task -eq "OnlineBackup") {
    #Settings for OnlineBackup
    $logPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName"
    $logName = "$InstanceName-OnlineBackup-$date.log"
    New-Item -Name $logName -Path $logPath -ItemType "file"
}

###################################
## 
##  Task "CopyLogs"  
##
###################################

###################################
## 
##  Task "PurgeBackup"  
##
###################################

###################################
## 
##  Task "PurgeLogs"  
##
###################################

###################################
## 
##  Task "OfflineBackup"  
##
###################################

###################################
## 
##  Task "OnlineBackup"  
##
###################################

$7zipPath = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "7-Zip"}).InstallLocation

function LogWarning ([string]$warnValue) {
    $logDate = Get-Date -UFormat "%D %T"
    Add-Content -Path $logPath/$logName -Value "$logDate $warnValue"
}

