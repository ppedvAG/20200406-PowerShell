[cmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[string]$ComputerName,
[int]$EventId = 4624,
[int]$Newest = 5
)

Write-Verbose -Message "Vor Abfrage es wurden folgende Werte verwendet:
Computername: $ComputerName
EventID: $EventID
Newest: $Newest
"
#Abfrage des EventLog Security und anschließendes Filtern auf die Eventid 4624 (AnmeldeEvent)
Get-EventLog -LogName Security -ComputerName $ComputerName | Where-Object EventID -eq $EventId | Select-Object -First $Newest 
