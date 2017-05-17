Enter-PSSession -ComputerName hyperv-test -Credential horaios\cleadm
$Policy = New-WBPolicy
$VolumeBackupLocation = New-WBBackupTarget -VolumePath D:
#$VolumeBackupLocation = New-WBBackupTarget -NetworkPath \\nevada\Backup\cle
$VirtualMachines = Get-WBVirtualMachine | Where-Object {$_.VMName -eq 'DC1'} #-or $_.VMName -eq 'Austin'}
Add-WBBackupTarget -Policy $Policy -Target $VolumeBackupLocation
Add-WBVirtualMachine -Policy $Policy -VirtualMachine $VirtualMachines
#Set-WBSchedule -Policy $Policy -Schedule ""
Set-WBVssBackupOption -Policy $Policy -VssFullBackup
Start-WBBackup -Policy $Policy
Exit-PSSession