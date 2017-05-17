$HyperVHost = 'HyperV02.horaios.local' 
$LXServer = Get-VM -ComputerName $HyperVHost | where {$_.Name -match 'LX'} | Select-Object -ExpandProperty Name
$LXServer
Stop-VM -ComputerName $HyperVHost -Name $LXServer -WhatIf

$VMId = (Get-VM -ComputerName $HyperVHost -Name $LXServer).VMId

(Get-VHD -ComputerName $HyperVHost -VMId $VMId).Path

Start-VM -ComputerName $HyperVHost -Name $LXServer