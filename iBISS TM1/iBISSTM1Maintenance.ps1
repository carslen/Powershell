#Requires -RunAsAdministrator

Param (
    #[Parameter(Mandatory = $true, Position = 1, HelpMessage = "TM1 instance service name")][ValidateNotNull()] [string[]]$ServiceName,
    #[Parameter(Mandatory = $true, Position = 2, HelpMessage = "TM1 instance directory name as available below d:\tm1")][ValidateNotNull()] [string[]]$InstanceFilesystemBaseName,
    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Task to execute")][ValidateSet("CopyLogs", "ExpireLogs", "OfflineBackup", "OnlineBackup")] [string[]]$Task
    #[Parameter(Mandatory = $false, Position = 4, HelpMessage = "Copy destination for Task CopyLogs")][ValidateNotNull()] [string[]]$CopyLogDestination
)

<#
 ####################################################################################################################################################################################
 #   START CONFIGURATION SECTION
 ####################################################################################################################################################################################
#>

# TM1 Basenames
#
$ServiceName                = "Tomcat8"     # TM1 instance service name
$InstanceFilesystemBaseName = "Tomcat82"    # TM1 instance directory name as available below D:\TM1\
$CopyLogDestination         = "C:\Users\CARSLEN\Desktop\Test\Robo_Dest\logs"            # Copy destination for task CopyLogs

# Backup configuration
#
$weekly = "$true" # If set to $true, then weekly backups will be created
$yearly = "$true" # If set to $true, then yearly backups will be created

# Backup expiration configuration
#
[int]$ExpireDaily   =   "1" # specify in number of days, e.g. "13" for 14 days
[int]$ExpireWeekly  =  "28" # specify in number of days, e.g. "28" for 28 days/4 weeks, takes only affect if $weekly is set to $true
[int]$ExpireMonthly = "180" # specify in number of days, e.g. "180" for ~ 6 months
[int]$ExpireYearly  = "365" # specify in number of days, e.g. "365" for 1 year, takes only affect if $yearly is set to $true

# Logfile expiration configuration
#
[int]$ExpireLogs = "6"  # specify in number of days

<#
 ####################################################################################################################################################################################
 #   END CONFIGURATION SECTION
 #   DO NOT CHANGE ANY LINE BELOW THIS CONFIGURATION SECTION
 ####################################################################################################################################################################################
#>


# Load functions using dot sourcing
#
. "C:\Users\CARSLEN\Documents\git\Powershell\iBISS TM1\iBISS-TM1-Functions.ps1"

# Some baseline variables 
#
$date1      = Get-Date -UFormat "%Y-%m-%d"
$date2      = Get-Date -Uformat "%Y-%m-%d_%H%M%S"
$BaseDir    = "C:\Users\CARSLEN\Desktop\Test"# Muss deaktiviert werden, wenn das Script in den Template-Ordner wandert/produktiv geht
#$BaseDir = "D:\TM1"                      # Muss aktiviert werden, wenn das Script in den Template-Ordner wandert/produktiv geht
$InstanceBaseDir    = "$BaseDir\$InstanceFilesystemBaseName"
$BackupBaseDir      = "$InstanceBaseDir\backups"
$LogBaseDir         = "$InstanceBaseDir\logs"


