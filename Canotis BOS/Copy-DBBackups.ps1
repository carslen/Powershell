function Copy-DBBackups {
    
    Param(
        # TargetComp gibt den oder die abzufragenden Computersysteme an
        [string[]]$DBHost = "Seattle" # Standard-Wert, wenn nichts anderes angegeben
    )
    
    $User = Read-Host -Prompt "Please enter your Admin Username"
    $cred = Get-Credential -Credential horaios\$User
    $Date = Get-Date
    Write-Host -ForegroundColor Cyan Mounting Source and Target Filesystems
    New-PSDrive -Name 'Remote' -PSProvider FileSystem -Root \\horaios23-2.horaios.local\G$ -Credential $cred -Description 'Remote destination for archiving DB Backups'
    New-PSDrive -Name 'Source' -PSProvider FileSystem -Root \\nevada\backup\ -Description 'Source of DB Backups'
    
    if ($DBHost -match '[Ss]eattle')
    {
         $CopyItemsDaily    = Get-ChildItem Source:\Databases\$DBHost\Daily | Sort-Object -Property LastWriteTime | Select-Object -Last 1 | Get-ChildItem
         $CopyItemsMonthly  = Get-ChildItem Source:\Databases\$DBHost\Monthly | Sort-Object -Property LastWriteTime | Select-Object -Last 1 | Get-ChildItem
         
         Write-Host -ForegroundColor DarkGray "Cleanup Destination Daily " -NoNewline
         if ((Test-Path -Path Remote:\AG\Databases\$DBHost\Daily) -eq $true)
         {
             Get-ChildItem Remote:\AG\Databases\$DBHost\Daily | Where-Object {($Date - $_.LastWriteTime).Days -gt 1} | Remove-Item -Recurse -Force
         }
         Write-Host -ForegroundColor Green "... Done!"
         
         Write-Host -ForegroundColor DarkGray "Cleanup Destination Monthly " -NoNewline
         if ((Test-Path -Path Remote:\AG\Databases\$DBHost\Monthly) -eq $true)
         {
             Get-ChildItem Remote:\AG\Databases\$DBHost\Monthly| Where-Object {($Date - $_.LastWriteTime).Days -gt 1} | Remove-Item -Recurse -Force
         }
         Write-Host -ForegroundColor Green "... Done."

         foreach ($item in $CopyItemsDaily) 
         {
             $DBName = $item.BaseName
             Write-Host -ForegroundColor DarkGray -NoNewline "Copy Database $DBName to daily archive destination "
             Copy-Item -Path $item.FullName -Destination Remote:\ag\Databases\$DBHost\Daily\ -Recurse
             Write-Host -ForegroundColor Green "... Done."
         }
     
         foreach ($item in $CopyItemsMonthly) 
         {
             $DBName = $item.BaseName
             Write-Host -ForegroundColor DarkGray -NoNewline "Copy Database $DBName to monthly archive destination "
             Copy-Item -Path $item.FullName -Destination Remote:\AG\Databases\$DBHost\Monthly -Recurse
             Write-Host -ForegroundColor Green "... Done."
         }

    }
    else
    {
        $AustinDBs = Get-ChildItem Source:\Databases\$DBHost\
        
        foreach ($item in $AustinDBs)
        {
            $DBName = $item.BaseName
            $DBPath = "Remote:\AG\Databases\$DBHost\$DBName"

            Get-ChildItem $DBPath | Where-Object {($Date - $_.LastWriteTime).Days -gt 1} | Remove-Item -Recurse -Force

            if ((Test-Path -Path $DBPath) -eq $false)
            {
                New-Item -Path $DBPath -ItemType Directory
            }

            Write-Host -ForegroundColor DarkGray "Copy $DBHost Database $DBName to Archive Destination " -NoNewline
            Get-ChildItem $item.FullName | Where-Object {$_.LastWriteTime -gt (Get-Date).Date} | Copy-Item -Destination $DBPath
            Write-Host -ForegroundColor Green "... Done."
        }

    }
    
    Write-Host -ForegroundColor Cyan "Umounting PSDrives."
    Remove-PSDrive -Name Remote,Source
    Write-Host -ForegroundColor Green "Job done."
}

#$VMs = @("DC","DC2","AUSTIN","WSUS")
#
#foreach ($item in $VMs)
#{
#    if ((Test-Path -Path Remote:\AG\WindowsImageBackup\$item) -eq $true)
#    {
#        Remove-Item -Path Remote:\AG\WindowsImageBackup\$item -Recurse
#    }
#    
#    Copy-Item -Path Source:\WindowsImageBackup\$item -Destination Remote:\AG\WindowsImageBackup\ -Recurse
#}
