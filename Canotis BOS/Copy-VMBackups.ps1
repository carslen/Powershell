function Copy-VMBackups {
#    
#    Param(
#        # TargetComp gibt den oder die abzufragenden Computersysteme an
#        [string[]]$VM = "DC" # Standard-Wert, wenn nichts anderes angegeben
#    )
#    
    $Cred = Get-Credential -Credential horaios\cleadm 
    
    Write-Host -ForegroundColor Yellow "Mounting Source and Target Filesystems"
    New-PSDrive -Name 'Remote' -PSProvider FileSystem -Root \\horaios23-2.horaios.local\g$ -Credential $Cred -Description 'Remote destination for archiving DB Backups'
    New-PSDrive -Name 'Source' -PSProvider FileSystem -Root \\nevada\backup\ -Description 'Source of DB Backups'

    $VM = @("DC","DC2","Austin","WSUS")
    #$VM = @("Vorlagen","trashbox")

    foreach ($item in $VM)
    {
        if ((Test-Path -Path Remote:\AG\WindowsImageBackup\$item) -eq $true)
        {
            Write-Host -ForegroundColor DarkGray "Remove existing directory $item"
            Remove-Item -Path Remote:\AG\WindowsImageBackup\$item -Recurse 
        }

        Write-Host -ForegroundColor DarkGray "Copy $item to archive location " -NoNewline
        Copy-Item -Path Source:\WindowsImageBackup\$item -Destination Remote:\AG\WindowsImageBackup\ -Recurse 
        Write-Host -ForegroundColor Green "... Done" 
    }

    Remove-PSDrive -Name Remote,Source
}