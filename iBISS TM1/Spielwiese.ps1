get-childitem $env:ProgramFiles\7-zip\7z.exe


if (Test-Path -Path $env:ProgramFiles\7-zip\7z.exe) {
    Set-Alias 7z "$env:ProgramFiles\7-zip\7z.exe"
    $target = "C:\Users\CARSLEN\Desktop\Test\instanceTest\backups\backup2.zip"
    $source = "C:\Users\CARSLEN\Desktop\Test\instanceTest\model\"
    $log    = "C:\Users\CARSLEN\Desktop\Test\instanceTest\logs\backups\instanceTest-OnlineBackup-2017-06-27-2.log"
    #7z a -r $target $source >> $log # Offline Backup
    #7z a -tzip "$target" "$source" -xr!*.cub -xr!*.sub -xr!*.vue  >> $log # Online Backup
    7z a -tzip '-xr!*.cub' '-xr!*.sub' '-xr!*.vue' $target $source >> $log # Online Backup
    #7z a -r C:\Users\CARSLEN\Desktop\Test\instanceTest\backup.zip C:\Users\CARSLEN\Desktop\Test\instanceTest\model\
    Write-Host -ForegroundColor Yellow $LASTEXITCODE
}

"%BCKP_ZIPPER%" %BCKP_ZIPPER_OPTS% "%BCKP_FILENAME%" "%BCKP_SOURCE%\*" 2>&1 >>"%BCKP_LOGFILE%"

