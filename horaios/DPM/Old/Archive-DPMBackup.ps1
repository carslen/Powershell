function Start-DPMBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)]  [string]$DPMServer,
        [Parameter(Mandatory=$True,Position=2)]  [ValidateSet("Hyper-V", "iSCSI", "Exchange", "SQL")] [string]$RecoveryType,
        [Parameter(Mandatory=$True,Position=3)]  [string]$ProtectionGroupName,
        [Parameter(Mandatory=$False,Position=4)] [string]$RecoveryLocationServer = "$env:Computername",
        [Parameter(Mandatory=$True,Position=5)]  [string]$ArchiveLocation,
        [Parameter(Mandatory=$False,Position=6)] [ValidateNotNull()] [System.Management.Automation.PSCredential] [System.Management.Automation.Credential()] $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    
    begin {
        $RecoveryLocationServer
        $RecoveryType
        $Date = Get-Date
        Write-Host "Cleanup Archive Location $ArchiveLocation\:" -ForegroundColor Yellow -NoNewline
        if ((Test-Path $ArchiveLocation\*) -eq $False) {
            Write-Host " Noting to do!" -ForegroundColor Green
        }
        else {
            Get-ChildItem "$ArchiveLocation" | Where-Object {($Date - $_.LastWriteTime).Days -gt 6} |  Remove-Item -Recurse -Force 
            Write-Host " Done!" -ForegroundColor Green
        }
        
        Write-Host "Defining restore options" -ForegroundColor Yellow #-NoNewline
         
        Write-Host "Populating Variable 'PS'" -ForegroundColor Gray -NoNewline
        $PS = Get-DPMProductionServer -DPMServerName $DPMServer | Where-Object {$_.ServerName -eq $DPMServer}
        Write-Host " Done!" -ForegroundColor DarkGray 
        
        Write-Host "Validating DPM Datasources" -ForegroundColor Gray -NoNewline
        Get-DPMDatasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null
        Write-Host " Done!" -ForegroundColor DarkGray
        
        Write-Host "Populating Variable 'PG'" -ForegroundColor Gray -NoNewline
        $PG = Get-DPMProtectionGroup -DPMServerName $DPMServer | Where-Object {$_.name -match $ProtectiongroupName}
        Write-Host " Done!" -ForegroundColor DarkGray 
        
        Write-Host "Populating Variable 'DS'" -ForegroundColor Gray -NoNewline
        $DS = Get-DPMDatasource $PG
        Write-Host " Done!" -ForegroundColor DarkGray 
        
        Write-Host "Populating Variable 'ROP'" -ForegroundColor Gray -NoNewline
        if ($RecoveryType -eq "Hyper-V") {
            $ROP = New-DPMRecoveryOption -TargetServer $RecoveryLocationServer  -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetLocation $ArchiveLocation -HyperVDatasource
        }
        elseif ($RecoveryType -eq "iSCSI") {
            $ROP = New-DPMRecoveryOption -FileSystem -OverwriteType Overwrite -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -AlternateLocation $ArchiveLocation -RestoreSecurity
        }
        elseif ($RecoveryType -eq "Exchange") {
            $ROP = New-DPMRecoveryOption -E14Datasource -ExchangeOperationType NoOperation -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -TargetLocation $ArchiveLocation -RestoreSecurity
        }
        elseif ($RecoveryType -eq "SQL") {
            $ROP = New-DPMRecoveryOption -RecoveryLocation CopyToFolder -RecoveryType Restore -SQL -TargetServer $RecoveryLocationServer -TargetLocation $ArchiveLocation
        }
        #$ROP = New-DPMRecoveryOption -TargetServer $RecoveryLocationServer  -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetLocation $ArchiveLocation -HyperVDatasource
        Write-Host " Done!" -ForegroundColor DarkGray
        
        Write-Host "Restore Options defined!" -ForegroundColor Green
    }
    
    process {
        Write-Host "Initializing restore ..." -ForegroundColor Gray
        foreach ($entry in $DS) {
            $rpl = Get-DPMRecoveryPoint -Datasource $entry | Sort-Object -Property BackupTime -Descending | select -First 1
            Restore-DPMRecoverableItem -RecoverableItem $rpl -RecoveryOption $ROP #-WhatIf
        }
        Write-Host "Wait for the last restore to be completed. This may take some time ..." -ForegroundColor Yellow
        
        do {
            Write-Host "." -NoNewline
            start-sleep -Seconds 60
        } while (Get-DPMJob -Datasource $DS -Type Recovery -Status InProgress)
        
        Write-Host ""
        Write-Host "All restore jobs completed! Continuing ..." -ForegroundColor Green 
    }
    
    end {
        if ($RecoveryType -eq "Hyper-V") {
            $VHDDirs = (Get-ChildItem $ArchiveLocation).FullName
            foreach ($entry in $VHDDirs)
            {
                $TEMPVHDName = (Get-ChildItem $entry -Recurse | Where-Object {($_.Extension -eq ".vhdx") -or ($_.Extenstion -eq ".vhd") -and ($_.BaseName -match "_c$") }).BaseName
                if ($TEMPVHDName -cmatch "_c") {
                    $VHDName = $TEMPVHDName.Replace("_c","")
                    Rename-Item -Path $entry -NewName $VHDName 
                }
                else {
                    $VHDName = $TEMPVHDName.Replace("_C","")
                    Rename-Item -Path $entry -NewName $VHDName
                }
                Write-Host "Renaming of Restore Dir to  $VHDName completed!"-ForegroundColor Green
            }
        }
        elseif ($RecoveryType -eq "Exchange") {
            $DBDirs = (Get-ChildItem $ArchiveLocation).FullName
            foreach ($entry in $DBDirs)
            {
                $DBName = (Get-ChildItem $entry -Recurse | Where-Object {$_.Extension -eq '.edb'}).BaseName
                Rename-Item -Path $entry -NewName $DBName
                Write-Host "Umbenennen nach $DBName abgeschlossen!"-ForegroundColor DarkYellow -BackgroundColor DarkGray
            }
            
        }
        elseif ($RecoveryType -eq "SQL") {
            $DBDirs = (Get-ChildItem $ArchiveLocation).FullName
            foreach ($entry in $DBDirs)
            {
                $TEMPDBName = (Get-ChildItem $entry -Recurse| Where-Object {$_.Extension -eq ".mdf"}).Basename
                $DBName = $TEMPDBName.Replace("_Primary","")
                Rename-Item -Path $entry -NewName $DBName
                Write-Host "Umbenennen nach $DBName abgeschlossen!"-ForegroundColor DarkYellow -BackgroundColor DarkGray
            }
        }
        
        Write-Host "Job finished!" -ForegroundColor darkYellow -BackgroundColor DarkCyan
    }
}

