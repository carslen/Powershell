Get-AppxProvisionedPackage -Online | Select-Object -Property displayName

$Apps = "Microsoft.BingFinance",
        "Microsoft.BingFoodAndDrink",
        "Microsoft.BingHealthAndFitness",
        "Microsoft.BingNews",
        "Microsoft.BingSports",
        "Microsoft.BingTravel",
        "Microsoft.SkypeApp",
        "Microsoft.XboxLIVEGames",
        "Microsoft.Reader"

Get-AppxProvisionedPackage -Online 

Remove-AppxProvisionedPackage -Online -PackageName

foreach ($item in $Apps)
{
    $Package = (Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $item}).PackageName
    Write-Host -ForegroundColor Yellow "Entferne App $item" -NoNewline
    #Remove-AppxProvisionedPackage -Online -PackageName $Package
    Clear-Variable -Name Package
    do
    {
        Write-Host -ForegroundColor Gray "." -NoNewline
        Start-Sleep -Seconds 1
    }
    while ($item -match "$Package")
    Write-Host -ForegroundColor Green "done" 
    Write-Host ""
}

(Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "Microsoft.BingFinance"}).PackageName

$remove = @()

$AppName = (Get-AppxProvisionedPackage -Online).DisplayName


foreach ($item in $AppName)
{
    $title = "Select Appx"
    $message = "Do you want to remove the $item from this machine?"
    
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Removes the App from this PC"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Retains the App on this PC."
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    
    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    
    switch ($result)
    {
        0 {$remove += ,"$item"}
    }
}

Start-Job -Name "Remove $item" -ScriptBlock {write-host "hallo"}
