$BaseDir = Z:
$BOSInstanceNames = (Get-ChildItem "$BaseDir\users\canotisit\AppData\Local\Canotis BOS\Logs").FullName
$date = get-date -Format yyyyMMdd

[int] $moveToBackupLimit = 10
[int] $filesToLeave = 10
[int] $packLimit = 90


# Manage ZIP Files (Package) with the Windows-Shell COM Object
# This works native from Windows XP, Vista, Windows 7 and dont need any additional Module or executeable!
# The Windows Shell treads a Zip-File like a Filesystem Folder
# Documentation of the Shell Object (COM):
# http://msdn.microsoft.com/en-us/library/windows/desktop/bb774094(v=vs.85).aspx
# Documentation of the Folder Object (COM):
# http://msdn.microsoft.com/en-us/library/windows/desktop/bb787868(v=vs.85).aspx
 
#David Aiken: Compress Files with Windows PowerShell then package a Windows Vista Sidebar Gadget
#http://blogs.msdn.com/b/daiken/archive/2007/02/12/compress-files-with-windows-powershell-then-package-a-windows-vista-sidebar-gadget.aspx
 
#Michal Gajda: From PS to Zip
#http://commandlinegeeks.com/2011/03/05/from-ps-to-zip/
 
#ZIP-Dateien mit Powershell Bordmitteln erzeugen und bearbeiten
#http://newyear2006.wordpress.com/2011/05/20/zip-dateien-mit-powershell-bordmitteln-erzeugen-und-bearbeiten/
 
 
Function Add-Zip {
      # Add one or more Files to the ZIP Package
  param
  (
    [array]$PackFilesPath,
    [string]$DestinationZipPath
  )
 
  # Create the ZIP File if it is not existing
  if(-not (Test-Path ($DestinationZipPath))) {
      # Write ZIP File-header to File
      Set-Content $DestinationZipPath (“PK”+ [char]5 + [char]6 + (“$([char]0)”* 18))
  }
 
  # remove read only flag from File
  $zip = Get-Item $DestinationZipPath
  $zip.IsReadOnly = $false
  # we need the Fullpath to the File
  $DestinationZipPath = $zip.FullName
  # Create the Shell COM Object
  $ShellApplication = New-Object -ComObject Shell.Application
  # Create the COM Folder Object from ZIP File
  $ZipFolder = $ShellApplication.NameSpace($DestinationZipPath)
 
  # Process Files given with the as Parameter Argument
  # Pack file(s) into ZIP Package
  If($PackFilesPath) {
        Foreach($File in $PackFilesPath) {
        # Pack file into Package
            $ZipFolder.CopyHere($File)
            # Try to wait to finish the copy action
            Start-sleep -milliseconds 500
      }
  }
 
  # Process Files comming from Pipeline $input.
  # Pack file(s) into ZIP Package
  If($input) {
    Foreach($file in $input) {
        # Pack file into Package
      $ZipFolder.CopyHere($file.FullName)
        # Try to wait to finish the copy action
      Start-sleep -milliseconds 500
    }
  }
}


foreach($item in $BOSInstanceNames){
    $BosInstanceServers = ((Get-ChildItem $item).FullName)

    foreach($entry in $BosInstanceServers){
       $ItemsInFolder = (Get-ChildItem $entry -Exclude "*.log").Count
       if($ItemsInFolder -ge $moveToBackupLimit){
            if(!(Test-Path $entry\backup)){new-item $entry\backup -ItemType Directory}
            $foundFiles = Get-ChildItem $entry -Exclude "*.log" | Where-Object {$_.psIsContainer -eq $false} | Sort-Object LastWriteTime -Descending
            Move-Item $foundFiles[($filesToLeave - 1)..$foundFiles.Count] -Destination $entry\backup
         
       }
       else{
            Write-Host "Nichts zu für Server "$entry" aus Instanz "$item""
       }
       if((Get-ChildItem $entry\backup).Count -ge $packLimit){
            $CompressFile = "LogFiles_${date}.zip"
            Add-Zip $entry\backup\ $entry\backup\$CompressFile
            Remove-Item $entry\backup\* -Exclude $CompressFile -Force
       }
            
    }
}
