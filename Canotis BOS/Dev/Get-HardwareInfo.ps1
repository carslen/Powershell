<#
.Synopsis
   Get-HardwareInfo liefert Informationen zu RAM, CPU und HDD.
.DESCRIPTION
   Die Funktion Get-HardwareInfo liefert Informationen zu CPU, Arbeitsspeicher und Festplatte von angegebenen Computern Ã¼bersichtlich in einer Tabelle zusammengefasst
.EXAMPLE
   Get-HardwareInfo

   Liefert die Hardware-Informationen fÃ¼r den lokalen Computer
.EXAMPLE
   Get-HardwareInfo -TargetComp "SRV2","SRV3"

   Liefert die Informationen fÃ¼r die beiden Maschinen "SRV2" und "SRV3"
#>
Function Get-HardwareInfo
{

    Param(
        # TargetComp gibt den oder die abzufragenden Computersysteme an
        [string[]]$TargetComp = "localhost" # Standard-Wert, wenn nichts anderes angegeben
    )

    # Auslesen der CPU-Informationen via WMI
    $CPU = Get-WmiObject Win32_Processor -ComputerName $TargetComp
    # Auslesen der RAM-Informationen via WMI
    $RAM = Get-WmiObject Win32_OperatingSystem -ComputerName $TargetComp
    # Auslesen der HDD-Informationen via WMI
    $Disk = Get-WmiObject Win32_LogicalDisk -ComputerName $TargetComp # | Where-Object DeviceId -Like C*

    Write-Host "Prozessor-Informationen" -ForegroundColor Yellow
    $CPU | Format-Table @{n="Computer";    e={$_.SystemName}},
                        @{n="Anzahl Kerne";e={$_.NumberOfLogicalProcessors}},
                        @{n="CPU(%)";      e={$_.LoadPercentage}}

    Write-Host "Arbeitsspeicher-Informationen" -ForegroundColor Yellow
    $RAM | Format-Table @{n="Computer";    e={$_.PSComputerName}},
                        @{n="Ram ges.(GB)";e={[math]::Round($_.TotalVisibleMemorySize / 1MB,0)}},
                        @{n="RAM frei(GB)";e={[math]::Round($_.FreePhysicalMemory / 1MB,2)}}

    Write-Host "Festplatten-Informationen" -ForegroundColor Yellow
    $Disk | Format-Table @{n="Computer";e={$_.PSComputerName}},
                         @{n="Laufwerk";e={$_.Name}},
                         @{n="Größe (GB)";e={[math]::Round($_.Size /1GB,0)}},
                         @{n="Frei (GB)";e={[math]::Round($_.FreeSpace / 1GB,2)}},
                         @{n="Frei (%)"; e={[math]::Round($_.FreeSpace / $_.Size * 100,1)}}
}

# Get-HardwareInfo
# Get-HardwareInfo -TargetComp "SRV1","SRV2","SRV3"