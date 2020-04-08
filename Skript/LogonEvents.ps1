[cmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[string]$ComputerName,
[int]$EventId = 4624,
[int]$Newest = 5
)
#Abfrage des EventLog Security und anschließendes Filtern auf die Eventid 4624 (AnmeldeEvent)
Get-EventLog -LogName Security -ComputerName $ComputerName | Where-Object EventID -eq $EventId | Select-Object -First $Newest 
