$serverPath = 'C:\Users\canotisbos\AppData\Local\Canotis BOS\Logs\Prod Instance\'
$serverBackup = '\\prolux.de\CanotisBOS\Canotis BOS\Backups\'
$serverNames = @("Server1", "Server2", "TDM", "FileInput", "Worker", "Service")
$pathToRar = "C:\Program Files\WinRAR\rar.exe"

[int] $moveToBackupLimit = 10
[int] $filesToLeave = 10
[int] $packLimit = 90

#region testing

#$serverPath = 'C:\Users\canotisbos\AppData\Local\Canotis BOS\Logs\Prod Instance\'
#$serverBackup = '\\prolux.de\CanotisBOS\Canotis BOS\Backups\'
#$pathToRar = "C:\Program Files\WinRAR\rar.exe"

#endregion

$date = Get-Date -format ddMMyy_H_mm

foreach($server in $serverNames)
{
    $logPath = $serverPath + $server
	$backupPath = $serverBackup + $server
	
    if(!(Test-Path $logPath)) 
    {
        echo "logPath for $server does not exist ($logPath)"
        continue
    }        
    
	$itemsInFolder = (Get-ChildItem $logPath -exclude "*.log" ).Count
	
    if($itemsInFolder -ge $moveToBackupLimit)
    {   		
		if(!(Test-Path $backupPath)){New-Item -Path $backupPath -type directory}
		$foundFiles = (Get-ChildItem -path $logPath -exclude "*.log" | ?{$_.psIsContainer -eq $false}) |  sort LastWriteTime -descending 
		Move-Item $foundFiles[($filesToLeave - 1 )..$foundFiles.Count] -destination $backupPath         			
    }
	else
	{
		echo "Nothing to do for $server. Items: $itemsInFolder"
	}
	
	if((Get-ChildItem $backupPath).Count -ge $packLimit)
	{		
		$packPath = "${backupPath}_${date}"
		New-Item -Path $packPath -type directory
		
		Get-ChildItem $backupPath | mv -Destination $packPath		
		
		#'a' -> archive, '-ep1' -> low priority, '-df' -> delete files after compression
		&$pathToRar 'a' '-ep1' '-df' $packPath ".rar" $packPath
	}
}

[System.Threading.Thread]::Sleep(5000)