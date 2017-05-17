##############################################################################################
# Script zum Export von VMs unter Hyper-V mit Windows Server 2012 oder Windows 8 Pro         #
# erstellt von Jan Kappen - j.kappen@rachfahl.de                                             #
# Version 0.2                                                                                #
# 16. Maerz 2013                                                                             #
# Diese Script wird bereitgestellt wie es ist, ohne jegliche Garantie. Der Einsatz           #
# erfolgt auf eigene Gefahr. Es wird jegliche Haftung ausgeschlossen.                        #
#                                                                                            #
# Dieses Script beinhaltet keine Hilfe. RTFM.                                                #
#                                                                                            #
# www.hyper-v-server.de | www.rachfahl.de                                                    #
#                                                                                            #
##############################################################################################
Param(
	[string] $VM ="",
	[string] $Exportpfad = "",
	[string] $Logpfad = "",
	[switch] $Speichern,
	[switch] $Auslassen,
	[switch] $verbose,
    [switch] $statusmail
)

########################
# Logging des Vorgangs #
########################
$LogDateiDatum = Get-Date -Format yyyy-MM-dd
if (!$Logpfad) {
               $LogPfadVorhanden = Test-Path ${env:homedrive}\temp\
               if ($LogPfadVorhanden -eq $False)
                   { new-item ${env:homedrive}\temp\ -itemtype directory }
               $Logdatei = "${env:homedrive}\temp\$VM-$LogDateiDatum.log" }
               else 
               { $Logdatei = "$Logpfad\$VM-$LogDateiDatum.log" }

####################################
# Test auf (in-)korrekte Parameter #
####################################
if (!$VM) { Write-Host (Get-Date) "Parameter -VM muss vorhanden sein und einen Namen enthalten. Abbruch!"
          $temp1 = (Get-Date)
          $temp2 = "Parameter -VM muss vorhanden sein und einen Namen enthalten. Abbruch!"
          $temp3 = "---------------------------------"
          "$temp1 - $temp2" | Out-File $Logdatei -Append
          "$temp3" | Out-File $Logdatei -Append
          exit }
if (!$Exportpfad) { Write-Host (Get-Date)  "Parameter -RemotePfad muss vorhanden sein und einen Pfad enthalten. Abbruch!"
                  $temp1 = (Get-Date)
                  $temp2 = "Parameter -RemotePfad muss vorhanden sein und einen Pfad enthalten. Abbruch!"
                  $temp3 = "---------------------------------"
                  "$temp1 - $temp2" | Out-File $Logdatei -Append
                  "$temp3" | Out-File $Logdatei -Append
                  exit }

#################
# Zeit ausgeben #
#################
if ($verbose -eq $true) { Write-Host (Get-Date) "Export der VM $VM gestartet" }
                        $temp1 = (Get-Date)
                        $temp2 = "Export der VM $VM gestartet"
                        "$temp1 - $temp2" | Out-File $Logdatei -Append
####################################################
# Test auf Integrationskomponente "Herunterfahren" #
####################################################
$vmHeartBeat = Get-VM –Name $VM | Get-VMIntegrationService –Name Herunterfahren
if($vmHeartBeat.enabled -match "True")
    {
    if ($verbose -eq $true) { Write-Host (Get-Date) "Der Integrationsdienst 'Herunterfahren' ist aktiviert" }
                              $temp1 = (Get-Date)
                              $temp2 = "Der Integrationsdienst 'Herunterfahren' ist aktiviert"
                              "$temp1 - $temp2" | Out-File $Logdatei -Append
    }
    else
    {
        if ($verbose -eq $true) { Write-Host (Get-Date) "Der Integrationsdienst 'Herunterfahren' ist NICHT aktiviert. VM kann nur gespeichert werden!" }
                                  $temp1 = (Get-Date)
                                  $temp2 = "Der Integrationsdienst 'Herunterfahren' ist NICHT aktiviert. VM kann nur gespeichert werden!"
                                  "$temp1 - $temp2" | Out-File $Logdatei -Append
            if($Speichern.IsPresent -match "True") { 
                                                     if ($verbose -eq $true) { Write-Host (Get-Date) "VM kann trotzdem exportiert werden, da sie gespeichert wird" }
                                                     $temp1 = (Get-Date)
                                                     $temp2 = "VM kann trotzdem exportiert werden, da sie gespeichert wird"
                                                     "$temp1 - $temp2" | Out-File $Logdatei -Append
                                                   }
            else
            { 
            if ($verbose -eq $true) { Write-Host (Get-Date) "Vm wird nicht exportiert, Abbruch!" }
            $temp1 = (Get-Date)
            $temp2 = "Vm wird nicht exportiert, Abbruch!"
            $temp3 = "---------------------------------"
            "$temp1 - $temp2" | Out-File $Logdatei -Append
            "$temp3" | Out-File $Logdatei -Append
            exit 
            }
    }

##################################################################
# Test auf Integrationskomponente "Herunterfahren" abgeschlossen #
##################################################################
# In welchem Zustand befindet sich die VM? #
############################################

