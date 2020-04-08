

#Abfrage des EventLog Security und anschließendes Filtern auf die Eventid 4624 (AnmeldeEvent)
Get-EventLog -LogName Security -ComputerName localhost | Where-Object EventID -eq 4624 | Select-Object -First 5
