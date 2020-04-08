

Get-EventLog -LogName Security -ComputerName localhost | Where-Object EventID -eq 4624 | Select-Object -First 5
