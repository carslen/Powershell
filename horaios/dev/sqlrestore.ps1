param ([string] $DPMServerName, [string[]] $DatabaseList, [string] $DestinationServerName, [string] $DestinationLocation)

if(("-?","-help") -contains $args[0])
{
    Write-Host "Description: This script copies the latest recovery point of the specified SQL databases to the destination folder on a production server."
    Write-Host "Usage: Restore-SqlDatabase.ps1 [-DPMServerName] <Name of the DPM server> [-DatabaseList] <Array of SQL databases to restore> [-DestinationServerName <Name of the server to copy the database files to>] [-DestinationLocation] <Location on the destination server>"
    Write-Host "Example: Restore-SqlDatabase.ps1 mohitc02 `"mohitc04\* db`", `"mohitc04\reportservertempdb`" mohitc04 `"d:\recoverdir`""

    exit 0
}

if (!$DPMServerName)
{
    $DPMServerName = Read-Host "DPM server name"

    if (!$DPMServerName)
    {
        Write-Error "Dpm server name not specified."
        exit 1
    }
}

if (!$DatabaseList)
{
    $DatabaseList = Read-Host "SQL database to recover"

    if (!$DatabaseList)
    {
        Write-Error "SQL database(s) not specified."
        exit 1
    }
}

if (!$DestinationServerName)
{
    $DestinationServerName = Read-Host "Destination server"

    if (!$DestinationServerName)
    {
        Write-Error "Destination server not specified."
        exit 1
    }
}

if (!$DestinationLocation)
{
    $DestinationLocation = Read-Host "Location on the destination server"

    if (!$DestinationLocation)
    {
        Write-Error "Destination location not specified"
        exit 1
    }
}

if (!(Connect-DPMServer $DPMServerName))
{
    Write-Error "Failed to connect To DPM server $DPMServerName"
    exit 1
}

$datasourceList = @()
Get-ProtectionGroup $DPMServerName | % {Get-Datasource $_} | % {if ($DatabaseList -contains $_.LogicalPath) {$datasourceList += $_}}

# Show all the SQL databases that could not be found as protected datasources.
foreach ($datasourceName in $DatabaseList)
{
    if (@($datasourceList | ? {$_.LogicalPath -ieq $datasourceName}).Length -eq 0)
    {
        Write-Error "Could not find datasource $datasourceName"
    }
}

# Restore the latest recovery point of each SQL datasource.
foreach ($datasource in $datasourceList)
{
    # Select the latest recovery point that exists on disk and trigger the restore job.
    foreach ($rp in @(Get-RecoveryPoint -Datasource $datasource | sort -Property RepresentedPointInTime -Descending))
    {
        foreach ($rsl in $rp.RecoverySourceLocations)
        {
            if ($rsl -is [Microsoft.Internal.EnterpriseStorage.Dls.UI.ObjectModel.OMCommon.ReplicaDataset])
            {
                $recoveryOption = New-RecoveryOption -TargetServer $DestinationServerName -TargetLocation $DestinationLocation -RecoveryLocation CopyToFolder -SQL -RecoveryType Restore
                $restoreJob = Recover-RecoverableItem -RecoverableItem $rp -RecoveryOption $recoveryOption -RecoveryPointLocation $rsl

                break
            }
        }

        if ($restoreJob)
        {
            break
        }
    }

    if ($restoreJob)
    {
        Write-Host "`nRunning restore of $($datasource.LogicalPath) from $($rp.RepresentedPointInTime) to $DestinationServerName\$DestinationLocation"

        # Comment out the next 7 lines to not wait for one restore job to finish before triggering the next one.
        while (!$restoreJob.HasCompleted)
        {
            Write-Host "." -NoNewLine
            sleep 3
        }

        Write-Host "`nJob status: $($restoreJob.Status)"
    }
    else
    {
        Write-Error "Could not find a recovery point on disk for $($datasource.LogicalPath)"
    }
}