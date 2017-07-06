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

if ((Get-Date).Day -eq "27") {
    Write-Host "Es ist Monatsanfang, Kopiere nach monthly"
}
else {
    Write-Host "Nix zu tun!"
}

Get-ChildItem -Path "C:\Users\CARSLEN\Downloads" -Filter "*.jnlp" | Where-Object {((Get-Date) - $_.LastWriteTime).Days -gt 2} # | Remove-Item -Recurse -WhatIf

[int]$expire ="10"
(Get-ChildItem -Path "C:\Users\CARSLEN\Downloads" | Where-Object {((Get-Date) - $_.LastWriteTime).days -gt "$($expire * 10)"}).Length # | Remove-Item -Recurse -WhatIf
(Get-ChildItem -Path "C:\Users\CARSLEN\Downloads" | Where-Object {((Get-Date) - $_.LastWriteTime).days -gt "100"}).Length

Start-Transcript

Get-ChildItem -Path C:\Users\CARSLEN\Desktop\Test\ | Where-Object {$_.BaseName -match "itc-int" -and $_.Extension -eq ""}

(Get-ChildItem -Path C:\Users\CARSLEN\Desktop\Test\itc).BaseName

$InstanceName = "itc_int"
$temp = Get-ChildItem -Path C:\Users\CARSLEN\Desktop\Test -Directory
#$temp = Get-ChildItem -Path $BaseDir -Directory
foreach ($dir in $temp) {
    $BaseName = $dir.BaseName
    if ($InstanceName -match $BaseName) {
        Write-Host -ForegroundColor Yellow "Input InstanceName was: " -NoNewline
        Write-Host -ForegroundColor Red "$InstanceName"
        $InstanceName = $BaseName
        Write-Host -ForegroundColor Yellow "Correct InstanceName is: " -NoNewline
        Write-Host -ForegroundColor Green "$InstanceName"
        Break
    }
}
Write-Host -ForegroundColor DarkGreen $BaseName

"ITC" -match "itc_int"
"itc_int" -match "ITC"

$temp[1] -match $InstanceName
$InstanceName -match $temp[1]

[System.Math]::Round(12.12345,2)

(Get-date).DayOfWeek -eq "Wednesday"