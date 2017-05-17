$BackupDBs = Get-SqlDatabase -ServerInstance SEATTLE | Where-Object {($_.Name -ne "master") -and ($_.Name -ne "model") -and ($_.Name -ne "tempdb") -and ($_.Name -ne "msdb")}


if ((get-date).Day -gt 1)
{
    $BackupBase = "D:\Backups\Daily\"
    foreach ($item in $BackupDBs)
    {
        <#
        # Backuppfad prüfen und ggf. erstellen.
        #>
    
        $BackupPath = $BackupBase + $item.Name
        if (Test-Path $BackupPath)
        {
            Write-Host -ForegroundColor Green "Pfad für Datenbanksicherung schon vorhanden!"
        }
        else
        {
            Write-Host -ForegroundColor Red "Erstelle Pfad $BackupPath für Datenbanksicherung, da Pfad nicht vorhanden!"
            New-Item -Path $BackupPath -ItemType Directory
        }

        if ($item.RecoveryModel -eq "Simple")
        {
            Backup-SqlDatabase -Database $item.Name -ServerInstance SEATTLE -BackupContainer $BackupPath -CompressionOption On 
        }
        else
        {
            Backup-SqlDatabase -Database $item.Name -ServerInstance SEATTLE -BackupContainer $BackupPath -BackupAction Log -CompressionOption On 
            Backup-SqlDatabase -Database $item.Name -ServerInstance SEATTLE -BackupContainer $BackupPath -CompressionOption On
        }
    
    }
}
else
{
    $BackupBase = "D:\Backups\Monthly\"
    foreach ($item in $BackupDBs)
    {
        <#
        # Backuppfad prüfen und ggf. erstellen.
        #>
    
        $BackupPath = $BackupBase + $item.Name
        if (Test-Path $BackupPath)
        {
            Write-Host -ForegroundColor Green "Pfad für Datenbanksicherung schon vorhanden!"
        }
        else
        {
            Write-Host -ForegroundColor Red "Erstelle Pfad $BackupPath für Datenbanksicherung, da Pfad nicht vorhanden!"
            New-Item -Path $BackupPath -ItemType Directory
        }

        if ($item.RecoveryModel -eq "Simple")
        {
            Backup-SqlDatabase -Database $item.Name -ServerInstance SEATTLE -BackupContainer $BackupPath -CompressionOption On 
        }
        else
        {
            Backup-SqlDatabase -Database $item.Name -ServerInstance SEATTLE -BackupContainer $BackupPath -BackupAction Log -CompressionOption On 
            Backup-SqlDatabase -Database $item.Name -ServerInstance SEATTLE -BackupContainer $BackupPath -CompressionOption On
        }
    
    }
}






