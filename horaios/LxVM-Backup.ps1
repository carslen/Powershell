function Start-LxVMBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)] [string]$VMName = "test",
        [Parameter(Mandatory=$True,Position=2)] [string]$Path = "",
        [Parameter(Mandatory=$True,Position=3)] [string]$ComputerName = "",
        [Parameter(Mandatory=$True,Position=3)] [ValidateSet("Entwicklung", "GF", "Ausbildung", "IT", "Extern")] [string]$Role = "Entwicklung",
        [Parameter(Mandatory=$True,Position=4)] [switch]$MailBox,
        #[Parameter(Mandatory=$True,Position=3)]  [string]$UserAlias,
        #[Parameter(Mandatory=$True,Position=2)]  [ValidateSet("Hyper-V", "iSCSI", "Exchange", "SQL")] [string]$RecoveryType,
        #[Parameter(Mandatory=$True,Position=3)]  [string]$ProtectionGroupName,
        #[Parameter(Mandatory=$False,Position=4)] [string]$RecoveryLocationServer = "$env:Computername",
        #[Parameter(Mandatory=$True,Position=5)]  [string]$ArchiveLocation,
        [Parameter(Mandatory=$False)] [ValidateNotNull()] [System.Management.Automation.PSCredential] [System.Management.Automation.Credential()] $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    
    begin {
        # VM Integrationcomponent "herunterfahren"
        $vmheartbeat = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            param($VMName)
            Get-VM -Name $VMName | Get-VMIntegrationService -Name Herunterfahren
        }
        if ($vmheartbeat.Enabled -eq $True) {
            Write-Host (Get-Date) "Der Integrationsdienst "Herunterfahren" ist aktiviert."
        }
        else {
            Write-Host (Get-Date) "Der Integrationsdienst "Herunterfahren" ist nicht verfügbar."
        }
        $VMStatus = 
    }
    
    process {

    }
    
    end {
    }
}