param(
    [Parameter(Mandatory = $true,
        Position = 1, 
        HelpMessage = "Select Customer")]
    [ValidateSet("CubesVT", "DFS", "FMA", "FMP", "GIPSY", "MARS", "MBC", "MBVLLC", "PART", "TRAST", "WRP")]
    [string[]]$Customer,

    [Parameter(Mandatory = $true,
        Position = 2,
        HelpMessage = "WCP access required?")]
    [ValidateSet("DEV", "INT", "PROD")]
    [string[]]$Environment,
    
    [Parameter(Mandatory = $true,
        Position = 2,
        HelpMessage = "WCP access required?")]
    [ValidateSet($true, $false)]
    [string[]]$WCP,
    
    [Parameter(Mandatory = $true, 
        Position = 2,
        HelpMessage = "WCP access required?")]
    [ValidateSet($true, $false)]
    [string[]]$HomeShare,
    
    # Specifies a path to one or more locations.
    [Parameter(Mandatory = $true,
        Position = 0,
        ParameterSetName = "ParameterSetName",
        ValueFromPipeline = $true,
        #ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Comma separated list of one or more user names.")]
    [Alias("SamAccountName")]
    [ValidateNotNullOrEmpty()]
    $Identity = @()
)

# Some basic setup
#
$ADBaseGrp = "E415_TM1-BISS"
Write-Host -ForegroundColor Yellow "Populating Domain list: " -NoNewline
$Domains   = (Get-ADForest).Domains
Write-Host "OK"

#Declare empty array
[System.Collections.ArrayList]$AddToADGrp = @()
[System.Collections.ArrayList]$ADUsers = @()

# Parameter dependency checks
#

# Homeshare only available for GIPSY, no provisioning für FMP users
if ($Customer -ne "GIPSY" -and $HomeShare -eq "$true") {
    Write-Host -ForegroundColor Red "WCP Homeshare permission is only available for Customer GIPSY but not for $Customer."
    Write-Host -ForegroundColor Red "Please use -HomeShare False instead."
    Write-Host -ForegroundColor Red "Aborting."
    break
}
elseif ($Customer -eq "FMP") {
    Write-Warning "User provisioning for Customer $Customer is done by ITS/FMP!"
    break
}

# Find required AD-Groups to enable WCP access
#

Write-Host -ForegroundColor Yellow "Creating AD-Group list for user addition: " -NoNewline
if ($WCP -eq $true) {
    
    # Get all Customer AD-Groups
    $ADGrps = Get-ADGroup -Filter "Name -like '$ADBaseGrp-$Customer-W*-$Environment'"

        # Explore needed AD-Groups to add user to.
    foreach ($grp in $ADGrps) {
        # Search for old fashioned WP AD-Groups and add to array
        if ($grp.Name -match "WP") {
            $AddToADGrp += $grp
        }
        # Search for new fashioned WCP AD-Groups and add to array
        elseif ($grp.Name -match "WCP") {
            $AddToADGrp += $grp
        }
    }
}

if ($HomeShare -eq $true) {
    $HomeShareGrp = Get-ADGroup -Filter "Name -eq '$ADBaseGrp-$Customer-WCP-Homeshare'"
    $AddToADGrp += $HomeShareGrp
}

Write-Host "OK"
Write-Host -ForegroundColor Yellow "Users will be added to: " #-NoNewline
$AddToADGrp.Name

Write-Host -ForegroundColor Yellow "Numer of users to add: " -NoNewline
$Identity.Count

# Fetch AD user object for provided users via $Identity
#
foreach ($User in $Identity) {
    foreach ($Domain in $Domains) {
        if ([bool](Get-ADUser -Filter "SamAccountName -eq '$User'" -Server $Domain)) {
            Write-Host -ForegroundColor Yellow "Searching user $($User): " -NoNewline
            Write-Host "Found in Domain $Domain."
            $ADUsers += Get-ADUser -Identity $User -Server $Domain
            break
        }
    }
}

# # Check if User is already member of selected AG groups
# #
# Write-Host -ForegroundColor Yellow "Checking if users are already member of given AD groups"
# $ADUsers.Count
# foreach ($Grp in $AddToADGrp) {
#     $Member = (Get-ADGroupMember -Identity $grp -Recursive).SamAccountName
#     foreach ($User in $ADUsers) {
#         #$UserName = $User.SamAccountName
#         if ($Member -contains $User) {
#             Write-Host -ForegroundColor Yellow "User $User already a member of $($Grp.SamAccountName)"
#             #$ADUsers -= $User.SamAccountName
#             $ADUsers.Remove("$User")
#         }
#     }
# }
# $ADUsers.Count
#foreach ($User in $ADUsers) {
    # foreach ($Grp in $AddToADGrp) {
    #     Add-ADGroupMember -Identity $grp.Name -Members $ADUsers -WhatIf
    # }
#}