if (!(Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
    Write-Warning -Message "Service ""$ServiceName"" doesn't exists!"
    Break
}
else {
    if ($Task -eq "CopyLogs") {
        # This Task copies almost all logfiles from $LogBaseDir to Instance exchange share which is currently located at 
        # \\sstr291f.emea.isn.corpintra.net\CUSTOMER\INSTANCE_DESCRIPTION
        # Unfortunately INSTANCE description doesn't macht $ServiceName, which is the cause for the config parameter $CopyLogDestination.

        # Setting up Log environment
        #
        $LogPath = "$LogBaseDir\robocopy"
        $LogName = "$ServiceName-$Task-$date2.log"
        $log     = "$LogPath\$LogName"
        
        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType "Directory" | Out-Null
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Created logdirs for Task $Task"
        }
        else {
            New-Item -Name $LogName -Path $LogPath -ItemType "file"
            Start-iBISSTM1Log -Path $log -Task $Task
        }

        Write-iBISSTM1Log -Path $log -Message "Start copying files from $LogBaseDir to $CopyLogDestination"

        # Starting things to do!
        #
        # TBD!
        Robocopy.exe $LogBaseDir $CopyLogDestination /mir /v /np /log+:"$log" /xd robocopy /xf tm1s.log /xf tm1s20????????????.log

        Write-iBISSTM1Log -Path $log -Message "Finished copying files from $LogBaseDir to $CopyLogDestination"
        Stop-iBISSTM1Log -Path $log -Task $Task

    }
    elseif ($Task -eq "ExpireLogs") {
        # Setting up Log environment
        #
        $LogPath = "$LogBaseDir\logfiles"
        $LogName = "$ServiceName-$Task-$date2.log"
        $log     = "$LogPath\$LogName"

        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType "Directory" | Out-Null
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Created logdirs for Task $Task"
        }
        else {
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
        }

        # Search for expired logfiles in $logBaseDir and delete them
        #

        $ExpiredLogs = Get-ChildItem -Path $LogBaseDir -Recurse -File | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt $ExpireLogs}
        Write-Host "Deleting exired files:"
        Write-iBISSTM1Log -Path $log -Message "Deleting expired files:"
        if ($ExpiredLogs.Length -lt $ExpireLogs) {
            Write-Host "Nothing to do"
            Write-iBISSTM1Log -Path $log -Message "Nothing to do."
        }
        else {
            foreach ($todel in $ExpiredLogs) {
                Remove-Item -Path $todel.FullName #-WhatIf
                $deleted = $todel.Name
                Write-Host "`t$($todel.Directory.Name)\$deleted"
                Write-iBISSTM1Log -Path $log -Message "`t$($todel.Directory.Name)\$deleted"
            }
        Write-Host "Deleting expired files finished for $InstanceFilesystemBaseName"
        Write-iBISSTM1Log -Path $log -Message "Deleting expired files finished for $InstanceFilesystemBaseName"
        }
        
        Stop-iBISSTM1Log -Path $log -Task $Task

    }
    elseif ($Task -eq "OfflineBackup") {
        # Setting up Log environment
        #
        $LogPath = "$LogBaseDir\backups"
        $LogName = "$ServiceName-$Task-$date2.log"
        $log     = "$LogPath\$LogName"
        
        # Setting up Backup environment
        #
        $BackupDirDaily = "$BackupBaseDir\daily"
        $BackupDirweekly = "$BackupBaseDir\weekly"
        $BackupDirMonthly = "$BackupBaseDir\monthly"
        $BackupDirYearly = "$BackupBaseDir\yearly"
        $BackupSource = "$InstanceBaseDir\model"
        $BackupTarget = "$ServiceName-$Task-$date1.zip"

        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType "Directory" | Out-Null
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Started Logfile for Task $Task"
            Write-iBISSTM1Warn -Path $log -Message "Logdir not found, creating logdir now."
            Write-iBISSTM1Log -Path $log -Message "Logdir $LogPath created successful."
        }
        else {
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Started Logfile for Task $Task"
        }

        # Check if we run first time and create Backup structure
        #
        if (!(Test-Path $BackupBaseDir)) {
            Write-iBISSTM1Warn -Path $log -Message "Backupdirs not found, creating backupdirs now."
            New-item -Path $BackupBaseDir\daily -ItemType "Directory" | Out-Null
            New-item -Path $BackupBaseDir\monthly -ItemType "Directory" | Out-Null
            Write-iBISSTM1Log -Path $log -Message "Backupdirs in $BackupBaseDir created successful."
        }
        elseif ($weekly -and !(Test-Path $BackupBaseDir\weekly)) {
            New-item -Path $BackupBaseDir\weekly -ItemType "Directory" | Out-Null
            Write-iBISSTM1Log -Path $log -Message "Created additional backupdir for weekly backup successful."
        }
        elseif ($yearly -and !(Test-Path $BackupBaseDir\yearly)) {
            New-item -Path $BackupBaseDir\yearly -ItemType "Directory" | Out-Null
            Write-iBISSTM1Log -Path $log -Message "Created additional backupdir for yearly backup successful."
        }

        # Finaly start offline Backup
        #
        Start-iBISSTM1Backup -Type Offline -Target $BackupDirDaily\$BackupTarget -Source $BackupSource -ServiceName $ServiceName
        
        # First day of year? Copy backup also to yearly and exipre old ones
        #
        if ((Get-Date).DayOfYear -eq "1" -and $yearly -eq "$true") {
            Write-iBISSTM1Log -Path $log -Message "1st day of year detected, creating yearly backup!"
            Copy-Item -Path $BackupDirDaily\$BackupTarget -Destination $BackupDirYearly
            Write-iBISSTM1Log -Path $log -Message "Copied $BackupTarget to $BackupDirYearly"

            $ExpiredYearlys = Get-ChildItem -Path $BackupDirYearly -Filter "*Offline*" | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt $ExpireYearly}
            foreach ($backup in $ExpiredYearlys) {
                Remove-Item -Path $backup.FullName
                $deleted = $backup.Name
                Write-iBISSTM1Log -Path $log -Message "Deleted expired yearly backup:`t$deleted"
            }
        }
        
        # First day of month? Copy backup also to monthly and expire old ones
        #
        if ((Get-Date).Day -eq "1") {
            Write-iBISSTM1Log -Path $log -Message "1st day of month detected, creating monthly backup!"
            Copy-Item -Path $BackupDirDaily\$BackupTarget -Destination $BackupDirMonthly
            Write-iBISSTM1Log -Path $log -Message "Copied $BackupTarget to $BackupDirMonthly"

            $ExpiredMonthlys = Get-ChildItem -Path $BackupDirMonthly -Filter "*Offline*" | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt $ExpireMonthly}
            foreach ($backup in $ExpiredMonthlys) {
                Remove-Item -Path $backup.FullName
                $deleted = $backup.Name
                Write-iBISSTM1Log -Path $log -Message "Deleted expired monthly backup:`t$deleted"
            }
        }

        # Last day of week? Copy backup also to weekly and exipre old ones
        #
        if ((Get-Date).DayOfWeek -eq "Sunday" -and $weekly -eq "$true") {
            Write-iBISSTM1Log -Path $log -Message "Last day of week detected, creating weekly backup!"
            Copy-Item -Path $BackupDirDaily\$BackupTarget -Destination $BackupDirWeekly
            Write-iBISSTM1Log -Path $log -Message "Copied $BackupTarget to $BackupDirWeekly"

            $Expiredweeklys = Get-ChildItem -Path $BackupDirWeekly -Filter "*Offline*" | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt $ExpireWeekly}
            foreach ($backup in $Expiredweeklys) {
                Remove-Item -Path $backup.FullName
                $deleted = $backup.Name
                Write-iBISSTM1Log -Path $log -Message "Deleted expired weekly backup:`t$deleted"
            }
        }

        # Exire old daily backups
        #
        Write-iBISSTM1Log -Path $log -Message "Checking for old Backups to expire..."
        $ExpiredDailys = Get-ChildItem -Path $BackupDirDaily -Filter "*Offline*" | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt $ExpireDaily}
        if ($ExpiredDailys.Length -gt "0") {
            foreach ($backup in $ExpiredDailys) {
                Remove-Item -Path $backup.FullName
                $deleted = $backup.Name
                Write-iBISSTM1Log -Path $log -Message "Deleted expired daily backup:`t$deleted"
            }    
        }
        else {
            Write-iBISSTM1Log -Path $log -Message "No old Backups to expire."
        }
        
        Stop-iBISSTM1Log -Path $log -Task $Task

    }
    elseif ($Task -eq "OnlineBackup") {
        # Setting up Log environment
        #
        $LogPath = "$LogBaseDir\backups"
        $LogName = "$ServiceName-$Task-$date2.log"
        $log = "$LogPath\$LogName"
        
        # Setting up Backup environment
        #
        $BackupDirDaily = "$BackupBaseDir\daily"
        $BackupDirweekly = "$BackupBaseDir\weekly"
        $BackupDirMonthly = "$BackupBaseDir\monthly"
        $BackupDirYearly = "$BackupBaseDir\yearly"
        $BackupSource = "$InstanceBaseDir\model"
        $BackupTarget = "$ServiceName-$Task-$date1.zip"

        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType "Directory" | Out-Null
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Started Logfile for Task $Task"
            Write-iBISSTM1Warn -Path $log -Message "Logdir not found, creating logdir now."
            Write-iBISSTM1Log -Path $log -Message "Logdir $LogPath created successful."
        }
        else {
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Started Logfile for Task $Task"
        }

        # Check if we run first time and create Backup structure
        #
        if (!(Test-Path $BackupBaseDir)) {
            Write-iBISSTM1Warn -Path $log -Message "Backupdirs not found, creating backupdirs now."
            New-item -Path $BackupBaseDir\daily -ItemType "Directory" | Out-Null
            New-item -Path $BackupBaseDir\monthly -ItemType "Directory" | Out-Null
            Write-iBISSTM1Log -Path $log -Message "Backupdirs in $BackupBaseDir created successful."
        }
        elseif ($weekly -and !(Test-Path $BackupBaseDir\weekly)) {
            New-item -Path $BackupBaseDir\weekly -ItemType "Directory" | Out-Null
            Write-iBISSTM1Log -Path $log -Message "Created additional backupdir for weekly backup successful."
        }
        elseif ($yearly -and !(Test-Path $BackupBaseDir\yearly)) {
            New-item -Path $BackupBaseDir\yearly -ItemType "Directory" | Out-Null
            Write-iBISSTM1Log -Path $log -Message "Created additional backupdir for yearly backup successful."
        }

        # Finaly start online Backup
        #
        Start-iBISSTM1Backup -Type Online -Target $BackupDirDaily\$BackupTarget -Source $BackupSource -ServiceName $ServiceName
        
        # First day of year? Copy backup also to yearly and exipre old ones
        #
        if ((Get-Date).DayOfYear -eq "1" -and $yearly -eq "$true") {
            Write-iBISSTM1Log -Path $log -Message "1st day of year detected, creating yearly backup!"
            Copy-Item -Path $BackupDirDaily\$BackupTarget -Destination $BackupDirYearly
            Write-iBISSTM1Log -Path $log -Message "Copied $BackupTarget to $BackupDirYearly"

            $ExpiredYearlys = Get-ChildItem -Path $BackupDirYearly -Filter "*Online*" | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt $ExpireYearly}
            foreach ($backup in $ExpiredYearlys) {
                Remove-Item -Path $backup.FullName
                $deleted = $backup.Name
                Write-iBISSTM1Log -Path $log -Message "Deleted expired yearly backup:`t$deleted"
            }
        }
        
        # First day of month? Copy backup also to monthly and expire old ones
        #
        if ((Get-Date).Day -eq "1") {
            Write-iBISSTM1Log -Path $log -Message "1st day of month detected, creating monthly backup!"
            Copy-Item -Path $BackupDirDaily\$BackupTarget -Destination $BackupDirMonthly
            Write-iBISSTM1Log -Path $log -Message "Copied $BackupTarget to $BackupDirMonthly"

            $ExpiredMonthlys = Get-ChildItem -Path $BackupDirMonthly -Filter "*Online*" | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt "$($ExpireMonthly * 30)"}
            foreach ($backup in $ExpiredMonthlys) {
                Remove-Item -Path $backup.FullName
                $deleted = $backup.Name
                Write-iBISSTM1Log -Path $log -Message "Deleted expired monthly backup:`t$deleted"
            }
        }

        # Last day of week? Copy backup also to weekly and exipre old ones
        #
        if ((Get-Date).DayOfWeek -eq "Sunday" -and $weekly -eq "$true") {
            Write-iBISSTM1Log -Path $log -Message "Last day of week detected, creating weekly backup!"
            Copy-Item -Path $BackupDirDaily\$BackupTarget -Destination $BackupDirWeekly
            Write-iBISSTM1Log -Path $log -Message "Copied $BackupTarget to $BackupDirWeekly"

            $Expiredweeklys = Get-ChildItem -Path $BackupDirWeekly -Filter "*Online*" | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt $ExpireWeekly}
            foreach ($backup in $Expiredweeklys) {
                Remove-Item -Path $backup.FullName
                $deleted = $backup.Name
                Write-iBISSTM1Log -Path $log -Message "Deleted expired weekly backup:`t$deleted"
            }
        }

        # Exire old daily backups
        #
        Write-iBISSTM1Log -Path $log -Message "Checking for old Backups to expire..."
        $ExpiredDailys = Get-ChildItem -Path $BackupDirDaily -Filter "*Online*" | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt $ExpireDaily}
        if ($ExpiredDailys.Length -gt "0") {
            foreach ($backup in $ExpiredDailys) {
                Remove-Item -Path $backup.FullName
                $deleted = $backup.Name
                Write-iBISSTM1Log -Path $log -Message "Deleted expired daily backup:`t$deleted"
            }    
        }
        else {
            Write-iBISSTM1Log -Path $log -Message "No old Backups to expire."
        }
        
        Stop-iBISSTM1Log -Path $log -Task $Task
    
    }

}