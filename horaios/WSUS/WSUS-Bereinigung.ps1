#Requires -RunAsAdministrator

# Variablen
$DateFormat = Get-Date -format yyyyMMdd-HH-mm
$Logfile 	= "E:\Logs\wsus-bereinigung-$DateFormat.log"
$WSUSServer = Get-WsusServer

# WSUS Bereinigung durchführen
Invoke-WsusServerCleanup -UpdateServer $WSUSServer -CleanupObsoleteUpdates -CleanupUnneededContentFiles -CompressUpdates -DeclineExpiredUpdates -DeclineSupersededUpdates | Out-File $Logfile

# Mail Variablen
$MailSMTPServer = "exch01.horaios.local"
$MailFrom 		= "administrator@horaios.local"
$MailTo 		= "it@horaios.de"
$MailSubject 	= "${env:COMPUTERNAME} Bereinigung $DateFormat"
$MailBody 		= Get-Content $Logfile | Out-String

# Mail versenden
#Send-MailMessage -SmtpServer $MailSMTPServer -From $MailFrom -To $MailTo -Subject $MailSubject -Body $MailBody -Encoding UTF8