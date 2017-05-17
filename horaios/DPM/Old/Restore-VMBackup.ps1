function Restore-VMBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)]  [string]$DPMServer,
        [Parameter(Mandatory=$True,Position=2)]  [string]$ProtectionGroupName,
        [Parameter(Mandatory=$False,Position=3)] [string]$RecoveryLocationServer = "$env:Computername",
        [Parameter(Mandatory=$True,Position=4)]  [string]$ArchiveLocation
    )
    
    begin {
        $RecoveryLocationServer
        $Date = Get-Date
        Write-Host "Cleanup Archive Location $ArchiveLocation\:" -ForegroundColor Yellow -NoNewline
        if ((Test-Path $ArchiveLocation\*) -eq $False) {
            Write-Host " Noting to do!" -ForegroundColor Green
        }
        else {
            Get-ChildItem "$ArchiveLocation" | Where-Object {($Date - $_.LastWriteTime).Days -gt 6} |  Remove-Item -Recurse
            Write-Host " Done!" -ForegroundColor Green
        }
        
        Write-Host "Defining restore options" -ForegroundColor Yellow #-NoNewline
         
        Write-Host "Populating Variable 'PS'" -ForegroundColor Gray -NoNewline
        $PS=Get-DPMProductionServer -DPMServerName $DPMServer | where {$_.servername -eq $DPMServer}
        Write-Host " Done!" -ForegroundColor DarkGray 
        
        Get-DPMDatasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null
        
        Write-Host "Populating Variable 'PG'" -ForegroundColor Gray -NoNewline
        $PG = Get-DPMProtectionGroup -DPMServerName $DPMServer | where {$_.name -match $ProtectiongroupName}
        Write-Host " Done!" -ForegroundColor DarkGray 
        
        Write-Host "Populating Variable 'DS'" -ForegroundColor Gray -NoNewline
        $DS = Get-DPMDatasource $PG
        Write-Host " Done!" -ForegroundColor DarkGray 
        
        Write-Host "Populating Variable 'ROP'" -ForegroundColor Gray -NoNewline
        $ROP = New-DPMRecoveryOption -TargetServer $RecoveryLocationServer  -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetLocation $ArchiveLocation -HyperVDatasource
        Write-Host " Done!" -ForegroundColor DarkGray
        
        Write-Host " Restore Options defined!" -ForegroundColor Green
    }
    
    process {
        Write-Host "Initializing VM restore ..." -ForegroundColor Gray
        foreach ($entry in $DS) {
            $rpl = Get-DPMRecoveryPoint -Datasource $entry | Sort-Object -Property BackupTime -Descending | select -First 1
            Restore-DPMRecoverableItem -RecoverableItem $rpl -RecoveryOption $rop 
        }
        Write-Host "Wait for the last restore to be completed. This may last some time ..." -ForegroundColor Yellow
        
        do {
            Write-Host "." -NoNewline
            start-sleep -Seconds 60
        } while (Get-DPMJob -Datasource $ds -Type Recovery -Status InProgress)
        
        Write-Host ""
        Write-Host "Restore of all VMs completed! Continuing ..." -ForegroundColor Green 
    }
    
    end {
        $VHDDirs = (Get-ChildItem $ArchiveLocation).FullName
        foreach ($entry in $VHDDirs)
        {
            $TEMPVHDName = (Get-ChildItem $entry -Recurse | where {($_.Extension -eq ".vhdx") -or ($_.Extenstion -eq ".vhd") -and ($_.BaseName -match "_c$") }).BaseName
            if ($TEMPVHDName -cmatch "_c") {
                $VHDName = $TEMPVHDName.Replace("_c","")
                Rename-Item -Path $entry -NewName $VHDName -WhatIf
            }
            else {
                $VHDName = $TEMPVHDName.Replace("_C","")
                Rename-Item -Path $entry -NewName $VHDName -WhatIf
            }
            Write-Host "Renaming of Restore Dir to  $VHDName completed!"-ForegroundColor Green 
        }
        Write-Host "Job finished!" -ForegroundColor darkYellow -BackgroundColor DarkCyan
    }
}

