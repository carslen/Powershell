[STRING[]]$Location = "C:\sw\mnt\test1\"


$VHDDirs = (Get-ChildItem $Location).FullName 

foreach ($entry in $VHDDirs) 
    {
        $TEMPVHDName = (Get-ChildItem $entry -Recurse | where {($_.Extension -eq ".vhdx") -or ($_.Extenstion -eq ".vhd") -and ($_.BaseName -match "_c") }).BaseName
        if ($TEMPVHDName -cmatch "_c") {
            $VHDName = $TEMPVHDName.Replace("_c","")
            Rename-Item -Path $entry -NewName $VHDName
        }
        else {
            $VHDName = $TEMPVHDName.Replace("_C","")
            Rename-Item -Path $entry -NewName $VHDName
        }
        
        Write-Host "Umbenennen nach $VHDName abgeschlossen!"-ForegroundColor DarkYellow -BackgroundColor DarkGray
    }

# Remove-Variable -Name DPMServer,RecoveryLocationServer,Location,Protectiongroupname,Date,PS,pg,ds,rop,entry,rpl,VHDDirs,RestoreDate,TEMPVHDName


