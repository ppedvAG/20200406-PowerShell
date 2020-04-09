<#
.SYNOPSIS 
    Abfrage von Anmeldebezogenen Events
.DESCRIPTION
    Ausführliche Beschreibung wie dieses Skript Anmeldeevents abfrägt
.PARAMETER Computername
    Name des Computers der auf die Events abgefragt werden soll
.EXAMPLE 
    Logonevent.ps1 -ComputerName localhost

    Frägt vom Computer Localhost die aktuellesten 5 AnmeldeEvents ab.
    Beispielausgabe:

   Index Time          EntryType   Source                 InstanceID Message
   ----- ----          ---------   ------                 ---------- -------
   25995 Apr 08 14:19  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
   25990 Apr 08 14:18  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
   25987 Apr 08 14:18  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
   25982 Apr 08 14:18  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
   25979 Apr 08 14:18  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
.LINK
    https://github.com/ppedvAG/20200406-PowerShell
#>
[cmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[ValidateScript({Test-Connection -ComputerName $PSItem -Count 2 -Quiet})]
[string]$ComputerName,

[ValidateSet(4624,4625,4634)]
[int]$EventId = 4624,

[ValidateRange(5,20)]
[int]$Newest = 5,

[switch]$Detailed,

[ValidateSet("Blau","Grün")]
[string]$AusgabeFarbe = "leer"
)

Write-Verbose -Message "Vor Abfrage es wurden folgende Werte verwendet:
Computername: $ComputerName
EventID: $EventID
Newest: $Newest
"

#Abfrage des EventLog Security und anschließendes Filtern auf die Eventid 4624 (AnmeldeEvent)
$Ergebnis = Get-EventLog -LogName Security -ComputerName $ComputerName | Where-Object EventID -eq $EventId | Select-Object -First $Newest 

If($Detailed -eq $true)
{
    Format-List -InputObject $Ergebnis
}
else
{
    if($AusgabeFarbe -eq "leer")
    {
        $Ergebnis
    }
    else
    {
        Write-Debug -Message "Vor SwitchCase Color"
        switch($AusgabeFarbe)
        {
            "Blau" {Write-Host ($Ergebnis | Out-String) -ForegroundColor Blue -BackgroundColor White}
            "Grün" {Write-Host ($Ergebnis | Out-String) -ForegroundColor Green}
        }
    }
}

