Param (
    [Parameter(Mandatory=$true,Position=1)][ValidateSet("CopyLogs", "ExpireLogs", "OfflineBackup", "OnlineBackup")] [string[]]$Task,
    [Parameter(Mandatory=$true,Position=2)][ValidateNotNull()] [string[]]$InstanceName
)

# Load functions using dot sourcing
#
. "C:\Users\CARSLEN\Documents\git\Powershell\iBISS TM1\iBISS-TM1-Functions.ps1"
$date1   = Get-Date -UFormat "%Y-%m-%d"
$date2   = Get-Date -Uformat "%Y-%m-%d_%H%M%S"
$BaseDir = "C:\Users\CARSLEN\Desktop\Test"          # Muss gelöscht werden, wenn das Script in den Template-Ordner wandert/produktiv geht
#$BaseDir = "D:\TM1"                                # Muss aktiviert werden, wenn das Script in den Template-Ordner wandert/produktiv geht

#if (!(Get-Service -Name $InstanceName -ErrorAction SilentlyContinue)) {
if (!(Get-Service -Name wuauserv -ErrorAction SilentlyContinue)) { # wuauserv durch $InstanceName ersetzen auf TM1 Maschinen!
    Write-Warning -Message "Service ""$InstanceName"" doesn't exists!"
    Break
}
else {
    if ($Task -eq "CopyLogs") {
        # Setting up Log environment
        #
        $LogPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\logfiles"
        $LogName = "$InstanceName-CopyLogs-$date2.log"
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
    }
    elseif ($Task -eq "ExpireLogs") {
        # Setting up Log environment
        #
        $LogPath = "$BaseDir\$InstanceName\logs\exirelogs"
        $LogName = "$InstanceName-$Task-$date2.log"
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
    }
    elseif ($Task -eq "OfflineBackup") {
        # Setting up Log environment
        #
        $LogPath = "$BaseDir\$InstanceName\logs\backups"
        $LogName = "$InstanceName-$Task-$date2.log"
        $log     = "$LogPath\$LogName"

        # Setting up Backup environment
        #
        $BackupSource = "$BaseDir\$InstanceName\model\"
        $BackupTarget = "$BaseDir\$InstanceName\backups\$InstanceName-$Task-$date2.zip"
        
        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType "Directory" | Out-Null
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Started Logfile for Task $Task"
            Write-iBISSTM1Warn -Path $log -Message "Logdir not found, creating logdir now."
        }
        else {
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Started Logfile for Task $Task"
        }

        # Check if we run first time and create Backup structure
        #
        if (!(Test-Path $BaseDir\$InstanceName\backups)) {
            Write-iBISSTM1Warn -Path $log -Message "Backupdir not found, creating backupdir now."
            New-item -Path $BaseDir\$InstanceName\backups -ItemType "Directory" | Out-Null
            Write-iBISSTM1Log -Path $log -Message "Backupdir $BaseDir\$InstanceName\backups created successful."
        }

        # Finaly start offline Backup
        #
        Start-iBISSTM1Backup -Type Offline -Target $BackupTarget -Source $BackupSource

    }
    elseif ($Task -eq "OnlineBackup") {
        # Setting up Log environment
        #
        $LogPath = "$BaseDir\$InstanceName\logs\backups"
        $LogName = "$InstanceName-$Task-$date2.log"
        $log     = "$LogPath\$LogName"
        
        # Setting up Backup environment
        #
        $BackupBaseDir    = "$BaseDir\$InstanceName\backups"
        $BackupDirDaily   = "$BackupBaseDir\daily"
        $BackupDirMonthly = "$BackupBaseDir\monthly"
        $BackupSource     = "$BaseDir\$InstanceName\model\"
        $BackupTarget     = "$InstanceName-$Task-$date1.zip"

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

        # Finaly start offline Backup
        #
        Start-iBISSTM1Backup -Type Online -Target $BackupDirDaily\$BackupTarget -Source $BackupSource
        
        # First day in month? Copy backup also to monthly and expire old ones
        #
        if ((Get-Date).Day -eq "1") {
            Write-iBISSTM1Log -Path $log -Message "1st day of month detected, creating monthly backup!"
            Copy-Item -Path $BackupDirDaily\$BackupTarget -Destination $BackupDirMonthly
            Write-iBISSTM1Log -Path $log -Message "Copied $BackupTarget to $BackupDirMonthly"

            $ExpiredMonthlys = Get-ChildItem -Path $BackupDirMonthly | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt 190}
            foreach ($backup in $ExpiredMonthlys) {
                Remove-Item -Path $backup.FullName
                Write-iBISSTM1Log -Path $log -Message "Deleted expired monthly backup $backup.BaseName"          
            }
        }

        # Exire old daily backups
        #
        Write-iBISSTM1Log -Path $log -Message "Checking for old Backups to expire..."
        $ExpiredDailys   = Get-ChildItem -Path $BackupDirDaily | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt 13}
        if ($ExpiredDailys.Length -gt "0") {
            foreach ($backup in $ExpiredDailys) {
                Remove-Item -Path $backup.FullName
                Write-iBISSTM1Log -Path $log -Message "Deleted expired daily backup $backup.BaseName"          
            }    
        }
        else {
            Write-iBISSTM1Log -Path $log -Message "No old Backups to expire."
        }
        
    }

}