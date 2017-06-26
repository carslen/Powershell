
function Write-iBISSLog {
    <#
    .SYNOPSIS
    Short description
    Inspired by http://9to5it.com/powershell-logging-function-library/ 
    
    .DESCRIPTION
    Long description
    
    .PARAMETER Path
    Parameter description
    
    .PARAMETER Message
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    
    Param (
        [Parameter(Mandatory=$true)][string[]]$Path,
        [Parameter(Mandatory=$true)][string[]]$Message
        )
    
    Process{
        $logDate = Get-Date -UFormat "%D %T"
        $Value   = $logDate + " " + $Message
        Add-Content -Path $Path -Value $Value
        
        #Write to screen for debug mode
        Write-Debug $Value
    }
}