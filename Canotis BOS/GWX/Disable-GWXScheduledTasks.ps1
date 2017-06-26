$task = Get-ScheduledTask -TaskPath \microsoft\windows\Setup\GWX\
#$tasktrigger = Get-ScheduledTask -TaskPath \microsoft\windows\Setup\GWXTriggers\

Get-Process -Name "GWX*" | Stop-Process

foreach ($item in $task)
{
   if ($item.State -ne "Disabled")
   {
       Disable-ScheduledTask -InputObject $item
   }
   
}


<#

foreach ($item in $tasktrigger)
{
    Disable-ScheduledTask -InputObject $item
}

#>