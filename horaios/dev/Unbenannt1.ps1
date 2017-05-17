$vhd = Get-ChildItem D:\temp -File | where {$_.Extension -eq ".vhd" -or $_.Extension -eq ".vhdx"} | foreach {get-vhd $_.Fullname}

foreach($item in $vhd){
    if 
        (!$item.Attached)
        {Remove-Item $item.Path -WhatIf}
      else
        {Write-Host Nüscht zu tun für $item.Path!}
}