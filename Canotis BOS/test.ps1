function New-horaiosEmployee {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)] [string]$Computername = "DPM.horaios.local",
        [Parameter(Mandatory=$False)] [ValidateNotNull()] [System.Management.Automation.PSCredential] [System.Management.Automation.Credential()] $Credential = [System.Management.Automation.PSCredential]::Empty
    )

begin {
    $Credential = Get-Credential horaios\clead
}

$DriveLetter = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE Label='DPM Archive'" | Select-Object -ExpandProperty Name}