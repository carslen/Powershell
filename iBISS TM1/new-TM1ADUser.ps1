param(
    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Select Customer")][ValidateSet("CubesVT", "DFS", "FMA", "FMP", "GIPSY", "MARS", "MBC", "MBVLLC", "PART", "TRAST", "WRP")][string[]]$Customer,
    [Parameter(Mandatory = $true, Position = 2, HelpMessage = "WCP access required?")][ValidateSet("DEV", "INT", "PROD")][string[]]$Environment,
    [Parameter(Mandatory = $true, Position = 2, HelpMessage = "WCP access required?")][ValidateSet($true, $false)][string[]]$WCP,
    [Parameter(Mandatory = $true, Position = 2, HelpMessage = "WCP access required?")][ValidateSet($true, $false)][string[]]$HomeShare #= "$true"
)

# Some basic setup
#

$ADBaseGrp = "E415_TM1-BISS"

# Check if WCP or WP AD Groups are available
#

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

if ($WCP -eq $true) {
    # Find required AD-Groups to enable WCP access
    #
    
    # Get all Customer AD-Groups
    $ADGrps = Get-ADGroup -Filter "Name -like '$ADBaseGrp-$Customer-W*-$Environment'"

    #Declare empty array
    [System.Collections.ArrayList]$AddToADGrp = @()

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
    $AddToADGrp.Name
}
