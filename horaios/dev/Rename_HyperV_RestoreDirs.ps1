$Basedir = '\\idaho\SCDPM\HyperV02'
$RestoreDirs = Get-ChildItem $Basedir\DPM_*
$RenameDate = Get-Date -Format 'yyyy-MM-dd_HH.mm.ss'
$Date = Get-Date

foreach($_ in $RestoreDirs)
{       
	$almostServerName = get-childitem $_ -include *.vhdx -recurse|select Name -First 1 
	#$almostServerName.Name
	$serverName = $almostServerName.Name.Replace(".vhdx","").Replace("_C","").Replace("_c","")
	#$ServerName
	Rename-Item -Path $_.FullName -NewName "$ServerName $RenameDate" 
}
#Get-ChildItem $Basedir\*


# Delete Restored data older than 7 days
 
Get-ChildItem $Basedir | Where-Object {($Date - $_.LastWriteTime).Days -gt 7} |  Remove-Item -Recurse 