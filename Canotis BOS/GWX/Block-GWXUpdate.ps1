# ------------------------------------------------------------------------
# NAME: Block-GWXUpdate.ps1
# AUTOR: Hajo Schulz (hos)
# COPYRIGHT: © 2015 Heise Medien - c't
# VERSION: 1.3, 2015-10-01
#
# Dieses Skript prüft, ob der Windows-Update-Patch KB3035583 (Windows 10
# Upgrade) auf dem Rechner installiert ist. Wenn ja, wird er
# deinstalliert. In jedem Fall wird versucht, ihn in die Liste der
# ausgeblendeten Updates zu schieben.
#
# Neu in Version 1.1: Zusätzlich setzt das Skript den im Knowledge-Base-
# Artikel 3080351 <https://support.microsoft.com/kb/3080351> beschriebenen
# Registry-Eintrag, der das Herunterladen und Installieren des Windows-10-
# Upgrades verhindern soll.
#
# ------------------------------------------------------------------------

param(
    [Switch]$AutoRestart, # Rechner bei Bedarf automatisch neustarten
    [Switch]$NoRestart    # Rechner nie automatisch neustarten
)

# Laufen wir mit Admin-Rechten? Wenn nicht, Meldung ausgeben und raus.
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$princ = New-Object System.Security.Principal.WindowsPrincipal($identity)
if(-not $princ.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show('Dieses Skript muss mit Administratorrechten aufgerufen werden.',
                                            $MyInvocation.MyCommand.Name,
                                            [System.Windows.Forms.MessageBoxButtons]::OK,
                                            [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    return
}

# Initialisierung
$kbn = 3035583
$kb = "KB{0}" -f $kbn
$restart = $false
$session = New-Object -ComObject Microsoft.Update.Session
$searcher = $session.CreateUpdateSearcher()

# Versuchen, GWX über eine Gruppenrichtlinie stillzulegen
Start-Process "$Env:SystemRoot\System32\reg.exe" "ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v DisableOSUpgrade /t REG_DWORD /d 1 /f" -Wait

# Zur Sicherheit erst mal online nach neuen Updates suchen
"`nSuche Updates. Das kann mehrere Minuten dauern. Bitte Geduld ..." | Out-Host
$search = $searcher.Search('IsHidden=0 OR IsInstalled=1')

# GWX gefunden?
$gwxPatch = $search.Updates | Where-Object {$_.Title -match $kb}
if($gwxPatch) {
    # GWX installiert? Dann deinstallieren
    if($gwxPatch.IsInstalled) {
        "Deinstalliere $kb ..." | Out-Host
        # Wenn eines der GWX-Programme läuft, beenden. Dadurch läuft die 
        # Deinstallation in den allermeisten Fällen komplett durch und 
        # braucht keinen Neustart.
        $gwxProc = Get-Process GWXUX -ErrorAction SilentlyContinue
        if($gwxProc) {
            $gwxProc | Stop-Process -Force
        }
        $gwxProc = Get-Process GWX -ErrorAction SilentlyContinue
        if($gwxProc) {
            $gwxProc | Stop-Process -Force
        }
        $wusaProc = Start-Process "wusa" "/uninstall /kb:$kbn /quiet /norestart" -Wait -PassThru
        if($wusaProc.ExitCode -eq 0) {
            "Deinstallieren hat geklappt." | Out-Host
        } elseif($wusaProc.ExitCode -eq 3010) {
            # wusa.exe liefert den Exit-Code 3010, wenn für die komplette 
            # Deinstallation noch ein Neustart nötig ist.
            "Deinstallation erfolgreich." | Out-Host
            $restart = $true
        } else {
            "Fehler beim Deinstallieren." | Out-Host
        }
    }

    # KB3035583 verbergen
    "Verhindere (Wieder-)Installation von $kb ..." | Out-Host
    try {
        $gwxPatch.IsHidden = $true
        "Verstecken erfolgreich." | Out-Host
    }
    catch {
        "Blockieren fehlgeschlagen. ($_)" | Out-Host
        return
    }

    # Bei Bedarf Neustart, aber nur wenn der Benutzer zustimmt bzw. die passende
    # Kommandozeilenoption gesetzt hat.
    if($restart) {
        "`nZum Komplettieren der Deinstallation muss der Rechner neu gestartet werden." | Out-Host
        $answer = '';
        if($AutoRestart) {
            $answer = 'j'
        }
        elseif($NoRestart) {
            $answer = 's'
        }
        while($answer -ne 'j' -and $answer -ne 's') {
            $answer = Read-Host -Prompt "`nBitte wählen Sie: [J]etzt neu starten  [S]päter von Hand neu starten"
        } 
        if($answer -eq 'j') {
            shutdown /r /t 0
        }
    } else {
        "Alles Erledigt." | Out-Host
    }
} else {
    "$kb nicht gefunden - es gibt nichts zu tun." | Out-Host
}
