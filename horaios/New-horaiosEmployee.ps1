#Require -RunAsAdministrator
#Requires -Modules "ActiveDirectory","SmbShare"

. 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'

Connect-ExchangeServer -auto


function New-horaiosEmployee {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)] [string]$FirstName, # = "Mathias",
        [Parameter(Mandatory=$True,Position=2)] [string]$LastName, # = "Ludwig",
        [Parameter(Mandatory=$True,Position=3)] [ValidateSet("Entwicklung", "Ausbildung", "IT", "Extern")] [string]$Role, # = "Entwicklung",
        [Parameter(Mandatory=$False,Position=4)] [switch]$MailBox,
        [Parameter(Mandatory=$False)] [ValidateNotNull()] [System.Management.Automation.PSCredential] [System.Management.Automation.Credential()] $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    
    begin {
        $DC                  = (Get-ADDomainController).HostName
        $DFSRoot             = "\\horaios\Benutzer"
        $UserAlias           = $FirstName.Substring(0,1).ToLower() + $LastName.Substring(0,2).ToLower()
        $DFSFolderPath       = "$DFSRoot\$UserAlias"
        $FileServer          = "MAINE"
        $SMBShareBase        = "\\$FileServer"
        $DFSFolderTargetPath = "$SMBShareBase\$UserAlias"
        
        if ($Role -eq "Ausbildung") {
            $ADGroupMember = @("Entwicklung","horaios Azubis","horaios Entwicklung","horaios intern","Intern")
            $Identitiy     = "CN=$Firstname $Lastname,OU=Mitarbeiter,OU=Benutzerkonten,DC=horaios,DC=local"
            $LDAPPath      = "OU=Mitarbeiter,OU=Benutzerkonten,DC=horaios,DC=local"
        }
        elseif ($Role -eq "Entwicklung") {
            $ADGroupMember = @("Entwicklung","horaios Entwicklung","horaios intern","Intern")
            $Identitiy     = "CN=$Firstname $Lastname,OU=Mitarbeiter,OU=Benutzerkonten,DC=horaios,DC=local"
            $LDAPPath      = "OU=Mitarbeiter,OU=Benutzerkonten,DC=horaios,DC=local"
        }
        elseif ($Role -eq "Extern") {
            $ADGroupMember = @("horaios extern","Intern")
            $Identitiy     = "CN=$Firstname $Lastname,OU=Mitarbeiter extern,OU=Benutzerkonten,DC=horaios,DC=local"
            $LDAPPath      = "OU=Mitarbeiter extern,OU=Benutzerkonten,DC=horaios,DC=local"
        }     
    }
    
    process {
        Write-Host "Benutzerangaben:" -ForegroundColor Yellow
        Write-Host "Vorname:"  $FirstName
        Write-Host "Nachname:" $LastName
        Write-Host "Alias:"   $UserAlias
        
        # Benutzer Anlegen
        if ((Get-ADUser -LDAPFilter "(samAccountName=$UserAlias)") -ne $null) {
            Write-Host "User existiert bereits!!!" -ForegroundColor Red
        }
        else {
            # Write-Host "Weiter geht's" -ForegroundColor Cyan
            Write-Host "Lege benutzer an:" -ForegroundColor Yellow
            
            Write-Host "$FirstName $LastName ... " -NoNewline
            New-ADUser -AccountPassword (ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force) -ChangePasswordAtLogon $True -City "Blaustein" -Company "horaios GmbH" -Department "$Role" -DisplayName "$Firstname $Lastname" -Fax "0731/950334-29" -GivenName "$Firstname" -HomePage "http://www.horaios.de" -Name "$Firstname $Lastname" -OfficePhone:"0731/950334-0" -Path "$LDAPPath" -PostalCode:"89134" -SamAccountName:"$UserAlias" -Server "$DC" -State:"BW" -StreetAddress:"Lindenstraße 40" -Surname:"$Lastname" -Type:"user" -Enabled $True -UserPrincipalName:"$UserAlias@horaios.local"
            Write-Host "Erledigt!" -ForegroundColor Green

            Write-Host "Schuetze Objekt vor versehentlichem loeschen ... " -NoNewline
            Set-ADObject -Identity "$Identitiy" -ProtectedFromAccidentalDeletion $true -Server "$DC"
            Write-Host "Erledigt!" -ForegroundColor Green

            Write-Host "Setzte verschiedene Objekteigenschaften ... " -NoNewline
            Set-ADAccountControl -AccountNotDelegated:$false -AllowReversiblePasswordEncryption:$false -CannotChangePassword:$false -DoesNotRequirePreAuth:$false -Identity:"$Identitiy" -PasswordNeverExpires:$false -Server:"$DC" -UseDESKeyOnly:$false
            Write-Host "Erledigt!" -ForegroundColor Green
            
            Write-Host "Setzte Gruppenmitgliedschaften ... "
            foreach ($item in $ADGroupMember) {
                Add-ADGroupMember -Identity $item -Members "$UserAlias" -Server "$DC"
                Write-Host "$item"
            }
            Write-Host "Erledigt!" -ForegroundColor Green
        }
        
        # Benutzerlaufwerk im DFS anlegen
        Write-Host "Erstelle Benutzerlaufwerk im DFS ... " -NoNewline
        Invoke-Command -ScriptBlock {
            param($UserAlias,$DFSFolderPath,$DFSFolderTargetPath)
            #$UserAlias
            #$DFSFolderPath
            #$DFSFolderTargetPath
            $NTFSPath = (New-Item -Path G:\$UserAlias -ItemType Directory).FullName
            New-SmbShare -Name $UserAlias -Path $NTFSPath -FullAccess $UserAlias 
            Start-Sleep -Seconds 5
            New-DfsnFolderTarget -Path "$DFSFolderPath" -TargetPath "$DFSFolderTargetPath"}  -ArgumentList "$UserAlias","$DFSFolderPath","$DFSFolderTargetPath" -ComputerName $FileServer -Credential $Credential

        Write-Host "Erledigt!" -ForegroundColor Green

        # ADUser Benutzerlaufwerk zuweisen
        Write-Host "Benutzerlaufwerk zuweisen ... " -NoNewline
        Set-ADUser -Identity $UserAlias -HomeDirectory "$DFSFolderPath" -HomeDrive "U:" -Server "$DC"
        Write-Host "Erledigt!" -ForegroundColor Green

        # Exchange Mailbox

        $NewUser = Get-ADUser -Identity $UserAlias
        Write-Host "Enable Exchange Mailbox for User $UserAlias" -ForegroundColor Yellow
        Enable-Mailbox -Identity $NewUser.UserPrincipalName
        Write-Host "All done!" -ForegroundColor Green

    }
    
    end {
    }
}