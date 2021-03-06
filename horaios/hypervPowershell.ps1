# Filter for parsing XML data
filter Import-CimXml 
{ 
   # Create new XML object from input
   $CimXml = [Xml]$_ 
   $CimObj = New-Object -TypeName System.Object 
 
   # Iterate over the data and pull out just the value name and data for each entry
   foreach ($CimProperty in $CimXml.SelectNodes("/INSTANCE/PROPERTY[@NAME='Name']")) 
      { 
         $CimObj | Add-Member -MemberType NoteProperty -Name $CimProperty.NAME -Value $CimProperty.VALUE 
      } 
 
   foreach ($CimProperty in $CimXml.SelectNodes("/INSTANCE/PROPERTY[@NAME='Data']")) 
      { 
         $CimObj | Add-Member -MemberType NoteProperty -Name $CimProperty.NAME -Value $CimProperty.VALUE 
      } 
 
   # Display output
   $CimObj 
} 
 
# Prompt for the Hyper-V Server to use
$HyperVServer = Read-Host "Specify the Hyper-V Server to use (enter '.' for the local computer)"
 
# Prompt for the virtual machine to use
$VMName = Read-Host "Specify the name of the virtual machine"
 
# Get the virtual machine object
$query = "Select * From Msvm_ComputerSystem Where ElementName='" + $VMName + "'"
$Vm = gwmi -namespace root\virtualization -query $query -computername $HyperVServer
 
# Get the KVP Object
$query = "Associators of {$Vm} Where AssocClass=Msvm_SystemDevice ResultClass=Msvm_KvpExchangeComponent"
$Kvp = gwmi -namespace root\virtualization -query $query -computername $HyperVServer
 
Write-Host
Write-Host "Guest KVP information for" $VMName
 
# Filter the results
$Kvp.GuestIntrinsicExchangeItems | Import-CimXml 