$vmstatus = Get-VM –Name $VM
    if($vmstatus.State -match "Running")
    {
        if ($verbose -eq $true) { Write-Host (Get-Date) "VM ist eingeschaltet" }
                                $temp1 = (Get-Date)
                                $temp2 = "VM ist eingeschaltet"
                                "$temp1 - $temp2" | Out-File $Logdatei -Append
        #################################
        # Abfrage auf Speichern-Zustand #
    	#################################
        if($Speichern.IsPresent -match "True")
            {
        ####################
        # Speichern der VM #
    	####################
                if ($verbose -eq $true) { Write-Host (Get-Date) "VM wird gespeichert" }
                                        $temp1 = (Get-Date)
                                        $temp2 = "VM wird gespeichert"
                                        "$temp1 - $temp2" | Out-File $Logdatei -Append
            Save-VM -Name $VM
               }
            else
            {
        #########################################
        # Kein Speichern, Herunterfahren der VM #
    	#########################################
                if ($verbose -eq $true) { Write-Host (Get-Date) "VM wird heruntergefahren" }
                                        $temp1 = (Get-Date)
                                        $temp2 = "VM wird heruntergefahren"
                                        "$temp1 - $temp2" | Out-File $Logdatei -Append
            ################################
            # Warten auf ausgeschaltete VM #
    	    ################################
            Stop-VM -Name $VM -Force
            }
        }
    else
    {
        if ($verbose -eq $true) { Write-Host (Get-Date) "VM ist bereits ausgeschaltet" }
                                $temp1 = (Get-Date)
                                $temp2 = "VM ist bereits ausgeschaltet"
                                "$temp1 - $temp2" | Out-File $Logdatei -Append
    }

######################################################
# Speichern oder Herunterfahren der VM abgeschlossen #
######################################################
# Export der VM #
#################
if ($verbose -eq $true) { Write-Host (Get-Date) "Export der VM" }
                        $temp1 = (Get-Date)
                        $temp2 = "Export der VM"
                        "$temp1 - $temp2" | Out-File $Logdatei -Append
        #######################################################
        # Falls Export-Ordner nicht vorhanden, Export starten #
        #######################################################
        $ZielPfadVorhanden = Test-Path $Exportpfad\$VM
        if ($ZielPfadVorhanden -eq $False)
            { Export-VM -Name $VM -Path $Exportpfad }
        else
        { Remove-Item -Recurse -Force $Exportpfad\$VM
            Export-VM -Name $VM -Path $Exportpfad }
if ($verbose -eq $true) { Write-Host (Get-Date) "Export der VM abgeschlossen" }
                        $temp1 = (Get-Date)
                        $temp2 = "Export der VM abgeschlossen"
                        "$temp1 - $temp2" | Out-File $Logdatei -Append
########################
# Export abgeschlossen #
########################
# Start der VM #
################
if ($verbose -eq $true) { Write-Host (Get-Date) "Ueberpruefung auf Startverhalten nach Export" }
                        $temp1 = (Get-Date)
                        $temp2 = "Ueberpruefung auf Startverhalten nach Export"
                        "$temp1 - $temp2" | Out-File $Logdatei -Append
        ###################################
        # Ueberpruefung auf Stop-Schalter #
        ###################################
        if ($Auslassen.IsPresent -eq $False)
            { if ($verbose -eq $true) { Write-Host (Get-Date) "VM wird eingeschaltet" }
                                    $temp1 = (Get-Date)
                                    $temp2 = "VM wird eingeschaltet"
                                    $temp3 = "---------------------------------"
                                    "$temp1 - $temp2" | Out-File $Logdatei -Append
                                    "$temp3" | Out-File $Logdatei -Append
            Start-VM -Name $VM }
        else
            { if ($verbose -eq $true) { Write-Host (Get-Date) "VM bleibt ausgeschaltet" }
                                    $temp1 = (Get-Date)
                                    $temp2 = "VM bleibt ausgeschaltet"
                                    $temp3 = "---------------------------------"
                                    "$temp1 - $temp2" | Out-File $Logdatei -Append
                                    "$temp3" | Out-File $Logdatei -Append }
##############################
# Start der VM abgeschlossen #
##############################

if ($verbose -eq $true) { Write-Host (Get-Date) "Ueberpruefung auf Sendung einer Status-Mail" }
                        $temp1 = (Get-Date)
                        $temp2 = "Ueberpruefung auf Sendung einer Status-Mail"
                        "$temp1 - $temp2" | Out-File $Logdatei -Append
###########################################################################

        if ($statusmail.IsPresent -eq $False)
            { if ($verbose -eq $true) { Write-Host (Get-Date) "Es wird keine Email versendet" }
                                    $temp1 = (Get-Date)
                                    $temp2 = "Es wird keine Email versendet"
                                    "$temp1 - $temp2" | Out-File $Logdatei -Append }
        else
##################################
# Email versenden mit Status-Log #
##################################
         { if ($verbose -eq $true) { Write-Host (Get-Date) "Es wird eine Email versendet" }
                                   $temp1 = (Get-Date)
                                   $temp2 = "Es wird eine Email versendet"
                                   "$temp1 - $temp2" | Out-File $Logdatei -Append

########################################################################
# Ab hier muessen die persoenlichen Einstellungen konfiguriert werden! #
########################################################################

{ if ($verbose -eq $true) { Write-Host (Get-Date) "Diese Zeile muss auskommentiert werden!" }

# $mail = @{
#    SmtpServer = 'mailer.domain.loc'
#    Port = 25
#    From = 'backupskript@rachfahl.de'
#    To = 'empfaenger@domain.loc'
#    Subject = "'Script-Sicherung der VM' $VM"
#    Body = "'Anbei das Log der Export-Sicherung von VM' $VM"
#    Attachments = "$Logdatei"
# }
# Send-MailMessage @mail }
########################
# Script abgeschlossen #
########################