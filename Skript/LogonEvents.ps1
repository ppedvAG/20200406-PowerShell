[cmdletBinding()]
Param(
[string]$ComputerName,
[int]$EventId,
[int]$Newest 
)
#Abfrage des EventLog Security und anschließendes Filtern auf die Eventid 4624 (AnmeldeEvent)
Get-EventLog -LogName Security -ComputerName $ComputerName | Where-Object EventID -eq $EventId | Select-Object -First $Newest 
