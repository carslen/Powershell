Param (
    [Parameter(Mandatory=$true,Position=1)][ValidateSet("CopyLogs", "PurgeBackup", "PurgeLogs", "OfflineBackup", "OnlineBackup")] [string[]]$Task,
    [Parameter(Mandatory=$true,Position=2)][ValidateNotNull()] [string[]]$InstanceName #= "testInstance"
)


. "C:\Users\CARSLEN\Documents\git\Powershell\iBISS TM1\iBISS-TM1-Functions.ps1"
$date1   = Get-Date -UFormat "%Y-%m-%d"
$date2   = Get-Date -Uformat "%Y-%m-%d_%H%M%S"
$BaseDir = "C:\Users\CARSLEN\Desktop\Test"

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
            Write-Host -ForegroundColor Yellow "Creating logdirs for Task:"$Task" ... " -NoNewline
            New-Item -Path $LogPath -ItemType "Directory" | Out-Null
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Write-Host -ForegroundColor Green "Done!"
            Start-iBISSTM1Log -Path $log -Task $Task
            Write-iBISSTM1Log -Path $log -Message "Created logdirs for Task $Task"
        }
        else {
            New-Item -Name $LogName -Path $LogPath -ItemType "file"
            Start-iBISSTM1Log -Path $log -Task $Task
        }
    }
    <#elseif ($Task -eq "PurgeBackup") {
        # Setting up Log environment
        #
        $LogPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\backups"
        $LogName = "$InstanceName-PurgeBackup-$date1.log"
        $log     = "$LogPath\$LogName"

        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType "Directory" | Out-Null
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
        }
        else {
            New-Item -Name $LogName -Path $LogPath -ItemType "file"
            Start-iBISSTM1Log -Path $log -Task $Task
        }
    }#>
    elseif ($Task -eq "PurgeLogs") {
        # Setting up Log environment
        #
        $LogPath = "C:\Users\CARSLEN\Desktop\Test\$InstanceName\logs\logfiles"
        $LogName = "$InstanceName-PurgeLogs-$date1.log"
        $log     = "$LogPath\$LogName"

        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType "Directory" | Out-Null
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
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
        }
        else {
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
        }

        # Check if we run first time and create Backup structure
        #
        if (!(Test-Path $BaseDir\$InstanceName\backups)) {
            Write-iBISSTM1Warn -Path $log -Message "Backupdir not found, will create backupdir now."
            New-item -Path $BaseDir\$InstanceName\backups -ItemType "Directory" | Out-Null
            Write-iBISSTM1Log -Path $log -Message "Backupdir $BaseDir\$InstanceName\backups created successful."
        }

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
        $BackupSource = "$BaseDir\$InstanceName\model\"
        $BackupTarget = "$BaseDir\$InstanceName\backups\$InstanceName-$Task-$date2.zip"

        # Check if we run first time and create Log structure, else create new logfile only
        #
        if (!(Test-Path $LogPath)) {
            New-Item -Path $LogPath -ItemType "Directory" | Out-Null
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
        }
        else {
            New-Item -Name $LogName -Path $LogPath -ItemType "file" | Out-Null
            Start-iBISSTM1Log -Path $log -Task $Task
        }

        # Check if we run first time and create Backup structure
        #
        if (!(Test-Path $BaseDir\$InstanceName\backups)) {
            Write-iBISSTM1Warn -Path $log -Message "Backupdir not found, will create backupdir now."
            New-item -Path $BaseDir\$InstanceName\backups -ItemType "Directory" | Out-Null
            Write-iBISSTM1Log -Path $log -Message "Backupdir $BaseDir\$InstanceName\backups created successful."
        }

        Start-iBISSTM1Backup -Type Online -Target $BackupTarget -Source $BackupSource
        
    }

}