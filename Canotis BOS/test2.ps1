function Test-Function 
    (
        [string[]]$Computername = 'Localhost',
        [Switch]$switch
    ) {
    Get-Process -ComputerName $Computername
}