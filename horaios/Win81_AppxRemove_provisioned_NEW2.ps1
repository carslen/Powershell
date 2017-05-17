#Requires -RunAsAdministrator

[String[]]$AppxName = @()

Write-Host -ForegroundColor Green "Collecting provisioned Apps ..."

[String[]]$AppList = (Get-AppxProvisionedPackage -Online | 
            Where-Object {
                ($_.DisplayName -notmatch "LenovoCompanion") -and
                ($_.DisplayName -notmatch "LenovoSupport") -and
                ($_.DisplayName -notmatch "LenovoSettings") -and
                ($_.DisplayName -ne "Microsoft.Appconnector") -and
                ($_.DisplayName -ne "Microsoft.Getstarted") -and
                ($_.DisplayName -ne "Microsoft.Windows.Photos") -and
                ($_.DisplayName -ne "Microsoft.WindowsAlarms") -and
                ($_.DisplayName -ne "Microsoft.WindowsCamera") -and 
                ($_.DisplayName -ne "Microsoft.WindowsCalculator") -and
                ($_.DisplayName -ne "Microsoft.WindowsMaps") -and
                ($_.DisplayName -ne "Microsoft.WindowsPhone") -and
                ($_.DisplayName -ne "Microsoft.WindowsReadingList") -and
                ($_.DispalyName -ne "Microsoft.WindowsScan") -and 
                ($_.DisplayName -ne "Microsoft.WindowsSoundRecorder") -and
                ($_.DisplayName -ne "Microsoft.WindowsStore") -and
                ($_.DisplayName -ne "Microsoft.ZuneMusic") -and
                ($_.DisplayName -ne "Microsoft.ZuneVideo")}).DisplayName

if ($AppList.Count -gt 0)
{
    foreach ($item in $AppList)
    {
        $title   = " "
        $message = "Do you want to remove $item from this PC?"
    
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Removes the App from this PC"
        $no  = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Retains the App on this PC."
    
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    
        $result = $host.ui.PromptForChoice($title, $message, $options, 1) 
    
        switch ($result)
        {
            0 {$AppxName += ,"$item"}
        }
    }
}
else
{
    Write-Host -ForegroundColor Green "Nichts zu tun!"
}

Write-Host -ForegroundColor 'Red' Folgende Apps wurden zur Deinstallation markiert:
foreach ($item in $AppxName)
{
    Write-Host -ForegroundColor Gray $item.Replace("."," ")
}

Write-Host ""

$start = Read-Host -Prompt "Are you sure (y/n)?"

Write-Host -ForegroundColor Green "Extracting Appx Packagenames."
 
foreach ($App in $AppxName)
{
    [string[]]$AppxPackageName += (Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$App"}).PackageName
    #Write-Host -NoNewLine "."
    Write-Host $AppxPackageName.Count / $AppxName.Count
}

Write-Host -ForegroundColor Green "Finished"
Write-Host ""

if ($start -eq "y")
{
    foreach ($item in $AppxPackageName)
    {
        Write-Host -ForegroundColor Red Removing provisioned Appx $item.Replace("."," ") ...
        Remove-AppxProvisionedPackage -Online -PackageName $item  
        Write-Host -ForegroundColor Green " Done!"
    }
}
else
{
    if ($Start -ne "n")
    {
        Write-Host -ForegroundColor Red "'y' or 'n' expected, aborting..."
    }
    else
    {
        Write-Host -ForegroundColor Red "Canceled..!"
    }
}