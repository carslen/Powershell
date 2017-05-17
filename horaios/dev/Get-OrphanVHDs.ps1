[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$VHDPath
)

$vmVHds = get-vm | foreach{($_.Harddrives).Path}
$fsVHDs = Get-ChildItem $VHDPath -File -Recurse| where {$_.Extension -eq ".vhd" -or $_.Extension -eq ".vhdx"} | foreach {(get-vhd $_.Fullname).Path}

foreach($item in $fsVHds){
    if
        ($vmVHDs -contains $item)
        {Write-Host -NoNewline Kann nicht gelöscht werden: 
         Write-Host -ForegroundColor Red $item}
      else
        {Write-Host -NoNewline Kann gelöscht werden:
         Write-Host -ForegroundColor Green $item}
}