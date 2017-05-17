#$strFilter = "(SamAccountName=$env:USERNAME)"
$strFilter = "SamAccountName=cle"
$objDomain = New-Object System.DirectoryServices.DirectoryEntry

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Subtree"

$colProplist = "name","mail"
foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i)}

$colResults = $objSearcher.FindAll()

foreach ($objResult in $colResults)
    {$objItem = $objResult.Properties; $objItem.name; $objItem.mail}



Get-ADUser -Identity:"CN=Carsten Lenz,OU=Mitarbeiter,OU=Benutzerkonten,DC=horaios,DC=local" -Properties:mail,servicePrincipalName,objectClass,department,logonCount,ipPhone,canonicalName,otherMobile,CannotChangePassword,msDS-PhoneticLastName,url,homeDirectory,lastKnownParent,sAMAccountName,lastLogonTimestamp,userPrincipalName,msDS-User-Account-Control-Computed,msDS-AllowedToDelegateTo,userAccountControl,uSNChanged,sIDHistory,l,scriptPath,givenName,lockoutTime,otherPager,profilePath,primaryGroupID,badPwdCount,description,physicalDeliveryOfficeName,displayName,mobile,objectSid,postalCode,systemFlags,st,otherIpPhone,homeDrive,manager,ProtectedFromAccidentalDeletion,memberOf,badPasswordTime,whenCreated,title,wWWHomePage,pager,msDS-SupportedEncryptionTypes,sDRightsEffective,PasswordExpired,msDS-PhoneticFirstName,uSNCreated,otherFacsimileTelephoneNumber,streetAddress,pwdLastSet,whenChanged,msDS-PhoneticDisplayName,sn,userWorkstations,directReports,lastLogoff,otherTelephone,logonHours,otherHomePhone,telephoneNumber,msDS-PSOApplied,msDS-PhoneticDepartment,company,allowedAttributesEffective,homePhone,PasswordNeverExpires,employeeID,c,facsimileTelephoneNumber,accountExpires,msDS-PhoneticCompanyName,initials -Server:"DC1.horaios.local"

Get-ADUser -Identity cle -Properties mail,servicePrincipalName,Department