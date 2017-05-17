<#
.Synopsis
	Restore-ExchDB stellt Exchange Datenbanken wieder her.
.DESCRIPTION
	Die Funktion Restore-ExchDB stellt die aktuellste Exchange Mailbox-Datenbanken über System Center Data Protection Manager wieder her.
.Example
	Restore-ExchDB -DBName MBDB1
#>

function Restore-ExchDB
{
	Param(
		[Parameter(Mandatory=$true)]
		[string]$DPMServer,
	
		[Parameter(Mandatory=$true)]
		[string]$RecoveryLocationServer,
		
		[Parameter(Mandatory=$true)]
		[string]$RecoveryLocation,
		
		[Parameter(Mandatory=$true)]
		[string]$ProtectionGroup,
		
		[Parameter(Mandatory=$false)]
		[switch]$GetProtectionGroups
	)
	
	# DPMDatasource prüfen
	$PS = Get-DPMProductionServer -DPMServerName $DPMServer | Where-Object {$_.ServerName -eq $DPMServer} 
	Get-DPMDatasource -ProductionServer $PS -Inquire -ErrorAction SilentlyContinue | Out-Null
	
	# DPM ProtectionGroup auswählen
	$PG = Get-DPMProtectionGroup -DPMServerName $DPMServer | Where-Object {$_.Name -eq "$ProtectionGroup"}
	$DS = Get-DPMDatasource $PG 
	
	# DPM Restoreoptionen setzen
	$rop = New-DPMRecoveryOption -E14Datasource -ExchangeOperationType NoOperation -RecoveryLocation CopyToFolder -RecoveryType Restore -TargetServer $RecoveryLocationServer -TargetLocation $RecoveryLocation
	
	foreach ($item in $DS)
	{
		$rpl = Get-DPMRecoveryPoint -Datasource $item | Sort-Object -Property BackupTime -Descending | Select-Object -First 1
		Recover-DPMRecoverableItem -RecoverableItem $rpl -RecoveryOption $rop
	}
	
}

function Get-ExchDB 
{
	Param(
		[Parameter(Mandatory=$true)]
		[string]$DPMServer,
	)
	
}