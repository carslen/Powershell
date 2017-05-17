$cred = Get-Credential -Credential horaios\cle 
New-PSDrive -Name 'RemoteDPM' -PSProvider FileSystem -Root \\pc-w10-01.horaios.local\d$ -Credential $cred -Description 'Remote destination for archiving DB Backups'
New-PSDrive -Name 'Source' -PSProvider FileSystem -Root \\nevada\backup\

$CopyItemsDaily    = Get-ChildItem Source:\Databases\Seattle\Daily | Sort-Object -Property LastWriteTime | Select-Object -Last 1 | Get-ChildItem
$CopyItemsMonthly  = Get-ChildItem Source:\Databases\Seattle\Monthly | Sort-Object -Property LastWriteTime | Select-Object -Last 1 | Get-ChildItem

foreach ($item in $CopyItemsDaily)
{
    Write-Host -ForegroundColor Green Copy Database $item.BaseName to Archive Destination
    Copy-Item -Path $item.FullName -Destination RemoteDPM:\ag\Databases\Seattle\Daily\ -Recurse
}

foreach ($item in $CopyItemsMonthly)
{
    Write-Host -ForegroundColor Green Copy Database $item.BaseName to Archive Destination
    Copy-Item -Path $item.FullName -Destination RemoteDPM:\ag\Databases\Seattle\Monthly -Recurse
}


Copy-Item -Path $CopyItems[0].FullName -Destination RemoteDPM:\ag\Databases\Seattle\ -Recurse

